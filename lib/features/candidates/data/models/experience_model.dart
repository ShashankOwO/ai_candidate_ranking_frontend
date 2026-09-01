class ExperienceModel {
  final String? id;
  final String? candidateId;
  final String company;
  final String position;
  final String? description;
  final String? startDate;
  final String? endDate;
  final bool current;

  const ExperienceModel({
    this.id,
    this.candidateId,
    required this.company,
    required this.position,
    this.description,
    this.startDate,
    this.endDate,
    this.current = false,
  });

  factory ExperienceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExperienceModel(
      id: _stringValue(
        json['id'] ?? json['experience_id'],
      ),
      candidateId: _stringValue(
        json['candidate_id'] ?? json['candidateId'],
      ),
      company: _stringValue(json['company']) ?? '',
      position: _stringValue(
            json['position'] ?? json['job_title'],
          ) ??
          '',
      description: _stringValue(
        json['description'],
      ),
      startDate: _stringValue(
        json['start_date'] ?? json['startDate'],
      ),
      endDate: _stringValue(
        json['end_date'] ?? json['endDate'],
      ),
      current: _boolValue(
        json['current'] ?? json['is_current'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (candidateId != null) 'candidate_id': candidateId,
      'company': company,
      'position': position,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'current': current,
    };
  }

  static String? _stringValue(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static bool _boolValue(dynamic value) {
    if (value is bool) return value;

    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    return false;
  }
}