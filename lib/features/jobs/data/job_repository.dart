import 'job_remote_data_source.dart';
import 'models/evaluation_criterion_model.dart';
import 'models/job_model.dart';
import 'models/job_skill_model.dart';
import 'models/ranking_result_model.dart';

class JobRepository {
  final JobRemoteDataSource remoteDataSource;

  JobRepository(this.remoteDataSource);

  Future<List<JobModel>> getJobs() async {
    return remoteDataSource.getJobs();
  }

  Future<JobModel> getJob(int jobId) async {
    return remoteDataSource.getJob(jobId);
  }

  Future<JobModel> createJob(
    Map<String, dynamic> data,
  ) async {
    return remoteDataSource.createJob(data);
  }

  Future<JobModel> updateJob(
    int jobId,
    Map<String, dynamic> data,
  ) async {
    return remoteDataSource.updateJob(
      jobId,
      data,
    );
  }

  Future<void> deleteJob(int jobId) async {
    await remoteDataSource.deleteJob(jobId);
  }

  Future<List<JobSkillModel>> getSkills(
    int jobId,
  ) async {
    return remoteDataSource.getSkills(jobId);
  }

  Future<JobSkillModel> addSkill(
    int jobId,
    Map<String, dynamic> data,
  ) async {
    return remoteDataSource.addSkill(
      jobId,
      data,
    );
  }

  Future<void> deleteSkill(
    int jobId,
    int skillId,
  ) async {
    await remoteDataSource.deleteSkill(
      jobId,
      skillId,
    );
  }

  Future<List<EvaluationCriterionModel>> getCriteria(
    int jobId,
  ) async {
    return remoteDataSource.getCriteria(jobId);
  }

  Future<EvaluationCriterionModel> addCriterion(
    int jobId,
    Map<String, dynamic> data,
  ) async {
    return remoteDataSource.addCriterion(
      jobId,
      data,
    );
  }

  Future<EvaluationCriterionModel> updateCriterion(
    int criterionId,
    Map<String, dynamic> data,
  ) async {
    return remoteDataSource.updateCriterion(
      criterionId,
      data,
    );
  }

  Future<void> deleteCriterion(
    int criterionId,
  ) async {
    await remoteDataSource.deleteCriterion(
      criterionId,
    );
  }

  Future<void> rankJob(int jobId) async {
    await remoteDataSource.rankJob(jobId);
  }

  Future<List<RankingResultModel>> getRankings(
    int jobId,
  ) async {
    return remoteDataSource.getRankings(jobId);
  }
}