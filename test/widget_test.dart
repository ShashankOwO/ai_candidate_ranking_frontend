import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_ai_candidate/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    await tester.pump();

    expect(find.text('Jobs'), findsOneWidget);
  });
}