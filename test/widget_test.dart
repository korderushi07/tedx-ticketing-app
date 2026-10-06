import 'package:flutter_test/flutter_test.dart';
import 'package:ticketingapp/main.dart';

void main() {
  testWidgets('TEDx Event Ops app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TEDxEventOpsApp());
    expect(find.text('TEDx Event Ops'), findsOneWidget);
  });
}
