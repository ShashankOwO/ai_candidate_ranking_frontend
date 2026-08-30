class RankingResultModel {
  final int candidateId;
  final String candidateName;
  final int rank;
  final double score;
  final String? skillMatchSummary;
  final String? status;

  const RankingResultModel({
    required this.candidateId,
    required this.candidateName,
    required this.rank,
    required this.score,
    this.skillMatchSummary,
    this.status,
  });

  factory RankingResultModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final candidate = json['candidate'];

    return RankingResultModel(
      candidateId: _toInt(
        json['candidate_id'] ??
            (candidate is Map ? candidate['id'] : null),
      ),
      candidateName: json['candidate_name']?.toString() ??
          json['name']?.toString() ??
          (candidate is Map
              ? candidate['name']?.toString()
              : null) ??
          'Unknown Candidate',
      rank: _toInt(json['rank'] ?? json['ranking']),
      score: _toDouble(
        json['score'] ??
            json['ranking_score'] ??
            json['match_score'],
      ),
      skillMatchSummary: json['skill_match_summary']?.toString() ??
          json['skills_summary']?.toString(),
      status: json['status']?.toString(),
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