import '../../jobs/data/models/ranking_result_model.dart';
import 'models/candidate_evaluation_model.dart';
import 'models/evaluation_run_model.dart';
import 'ranking_remote_data_source.dart';

class RankingRepository {
  final RankingRemoteDataSource _dataSource;

  RankingRepository(this._dataSource);

  Future<void> runRanking(int jobId) =>
      _dataSource.runRanking(jobId);

  Future<List<EvaluationRunModel>> getEvaluationRuns(int jobId) =>
      _dataSource.getEvaluationRuns(jobId);

  Future<EvaluationRunModel> getEvaluationRun(int runId) =>
      _dataSource.getEvaluationRun(runId);

  Future<List<RankingResultModel>> getRankedCandidates(int runId) =>
      _dataSource.getRankedCandidates(runId);

  Future<CandidateEvaluationModel> getCandidateEvaluation(
    int runId,
    int candidateId,
  ) =>
      _dataSource.getCandidateEvaluation(runId, candidateId);
}
