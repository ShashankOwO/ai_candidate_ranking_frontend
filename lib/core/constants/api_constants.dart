class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Jobs — prefix /jobs
  static const String createJob = '/jobs/create';
  static const String jobs = '/jobs/all';
  static String job(int id) => '/jobs/$id';

  // Skills (master list) — prefix /skills
  static const String skills = '/skills/all';
  static const String createSkill = '/skills/create';

  // Job Skills — under /jobs prefix
  static String jobSkills(int jobId) => '/jobs/$jobId/skills';
  static String jobSkill(int jobId, int skillId) =>
      '/jobs/$jobId/skills/$skillId';

  // Evaluation Criteria & Ranking — prefix /job (singular!)
  static String jobCriteria(int jobId) => '/job/$jobId/criteria';
  static String jobCriterion(int jobId, int criteriaId) =>
      '/job/$jobId/criteria/$criteriaId';
  static String rankJob(int jobId) => '/job/$jobId/rank';
  static String evaluationRuns(int jobId) => '/job/$jobId/evaluation-runs';

  // Evaluation runs — also under /job prefix
  static String evaluationRun(int runId) => '/job/evaluation-runs/$runId';
  static String rankedCandidates(int runId) =>
      '/job/evaluation-runs/$runId/rankings';
  static String candidateEvaluation(int runId, int candidateId) =>
      '/job/evaluation-runs/$runId/candidates/$candidateId';

  // Candidates — prefix /candidates
  static const String createCandidate = '/candidates/create';
  static const String candidates = '/candidates/all';
  static String candidate(int id) => '/candidates/$id';
  static String candidateSkills(int id) => '/candidates/$id/skills';
  static String candidateQualifications(int id) =>
      '/candidates/$id/qualifications';
  static String candidateExperience(int id) => '/candidates/$id/experience';
  static String candidateProjects(int id) => '/candidates/$id/projects';

  // Resume Upload & List — prefix /resumes
  static const String uploadResume = '/resumes/upload';
  static const String resumes = '/resumes/all';
  static String resume(int id) => '/resumes/$id';
  static String resumeDownload(int id) => '/resumes/$id/download';
}
