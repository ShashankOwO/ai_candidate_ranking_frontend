import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/candidate_experience_model.dart';
import 'models/candidate_model.dart';
import 'models/candidate_project_model.dart';
import 'models/candidate_qualification_model.dart';
import 'models/candidate_skill_model.dart';

class CandidateRemoteDataSource {
  final ApiClient apiClient;

  CandidateRemoteDataSource(this.apiClient);

  Future<List<CandidateModel>> getCandidates() async {
    final response = await apiClient.get(ApiConstants.candidates);
    return _listFromResponse(response, CandidateModel.fromJson);
  }

  /// Backend has no GET /candidates/{id} — only PUT and DELETE.
  /// So we fetch the full list and filter.
  Future<CandidateModel> getCandidate(int candidateId) async {
    final all = await getCandidates();
    return all.firstWhere(
      (c) => c.candidateId == candidateId,
      orElse: () => throw Exception('Candidate #$candidateId not found'),
    );
  }

  // POST /candidates/create
  // Body: { full_name, contact_no?, email_address? }
  Future<CandidateModel> createCandidate(Map<String, dynamic> data) async {
    final response =
        await apiClient.post(ApiConstants.createCandidate, body: data);
    return CandidateModel.fromJson(response as Map<String, dynamic>);
  }

  // PUT /candidates/{id}
  Future<CandidateModel> updateCandidate(
      int candidateId, Map<String, dynamic> data) async {
    final response = await apiClient.put(
      ApiConstants.candidate(candidateId),
      body: data,
    );
    return CandidateModel.fromJson(response as Map<String, dynamic>);
  }

  // DELETE /candidates/{id}
  Future<void> deleteCandidate(int candidateId) async {
    await apiClient.delete(ApiConstants.candidate(candidateId));
  }

  Future<List<CandidateSkillModel>> getCandidateSkills(
      int candidateId) async {
    final response =
        await apiClient.get(ApiConstants.candidateSkills(candidateId));
    return _listFromResponse(response, CandidateSkillModel.fromJson);
  }

  Future<List<CandidateExperienceModel>> getCandidateExperience(
      int candidateId) async {
    final response =
        await apiClient.get(ApiConstants.candidateExperience(candidateId));
    return _listFromResponse(response, CandidateExperienceModel.fromJson);
  }

  Future<List<CandidateQualificationModel>> getCandidateQualifications(
      int candidateId) async {
    final response =
        await apiClient.get(ApiConstants.candidateQualifications(candidateId));
    return _listFromResponse(response, CandidateQualificationModel.fromJson);
  }

  /// Backend has POST /{candidate_id}/projects but no GET.
  /// Try the GET endpoint; if it returns 404/405, return empty list.
  Future<List<CandidateProjectModel>> getCandidateProjects(
      int candidateId) async {
    try {
      final response =
          await apiClient.get(ApiConstants.candidateProjects(candidateId));
      return _listFromResponse(response, CandidateProjectModel.fromJson);
    } catch (e) {
      // No GET endpoint exists — silently return empty.
      return [];
    }
  }

  Future<void> addQualification(
      int candidateId, Map<String, dynamic> data) async {
    await apiClient.post(
      ApiConstants.candidateQualifications(candidateId),
      body: data,
    );
  }

  Future<void> addExperience(
      int candidateId, Map<String, dynamic> data) async {
    await apiClient.post(
      ApiConstants.candidateExperience(candidateId),
      body: data,
    );
  }

  Future<void> addProject(
      int candidateId, Map<String, dynamic> data) async {
    await apiClient.post(
      ApiConstants.candidateProjects(candidateId),
      body: data,
    );
  }

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
