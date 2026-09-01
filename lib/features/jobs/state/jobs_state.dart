import '../data/models/evaluation_criterion_model.dart';
import '../data/models/job_model.dart';
import '../data/models/job_skill_model.dart';
import '../data/models/ranking_result_model.dart';

enum JobsStatus {
  initial,
  loading,
  success,
  error,
}

class JobsState {
  final JobsStatus status;
  final List<JobModel> jobs;
  final List<JobSkillModel> skills;
  final List<EvaluationCriterionModel> criteria;
  final List<RankingResultModel> rankings;
  final String? errorMessage;

  const JobsState({
    this.status = JobsStatus.initial,
    this.jobs = const [],
    this.skills = const [],
    this.criteria = const [],
    this.rankings = const [],
    this.errorMessage,
  });

  JobsState copyWith({
    JobsStatus? status,
    List<JobModel>? jobs,
    List<JobSkillModel>? skills,
    List<EvaluationCriterionModel>? criteria,
    List<RankingResultModel>? rankings,
    String? errorMessage,
  }) {
    return JobsState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      skills: skills ?? this.skills,
      criteria: criteria ?? this.criteria,
      rankings: rankings ?? this.rankings,
      errorMessage: errorMessage,
    );
  }
}