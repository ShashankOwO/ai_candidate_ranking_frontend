import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_ai_candidate/app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    await tester.pump();

    expect(find.text('Jobs'), findsOneWidget);
  });
}