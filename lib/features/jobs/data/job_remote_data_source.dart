import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/evaluation_criterion_model.dart';
import 'models/job_model.dart';
import 'models/job_skill_model.dart';
import 'models/skill_model.dart';

class JobRemoteDataSource {
  final ApiClient apiClient;

  JobRemoteDataSource(this.apiClient);

  // ── Jobs ──

  Future<List<JobModel>> getJobs() async {
    final response = await apiClient.get(ApiConstants.jobs);
    // Returns a plain list: [{...}, {...}]
    return _listFromResponse(response, JobModel.fromJson);
  }

  Future<JobModel> getJob(int jobId) async {
    final response = await apiClient.get(ApiConstants.job(jobId));
    // Returns a flat object with skills and evaluation_criteria embedded
    return JobModel.fromJson(response as Map<String, dynamic>);
  }

  Future<JobModel> createJob(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiConstants.createJob, body: data);
    return JobModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteJob(int jobId) async {
    await apiClient.delete(ApiConstants.job(jobId));
  }

  // ── Master Skills ──

  Future<List<SkillModel>> getAvailableSkills() async {
    final response = await apiClient.get(ApiConstants.skills);
    // Returns a plain list
    return _listFromResponse(response, SkillModel.fromJson);
  }

  // ── Job Skills ──

  Future<List<JobSkillModel>> getJobSkills(int jobId) async {
    final response = await apiClient.get(ApiConstants.jobSkills(jobId));
    // Returns a plain list
    return _listFromResponse(response, JobSkillModel.fromJson);
  }

  Future<void> addJobSkill(int jobId, Map<String, dynamic> data) async {
    await apiClient.post(ApiConstants.jobSkills(jobId), body: data);
  }

  Future<void> deleteJobSkill(int jobId, int skillId) async {
    await apiClient.delete(ApiConstants.jobSkill(jobId, skillId));
  }

  // ── Evaluation Criteria ──
  // Response: {"job_id": N, "total_weight": N, "criteria": [...]}

  Future<List<EvaluationCriterionModel>> getCriteria(int jobId) async {
    final response = await apiClient.get(ApiConstants.jobCriteria(jobId));
    dynamic list;
    if (response is Map<String, dynamic>) {
      list = response['criteria'];
    } else {
      list = response;
    }
    if (list is! List) return [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(EvaluationCriterionModel.fromJson)
        .toList();
  }

  Future<EvaluationCriterionModel> addCriterion(
    int jobId,
    Map<String, dynamic> data,
  ) async {
    final response =
        await apiClient.post(ApiConstants.jobCriteria(jobId), body: data);
    return EvaluationCriterionModel.fromJson(response as Map<String, dynamic>);
  }

  Future<EvaluationCriterionModel> updateCriterion(
    int jobId,
    int criteriaId,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put(
      ApiConstants.jobCriterion(jobId, criteriaId),
      body: data,
    );
    return EvaluationCriterionModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteCriterion(int jobId, int criteriaId) async {
    await apiClient.delete(ApiConstants.jobCriterion(jobId, criteriaId));
  }

  // ── Helpers ──

  List<T> _listFromResponse<T>(
    dynamic response,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (response is List) {
      return response.whereType<Map<String, dynamic>>().map(parser).toList();
    }
    return [];
  }
}