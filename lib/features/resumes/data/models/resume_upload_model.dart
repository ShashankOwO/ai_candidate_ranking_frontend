// Response from POST /resumes/upload:
// {
//   "message": "Resume Uploaded Successfully",
//   "resume_id": 1,
//   "candidate_id": 1,
//   "filename": "resume.pdf",
//   "text_length": 1234
// }
class ResumeUploadModel {
  final String message;
  final int resumeId;
  final int candidateId;
  final String filename;
  final int? textLength;

  const ResumeUploadModel({
    required this.message,
    required this.resumeId,
    required this.candidateId,
    required this.filename,
    this.textLength,
  });

  factory ResumeUploadModel.fromJson(Map<String, dynamic> json) {
    return ResumeUploadModel(
      message: json['message']?.toString() ?? '',
      resumeId: json['resume_id'] ?? 0,
      candidateId: json['candidate_id'] ?? 0,
      filename: json['filename']?.toString() ?? '',
      textLength: json['text_length'],
    );
  }
}
