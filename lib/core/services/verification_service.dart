// Core Services - Verification Service
import 'dart:io';
import '../config/supabase_config.dart';
import '../../features/verification/domain/models/verification_models.dart';

class VerificationService {
  static final VerificationService _instance = VerificationService._internal();
  factory VerificationService() => _instance;
  VerificationService._internal();

  static VerificationService get instance => _instance;

  // Upload verification document
  Future<String> uploadVerificationDocument({
    required String filePath,
    required VerificationDocumentType documentType,
    required String userId,
  }) async {
    try {
      final file = File(filePath);
      final fileName =
          '${documentType.value}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      final fileSize = await file.length();

      // Get file extension for mime type
      final extension = file.path.split('.').last.toLowerCase();
      String mimeType;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'pdf':
          mimeType = 'application/pdf';
          break;
        default:
          mimeType = 'application/octet-stream';
      }

      // Upload to storage
      final bytes = await file.readAsBytes();
      final uploadPath = '$userId/$fileName';

      await SupabaseConfig.client.storage
          .from('verification-documents')
          .uploadBinary(uploadPath, bytes);

      // Get public URL
      final publicUrl = SupabaseConfig.client.storage
          .from('verification-documents')
          .getPublicUrl(uploadPath);

      // Save document record
      final response =
          await SupabaseConfig.client
              .from('verification_documents')
              .insert({
                'user_id': userId,
                'document_type': documentType.value,
                'file_name': fileName,
                'file_url': publicUrl,
                'file_size': fileSize,
                'mime_type': mimeType,
              })
              .select()
              .single();

      print('DEBUG: Verification document uploaded: $response');
      return response['id'];
    } catch (e) {
      print('ERROR: Failed to upload verification document: $e');
      throw Exception('Failed to upload verification document: $e');
    }
  }

  // Create verification submission
  Future<String> createVerificationSubmission({
    required String userId,
    required VerificationSubmissionType submissionType,
    required List<String> documentIds,
  }) async {
    try {
      final response =
          await SupabaseConfig.client
              .from('verification_submissions')
              .insert({
                'user_id': userId,
                'submission_type': submissionType.value,
                'status': 'pending',
                'expires_at':
                    DateTime.now()
                        .add(const Duration(days: 30))
                        .toIso8601String(),
              })
              .select()
              .single();

      print('DEBUG: Verification submission created: $response');
      return response['id'];
    } catch (e) {
      print('ERROR: Failed to create verification submission: $e');
      throw Exception('Failed to create verification submission: $e');
    }
  }

  // Get user's verification submission
  Future<VerificationSubmission?> getUserVerificationSubmission(
    String userId,
  ) async {
    try {
      final response = await SupabaseConfig.client
          .from('verification_submissions')
          .select('''
            *,
            documents:verification_documents(*)
          ''')
          .eq('user_id', userId)
          .order('submitted_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        final submissionData = response.first;
        final documents =
            (submissionData['documents'] as List<dynamic>?)
                ?.map((doc) => VerificationDocument.fromJson(doc))
                .toList() ??
            [];

        return VerificationSubmission(
          id: submissionData['id'],
          userId: submissionData['user_id'],
          submissionType: VerificationSubmissionType.fromString(
            submissionData['submission_type'],
          ),
          status: VerificationStatus.fromString(submissionData['status']),
          submittedAt: DateTime.parse(submissionData['submitted_at']),
          reviewedAt:
              submissionData['reviewed_at'] != null
                  ? DateTime.parse(submissionData['reviewed_at'])
                  : null,
          reviewedBy: submissionData['reviewed_by'],
          adminNotes: submissionData['admin_notes'],
          expiresAt: DateTime.parse(submissionData['expires_at']),
          documents: documents,
        );
      }
      return null;
    } catch (e) {
      print('ERROR: Failed to get verification submission: $e');
      return null;
    }
  }

  // Get required documents for submission type
  List<VerificationDocumentType> getRequiredDocuments(
    VerificationSubmissionType submissionType,
  ) {
    switch (submissionType) {
      case VerificationSubmissionType.student:
        return [
          VerificationDocumentType.livePhoto,
          VerificationDocumentType.livePhoto,
          VerificationDocumentType.livePhoto,
        ];
      case VerificationSubmissionType.hostelProvider:
        return [
          VerificationDocumentType.businessRegistration,
          VerificationDocumentType.livePhoto,
        ];
      case VerificationSubmissionType.eventOrganizer:
        return [
          VerificationDocumentType.organizationCertificate,
          VerificationDocumentType.officialContact,
          VerificationDocumentType.livePhoto,
        ];
      case VerificationSubmissionType.promoter:
        return [
          VerificationDocumentType.businessRegistration,
          VerificationDocumentType.officialContact,
          VerificationDocumentType.livePhoto,
        ];
    }
  }

  // Check if user can submit verification
  Future<bool> canSubmitVerification(String userId) async {
    try {
      final submission = await getUserVerificationSubmission(userId);
      if (submission == null) return true;

      // Can submit if previous submission is rejected or expired
      return submission.isRejected || submission.isExpired;
    } catch (e) {
      print('ERROR: Failed to check verification eligibility: $e');
      return false;
    }
  }

  // Delete verification document
  Future<void> deleteVerificationDocument(String documentId) async {
    try {
      // Get document info first
      final response =
          await SupabaseConfig.client
              .from('verification_documents')
              .select('file_name, user_id')
              .eq('id', documentId)
              .single();

      // Delete from storage
      final filePath = '${response['user_id']}/${response['file_name']}';
      await SupabaseConfig.client.storage.from('verification-documents').remove(
        [filePath],
      );

      // Delete from database
      await SupabaseConfig.client
          .from('verification_documents')
          .delete()
          .eq('id', documentId);

      print('DEBUG: Verification document deleted: $documentId');
    } catch (e) {
      print('ERROR: Failed to delete verification document: $e');
      throw Exception('Failed to delete verification document: $e');
    }
  }
}
