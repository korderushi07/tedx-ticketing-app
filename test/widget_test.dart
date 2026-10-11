import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketingapp/main.dart';

void main() {
  testWidgets('TEDx Nagpur 2026 app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TEDxEventOpsApp(),
      ),
    );
    expect(find.text('Volunteer sign in'), findsOneWidget);
  });
}
