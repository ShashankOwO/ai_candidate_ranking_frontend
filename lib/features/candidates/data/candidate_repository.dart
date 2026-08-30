import 'candidate_remote_data_source.dart';

import 'models/candidate_model.dart';
import 'models/experience_model.dart';
import 'models/project_model.dart';
import 'models/qualification_model.dart';

class CandidateRepository {
  final CandidateRemoteDataSource remoteDataSource;

  CandidateRepository(this.remoteDataSource);

  // ============================================================
  // CANDIDATES
  // ============================================================

  Future<List<CandidateModel>> getCandidates() {
    return remoteDataSource.getCandidates();
  }

  Future<CandidateModel> getCandidate(
    String candidateId,
  ) {
    return remoteDataSource.getCandidate(candidateId);
  }

  Future<CandidateModel> createCandidate(
    CandidateModel candidate,
  ) {
    return remoteDataSource.createCandidate(candidate);
  }

  Future<CandidateModel> updateCandidate(
    String candidateId,
    CandidateModel candidate,
  ) {
    return remoteDataSource.updateCandidate(
      candidateId,
      candidate,
    );
  }

  Future<void> deleteCandidate(
    String candidateId,
  ) {
    return remoteDataSource.deleteCandidate(
      candidateId,
    );
  }

  // ============================================================
  // QUALIFICATIONS
  // ============================================================

  Future<List<QualificationModel>> getQualifications(
    String candidateId,
  ) {
    return remoteDataSource.getQualifications(
      candidateId,
    );
  }

  Future<QualificationModel> createQualification(
    String candidateId,
    QualificationModel qualification,
  ) {
    return remoteDataSource.createQualification(
      candidateId,
      qualification,
    );
  }

  Future<QualificationModel> updateQualification(
    String qualificationId,
    QualificationModel qualification,
  ) {
    return remoteDataSource.updateQualification(
      qualificationId,
      qualification,
    );
  }

  Future<void> deleteQualification(
    String qualificationId,
  ) {
    return remoteDataSource.deleteQualification(
      qualificationId,
    );
  }

  // ============================================================
  // EXPERIENCE
  // ============================================================

  Future<List<ExperienceModel>> getExperience(
    String candidateId,
  ) {
    return remoteDataSource.getExperience(
      candidateId,
    );
  }

  Future<ExperienceModel> createExperience(
    String candidateId,
    ExperienceModel experience,
  ) {
    return remoteDataSource.createExperience(
      candidateId,
      experience,
    );
  }

  Future<ExperienceModel> updateExperience(
    String experienceId,
    ExperienceModel experience,
  ) {
    return remoteDataSource.updateExperience(
      experienceId,
      experience,
    );
  }

  Future<void> deleteExperience(
    String experienceId,
  ) {
    return remoteDataSource.deleteExperience(
      experienceId,
    );
  }

  // ============================================================
  // PROJECTS
  // ============================================================

  Future<List<ProjectModel>> getProjects(
    String candidateId,
  ) {
    return remoteDataSource.getProjects(
      candidateId,
    );
  }

  Future<ProjectModel> createProject(
    String candidateId,
    ProjectModel project,
  ) {
    return remoteDataSource.createProject(
      candidateId,
      project,
    );
  }

  Future<ProjectModel> updateProject(
    String projectId,
    ProjectModel project,
  ) {
    return remoteDataSource.updateProject(
      projectId,
      project,
    );
  }

  Future<void> deleteProject(
    String projectId,
  ) {
    return remoteDataSource.deleteProject(
      projectId,
    );
  }
}