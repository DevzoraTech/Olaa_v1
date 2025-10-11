// Presentation Layer - Verification Submission Screen
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/verification_service.dart';
import '../../../../core/services/supabase_auth_service.dart';
import 'package:pulse_campus/Features/verification/domain/models/verification_models.dart';

class VerificationSubmissionScreen extends StatefulWidget {
  final VerificationSubmissionType submissionType;

  const VerificationSubmissionScreen({super.key, required this.submissionType});

  @override
  State<VerificationSubmissionScreen> createState() =>
      _VerificationSubmissionScreenState();
}

class _VerificationSubmissionScreenState
    extends State<VerificationSubmissionScreen> {
  final VerificationService _verificationService = VerificationService.instance;
  final SupabaseAuthService _authService = SupabaseAuthService.instance;
  final ImagePicker _imagePicker = ImagePicker();

  Map<VerificationDocumentType, File?> _uploadedFiles = {};
  Map<VerificationDocumentType, bool> _uploadingFiles = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeUploadingStates();
  }

  void _initializeUploadingStates() {
    final requiredDocs = _verificationService.getRequiredDocuments(
      widget.submissionType,
    );
    for (final docType in requiredDocs) {
      _uploadingFiles[docType] = false;
    }
  }

  Future<void> _pickDocument(VerificationDocumentType documentType) async {
    try {
      setState(() {
        _uploadingFiles[documentType] = true;
      });

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _uploadedFiles[documentType] = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    } finally {
      setState(() {
        _uploadingFiles[documentType] = false;
      });
    }
  }

  Future<void> _submitVerification() async {
    if (!_canSubmit()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Upload all documents
      List<String> documentIds = [];
      for (final entry in _uploadedFiles.entries) {
        if (entry.value != null) {
          final documentId = await _verificationService
              .uploadVerificationDocument(
                filePath: entry.value!.path,
                documentType: entry.key,
                userId: user.id,
              );
          documentIds.add(documentId);
        }
      }

      // Create verification submission
      await _verificationService.createVerificationSubmission(
        userId: user.id,
        submissionType: widget.submissionType,
        documentIds: documentIds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Verification submitted successfully! You will be notified within 24 hours.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting verification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  bool _canSubmit() {
    final requiredDocs = _verificationService.getRequiredDocuments(
      widget.submissionType,
    );
    return requiredDocs.every((docType) => _uploadedFiles[docType] != null);
  }

  @override
  Widget build(BuildContext context) {
    final requiredDocs = _verificationService.getRequiredDocuments(
      widget.submissionType,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verification',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                _canSubmit() && !_isSubmitting ? _submitVerification : null,
            child: Text(
              'Submit',
              style: TextStyle(
                color:
                    _canSubmit() && !_isSubmitting
                        ? AppTheme.primaryColor
                        : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.verified_user,
                    color: AppTheme.primaryColor,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Get Verified',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getHeaderDescription(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Required Documents
            Text(
              'Required Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            // Document List
            ...requiredDocs.map((docType) => _buildDocumentCard(docType)),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _canSubmit() && !_isSubmitting ? _submitVerification : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Submit Verification',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your verification will be reviewed within 24 hours. You\'ll receive a notification once it\'s processed.',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(VerificationDocumentType documentType) {
    final isUploaded = _uploadedFiles[documentType] != null;
    final isUploading = _uploadingFiles[documentType] ?? false;

    // Get the index of this document type in the required documents list
    final requiredDocs = _verificationService.getRequiredDocuments(
      widget.submissionType,
    );
    final documentIndex = requiredDocs.indexOf(documentType);
    final isStudentLivePhoto =
        widget.submissionType == VerificationSubmissionType.student &&
        documentType == VerificationDocumentType.livePhoto;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded ? Colors.green : Colors.grey[300]!,
          width: isUploaded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  isUploaded
                      ? Colors.green.withOpacity(0.1)
                      : AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isUploaded ? Icons.check_circle : _getDocumentIcon(documentType),
              color: isUploaded ? Colors.green : AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStudentLivePhoto
                      ? 'Live Photo ${documentIndex + 1}'
                      : documentType.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDocumentDescription(documentType, documentIndex),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Upload Button
          GestureDetector(
            onTap: isUploading ? null : () => _pickDocument(documentType),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isUploaded
                        ? Colors.green.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child:
                  isUploading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(
                        isUploaded ? 'Uploaded' : 'Upload',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isUploaded ? Colors.green : AppTheme.primaryColor,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(VerificationDocumentType documentType) {
    switch (documentType) {
      case VerificationDocumentType.studentId:
        return Icons.badge;
      case VerificationDocumentType.businessRegistration:
        return Icons.business;
      case VerificationDocumentType.landlordAgreement:
        return Icons.home;
      case VerificationDocumentType.organizationCertificate:
        return Icons.school;
      case VerificationDocumentType.officialContact:
        return Icons.contact_phone;
      case VerificationDocumentType.livePhoto:
        return Icons.camera_alt;
    }
  }

  String _getDocumentDescription(
    VerificationDocumentType documentType,
    int documentIndex,
  ) {
    switch (documentType) {
      case VerificationDocumentType.studentId:
        return 'Take a clear photo of your student ID card';
      case VerificationDocumentType.businessRegistration:
        return 'Upload your business registration certificate';
      case VerificationDocumentType.landlordAgreement:
        return 'Upload your landlord agreement or property ownership documents';
      case VerificationDocumentType.organizationCertificate:
        return 'Upload your organization registration certificate';
      case VerificationDocumentType.officialContact:
        return 'Take a photo of official contact information or letterhead';
      case VerificationDocumentType.livePhoto:
        // Different descriptions for student live photos
        if (widget.submissionType == VerificationSubmissionType.student) {
          switch (documentIndex) {
            case 0:
              return 'Take a clear selfie showing your face';
            case 1:
              return 'Take a photo holding your student ID';
            case 2:
              return 'Take a photo in your campus environment';
            default:
              return 'Take a live photo of yourself';
          }
        }
        return 'Take a live photo of yourself holding your ID';
    }
  }

  String _getHeaderDescription() {
    switch (widget.submissionType) {
      case VerificationSubmissionType.student:
        return 'Upload 3 live photos to get verified and start selling in the marketplace.';
      case VerificationSubmissionType.hostelProvider:
        return 'Upload the required documents to get verified and start posting hostel listings.';
      case VerificationSubmissionType.eventOrganizer:
        return 'Upload the required documents to get verified and start organizing events.';
      case VerificationSubmissionType.promoter:
        return 'Upload the required documents to get verified and start promoting events.';
    }
  }
}
