import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'models/app_models.dart';
import 'widgets/tedx_components.dart';
import 'services/api_service.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/counter_assignment_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/attendee_verification_screen.dart';
import 'screens/success_redemption_screen.dart';
import 'screens/attendee_details_screen.dart';
import 'screens/redemption_history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
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
  String _screen = 'login'; // login, counter, dashboard, scanner, verifying, history, detail, outcome
  CounterKey _counterKey = CounterKey.food;

  final Map<CounterKey, int> _addedCount = {
    CounterKey.food: 0,
    CounterKey.merch: 0,
  };

  List<ScanModel> _history = [];

  ScanModel? _result;
  Timer? _verifyingTimer;

  @override
  void dispose() {
    _verifyingTimer?.cancel();
    super.dispose();
  }

  CounterInfo get _activeCounter => CounterInfo.fromKey(_counterKey);

  Future<void> _handleScanToken(String qrToken) async {
    if (_screen == 'verifying') return;

    final selectedCounter = _activeCounter;
    final tokenClean = qrToken.trim();

    setState(() {
      _screen = 'verifying';
    });

    Outcome outcome = Outcome.approved;
    String name = 'Attendee';
    String ticketId = tokenClean.toUpperCase();
    String pass = 'VIP';
    int? attendeeId;
    int? addonId;
    int counterId = ApiService().assignedCounterId ?? (_counterKey == CounterKey.food ? 2 : 3);

    try {
      final res = await ApiService().verifyQR(tokenClean);
      if (res.containsKey('attendee') && res['attendee'] != null) {
        final att = res['attendee'] as Map<String, dynamic>;
        attendeeId = att['id'] as int?;
        name = att['name']?.toString() ?? name;
        ticketId = att['ticket_id']?.toString() ?? ticketId;
        pass = att['ticket_type']?.toString() ?? pass;
        outcome = Outcome.approved;

        if (res.containsKey('entitlements') && res['entitlements'] is List) {
          final ents = res['entitlements'] as List<dynamic>;
          bool foundCounterEntitlement = false;

          for (final e in ents) {
            final item = e as Map<String, dynamic>;
            final addonName = (item['name'] ?? item['addon_name'] ?? '').toString().toUpperCase();
            final addonIdVal = item['addon_id'] as int?;
            final remainingQty = (item['remaining_quantity'] as int?) ?? (item['is_redeemed'] == true ? 0 : 1);
            final claimedQty = (item['claimed_quantity'] as int?) ?? 0;

            final isFoodCounter = _counterKey == CounterKey.food;
            final isMerchCounter = _counterKey == CounterKey.merch;

            final isFoodAddon = addonName.contains('FOOD') || addonName.contains('LUNCH') || addonIdVal == 1;
            final isMerchAddon = addonName.contains('SHIRT') || addonName.contains('MERCH') || addonIdVal == 2;

            if ((isFoodCounter && isFoodAddon) || (isMerchCounter && isMerchAddon)) {
              foundCounterEntitlement = true;
              addonId = addonIdVal ?? (isFoodCounter ? 1 : 2);

              if (remainingQty <= 0 || claimedQty > 0 || item['is_redeemed'] == true) {
                outcome = Outcome.redeemed;
              } else {
                outcome = Outcome.approved;
              }
              break;
            }
          }

          if (!foundCounterEntitlement) {
            outcome = Outcome.not_eligible;
          }
        }

        // If eligible and valid IDs are present, execute backend claim redemption
        if (outcome == Outcome.approved && attendeeId != null && addonId != null) {
          try {
            final claimRes = await ApiService().claimRedemption(
              attendeeId: attendeeId,
              addonId: addonId,
              counterId: counterId,
            );
            if (claimRes['success'] == true) {
              outcome = Outcome.approved;
            }
          } catch (claimErr) {
            debugPrint('[CLAIM REDEMPTION ERROR] $claimErr');
            final errStr = claimErr.toString();
            if (errStr.contains('409') || errStr.contains('ALREADY_CLAIMED')) {
              outcome = Outcome.redeemed;
            } else if (errStr.contains('COUNTER_UNAUTHORIZED')) {
              final fallbackCounterId = ApiService().assignedCounterId ?? 2;
              try {
                final retryRes = await ApiService().claimRedemption(
                  attendeeId: attendeeId,
                  addonId: addonId,
                  counterId: fallbackCounterId,
                );
                if (retryRes['success'] == true) {
                  outcome = Outcome.approved;
                }
              } catch (retryErr) {
                if (retryErr.toString().contains('409') || retryErr.toString().contains('ALREADY_CLAIMED')) {
                  outcome = Outcome.redeemed;
                } else {
                  outcome = Outcome.not_eligible;
                }
              }
            } else if (errStr.contains('403') || errStr.contains('NOT_ELIGIBLE')) {
              outcome = Outcome.not_eligible;
            }
          }
        }
      } else if (res['error'] == 'INVALID_QR') {
        outcome = Outcome.invalid;
      }
    } catch (e) {
      debugPrint('[VERIFY QR ERROR] $e');
      final errStr = e.toString();
      if (errStr.contains('404') || errStr.contains('INVALID_QR')) {
        outcome = Outcome.invalid;
        name = 'Unknown';
        ticketId = 'INVALID';
        pass = 'NONE';
      } else if (errStr.contains('403') || errStr.contains('NOT_ELIGIBLE')) {
        outcome = Outcome.not_eligible;
      } else if (errStr.contains('409') || errStr.contains('ALREADY_CLAIMED')) {
        outcome = Outcome.redeemed;
      } else {
        outcome = Outcome.invalid;
        name = 'Unknown';
        ticketId = 'INVALID';
        pass = 'NONE';
      }
    }

    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    final formattedTime = '${hour.toString().padLeft(2, '0')}:$minute $amPm';

    final scan = ScanModel(
      id: 'scan-${DateTime.now().millisecondsSinceEpoch}',
      time: formattedTime,
      name: name,
      ticketId: ticketId,
      pass: pass,
      benefit: selectedCounter.benefit,
      counter: selectedCounter.name,
      outcome: outcome,
      attendeeId: attendeeId,
      addonId: addonId,
      counterId: counterId,
    );

    if (!mounted) return;
    setState(() {
      _result = scan;
      if (scan.outcome != Outcome.network && scan.outcome != Outcome.invalid) {
        _history = [scan, ..._history];
      }
      if (scan.outcome == Outcome.approved) {
        _addedCount[_counterKey] = (_addedCount[_counterKey] ?? 0) + 1;
      }
      _screen = 'outcome';
    });
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
        onScanToken: _handleScanToken,
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
    } else if (_screen == 'outcome' && _result != null) {
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
    } else if (_screen == 'scanner' || _screen == 'verifying' || _screen == 'outcome') {
      activeTab = 'scanner';
    }

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: Column(
        children: [
          if (_screen == 'login') const TEDxTopBar(),
          Expanded(
            child: bodyWidget,
          ),
        ],
      ),
      bottomNavigationBar: showNav
          ? Container(
              padding: const EdgeInsets.only(top: 0, bottom: 8),
              decoration: const BoxDecoration(
                color: TEDxColors.bgDark,
                border: Border(top: BorderSide(color: Color(0xFF1F1F23), width: 1)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      // Counter Tab
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (_screen != 'verifying') setState(() => _screen = 'dashboard');
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 2,
                                width: 36,
                                color: activeTab == 'dashboard' ? TEDxColors.tedRed : Colors.transparent,
                              ),
                              const Spacer(),
                              Text(
                                'Counter',
                                style: AppFonts.body(
                                  color: activeTab == 'dashboard' ? Colors.white : const Color(0xFF71717A),
                                  fontSize: 13,
                                  fontWeight: activeTab == 'dashboard' ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ),

                      // Scan Tab
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (_screen != 'verifying') setState(() => _screen = 'scanner');
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 2,
                                width: 36,
                                color: activeTab == 'scanner' ? TEDxColors.tedRed : Colors.transparent,
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner_rounded,
                                    size: 16,
                                    color: activeTab == 'scanner' ? Colors.white : const Color(0xFF71717A),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Scan',
                                    style: AppFonts.body(
                                      color: activeTab == 'scanner' ? Colors.white : const Color(0xFF71717A),
                                      fontSize: 13,
                                      fontWeight: activeTab == 'scanner' ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ),

                      // History Tab
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (_screen != 'verifying') setState(() => _screen = 'history');
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 2,
                                width: 36,
                                color: activeTab == 'history' ? TEDxColors.tedRed : Colors.transparent,
                              ),
                              const Spacer(),
                              Text(
                                'History',
                                style: AppFonts.body(
                                  color: activeTab == 'history' ? Colors.white : const Color(0xFF71717A),
                                  fontSize: 13,
                                  fontWeight: activeTab == 'history' ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

extension StringExtension on String {
  String take(int n) {
    if (length <= n) return this;
    return substring(0, n);
  }
}
