class CandidateExperienceModel {
  final int? experienceId;
  final String companyName;
  final String jobTitle;
  final String? startDate;
  final String? endDate;
  final int? years;
  final String? description;

  const CandidateExperienceModel({
    this.experienceId,
    required this.companyName,
    required this.jobTitle,
    this.startDate,
    this.endDate,
    this.years,
    this.description,
  });

  factory CandidateExperienceModel.fromJson(Map<String, dynamic> json) {
    return CandidateExperienceModel(
      experienceId: json['experience_id'] is int ? json['experience_id'] : int.tryParse('${json['experience_id'] ?? ''}'),
      companyName: json['company_name']?.toString() ?? '',
      jobTitle: json['job_title']?.toString() ?? '',
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      years: json['years'] is int
          ? json['years']
          : int.tryParse('${json['years'] ?? ''}'),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'job_title': jobTitle,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (years != null) 'years': years,
      if (description != null) 'description': description,
    };
  }
}
