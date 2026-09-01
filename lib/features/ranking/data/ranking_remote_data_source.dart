import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../jobs/data/models/ranking_result_model.dart';
import 'models/candidate_evaluation_model.dart';
import 'models/evaluation_run_model.dart';

class RankingRemoteDataSource {
  final ApiClient apiClient;

  RankingRemoteDataSource(this.apiClient);

  Future<void> runRanking(int jobId) async {
    await apiClient.post(ApiConstants.rankJob(jobId));
  }

  // Response: {"job_id": N, "evaluation_runs": [...]}
  Future<List<EvaluationRunModel>> getEvaluationRuns(int jobId) async {
    final response = await apiClient.get(ApiConstants.evaluationRuns(jobId));
    dynamic list;
    if (response is Map<String, dynamic>) {
      list = response['evaluation_runs'];
    } else {
      list = response;
    }
    if (list is! List) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(EvaluationRunModel.fromJson)
        .toList();
  }

  Future<EvaluationRunModel> getEvaluationRun(int runId) async {
    final response = await apiClient.get(ApiConstants.evaluationRun(runId));
    return EvaluationRunModel.fromJson(response as Map<String, dynamic>);
  }

  // Response: {"evaluation_run_id": N, "rankings": [...]}
  // Note: ranking items do NOT have candidate_name
  Future<List<RankingResultModel>> getRankedCandidates(int runId) async {
    final response = await apiClient.get(ApiConstants.rankedCandidates(runId));
    dynamic list;
    if (response is Map<String, dynamic>) {
      list = response['rankings'];
    } else {
      list = response;
    }
    if (list is! List) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(RankingResultModel.fromJson)
        .toList();
  }

  Future<CandidateEvaluationModel> getCandidateEvaluation(
    int runId,
    int candidateId,
  ) async {
    final response = await apiClient
        .get(ApiConstants.candidateEvaluation(runId, candidateId));
    return CandidateEvaluationModel.fromJson(
        response as Map<String, dynamic>);
  }
}
