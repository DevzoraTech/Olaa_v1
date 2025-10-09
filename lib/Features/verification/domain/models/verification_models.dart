// Domain Layer - Verification Models
enum VerificationDocumentType {
  studentId('student_id', 'Student ID'),
  businessRegistration('business_registration', 'Business Registration'),
  landlordAgreement('landlord_agreement', 'Landlord Agreement'),
  organizationCertificate(
    'organization_certificate',
    'Organization Certificate',
  ),
  officialContact('official_contact', 'Official Contact'),
  livePhoto('live_photo', 'Live Photo');

  const VerificationDocumentType(this.value, this.displayName);
  final String value;
  final String displayName;

  static VerificationDocumentType fromString(String value) {
    return VerificationDocumentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => VerificationDocumentType.studentId,
    );
  }
}

enum VerificationSubmissionType {
  student('student', 'Student'),
  hostelProvider('hostel_provider', 'Hostel Provider'),
  eventOrganizer('event_organizer', 'Event Organizer'),
  promoter('promoter', 'Promoter');

  const VerificationSubmissionType(this.value, this.displayName);
  final String value;
  final String displayName;

  static VerificationSubmissionType fromString(String value) {
    return VerificationSubmissionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => VerificationSubmissionType.student,
    );
  }
}

enum VerificationStatus {
  pending('pending', 'Pending'),
  underReview('under_review', 'Under Review'),
  approved('approved', 'Approved'),
  rejected('rejected', 'Rejected');

  const VerificationStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}

class VerificationDocument {
  final String id;
  final String userId;
  final VerificationDocumentType documentType;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String mimeType;
  final DateTime uploadedAt;
  final VerificationStatus status;
  final String? adminNotes;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  VerificationDocument({
    required this.id,
    required this.userId,
    required this.documentType,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.mimeType,
    required this.uploadedAt,
    required this.status,
    this.adminNotes,
    this.reviewedAt,
    this.reviewedBy,
  });

  factory VerificationDocument.fromJson(Map<String, dynamic> json) {
    return VerificationDocument(
      id: json['id'],
      userId: json['user_id'],
      documentType: VerificationDocumentType.fromString(json['document_type']),
      fileName: json['file_name'],
      fileUrl: json['file_url'],
      fileSize: json['file_size'],
      mimeType: json['mime_type'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
      status: VerificationStatus.fromString(json['status']),
      adminNotes: json['admin_notes'],
      reviewedAt:
          json['reviewed_at'] != null
              ? DateTime.parse(json['reviewed_at'])
              : null,
      reviewedBy: json['reviewed_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'document_type': documentType.value,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_size': fileSize,
      'mime_type': mimeType,
      'uploaded_at': uploadedAt.toIso8601String(),
      'status': status.value,
      'admin_notes': adminNotes,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewed_by': reviewedBy,
    };
  }
}

class VerificationSubmission {
  final String id;
  final String userId;
  final VerificationSubmissionType submissionType;
  final VerificationStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? adminNotes;
  final DateTime expiresAt;
  final List<VerificationDocument> documents;

  VerificationSubmission({
    required this.id,
    required this.userId,
    required this.submissionType,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.adminNotes,
    required this.expiresAt,
    this.documents = const [],
  });

  factory VerificationSubmission.fromJson(Map<String, dynamic> json) {
    return VerificationSubmission(
      id: json['id'],
      userId: json['user_id'],
      submissionType: VerificationSubmissionType.fromString(
        json['submission_type'],
      ),
      status: VerificationStatus.fromString(json['status']),
      submittedAt: DateTime.parse(json['submitted_at']),
      reviewedAt:
          json['reviewed_at'] != null
              ? DateTime.parse(json['reviewed_at'])
              : null,
      reviewedBy: json['reviewed_by'],
      adminNotes: json['admin_notes'],
      expiresAt: DateTime.parse(json['expires_at']),
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map((doc) => VerificationDocument.fromJson(doc))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'submission_type': submissionType.value,
      'status': status.value,
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewed_by': reviewedBy,
      'admin_notes': adminNotes,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == VerificationStatus.pending;
  bool get isUnderReview => status == VerificationStatus.underReview;
  bool get isApproved => status == VerificationStatus.approved;
  bool get isRejected => status == VerificationStatus.rejected;
}







