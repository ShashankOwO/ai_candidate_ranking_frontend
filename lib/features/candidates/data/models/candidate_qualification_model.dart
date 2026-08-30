class CandidateQualificationModel {
  final String? university;
  final String? degree;
  final String? specialization;
  final double? percentage;
  final int? passedOutYear;
  final int? joiningYear;

  const CandidateQualificationModel({
    this.university,
    this.degree,
    this.specialization,
    this.percentage,
    this.passedOutYear,
    this.joiningYear,
  });

  factory CandidateQualificationModel.fromJson(Map<String, dynamic> json) {
    return CandidateQualificationModel(
      university: json['university']?.toString(),
      degree: json['degree']?.toString(),
      specialization: json['specialization']?.toString(),
      percentage: json['percentage'] is num
          ? (json['percentage'] as num).toDouble()
          : double.tryParse('${json['percentage'] ?? ''}'),
      passedOutYear: json['passed_out_year'] is int
          ? json['passed_out_year']
          : int.tryParse('${json['passed_out_year'] ?? ''}'),
      joiningYear: json['joining_year'] is int
          ? json['joining_year']
          : int.tryParse('${json['joining_year'] ?? ''}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (university != null) 'university': university,
      if (degree != null) 'degree': degree,
      if (specialization != null) 'specialization': specialization,
      if (percentage != null) 'percentage': percentage,
      if (passedOutYear != null) 'passed_out_year': passedOutYear,
      if (joiningYear != null) 'joining_year': joiningYear,
    };
  }
}
