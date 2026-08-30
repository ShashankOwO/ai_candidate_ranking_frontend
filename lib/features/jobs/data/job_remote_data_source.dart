import '../../../core/network/api_client.dart';

import 'models/evaluation_criterion_model.dart';
import 'models/job_model.dart';
import 'models/job_skill_model.dart';
import 'models/ranking_result_model.dart';

class JobRemoteDataSource {
  final ApiClient apiClient;

  JobRemoteDataSource(this.apiClient);

  Future<List<JobModel>> getJobs() async {
    final response = await apiClient.get('/jobs');

    return _listFromResponse(
      response,
      JobModel.fromJson,
    );
  }

  Future<JobModel> getJob(int jobId) async {
    final response = await apiClient.get(
      '/jobs/$jobId',
    );

    return JobModel.fromJson(
      _mapFromResponse(response),
    );
  }

  Future<JobModel> createJob(
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.post(
      '/jobs',
      body: data,
    );

    return JobModel.fromJson(
      _mapFromResponse(response),
    );
  }

  Future<JobModel> updateJob(
    int jobId,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put(
      '/jobs/$jobId',
      body: data,
    );

    return JobModel.fromJson(
      _mapFromResponse(response),
    );
  }

  Future<void> deleteJob(int jobId) async {
    await apiClient.delete(
      '/jobs/$jobId',
    );
  }

  Future<List<JobSkillModel>> getSkills(
    int jobId,
  ) async {
    final response = await apiClient.get(
      '/jobs/$jobId/skills',
    );

    return _listFromResponse(
      response,
      JobSkillModel.fromJson,
    );
  }

  Future<JobSkillModel> addSkill(
    int jobId,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.post(
      '/jobs/$jobId/skills',
      body: data,
    );

    return JobSkillModel.fromJson(
      _mapFromResponse(response),
    );
  }

  Future<void> deleteSkill(
    int jobId,
    int skillId,
  ) async {
    await apiClient.delete(
      '/jobs/$jobId/skills/$skillId',
    );
  }

  Future<List<EvaluationCriterionModel>> getCriteria(
    int jobId,
  ) async {
    final response = await apiClient.get(
      '/jobs/$jobId/criteria',
    );

    return _listFromResponse(
      response,
      EvaluationCriterionModel.fromJson,
    );
  }

  Future<EvaluationCriterionModel> addCriterion(
    int jobId,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.post(
      '/jobs/$jobId/criteria',
      body: data,
    );

    return EvaluationCriterionModel.fromJson(
      _mapFromResponse(response),
    );
  }

  Future<EvaluationCriterionModel> updateCriterion(
    int criterionId,
    Map<String, dynamic> data,
  ) async {
    final response = await apiClient.put(
      '/criteria/$criterionId',
      body: data,
    );

    return EvaluationCriterionModel.fromJson(
      _mapFromResponse(response),
    );
  }

  Future<void> deleteCriterion(
    int criterionId,
  ) async {
    await apiClient.delete(
      '/criteria/$criterionId',
    );
  }

  Future<void> rankJob(int jobId) async {
    await apiClient.post(
      '/jobs/$jobId/rank',
    );
  }

  Future<List<RankingResultModel>> getRankings(
    int jobId,
  ) async {
    final response = await apiClient.get(
      '/jobs/$jobId/rankings',
    );

    return _listFromResponse(
      response,
      RankingResultModel.fromJson,
    );
  }

  Map<String, dynamic> _mapFromResponse(
    dynamic response,
  ) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];

      if (data is Map<String, dynamic>) {
        return data;
      }

      return response;
    }

    throw Exception('Invalid API response');
  }

  List<T> _listFromResponse<T>(
    dynamic response,
    T Function(Map<String, dynamic>) parser,
  ) {
    dynamic data = response;

    if (response is Map<String, dynamic>) {
      data = response['data'] ??
          response['items'] ??
          response['results'];
    }

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(parser)
        .toList();
  }
}