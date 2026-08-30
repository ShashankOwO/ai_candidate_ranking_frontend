import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_ai_candidate/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const CandidateRankingApp());

    await tester.pump();

    expect(find.text('AI Candidate Ranking'), findsOneWidget);
  });
}