import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'features/jobs/data/job_remote_data_source.dart';
import 'features/jobs/data/job_repository.dart';
import 'features/jobs/presentation/pages/jobs_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient(
      baseUrl: 'http://127.0.0.1:8000',
    );

    final remoteDataSource =
        JobRemoteDataSource(apiClient);

    final repository =
        JobRepository(remoteDataSource);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Candidate Ranking',
      home: JobsPage(
        repository: repository,
      ),
    );
  }
}