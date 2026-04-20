import 'package:flutter_test/flutter_test.dart';

import 'package:finalassignment/main.dart';

void main() {
  testWidgets('Dashboard renders welcome and tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(firebaseReady: false));

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Languages'), findsOneWidget);
    expect(find.text('Recent Sessions'), findsOneWidget);
  });
}
