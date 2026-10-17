import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ticketingapp/main.dart';
import 'package:ticketingapp/models/app_models.dart';
import 'package:ticketingapp/screens/counter_assignment_screen.dart';
import 'package:ticketingapp/screens/dashboard_screen.dart';
import 'package:ticketingapp/screens/login_screen.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('TEDx Nagpur 2026 app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TEDxEventOpsApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Volunteer sign in'), findsOneWidget);
  });

  testWidgets('Login credential field accepts an alphanumeric password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen(onContinue: () {})));

    expect(find.text('Password / PIN'), findsOneWidget);
    final passwordField = tester
        .widgetList<TextField>(find.byType(TextField))
        .last;
    expect(passwordField.keyboardType, TextInputType.visiblePassword);

    await tester.enterText(find.byType(TextField).last, 'admin123');
    expect(passwordField.controller?.text, 'admin123');
  });

  testWidgets(
    'CounterAssignmentScreen allows counter switching and confirmation',
    (WidgetTester tester) async {
      CounterInfo? selected;
      bool started = false;

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: CounterAssignmentScreen(
            counter: CounterInfo.food,
            volunteerName: 'Rahul Sharma',
            volunteerCode: 'VOL-001',
            onCounterSelected: (c) => selected = c,
            onStartScanning: () => started = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select active counter.'), findsOneWidget);
      expect(find.text('Rahul Sharma'), findsOneWidget);
      expect(find.text('CONFIRM COUNTER & START SCANNING'), findsOneWidget);

      // Tap Confirm button
      final confirmBtn = find.text('CONFIRM COUNTER & START SCANNING');
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(started, isTrue);
      expect(selected, isNotNull);
    },
  );

  testWidgets(
    'DashboardScreen displays active counter and visible Logout button',
    (WidgetTester tester) async {
      bool loggedOut = false;
      bool switched = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(
              counter: CounterInfo.food,
              volunteerName: 'Rahul Sharma',
              addedCount: 0,
              recentScans: const [],
              onScanClick: () {},
              onViewHistoryClick: () {},
              onSelectScan: (_) {},
              onLogout: () => loggedOut = true,
              onSwitchCounter: () => switched = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('COUNTER C02'), findsOneWidget);
      expect(find.text('Food Counter 01'), findsOneWidget);
      expect(find.text('LOGOUT'), findsOneWidget);
      expect(find.text('SWITCH'), findsOneWidget);

      // Tap Logout button
      await tester.tap(find.text('LOGOUT'));
      await tester.pumpAndSettle();
      expect(loggedOut, isTrue);

      // Tap Switch button
      await tester.tap(find.text('SWITCH'));
      await tester.pumpAndSettle();
      expect(switched, isTrue);
    },
  );
}
