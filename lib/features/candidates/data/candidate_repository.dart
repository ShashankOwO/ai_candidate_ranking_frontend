import 'candidate_remote_data_source.dart';
import 'models/candidate_experience_model.dart';
import 'models/candidate_model.dart';
import 'models/candidate_project_model.dart';
import 'models/candidate_qualification_model.dart';
import 'models/candidate_skill_model.dart';

class CandidateRepository {
  final CandidateRemoteDataSource _dataSource;

  CandidateRepository(this._dataSource);

  Future<List<CandidateModel>> getCandidates() =>
      _dataSource.getCandidates();

  Future<CandidateModel> getCandidate(int candidateId) =>
      _dataSource.getCandidate(candidateId);

  Future<List<CandidateSkillModel>> getCandidateSkills(int candidateId) =>
      _dataSource.getCandidateSkills(candidateId);

  Future<List<CandidateExperienceModel>> getCandidateExperience(
          int candidateId) =>
      _dataSource.getCandidateExperience(candidateId);

  Future<List<CandidateQualificationModel>> getCandidateQualifications(
          int candidateId) =>
      _dataSource.getCandidateQualifications(candidateId);

  Future<List<CandidateProjectModel>> getCandidateProjects(
          int candidateId) =>
      _dataSource.getCandidateProjects(candidateId);

  Future<void> addQualification(
          int candidateId, Map<String, dynamic> data) =>
      _dataSource.addQualification(candidateId, data);

  Future<void> addExperience(
          int candidateId, Map<String, dynamic> data) =>
      _dataSource.addExperience(candidateId, data);

  Future<void> addProject(int candidateId, Map<String, dynamic> data) =>
      _dataSource.addProject(candidateId, data);
}
