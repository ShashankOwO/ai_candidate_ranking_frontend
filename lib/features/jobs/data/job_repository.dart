import 'job_remote_data_source.dart';
import 'models/evaluation_criterion_model.dart';
import 'models/job_model.dart';
import 'models/job_skill_model.dart';
import 'models/skill_model.dart';

class JobRepository {
  final JobRemoteDataSource _dataSource;

  JobRepository(this._dataSource);

  // ── Jobs ──

  Future<List<JobModel>> getJobs() => _dataSource.getJobs();

  Future<JobModel> getJob(int jobId) => _dataSource.getJob(jobId);

  Future<JobModel> createJob(Map<String, dynamic> data) =>
      _dataSource.createJob(data);

  Future<void> deleteJob(int jobId) => _dataSource.deleteJob(jobId);

  // ── Master Skills ──

  Future<List<SkillModel>> getAvailableSkills() =>
      _dataSource.getAvailableSkills();

  Future<SkillModel> createSkill(Map<String, dynamic> data) =>
      _dataSource.createSkill(data);

  // ── Job Skills ──

  Future<List<JobSkillModel>> getJobSkills(int jobId) =>
      _dataSource.getJobSkills(jobId);

  Future<void> addJobSkill(int jobId, Map<String, dynamic> data) =>
      _dataSource.addJobSkill(jobId, data);

  Future<void> deleteJobSkill(int jobId, int skillId) =>
      _dataSource.deleteJobSkill(jobId, skillId);

  // ── Evaluation Criteria ──

  Future<List<EvaluationCriterionModel>> getCriteria(int jobId) =>
      _dataSource.getCriteria(jobId);

  Future<EvaluationCriterionModel> addCriterion(
    int jobId,
    Map<String, dynamic> data,
  ) =>
      _dataSource.addCriterion(jobId, data);

  Future<EvaluationCriterionModel> updateCriterion(
    int jobId,
    int criteriaId,
    Map<String, dynamic> data,
  ) =>
      _dataSource.updateCriterion(jobId, criteriaId, data);

  Future<void> deleteCriterion(int jobId, int criteriaId) =>
      _dataSource.deleteCriterion(jobId, criteriaId);
}