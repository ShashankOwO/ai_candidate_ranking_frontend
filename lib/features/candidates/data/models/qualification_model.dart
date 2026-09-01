class QualificationModel {
  final String? id;
  final String? candidateId;
  final String name;
  final String? institution;
  final String? fieldOfStudy;
  final String? startDate;
  final String? endDate;
  final String? grade;

  const QualificationModel({
    this.id,
    this.candidateId,
    required this.name,
    this.institution,
    this.fieldOfStudy,
    this.startDate,
    this.endDate,
    this.grade,
  });

  factory QualificationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return QualificationModel(
      id: _stringValue(
        json['id'] ?? json['qualification_id'],
      ),
      candidateId: _stringValue(
        json['candidate_id'] ?? json['candidateId'],
      ),
      name: _stringValue(
            json['name'] ?? json['qualification'],
          ) ??
          '',
      institution: _stringValue(
        json['institution'],
      ),
      fieldOfStudy: _stringValue(
        json['field_of_study'] ?? json['fieldOfStudy'],
      ),
      startDate: _stringValue(
        json['start_date'] ?? json['startDate'],
      ),
      endDate: _stringValue(
        json['end_date'] ?? json['endDate'],
      ),
      grade: _stringValue(json['grade']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (candidateId != null) 'candidate_id': candidateId,
      'name': name,
      if (institution != null) 'institution': institution,
      if (fieldOfStudy != null) 'field_of_study': fieldOfStudy,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (grade != null) 'grade': grade,
    };
  }

  static String? _stringValue(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
}