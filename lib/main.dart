import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/api_constants.dart';
import 'core/network/api_client.dart';
import 'core/network/auth_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_remote_data_source.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/candidates/data/candidate_remote_data_source.dart';
import 'features/candidates/data/candidate_repository.dart';
import 'features/chatbot/data/chatbot_remote_data_source.dart';
import 'features/chatbot/data/chatbot_repository.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/jobs/data/job_remote_data_source.dart';
import 'features/jobs/data/job_repository.dart';
import 'features/ranking/data/ranking_remote_data_source.dart';
import 'features/ranking/data/ranking_repository.dart';
import 'features/resumes/data/resume_remote_data_source.dart';
import 'features/resumes/data/resume_repository.dart';

late final ApiClient apiClient;
late final AuthStorage authStorage;
late final AuthRepository authRepository;
late final JobRepository jobRepository;
late final CandidateRepository candidateRepository;
late final ResumeRepository resumeRepository;
late final RankingRepository rankingRepository;
late final ChatbotRepository chatbotRepository;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  authStorage = AuthStorage(prefs);
  apiClient = ApiClient(baseUrl: ApiConstants.baseUrl);

  // Restore saved token if exists.
  final savedToken = await authStorage.getToken();
  if (savedToken != null) {
    apiClient.setToken(savedToken);
  }

  // Initialize repositories.
  final authDataSource = AuthRemoteDataSource(apiClient);
  authRepository = AuthRepository(authDataSource, authStorage, apiClient);

  final jobDataSource = JobRemoteDataSource(apiClient);
  jobRepository = JobRepository(jobDataSource);

  final candidateDataSource = CandidateRemoteDataSource(apiClient);
  candidateRepository = CandidateRepository(candidateDataSource);

  final resumeDataSource = ResumeRemoteDataSource(apiClient);
  resumeRepository = ResumeRepository(resumeDataSource);

  final rankingDataSource = RankingRemoteDataSource(apiClient);
  rankingRepository = RankingRepository(rankingDataSource);

  final chatbotDataSource = ChatbotRemoteDataSource(apiClient);
  chatbotRepository = ChatbotRepository(chatbotDataSource);

  runApp(const CandidateRankingApp());
}

class CandidateRankingApp extends StatelessWidget {
  const CandidateRankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Candidate Ranking',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: FutureBuilder<String?>(
        future: authStorage.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
            return const DashboardScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
