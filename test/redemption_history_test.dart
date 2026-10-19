import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketingapp/models/app_models.dart';
import 'package:ticketingapp/providers/redemption_providers.dart';
import 'package:ticketingapp/screens/redemption_history_screen.dart';
import 'package:ticketingapp/screens/qr_scanner_screen.dart';
import 'package:ticketingapp/screens/success_redemption_screen.dart';
import 'package:ticketingapp/services/redemption_batch_service.dart';

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
    test(
      'redemption batch submits only selected tickets and preserves partial outcomes',
      () async {
        const tickets = [
          ScanModel(
            id: 'scan-t6',
            time: '10:00 AM',
            name: 'Attendee 6',
            ticketId: 't6',
            pass: 'Standard',
            benefit: 'Food',
            counter: 'Food Counter 01',
            outcome: Outcome.ready,
            attendeeId: 6,
            addonId: 2,
            counterId: 3,
          ),
          ScanModel(
            id: 'scan-t8',
            time: '10:00 AM',
            name: 'Attendee 8',
            ticketId: 't8',
            pass: 'VIP',
            benefit: 'Food',
            counter: 'Food Counter 01',
            outcome: Outcome.ready,
            attendeeId: 8,
            addonId: 2,
            counterId: 3,
          ),
          ScanModel(
            id: 'scan-t9',
            time: '10:00 AM',
            name: 'Attendee 9',
            ticketId: 't9',
            pass: 'Premium',
            benefit: 'Food',
            counter: 'Food Counter 01',
            outcome: Outcome.ready,
            attendeeId: 9,
            addonId: 2,
            counterId: 3,
          ),
        ];
        final attempted = <String>[];

        final results = await RedemptionBatchService().redeemSelected(
          tickets: tickets,
          claim: (ticket) async {
            attempted.add(ticket.ticketId);
            if (ticket.ticketId == 't6') {
              return {
                'success': true,
                'redemption': {
                  'redeemed_at': '2026-10-19T10:00:00Z',
                  'counter': 'Food Counter 01',
                  'volunteer': 'VOL-1',
                  'claimant_name': 'Attendee 6',
                },
              };
            }
            if (ticket.ticketId == 't8') {
              return {
                'detail': {
                  'error': 'ALREADY_CLAIMED',
                  'message': 'This item has already been claimed.',
                  'previous_redemption': {
                    'redeemed_at': '2026-10-18T10:00:00Z',
                    'counter': 'Food Counter 01',
                    'volunteer': 'VOL-2',
                    'claimant_name': 'Attendee 8',
                  },
                },
              };
            }
            throw Exception('Network timeout');
          },
          reconcile: (_) async => false,
        );

        expect(attempted, ['t6', 't8', 't9']);
        expect(results.map((result) => result.redemptionOutcome), [
          Outcome.approved,
          Outcome.redeemed,
          Outcome.network,
        ]);
        expect(results.first.redeemedBy, 'VOL-1');
        expect(results.first.claimedBy, 'Attendee 6');
        expect(results[1].redeemedBy, 'VOL-2');
        expect(results[1].claimedBy, 'Attendee 8');
        expect(results.last.isRedeemed, isFalse);
      },
    );

    testWidgets('manual ticket entry validates a trimmed ticket ID', (
      WidgetTester tester,
    ) async {
      String? submittedTicketId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ManualTicketEntry(
              isSmallScreen: true,
              isProcessing: false,
              onSubmit: (ticketId) => submittedTicketId = ticketId,
            ),
          ),
        ),
      );

      await tester.tap(find.text('VALIDATE TICKET ID'));
      await tester.pump();
      expect(find.text('Enter a ticket ID to validate.'), findsOneWidget);
      expect(submittedTicketId, isNull);

      await tester.enterText(find.byType(TextField), '  TDX-12345 \n');
      await tester.tap(find.text('VALIDATE TICKET ID'));
      expect(submittedTicketId, 'TDX-12345');
    });

    testWidgets('eligible scan requires explicit redemption confirmation', (
      WidgetTester tester,
    ) async {
      final selected = <String>{};
      List<String>? submittedTicketIds;
      const scan = ScanModel(
        id: 'scan-1',
        time: '10:00 AM',
        name: 'Person One',
        ticketId: 'T1',
        pass: 'general',
        benefit: 'Lunch',
        counter: 'Food Counter 01',
        outcome: Outcome.ready,
        attendeeId: 1,
        addonId: 2,
        counterId: 3,
        orderId: 'O1',
        orderTickets: [
          AttendeeModel(
            attendeeId: 2,
            ticketId: 'T2',
            name: 'Person Two',
            ticketType: 'general',
            benefits: [],
            addonId: 2,
            isEligible: true,
            statusMessage: 'Eligible for Lunch',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => OutcomeResultScreen(
              scan: scan,
              onActionClick: () {},
              onConfirmRedemption: () async {
                submittedTicketIds = List.of(selected);
              },
              onTogglePrimaryTicket: () {
                setState(() {
                  if (!selected.add('T1::2')) selected.remove('T1::2');
                });
              },
              onToggleRelatedTicket: (ticket) {
                setState(() {
                  final key = '${ticket.ticketId}::2';
                  if (!selected.add(key)) selected.remove(key);
                });
              },
              isPrimarySelected: selected.contains('T1::2'),
              selectedRedemptionKeys: selected,
              selectedTicketCount: selected.length,
            ),
          ),
        ),
      );

      expect(find.text('Eligible'), findsOneWidget);
      await tester.tap(find.text('Approve').first);
      await tester.pumpAndSettle();
      expect(selected, {'T1::2'});
      expect(find.text('Selected'), findsOneWidget);
      expect(find.text('1 ticket selected for Lunch'), findsOneWidget);
      await tester.tap(find.text('Selected').first);
      await tester.pumpAndSettle();
      expect(selected, isEmpty);

      expect(find.byType(ExpansionTile), findsNothing);
      expect(find.text('Other Tickets in Same Order'), findsOneWidget);
      expect(find.text('Person Two'), findsOneWidget);
      expect(find.text('T2 · general'), findsOneWidget);
      expect(find.text('Eligible for Lunch'), findsOneWidget);
      await tester.ensureVisible(find.text('Approve').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Approve').last);
      await tester.pumpAndSettle();
      expect(selected, {'T2::2'});
      expect(find.text('Selected'), findsOneWidget);
      expect(find.text('1 ticket selected for Lunch'), findsOneWidget);
      expect(find.text('CONFIRM 1 TICKET FOR LUNCH'), findsOneWidget);
      expect(submittedTicketIds, isNull);

      await tester.tap(find.text('CONFIRM 1 TICKET FOR LUNCH'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm redemption'), findsOneWidget);
      expect(find.text('Person Two'), findsNWidgets(2));
      expect(find.text('T2'), findsOneWidget);
      expect(submittedTicketIds, isNull);
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
      expect(submittedTicketIds, isNull);
      expect(selected, {'T2::2'});

      await tester.tap(find.text('CONFIRM 1 TICKET FOR LUNCH'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONFIRM'));
      await tester.pumpAndSettle();
      expect(submittedTicketIds, ['T2::2']);

      await tester.tap(find.text('Selected'));
      await tester.pumpAndSettle();
      expect(selected, isEmpty);
      expect(find.text('CONFIRM 1 TICKET FOR LUNCH'), findsNothing);
    });

    testWidgets('only eligible unredeemed order tickets can be selected', (
      WidgetTester tester,
    ) async {
      const scan = ScanModel(
        id: 'scan-filter',
        time: '10:00 AM',
        name: 'Scanned attendee',
        ticketId: 'T1',
        pass: 'General',
        benefit: 'Food',
        counter: 'Food Counter 01',
        outcome: Outcome.notEligible,
        attendeeId: 1,
        addonId: 2,
        counterId: 3,
        orderId: 'O1',
        orderTickets: [
          AttendeeModel(
            attendeeId: 2,
            ticketId: 'T2',
            name: 'Eligible attendee',
            ticketType: 'VIP',
            benefits: [],
            addonId: 2,
            isEligible: true,
          ),
          AttendeeModel(
            attendeeId: 3,
            ticketId: 'T3',
            name: 'Ineligible attendee',
            ticketType: 'Standard',
            benefits: [],
            addonId: 2,
            isEligible: false,
          ),
          AttendeeModel(
            attendeeId: 4,
            ticketId: 'T4',
            name: 'Redeemed attendee',
            ticketType: 'VIP',
            benefits: [],
            addonId: 2,
            isEligible: false,
            isRedeemed: true,
            statusMessage: 'Already redeemed',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: OutcomeResultScreen(
            scan: scan,
            onActionClick: () {},
            onConfirmRedemption: () async {},
            onToggleRelatedTicket: (_) {},
          ),
        ),
      );
      expect(find.byType(ExpansionTile), findsNothing);
      expect(find.text('Other Tickets in Same Order'), findsOneWidget);
      expect(find.text('Eligible attendee'), findsOneWidget);
      expect(find.text('Ineligible attendee'), findsNothing);
      expect(find.text('Redeemed attendee'), findsOneWidget);
      expect(find.text('REDEEMED'), findsOneWidget);
      expect(
        find.text('Claimed by Claimant information unavailable'),
        findsOneWidget,
      );
      expect(
        find.text('No other eligible tickets for this counter'),
        findsNothing,
      );
      expect(find.text('Scanned attendee'), findsOneWidget);
      expect(find.text('Not eligible'), findsOneWidget);
    });

    testWidgets('redeemed tickets show claimant and cannot be selected', (
      WidgetTester tester,
    ) async {
      final toggled = <String>[];
      const scan = ScanModel(
        id: 'scan-claimant',
        time: '10:00 AM',
        name: 'Different scanned attendee',
        ticketId: 'T1',
        pass: 'Standard',
        benefit: 'Food',
        counter: 'Food Counter 01',
        outcome: Outcome.ready,
        attendeeId: 1,
        addonId: 2,
        counterId: 3,
        orderId: 'O7',
        orderTickets: [
          AttendeeModel(
            attendeeId: 2,
            ticketId: 'T11',
            name: 'Sample Attendee 11',
            ticketType: 'Standard',
            benefits: [],
            addonId: 2,
            isEligible: false,
            isRedeemed: true,
            claimedBy: 'Sample Attendee 11',
            redeemedBy: 'Food Volunteer',
            redeemedAt: '2026-10-19T10:00:00Z',
          ),
          AttendeeModel(
            attendeeId: 3,
            ticketId: 'T12',
            name: 'Sample Attendee 12',
            ticketType: 'Premium',
            benefits: [],
            addonId: 2,
            isEligible: true,
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: OutcomeResultScreen(
            scan: scan,
            onActionClick: () {},
            onConfirmRedemption: () async {},
            onToggleRelatedTicket: (ticket) => toggled.add(ticket.ticketId),
            selectedRedemptionKeys: const {},
          ),
        ),
      );

      expect(find.byType(ExpansionTile), findsNothing);
      expect(find.text('Sample Attendee 11'), findsOneWidget);
      expect(find.text('REDEEMED'), findsOneWidget);
      expect(find.text('Claimed by Sample Attendee 11'), findsOneWidget);
      expect(find.text('Processed by Food Volunteer'), findsOneWidget);
      expect(find.text('Approve'), findsNWidgets(2));
      expect(find.text('Sample Attendee 12'), findsOneWidget);

      final approveButton = find.ancestor(
        of: find.text('Approve'),
        matching: find.byType(OutlinedButton),
      );
      await tester.ensureVisible(approveButton.last);
      await tester.pumpAndSettle();
      await tester.tap(approveButton.last);
      await tester.pumpAndSettle();
      expect(toggled, ['T12']);
      expect(find.text('Claimed by Sample Attendee 11'), findsOneWidget);
    });

    testWidgets(
      'primary redeemed ticket shows claimant and no approve action',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: OutcomeResultScreen(
              scan: const ScanModel(
                id: 'scan-primary-redeemed',
                time: '10:00 AM',
                name: 'Sample Attendee 11',
                ticketId: 'T11',
                pass: 'Standard',
                benefit: 'Food',
                counter: 'Food Counter 01',
                outcome: Outcome.redeemed,
                attendeeId: 11,
                previousRedemptionClaimant: 'Sample Attendee 11',
              ),
              onActionClick: () {},
              onConfirmRedemption: () async {},
            ),
          ),
        );
        expect(find.text('REDEEMED'), findsOneWidget);
        expect(find.text('Sample Attendee 11'), findsNWidgets(2));
        expect(find.text('Claimed by'), findsOneWidget);
        expect(find.text('Approve'), findsNothing);
      },
    );

    testWidgets('shows concise empty state when no linked ticket is eligible', (
      WidgetTester tester,
    ) async {
      const scan = ScanModel(
        id: 'scan-empty-order',
        time: '10:00 AM',
        name: 'Scanned attendee',
        ticketId: 'T1',
        pass: 'Standard',
        benefit: 'T-Shirt',
        counter: 'Merch Counter',
        outcome: Outcome.notEligible,
        attendeeId: 1,
        addonId: 3,
        counterId: 4,
        orderId: 'O1',
        orderTickets: [
          AttendeeModel(
            attendeeId: 2,
            ticketId: 'T2',
            name: 'Not eligible attendee',
            ticketType: 'Standard',
            benefits: [],
            addonId: 3,
            isEligible: false,
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: OutcomeResultScreen(
            scan: scan,
            onActionClick: () {},
            onConfirmRedemption: () async {},
          ),
        ),
      );
      expect(
        find.text('No other eligible tickets for this counter'),
        findsOneWidget,
      );
      expect(find.text('Not eligible attendee'), findsNothing);
      expect(find.text('Not eligible'), findsOneWidget);
    });

    testWidgets(
      'related-ticket eligibility loading and failure are recoverable',
      (WidgetTester tester) async {
        const scan = ScanModel(
          id: 'scan-related-loading',
          time: '10:00 AM',
          name: 'Scanned attendee',
          ticketId: 'T1',
          pass: 'VIP',
          benefit: 'Food',
          counter: 'Food Counter 01',
          outcome: Outcome.ready,
          attendeeId: 1,
          addonId: 2,
          counterId: 3,
          orderId: 'O1',
          orderTickets: [
            AttendeeModel(
              attendeeId: 2,
              ticketId: 'T2',
              name: 'Eligibility pending',
              ticketType: 'General',
              benefits: [],
            ),
          ],
          orderTicketsLoading: true,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: OutcomeResultScreen(
              scan: scan,
              onActionClick: () {},
              onConfirmRedemption: () async {},
            ),
          ),
        );
        expect(find.text('Checking eligibility for Food'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.text('CONFIRM 1 TICKET FOR FOOD'), findsNothing);

        var retried = false;
        await tester.pumpWidget(
          MaterialApp(
            home: OutcomeResultScreen(
              scan: scan.copyWith(
                orderTicketsLoading: false,
                orderTicketsLoadFailed: true,
              ),
              onActionClick: () {},
              onConfirmRedemption: () async {},
              onRetryRelatedEligibility: () => retried = true,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Some ticket eligibility could not be checked.'),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text('RETRY ELIGIBILITY CHECK'));
        await tester.pump();
        await tester.tap(find.text('RETRY ELIGIBILITY CHECK'));
        expect(retried, isTrue);
      },
    );

    testWidgets('redemption-in-progress state disables confirmation', (
      WidgetTester tester,
    ) async {
      const scan = ScanModel(
        id: 'scan-pending',
        time: '10:00 AM',
        name: 'Attendee Name',
        ticketId: 'TICKET-1',
        pass: 'General',
        benefit: 'Food',
        counter: 'Food Counter 01',
        outcome: Outcome.ready,
        attendeeId: 1,
        addonId: 2,
        counterId: 3,
        orderId: 'ORDER-1',
        orderTickets: [
          AttendeeModel(
            ticketId: 'TICKET-2',
            name: 'Related attendee',
            ticketType: 'General',
            benefits: [],
            addonId: 2,
            isEligible: true,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: OutcomeResultScreen(
            scan: scan,
            onActionClick: () {},
            onConfirmRedemption: () async {},
            onToggleRelatedTicket: (_) {
              fail('Related tickets must not navigate during redemption.');
            },
            isConfirming: true,
          ),
        ),
      );

      expect(find.text('Redemption in progress'), findsOneWidget);
      expect(find.text('PROCESSING REDEMPTIONS...'), findsOneWidget);
      final actionButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).first,
      );
      expect(actionButton.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final relatedSelectionButton = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton).last,
      );
      expect(relatedSelectionButton.onPressed, isNull);
    });

    testWidgets('result layout handles small and large viewports', (
      WidgetTester tester,
    ) async {
      const sizes = [Size(360, 640), Size(800, 1200)];
      const longName =
          'A very long attendee name that should wrap without clipping or overflow';
      var scanNextCount = 0;

      for (final size in sizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: size,
                textScaler: const TextScaler.linear(1.3),
              ),
              child: OutcomeResultScreen(
                scan: const ScanModel(
                  id: 'scan-long',
                  time: '10:00 AM',
                  name: longName,
                  ticketId: 'TICKET-WITH-A-LONG-IDENTIFIER-123456789',
                  pass: 'General Admission',
                  benefit: 'Food',
                  counter: 'Food Counter 01',
                  outcome: Outcome.approved,
                  attendeeId: 1,
                  addonId: 2,
                  orderId: 'ORDER-1',
                  orderTickets: [
                    AttendeeModel(
                      attendeeId: 2,
                      ticketId: 'TICKET-2',
                      name:
                          'Related attendee with a long name that wraps on a small phone viewport',
                      ticketType: 'General',
                      benefits: [],
                      addonId: 2,
                      isEligible: true,
                    ),
                    AttendeeModel(
                      attendeeId: 3,
                      ticketId: 'TICKET-3',
                      name: 'Related Attendee Three',
                      ticketType: 'VIP',
                      benefits: [],
                      addonId: 2,
                      isEligible: true,
                    ),
                  ],
                ),
                onActionClick: () => scanNextCount++,
                onConfirmRedemption: () async {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(longName), findsOneWidget);
        expect(find.text('Other Tickets in Same Order'), findsOneWidget);
        await tester.ensureVisible(find.text('Other Tickets in Same Order'));
        expect(find.byType(ExpansionTile), findsNothing);
        await tester.ensureVisible(
          find.text(
            'Related attendee with a long name that wraps on a small phone viewport',
          ),
        );
        expect(
          find.text(
            'Related attendee with a long name that wraps on a small phone viewport',
          ),
          findsOneWidget,
        );
        expect(find.text('Related Attendee Three'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('SCAN NEXT WITHOUT REDEEMING'));
        await tester.tap(find.text('SCAN NEXT WITHOUT REDEEMING'));
        expect(scanNextCount, greaterThan(0));
        expect(tester.takeException(), isNull);
      }

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('outcome states show safe next-step actions', (
      WidgetTester tester,
    ) async {
      const cases = [
        (Outcome.approved, 'REDEEMED'),
        (Outcome.redeemed, 'REDEEMED'),
        (Outcome.notEligible, 'Not eligible'),
        (Outcome.invalid, 'Ticket not recognized'),
        (Outcome.network, 'Verification uncertain'),
      ];

      for (final (outcome, title) in cases) {
        await tester.pumpWidget(
          MaterialApp(
            home: OutcomeResultScreen(
              scan: ScanModel(
                id: 'scan-${outcome.name}',
                time: '10:00 AM',
                name: 'Attendee Name',
                ticketId: 'TICKET-1',
                pass: 'General',
                benefit: 'Food',
                counter: 'Food Counter 01',
                outcome: outcome,
                attendeeId: outcome == Outcome.invalid ? null : 1,
                orderId: 'O7',
                volunteerName: 'Rahul Sharma (Nagpur)',
                statusMessage: 'State detail',
                previousRedemptionAt: outcome == Outcome.redeemed
                    ? '2026-10-19T14:30:00Z'
                    : null,
                previousRedemptionCounter: outcome == Outcome.redeemed
                    ? 'C02'
                    : null,
                previousRedemptionVolunteer: outcome == Outcome.redeemed
                    ? 'VOL-007'
                    : null,
              ),
              onActionClick: () {},
              onConfirmRedemption: () async {},
              onRetryVerification: outcome == Outcome.network
                  ? () async {}
                  : null,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(title), findsOneWidget);
        expect(find.text('SCAN NEXT TICKET'), findsOneWidget);
        expect(find.text('CONFIRM FOOD REDEMPTION'), findsNothing);
        expect(find.text('Order'), findsNothing);
        expect(find.text('Volunteer'), findsNothing);
        expect(find.text('Counter'), findsNothing);
        expect(find.text('O7'), findsNothing);
        expect(find.text('Rahul Sharma (Nagpur)'), findsNothing);
        if (outcome == Outcome.network) {
          expect(find.text('VERIFY THIS TICKET AGAIN'), findsOneWidget);
        }
        if (outcome == Outcome.redeemed) {
          expect(find.text('C02'), findsNothing);
          expect(find.text('VOL-007'), findsOneWidget);
          expect(find.text('Redeemed on'), findsOneWidget);
        }
        if (outcome == Outcome.approved) {
          expect(find.text('Recorded by'), findsNothing);
        }
        expect(tester.takeException(), isNull);
      }
    });

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

    test(
      'redemptionHistoryNotifier clear method empties history on logout',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(redemptionHistoryProvider.notifier).clear();
        final state = container.read(redemptionHistoryProvider);
        expect(state.value, isEmpty);
      },
    );

    testWidgets(
      'RedemptionHistoryScreen displays empty state when no redemptions exist',
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
        expect(
          find.text(
            'Redemption transactions recorded at this counter will appear here.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'RedemptionHistoryScreen displays data correctly without duplicating items',
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
              return TestRedemptionHistoryNotifier(
                const AsyncValue.data([scan1]),
              );
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
      },
    );
  });
}
