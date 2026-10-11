import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketingapp/models/app_models.dart';
import 'package:ticketingapp/providers/redemption_providers.dart';
import 'package:ticketingapp/screens/redemption_history_screen.dart';

class TestRedemptionHistoryNotifier extends RedemptionHistoryNotifier {
  TestRedemptionHistoryNotifier(AsyncValue<List<ScanModel>> initial) {
    state = initial;
  }

  @override
  Future<void> fetchHistory() async {}

  @override
  Future<void> refresh() async {}
}

void main() {
  group('Redemption History Riverpod State & UI Tests', () {
    test('currentScanProvider starts null and can set/clear scan', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(currentScanProvider), isNull);

      const testScan = ScanModel(
        id: 'scan-1',
        time: '10:00 AM',
        name: 'Rahul Sharma',
        ticketId: 'TDX-PREM-101',
        pass: 'VIP',
        benefit: 'Lunch',
        counter: 'Food Counter 01',
        outcome: Outcome.approved,
      );

      container.read(currentScanProvider.notifier).setScan(testScan);
      expect(container.read(currentScanProvider)?.name, equals('Rahul Sharma'));

      container.read(currentScanProvider.notifier).clearScan();
      expect(container.read(currentScanProvider), isNull);
    });

    test('redemptionHistoryNotifier clear method empties history on logout', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(redemptionHistoryProvider.notifier).clear();
      final state = container.read(redemptionHistoryProvider);
      expect(state.value, isEmpty);
    });

    testWidgets('RedemptionHistoryScreen displays empty state when no redemptions exist',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          redemptionHistoryProvider.overrideWith((ref) {
            return TestRedemptionHistoryNotifier(const AsyncValue.data([]));
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: RedemptionHistoryScreen(
              counter: CounterInfo.food,
              onSelectScan: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Redemptions Found'), findsOneWidget);
      expect(find.text('Redemption transactions recorded at this counter will appear here.'), findsOneWidget);
    });

    testWidgets('RedemptionHistoryScreen displays data correctly without duplicating items',
        (WidgetTester tester) async {
      const scan1 = ScanModel(
        id: 'history-1',
        time: '10:00 AM',
        name: 'Rahul Sharma',
        ticketId: 'TDX-PREM-101',
        pass: 'VIP',
        benefit: 'Lunch',
        counter: 'Food Counter 01',
        outcome: Outcome.approved,
      );

      final container = ProviderContainer(
        overrides: [
          redemptionHistoryProvider.overrideWith((ref) {
            return TestRedemptionHistoryNotifier(const AsyncValue.data([scan1]));
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: RedemptionHistoryScreen(
              counter: CounterInfo.food,
              onSelectScan: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Rahul Sharma'), findsOneWidget);
    });
  });
}
