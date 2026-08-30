import 'package:flutter/material.dart';

<<<<<<< HEAD
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  runApp(
    const CandidateRankingApp(),
  );
}

class CandidateRankingApp extends StatelessWidget {
  const CandidateRankingApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AI Candidate Ranking",
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}



=======
import 'app.dart';

void main() {
  runApp(const App());
}
>>>>>>> origin/mani_front
