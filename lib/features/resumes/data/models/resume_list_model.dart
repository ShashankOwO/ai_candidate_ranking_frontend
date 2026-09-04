// Model representing a resume entry returned by the backend list endpoint
class ResumeListModel {
  final int resumeId;
  final int candidateId;
  final String candidateName;
  final String candidateEmail;
  final String fileName;
  final String fileType;
  final int fileSize;
  final DateTime uploadedAt;
  final String? rawText;

  const ResumeListModel({
    required this.resumeId,
    required this.candidateId,
    required this.candidateName,
    required this.candidateEmail,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.uploadedAt,
    this.rawText,
  });

  factory ResumeListModel.fromJson(Map<String, dynamic> json) => ResumeListModel(
        resumeId: json['resume_id'] ?? 0,
        candidateId: json['candidate_id'] ?? 0,
        candidateName: json['candidate_name']?.toString() ?? '',
        candidateEmail: json['candidate_email']?.toString() ?? '',
        fileName: json['file_name']?.toString() ?? '',
        fileType: json['file_type']?.toString() ?? '',
        fileSize: json['file_size'] ?? 0,
        uploadedAt: DateTime.parse(json['uploaded_at']?.toString() ?? DateTime.now().toIso8601String()),
        rawText: json['raw_text']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'resume_id': resumeId,
        'candidate_id': candidateId,
        'candidate_name': candidateName,
        'candidate_email': candidateEmail,
        'file_name': fileName,
        'file_type': fileType,
        'file_size': fileSize,
        'uploaded_at': uploadedAt.toIso8601String(),
        if (rawText != null) 'raw_text': rawText,
      };
}
