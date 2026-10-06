import 'dart:async';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/app_models.dart';
import 'widgets/tedx_components.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/counter_assignment_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/attendee_verification_screen.dart';
import 'screens/success_redemption_screen.dart';
import 'screens/attendee_details_screen.dart';
import 'screens/redemption_history_screen.dart';

void main() {
  runApp(const TEDxEventOpsApp());
}

class TEDxEventOpsApp extends StatelessWidget {
  const TEDxEventOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEDx Nagpur 2026',
      debugShowCheckedModeBanner: false,
      theme: TEDxTheme.darkTheme,
      home: const VolunteerWorkspace(),
    );
  }
}

class VolunteerWorkspace extends StatefulWidget {
  const VolunteerWorkspace({super.key});

  @override
  State<VolunteerWorkspace> createState() => _VolunteerWorkspaceState();
}

class _VolunteerWorkspaceState extends State<VolunteerWorkspace> {
  String _screen = 'login'; // login, counter, dashboard, scanner, verifying, history, detail, or outcome name
  CounterKey _counterKey = CounterKey.food;

  final Map<CounterKey, int> _addedCount = {
    CounterKey.food: 0,
    CounterKey.merch: 0,
  };

  List<ScanModel> _history = [
    const ScanModel(
      id: 'scan-3',
      time: '01:47 PM',
      name: 'Rushikesh Korde',
      ticketId: 'TKT-92831',
      pass: 'VIP',
      benefit: 'Lunch',
      counter: 'Food Counter 01',
      outcome: Outcome.redeemed,
    ),
    const ScanModel(
      id: 'scan-2',
      time: '01:44 PM',
      name: 'Nehal Mehta',
      ticketId: 'TKT-92842',
      pass: 'Premium',
      benefit: 'Lunch',
      counter: 'Food Counter 01',
      outcome: Outcome.approved,
    ),
    const ScanModel(
      id: 'scan-1',
      time: '01:42 PM',
      name: 'Rushikesh Korde',
      ticketId: 'TKT-92831',
      pass: 'VIP',
      benefit: 'Lunch',
      counter: 'Food Counter 01',
      outcome: Outcome.approved,
    ),
  ];

  ScanModel? _result;
  ScanModel? _pending;
  Timer? _verifyingTimer;

  @override
  void dispose() {
    _verifyingTimer?.cancel();
    super.dispose();
  }

  CounterInfo get _activeCounter => CounterInfo.fromKey(_counterKey);

  void _simulateScan(Outcome targetOutcome, CounterKey? scenarioCounterKey) {
    if (_screen == 'verifying') return;

    final targetCounterKey = scenarioCounterKey ?? _counterKey;
    final selectedCounter = CounterInfo.fromKey(targetCounterKey);

    final String name = targetOutcome == Outcome.not_eligible ? 'Aarav Sharma' : 'Rushikesh Korde';
    final String ticketId = targetOutcome == Outcome.not_eligible ? 'TKT-92804' : 'TKT-92831';
    final String pass = targetOutcome == Outcome.not_eligible ? 'GENERAL' : 'VIP';

    final duplicate = _history.any(
      (scan) =>
          scan.outcome == Outcome.approved &&
          scan.ticketId == ticketId &&
          scan.benefit == selectedCounter.benefit &&
          scan.id.startsWith('session-'),
    );

    final finalOutcome = (targetOutcome == Outcome.approved && duplicate)
        ? Outcome.redeemed
        : targetOutcome;

    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    final formattedTime = '${hour.toString().padLeft(2, '0')}:$minute $amPm';

    final scan = ScanModel(
      id: 'session-${DateTime.now().millisecondsSinceEpoch}',
      time: formattedTime,
      name: name,
      ticketId: ticketId,
      pass: pass,
      benefit: selectedCounter.benefit,
      counter: selectedCounter.name,
      outcome: finalOutcome,
    );

    setState(() {
      _counterKey = targetCounterKey;
      _pending = scan;
      _screen = 'verifying';
    });

    _verifyingTimer?.cancel();
    _verifyingTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted || _pending == null) return;
      final pendingScan = _pending!;
      setState(() {
        _result = pendingScan;
        if (pendingScan.outcome != Outcome.network) {
          _history = [pendingScan, ..._history];
        }
        if (pendingScan.outcome == Outcome.approved) {
          _addedCount[_counterKey] = (_addedCount[_counterKey] ?? 0) + 1;
        }
        _screen = pendingScan.outcome.name;
        _pending = null;
      });
    });
  }

  void _showScreenSwitcherSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: TEDxColors.cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.85,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: TEDxColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.dashboard_customize_rounded, color: TEDxColors.tedRed),
                      SizedBox(width: 8),
                      Text(
                        'Direct UI Screen Switcher',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      children: [
                        _screenTile(ctx, '1. Login Screen', 'login'),
                        _screenTile(ctx, '2. Counter Assignment', 'counter'),
                        _screenTile(ctx, '3. Dashboard (Counter)', 'dashboard'),
                        _screenTile(ctx, '4. Scanner View', 'scanner'),
                        _screenTile(ctx, '5. Verifying State', 'verifying'),
                        _screenTile(ctx, '6. Outcome: Approved', 'approved'),
                        _screenTile(ctx, '7. Outcome: Already Redeemed', 'redeemed'),
                        _screenTile(ctx, '8. Outcome: Not Eligible', 'not_eligible'),
                        _screenTile(ctx, '9. Outcome: Invalid QR', 'invalid'),
                        _screenTile(ctx, '10. Outcome: Connection Lost', 'network'),
                        _screenTile(ctx, '11. Scan History', 'history'),
                        _screenTile(ctx, '12. Scan Detail View', 'detail'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _screenTile(BuildContext ctx, String label, String screenTarget) {
    final isCurrent = _screen == screenTarget;
    return ListTile(
      onTap: () {
        Navigator.pop(ctx);
        setState(() {
          if (screenTarget == 'approved' ||
              screenTarget == 'redeemed' ||
              screenTarget == 'not_eligible' ||
              screenTarget == 'invalid' ||
              screenTarget == 'network' ||
              screenTarget == 'detail') {
            final outcome = Outcome.values.firstWhere(
              (e) => e.name == screenTarget,
              orElse: () => Outcome.approved,
            );
            _result = ScanModel(
              id: 'demo-sample',
              time: '01:45 PM',
              name: 'Rushikesh Korde',
              ticketId: 'TKT-92831',
              pass: 'VIP',
              benefit: _activeCounter.benefit,
              counter: _activeCounter.name,
              outcome: outcome,
            );
          }
          _screen = screenTarget;
        });
      },
      leading: Icon(
        isCurrent ? Icons.check_circle_rounded : Icons.smartphone_rounded,
        color: isCurrent ? TEDxColors.tedRed : TEDxColors.textSecondary,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isCurrent ? TEDxColors.tedRed : Colors.white,
          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showNav = _screen != 'login' && _screen != 'counter';
    final scopedHistory = _history.where((scan) => scan.counter == _activeCounter.name).toList();

    ScanModel? lastSuccess;
    if (_result != null) {
      try {
        lastSuccess = _history.firstWhere(
          (scan) =>
              scan.outcome == Outcome.approved &&
              scan.ticketId == _result!.ticketId &&
              scan.benefit == _result!.benefit,
        );
      } catch (_) {
        lastSuccess = null;
      }
    }

    Widget bodyWidget;

    if (_screen == 'login') {
      bodyWidget = LoginScreen(
        onContinue: () => setState(() => _screen = 'counter'),
      );
    } else if (_screen == 'counter') {
      bodyWidget = CounterAssignmentScreen(
        counter: _activeCounter,
        onStartScanning: () => setState(() => _screen = 'dashboard'),
      );
    } else if (_screen == 'dashboard') {
      bodyWidget = DashboardScreen(
        counter: _activeCounter,
        addedCount: _addedCount[_counterKey] ?? 0,
        recentScans: scopedHistory,
        onScanClick: () => setState(() => _screen = 'scanner'),
        onViewHistoryClick: () => setState(() => _screen = 'history'),
        onSelectScan: (scan) {
          setState(() {
            _result = scan;
            _screen = 'detail';
          });
        },
        onSwitchCounter: (key) => setState(() => _counterKey = key),
      );
    } else if (_screen == 'scanner') {
      bodyWidget = QRScannerScreen(
        counter: _activeCounter,
        totalScans: _activeCounter.total + (_addedCount[_counterKey] ?? 0),
        onSimulateScan: _simulateScan,
      );
    } else if (_screen == 'verifying') {
      bodyWidget = AttendeeVerificationScreen(counter: _activeCounter);
    } else if (_screen == 'history') {
      bodyWidget = RedemptionHistoryScreen(
        counter: _activeCounter,
        history: _history,
        onSelectScan: (scan) {
          setState(() {
            _result = scan;
            _screen = 'detail';
          });
        },
      );
    } else if (_screen == 'detail' && _result != null) {
      bodyWidget = AttendeeDetailsScreen(
        scan: _result!,
        onBackPressed: () => setState(() => _screen = 'history'),
      );
    } else if (_result != null) {
      bodyWidget = OutcomeResultScreen(
        scan: _result!,
        lastSuccess: lastSuccess,
        onActionClick: () => setState(() => _screen = 'scanner'),
      );
    } else {
      bodyWidget = DashboardScreen(
        counter: _activeCounter,
        addedCount: _addedCount[_counterKey] ?? 0,
        recentScans: scopedHistory,
        onScanClick: () => setState(() => _screen = 'scanner'),
        onViewHistoryClick: () => setState(() => _screen = 'history'),
        onSelectScan: (scan) {
          setState(() {
            _result = scan;
            _screen = 'detail';
          });
        },
        onSwitchCounter: (key) => setState(() => _counterKey = key),
      );
    }

    String activeTab = 'dashboard';
    if (_screen == 'history' || _screen == 'detail') {
      activeTab = 'history';
    } else if (_screen == 'scanner') {
      activeTab = 'scanner';
    }

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: Column(
        children: [
          const TEDxTopBar(),
          Expanded(
            child: Stack(
              children: [
                bodyWidget,

                // Floating Screen Switcher Trigger
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.extended(
                    onPressed: _showScreenSwitcherSheet,
                    backgroundColor: TEDxColors.cardDark,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: TEDxColors.tedRed, width: 1.5),
                    ),
                    icon: const Icon(Icons.layers_rounded, color: TEDxColors.tedRed, size: 18),
                    label: const Text(
                      'All Screens',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: showNav
          ? Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: TEDxColors.cardBorder, width: 1)),
              ),
              child: BottomNavigationBar(
                currentIndex: activeTab == 'dashboard' ? 0 : (activeTab == 'scanner' ? 1 : 2),
                onTap: (index) {
                  if (_screen == 'verifying') return;
                  setState(() {
                    if (index == 0) {
                      _screen = 'dashboard';
                    } else if (index == 1) {
                      _screen = 'scanner';
                    } else {
                      _screen = 'history';
                    }
                  });
                },
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.meeting_room_outlined),
                    activeIcon: Icon(Icons.meeting_room_rounded),
                    label: 'Counter',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: activeTab == 'scanner' ? TEDxColors.tedRed : TEDxColors.tedRedSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: activeTab == 'scanner' ? Colors.white : TEDxColors.tedRed,
                        size: 20,
                      ),
                    ),
                    label: 'Scan',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.history_rounded),
                    label: 'History',
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
