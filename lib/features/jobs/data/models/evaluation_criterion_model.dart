class EvaluationCriterionModel {
  final int criteriaId;
  final int? jobId;
  final String criteriaName;
  final String criteriaType; // "skills" | "experience" | "qualification" | "projects" | "custom"
  final String? criteriaDescription;
  final double weight;   // float in backend schema (gt=0, le=100)
  final double maxScore; // float in backend schema (default=100)

  const EvaluationCriterionModel({
    required this.criteriaId,
    this.jobId,
    required this.criteriaName,
    required this.criteriaType,
    this.criteriaDescription,
    required this.weight,
    this.maxScore = 100,
  });

  factory EvaluationCriterionModel.fromJson(Map<String, dynamic> json) {
    return EvaluationCriterionModel(
      criteriaId: _toInt(json['criteria_id'] ?? json['id']),
      jobId: _toNullableInt(json['job_id']),
      criteriaName: json['criteria_name'] ?? json['name'] ?? '',
      criteriaType: json['criteria_type'] ?? json['type'] ?? 'custom',
      criteriaDescription: json['criteria_description'] ?? json['description'],
      weight: _toDouble(json['weight']),
      maxScore: _toDouble(json['max_score'] ?? 100),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criteria_name': criteriaName,
      'criteria_type': criteriaType,
      'criteria_description': criteriaDescription ?? '',
      'weight': weight,
      'max_score': maxScore,
    };
  }

  // For display — show as int if whole number
  String get weightDisplay =>
      weight == weight.truncate() ? '${weight.toInt()}' : '$weight';

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static const List<String> criteriaTypes = [
    'skills',
    'experience',
    'qualification',
    'projects',
    'custom',
  ];
}