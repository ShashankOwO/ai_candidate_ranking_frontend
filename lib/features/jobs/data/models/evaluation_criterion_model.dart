class EvaluationCriterionModel {
  final int id;
  final int? jobId;
  final String name;
  final String? description;
  final double weight;

  const EvaluationCriterionModel({
    required this.id,
    this.jobId,
    required this.name,
    this.description,
    this.weight = 1.0,
  });

  factory EvaluationCriterionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EvaluationCriterionModel(
      id: _toInt(json['id'] ?? json['criteria_id']),
      jobId: _toNullableInt(json['job_id']),
      name: json['name']?.toString() ??
          json['criterion']?.toString() ??
          '',
      description: json['description']?.toString(),
      weight: _toDouble(json['weight']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 1.0;
  }
}