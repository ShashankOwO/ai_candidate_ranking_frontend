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

  Future<CandidateModel> getCandidate(int candidateId) async {
    try {
      final response = await apiClient.get(ApiConstants.candidate(candidateId));
      return CandidateModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      // Fallback to searching all candidates
      final all = await getCandidates();
      return all.firstWhere(
        (c) => c.candidateId == candidateId,
        orElse: () => throw Exception('Candidate #$candidateId not found'),
      );
    }
  }

  // POST /candidates/create
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

  Future<void> addSkill(
      int candidateId, Map<String, dynamic> data) async {
    await apiClient.post(
      ApiConstants.candidateSkills(candidateId),
      body: data,
    );
  }

  // PUT /candidates/{id}/experience/{exp_id}
  Future<void> updateExperience(
      int candidateId, int experienceId, Map<String, dynamic> data) async {
    await apiClient.put(
      '${ApiConstants.candidateExperience(candidateId)}/$experienceId',
      body: data,
    );
  }

  // DELETE /candidates/{id}/experience/{exp_id}
  Future<void> deleteExperience(
      int candidateId, int experienceId) async {
    await apiClient.delete(
      '${ApiConstants.candidateExperience(candidateId)}/$experienceId',
    );
  }

  // PUT /candidates/{id}/qualifications/{qual_id}
  Future<void> updateQualification(
      int candidateId, int qualificationId, Map<String, dynamic> data) async {
    await apiClient.put(
      '${ApiConstants.candidateQualifications(candidateId)}/$qualificationId',
      body: data,
    );
  }

  // DELETE /candidates/{id}/qualifications/{qual_id}
  Future<void> deleteQualification(
      int candidateId, int qualificationId) async {
    await apiClient.delete(
      '${ApiConstants.candidateQualifications(candidateId)}/$qualificationId',
    );
  }

  // PUT /candidates/{id}/projects/{proj_id}
  Future<void> updateProject(
      int candidateId, int projectId, Map<String, dynamic> data) async {
    await apiClient.put(
      '${ApiConstants.candidateProjects(candidateId)}/$projectId',
      body: data,
    );
  }

  // DELETE /candidates/{id}/projects/{proj_id}
  Future<void> deleteProject(
      int candidateId, int projectId) async {
    await apiClient.delete(
      '${ApiConstants.candidateProjects(candidateId)}/$projectId',
    );
  }

  // PUT /candidates/{id}/skills/{skill_id}
  Future<void> updateSkill(
      int candidateId, int skillId, Map<String, dynamic> data) async {
    await apiClient.put(
      '${ApiConstants.candidateSkills(candidateId)}/$skillId',
      body: data,
    );
  }

  // DELETE /candidates/{id}/skills/{skill_id}
  Future<void> deleteSkill(
      int candidateId, int skillId) async {
    await apiClient.delete(
      '${ApiConstants.candidateSkills(candidateId)}/$skillId',
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
