import '../../../../core/network/api_client.dart';

import 'models/candidate_model.dart';
import 'models/experience_model.dart';
import 'models/project_model.dart';
import 'models/qualification_model.dart';

class CandidateRemoteDataSource {
  final ApiClient apiClient;

  CandidateRemoteDataSource(this.apiClient);

  // ============================================================
  // CANDIDATES
  // ============================================================

  Future<List<CandidateModel>> getCandidates() async {
    final response = await apiClient.get('/candidates');

    final data = _getData(response);

    final items = _extractList(
      data,
      const [
        'candidates',
        'items',
        'data',
        'results',
      ],
    );

    return items
        .whereType<Map>()
        .map(
          (item) => CandidateModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<CandidateModel> getCandidate(
    String candidateId,
  ) async {
    final response = await apiClient.get(
      '/candidates/$candidateId',
    );

    final data = _getData(response);

    final candidateData = _extractObject(
      data,
      const [
        'candidate',
        'data',
      ],
    );

    return CandidateModel.fromJson(candidateData);
  }

  Future<CandidateModel> createCandidate(
    CandidateModel candidate,
  ) async {
    final response = await apiClient.post(
      '/candidates',
      body: candidate.toJson(),
    );

    final data = _getData(response);

    final candidateData = _extractObject(
      data,
      const [
        'candidate',
        'data',
      ],
    );

    return CandidateModel.fromJson(candidateData);
  }

  Future<CandidateModel> updateCandidate(
    String candidateId,
    CandidateModel candidate,
  ) async {
    final response = await apiClient.put(
      '/candidates/$candidateId',
      body: candidate.toJson(),
    );

    final data = _getData(response);

    final candidateData = _extractObject(
      data,
      const [
        'candidate',
        'data',
      ],
    );

    return CandidateModel.fromJson(candidateData);
  }

  Future<void> deleteCandidate(
    String candidateId,
  ) async {
    await apiClient.delete(
      '/candidates/$candidateId',
    );
  }

  // ============================================================
  // QUALIFICATIONS
  // ============================================================

  Future<List<QualificationModel>> getQualifications(
    String candidateId,
  ) async {
    final response = await apiClient.get(
      '/candidates/$candidateId/qualifications',
    );

    final data = _getData(response);

    final items = _extractList(
      data,
      const [
        'qualifications',
        'items',
        'data',
        'results',
      ],
    );

    return items
        .whereType<Map>()
        .map(
          (item) => QualificationModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<QualificationModel> createQualification(
    String candidateId,
    QualificationModel qualification,
  ) async {
    final response = await apiClient.post(
      '/candidates/$candidateId/qualifications',
      body: qualification.toJson(),
    );

    final data = _getData(response);

    final qualificationData = _extractObject(
      data,
      const [
        'qualification',
        'data',
      ],
    );

    return QualificationModel.fromJson(
      qualificationData,
    );
  }

  Future<QualificationModel> updateQualification(
    String qualificationId,
    QualificationModel qualification,
  ) async {
    final response = await apiClient.put(
      '/qualifications/$qualificationId',
      body: qualification.toJson(),
    );

    final data = _getData(response);

    final qualificationData = _extractObject(
      data,
      const [
        'qualification',
        'data',
      ],
    );

    return QualificationModel.fromJson(
      qualificationData,
    );
  }

  Future<void> deleteQualification(
    String qualificationId,
  ) async {
    await apiClient.delete(
      '/qualifications/$qualificationId',
    );
  }

  // ============================================================
  // EXPERIENCE
  // ============================================================

  Future<List<ExperienceModel>> getExperience(
    String candidateId,
  ) async {
    final response = await apiClient.get(
      '/candidates/$candidateId/experience',
    );

    final data = _getData(response);

    final items = _extractList(
      data,
      const [
        'experience',
        'experiences',
        'items',
        'data',
        'results',
      ],
    );

    return items
        .whereType<Map>()
        .map(
          (item) => ExperienceModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<ExperienceModel> createExperience(
    String candidateId,
    ExperienceModel experience,
  ) async {
    final response = await apiClient.post(
      '/candidates/$candidateId/experience',
      body: experience.toJson(),
    );

    final data = _getData(response);

    final experienceData = _extractObject(
      data,
      const [
        'experience',
        'data',
      ],
    );

    return ExperienceModel.fromJson(
      experienceData,
    );
  }

  Future<ExperienceModel> updateExperience(
    String experienceId,
    ExperienceModel experience,
  ) async {
    final response = await apiClient.put(
      '/experience/$experienceId',
      body: experience.toJson(),
    );

    final data = _getData(response);

    final experienceData = _extractObject(
      data,
      const [
        'experience',
        'data',
      ],
    );

    return ExperienceModel.fromJson(
      experienceData,
    );
  }

  Future<void> deleteExperience(
    String experienceId,
  ) async {
    await apiClient.delete(
      '/experience/$experienceId',
    );
  }

  // ============================================================
  // PROJECTS
  // ============================================================

  Future<List<ProjectModel>> getProjects(
    String candidateId,
  ) async {
    final response = await apiClient.get(
      '/candidates/$candidateId/projects',
    );

    final data = _getData(response);

    final items = _extractList(
      data,
      const [
        'projects',
        'items',
        'data',
        'results',
      ],
    );

    return items
        .whereType<Map>()
        .map(
          (item) => ProjectModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<ProjectModel> createProject(
    String candidateId,
    ProjectModel project,
  ) async {
    final response = await apiClient.post(
      '/candidates/$candidateId/projects',
      body: project.toJson(),
    );

    final data = _getData(response);

    final projectData = _extractObject(
      data,
      const [
        'project',
        'data',
      ],
    );

    return ProjectModel.fromJson(
      projectData,
    );
  }

  Future<ProjectModel> updateProject(
    String projectId,
    ProjectModel project,
  ) async {
    final response = await apiClient.put(
      '/projects/$projectId',
      body: project.toJson(),
    );

    final data = _getData(response);

    final projectData = _extractObject(
      data,
      const [
        'project',
        'data',
      ],
    );

    return ProjectModel.fromJson(
      projectData,
    );
  }

  Future<void> deleteProject(
    String projectId,
  ) async {
    await apiClient.delete(
      '/projects/$projectId',
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  dynamic _getData(dynamic response) {
    if (response == null) {
      return null;
    }

    if (response is Map || response is List) {
      return response;
    }

    return response;
  }

  List<dynamic> _extractList(
    dynamic data,
    List<String> keys,
  ) {
    if (data is List) {
      return data;
    }

    if (data is Map) {
      for (final key in keys) {
        final value = data[key];

        if (value is List) {
          return value;
        }
      }
    }

    return <dynamic>[];
  }

  Map<String, dynamic> _extractObject(
    dynamic data,
    List<String> keys,
  ) {
    if (data is Map) {
      for (final key in keys) {
        final value = data[key];

        if (value is Map) {
          return Map<String, dynamic>.from(value);
        }
      }

      return Map<String, dynamic>.from(data);
    }

    throw const FormatException(
      'Invalid API response. Expected an object.',
    );
  }
}