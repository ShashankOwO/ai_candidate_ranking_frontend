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

  // Returns plain list: [{...}, {...}]
  Future<List<CandidateModel>> getCandidates() async {
    final response = await apiClient.get(ApiConstants.candidates);
    return _listFromResponse(response, CandidateModel.fromJson);
  }

  Future<CandidateModel> getCandidate(int candidateId) async {
    final response =
        await apiClient.get(ApiConstants.candidate(candidateId));
    return CandidateModel.fromJson(response as Map<String, dynamic>);
  }

  // Returns plain list
  Future<List<CandidateSkillModel>> getCandidateSkills(
      int candidateId) async {
    final response =
        await apiClient.get(ApiConstants.candidateSkills(candidateId));
    return _listFromResponse(response, CandidateSkillModel.fromJson);
  }

  // Returns plain list
  Future<List<CandidateExperienceModel>> getCandidateExperience(
      int candidateId) async {
    final response =
        await apiClient.get(ApiConstants.candidateExperience(candidateId));
    return _listFromResponse(response, CandidateExperienceModel.fromJson);
  }

  // Returns plain list
  Future<List<CandidateQualificationModel>> getCandidateQualifications(
      int candidateId) async {
    final response =
        await apiClient.get(ApiConstants.candidateQualifications(candidateId));
    return _listFromResponse(response, CandidateQualificationModel.fromJson);
  }

  // Returns plain list
  Future<List<CandidateProjectModel>> getCandidateProjects(
      int candidateId) async {
    final response =
        await apiClient.get(ApiConstants.candidateProjects(candidateId));
    return _listFromResponse(response, CandidateProjectModel.fromJson);
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
