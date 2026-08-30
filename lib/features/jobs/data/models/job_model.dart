class JobModel {
  final int id;
  final String title;
  final String description;
  final String? location;
  final String? employmentType;
  final int? minimumExperience;
  final String? status;

  const JobModel({
    required this.id,
    required this.title,
    required this.description,
    this.location,
    this.employmentType,
    this.minimumExperience,
    this.status,
  });

  factory JobModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return JobModel(
      id: json['job_id'] ?? json['id'],
      title: json['job_title'] ?? json['title'] ?? '',
      description:
          json['job_description'] ??
          json['description'] ??
          '',
      location: json['location'],
      employmentType:
          json['employment_type'],
      minimumExperience:
          json['minimum_experience'],
      status: json['status'] ?? 'Open',
    );
  }
}