class JobModel {
  final int jobId;
  final String jobTitle;
  final String jobDescription;
  final int? minimumExperience;
  final String? status;
  final String? createdAt;

  const JobModel({
    required this.jobId,
    required this.jobTitle,
    required this.jobDescription,
    this.minimumExperience,
    this.status,
    this.createdAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      jobId: json['job_id'] ?? json['id'] ?? 0,
      jobTitle: json['job_title'] ?? json['title'] ?? '',
      jobDescription:
          json['job_description'] ?? json['description'] ?? '',
      minimumExperience: _toNullableInt(json['minimum_experience']),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_title': jobTitle,
      'job_description': jobDescription,
      'minimum_experience': minimumExperience,
    };
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}