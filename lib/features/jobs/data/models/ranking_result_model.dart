// Rankings response item:
// {
//   "ranking_id": 1,
//   "candidate_id": 5,
//   "final_score": 78.5,
//   "rank_position": 1,
//   "recommendation": "Strong Match",
//   "created_at": "...",
//   "updated_at": "..."
// }
// Note: candidate_name is NOT returned — must be fetched separately if needed.
class RankingResultModel {
  final int rankingId;
  final int candidateId;
  final double finalScore;
  final int rankPosition;
  final String? recommendation;

  const RankingResultModel({
    required this.rankingId,
    required this.candidateId,
    required this.finalScore,
    required this.rankPosition,
    this.recommendation,
  });

  factory RankingResultModel.fromJson(Map<String, dynamic> json) {
    return RankingResultModel(
      rankingId: _toInt(json['ranking_id']),
      candidateId: _toInt(json['candidate_id']),
      finalScore: _toDouble(json['final_score'] ?? json['score']),
      rankPosition: _toInt(json['rank_position'] ?? json['rank']),
      recommendation: json['recommendation']?.toString(),
    );
  }

  // Backend uses: "Strong Match" | "Good Match" | "Potential Match" | "Not Recommended"
  String get recommendationLabel => recommendation ?? _defaultRecommendation;

  String get _defaultRecommendation {
    if (finalScore >= 80) return 'Strong Match';
    if (finalScore >= 60) return 'Good Match';
    if (finalScore >= 40) return 'Potential Match';
    return 'Not Recommended';
  }

  // Candidate name is not in response; display "Candidate #id" as fallback
  String get candidateName => 'Candidate #$candidateId';

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}