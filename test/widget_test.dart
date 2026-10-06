import 'package:flutter_test/flutter_test.dart';
import 'package:ticketingapp/main.dart';

void main() {
  testWidgets('TEDx Nagpur 2026 app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TEDxEventOpsApp());
    expect(find.text('Volunteer sign in'), findsOneWidget);
  });
}
