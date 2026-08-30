class CandidateEvaluationModel {
  final int evaluationRunId;
  final int candidateId;
  final RankingDetail ranking;
  final List<CriteriaResult> criteriaResults;

  const CandidateEvaluationModel({
    required this.evaluationRunId,
    required this.candidateId,
    required this.ranking,
    required this.criteriaResults,
  });

  factory CandidateEvaluationModel.fromJson(Map<String, dynamic> json) {
    final rankingJson = json['ranking'] as Map<String, dynamic>? ?? {};

    return CandidateEvaluationModel(
      evaluationRunId: json['evaluation_run_id'] ?? 0,
      candidateId: json['candidate_id'] ?? 0,
      ranking: RankingDetail.fromJson(rankingJson),
      criteriaResults: (json['criteria_results'] as List?)
              ?.map((e) => CriteriaResult.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RankingDetail {
  final double finalScore;
  final int rankPosition;
  final String? recommendation;

  const RankingDetail({
    required this.finalScore,
    required this.rankPosition,
    this.recommendation,
  });

  factory RankingDetail.fromJson(Map<String, dynamic> json) {
    return RankingDetail(
      finalScore: _toDouble(json['final_score']),
      rankPosition: _toInt(json['rank_position']),
      recommendation: json['recommendation']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class CriteriaResult {
  final int criteriaId;
  final String criteriaName;
  final double score;
  final String? reason;

  const CriteriaResult({
    required this.criteriaId,
    required this.criteriaName,
    required this.score,
    this.reason,
  });

  factory CriteriaResult.fromJson(Map<String, dynamic> json) {
    return CriteriaResult(
      criteriaId: json['criteria_id'] ?? 0,
      criteriaName: json['criteria_name']?.toString() ?? '',
      score: _toDouble(json['score']),
      reason: json['reason']?.toString(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
