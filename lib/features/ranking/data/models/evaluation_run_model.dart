class EvaluationRunModel {
  final int evaluationRunId;
  final int jobId;
  final String? runName;
  final int? totalCandidates;
  final String? createdAt;

  const EvaluationRunModel({
    required this.evaluationRunId,
    required this.jobId,
    this.runName,
    this.totalCandidates,
    this.createdAt,
  });

  factory EvaluationRunModel.fromJson(Map<String, dynamic> json) {
    return EvaluationRunModel(
      evaluationRunId: json['evaluation_run_id'] ?? json['id'] ?? 0,
      jobId: json['job_id'] ?? 0,
      runName: json['run_name']?.toString(),
      totalCandidates: json['total_candidates'] is int
          ? json['total_candidates']
          : int.tryParse('${json['total_candidates'] ?? ''}'),
      createdAt: json['created_at']?.toString(),
    );
  }
}
