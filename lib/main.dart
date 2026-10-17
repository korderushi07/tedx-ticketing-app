import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'models/app_models.dart';
import 'widgets/tedx_components.dart';
import 'services/api_service.dart';
import 'providers/redemption_providers.dart';

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
  runApp(const ProviderScope(child: TEDxEventOpsApp()));
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

class VolunteerWorkspace extends ConsumerStatefulWidget {
  const VolunteerWorkspace({super.key});

  @override
  ConsumerState<VolunteerWorkspace> createState() => _VolunteerWorkspaceState();
}

class _VolunteerWorkspaceState extends ConsumerState<VolunteerWorkspace> {
  String _screen =
      'loading'; // loading, login, counter, dashboard, scanner, verifying, history, detail, outcome
  CounterInfo _assignedCounter = CounterInfo.food;
  String _volunteerName = '';
  String _volunteerCode = '';
  CounterKey get _counterKey => _assignedCounter.key;

  final Map<CounterKey, int> _addedCount = {
    CounterKey.food: 0,
    CounterKey.merch: 0,
    CounterKey.goodie: 0,
    CounterKey.workshop: 0,
  };

  ScanModel? _selectedDetailScan;
  Timer? _verifyingTimer;

  @override
  void initState() {
    super.initState();
    _restoreSavedSession();
  }

  Future<void> _restoreSavedSession() async {
    try {
      final restored = await ApiService().restoreSession();
      if (!mounted) return;
      if (restored) {
        final api = ApiService();
        setState(() {
          if (api.assignedCounter != null) {
            _assignedCounter = api.assignedCounter!;
          }
          _volunteerName = api.assignedVolunteerName ?? 'Volunteer';
          _volunteerCode = api.assignedVolunteerCode ?? '';
          _screen = 'dashboard';
        });
        ref.read(redemptionHistoryProvider.notifier).refresh();
        return;
      }
    } catch (e) {
      debugPrint('[INIT SESSION ERROR] $e');
    }
    if (mounted) {
      setState(() => _screen = 'login');
    }
  }

  Future<void> _handleLogout() async {
    await ApiService().logout();
    if (!mounted) return;
    ref.read(redemptionHistoryProvider.notifier).clear();
    ref.read(currentScanProvider.notifier).clearScan();
    setState(() {
      _screen = 'login';
      _volunteerName = '';
      _volunteerCode = '';
      _addedCount.updateAll((key, val) => 0);
    });
  }

  void _handleSwitchCounter() {
    setState(() => _screen = 'counter');
  }

  @override
  void dispose() {
    _verifyingTimer?.cancel();
    super.dispose();
  }

  CounterInfo get _activeCounter => _assignedCounter;

  Future<void> _handleScanToken(String qrToken) async {
    if (_screen == 'verifying') return;

    final selectedCounter = _activeCounter;
    final tokenClean = qrToken.trim();

    setState(() {
      _screen = 'verifying';
    });

    Outcome outcome = Outcome.network;
    String name = 'Attendee';
    String ticketId = tokenClean.toUpperCase();
    String pass = 'VIP';
    int? attendeeId;
    int? addonId;
    final counterId = selectedCounter.id;
    final requiredAddonId = selectedCounter.addonId;
    if (counterId == null || requiredAddonId == null) {
      debugPrint(
        '[SCAN] Cannot process a scan without an assigned counter and add-on.',
      );
      setState(() => _screen = 'dashboard');
      return;
    }

    try {
      final res = await ApiService().verifyQR(
        tokenClean,
        counterId: counterId,
      );
      if (res.containsKey('attendee') && res['attendee'] != null) {
        final att = res['attendee'] as Map<String, dynamic>;
        attendeeId = att['id'] as int?;
        name = att['name']?.toString() ?? name;
        ticketId = att['ticket_id']?.toString() ?? ticketId;
        pass = att['ticket_type']?.toString() ?? pass;

        if (res.containsKey('entitlements') && res['entitlements'] is List) {
          final ents = res['entitlements'] as List<dynamic>;
          bool foundCounterEntitlement = false;

          for (final e in ents) {
            final item = e as Map<String, dynamic>;
            final addonIdVal = item['addon_id'] as int?;
            final remainingQty =
                (item['remaining_quantity'] as int?) ??
                (item['is_redeemed'] == true ? 0 : 1);
            final claimedQty = (item['claimed_quantity'] as int?) ?? 0;

            if (addonIdVal == requiredAddonId) {
              foundCounterEntitlement = true;
              addonId = addonIdVal;

              if (remainingQty <= 0 ||
                  claimedQty > 0 ||
                  item['is_redeemed'] == true) {
                outcome = Outcome.redeemed;
              } else {
                outcome = Outcome.approved;
              }
              break;
            }
          }

          if (!foundCounterEntitlement) {
            outcome = Outcome.notEligible;
          }
        } else {
          outcome = Outcome.network;
        }

        // If eligible and valid IDs are present, execute backend claim redemption
        if (outcome == Outcome.approved &&
            attendeeId != null &&
            addonId != null) {
          try {
            final claimRes = await ApiService().claimRedemption(
              attendeeId: attendeeId,
              addonId: addonId,
              counterId: counterId,
            );
            if (claimRes['success'] == true) {
              outcome = Outcome.approved;
              // Refresh persistent history provider in Riverpod upon successful redemption claim
              ref.read(redemptionHistoryProvider.notifier).refresh();
            } else if (claimRes['error'] == 'ALREADY_CLAIMED') {
              outcome = Outcome.redeemed;
            } else if (claimRes['error'] == 'NOT_ELIGIBLE' ||
                claimRes['error'] == 'COUNTER_UNAUTHORIZED') {
              outcome = Outcome.notEligible;
            } else {
              outcome = Outcome.network;
            }
          } catch (claimErr) {
            final errStr = claimErr.toString();
            if (errStr.contains('409') || errStr.contains('ALREADY_CLAIMED')) {
              outcome = Outcome.redeemed;
            } else if (errStr.contains('COUNTER_UNAUTHORIZED')) {
              outcome = Outcome.notEligible;
            } else if (errStr.contains('403') ||
                errStr.contains('NOT_ELIGIBLE')) {
              outcome = Outcome.notEligible;
            } else {
              outcome = Outcome.network;
            }
          }
        } else if (outcome == Outcome.approved) {
          outcome = Outcome.network;
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
        outcome = Outcome.notEligible;
      } else if (errStr.contains('409') || errStr.contains('ALREADY_CLAIMED')) {
        outcome = Outcome.redeemed;
      } else {
        outcome = Outcome.network;
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
    ref.read(currentScanProvider.notifier).setScan(scan);
    setState(() {
      if (scan.outcome == Outcome.approved) {
        _addedCount[_counterKey] = (_addedCount[_counterKey] ?? 0) + 1;
      }
      _screen = 'outcome';
    });
  }

  void _onScanNext() {
    ref.read(currentScanProvider.notifier).clearScan();
    setState(() {
      _screen = 'scanner';
    });
  }

  @override
  Widget build(BuildContext context) {
    final showNav = _screen != 'login' &&
        _screen != 'counter' &&
        _screen != 'loading';
    final historyAsync = ref.watch(redemptionHistoryProvider);
    final currentScan = ref.watch(currentScanProvider);

    final historyScans = historyAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <ScanModel>[],
    );

    final scopedHistory = historyScans
        .where((scan) => scan.counter == _activeCounter.name)
        .toList();

    ScanModel? lastSuccess;
    if (currentScan != null) {
      try {
        lastSuccess = historyScans.firstWhere(
          (scan) =>
              scan.outcome == Outcome.approved &&
              scan.ticketId == currentScan.ticketId &&
              scan.benefit == currentScan.benefit,
        );
      } catch (_) {
        lastSuccess = null;
      }
    }

    Widget bodyWidget;

    if (_screen == 'loading') {
      bodyWidget = const Center(
        child: CircularProgressIndicator(color: TEDxColors.tedRed),
      );
    } else if (_screen == 'login') {
      bodyWidget = LoginScreen(
        onContinue: () {
          final api = ApiService();
          setState(() {
            if (api.assignedCounter != null) {
              _assignedCounter = api.assignedCounter!;
            }
            _volunteerName = api.assignedVolunteerName ?? 'Volunteer';
            _volunteerCode = api.assignedVolunteerCode ?? '';
            _screen = 'counter';
          });
          ref.read(redemptionHistoryProvider.notifier).refresh();
        },
      );
    } else if (_screen == 'counter') {
      bodyWidget = CounterAssignmentScreen(
        counter: _activeCounter,
        volunteerName: _volunteerName,
        volunteerCode: _volunteerCode,
        onCounterSelected: (newCounter) {
          setState(() {
            _assignedCounter = newCounter;
          });
        },
        onStartScanning: () => setState(() => _screen = 'dashboard'),
        onBackPressed: () => setState(() => _screen = 'dashboard'),
      );
    } else if (_screen == 'dashboard') {
      bodyWidget = DashboardScreen(
        counter: _activeCounter,
        volunteerName: _volunteerName,
        addedCount: _addedCount[_counterKey] ?? 0,
        recentScans: scopedHistory,
        onScanClick: () => setState(() => _screen = 'scanner'),
        onViewHistoryClick: () => setState(() => _screen = 'history'),
        onLogout: _handleLogout,
        onSwitchCounter: _handleSwitchCounter,
        onSelectScan: (scan) {
          setState(() {
            _selectedDetailScan = scan;
            _screen = 'detail';
          });
        },
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
        onSelectScan: (scan) {
          setState(() {
            _selectedDetailScan = scan;
            _screen = 'detail';
          });
        },
      );
    } else if (_screen == 'detail' && _selectedDetailScan != null) {
      bodyWidget = AttendeeDetailsScreen(
        scan: _selectedDetailScan!,
        onBackPressed: () => setState(() => _screen = 'history'),
      );
    } else if (_screen == 'outcome' && currentScan != null) {
      bodyWidget = OutcomeResultScreen(
        scan: currentScan,
        lastSuccess: lastSuccess,
        onActionClick: _onScanNext,
      );
    } else {
      bodyWidget = DashboardScreen(
        counter: _activeCounter,
        volunteerName: _volunteerName,
        addedCount: _addedCount[_counterKey] ?? 0,
        recentScans: scopedHistory,
        onScanClick: () => setState(() => _screen = 'scanner'),
        onViewHistoryClick: () => setState(() => _screen = 'history'),
        onLogout: _handleLogout,
        onSwitchCounter: _handleSwitchCounter,
        onSelectScan: (scan) {
          setState(() {
            _selectedDetailScan = scan;
            _screen = 'detail';
          });
        },
      );
    }

    String activeTab = 'dashboard';
    if (_screen == 'history' || _screen == 'detail') {
      activeTab = 'history';
    } else if (_screen == 'scanner' ||
        _screen == 'verifying' ||
        _screen == 'outcome') {
      activeTab = 'scanner';
    }

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: Column(
        children: [
          if (_screen == 'login') const TEDxTopBar(),
          Expanded(child: bodyWidget),
        ],
      ),
      bottomNavigationBar: showNav
          ? Container(
              padding: const EdgeInsets.only(top: 0, bottom: 8),
              decoration: const BoxDecoration(
                color: TEDxColors.bgDark,
                border: Border(
                  top: BorderSide(color: Color(0xFF1F1F23), width: 1),
                ),
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
                            if (_screen != 'verifying') {
                              setState(() => _screen = 'dashboard');
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 2,
                                width: 36,
                                color: activeTab == 'dashboard'
                                    ? TEDxColors.tedRed
                                    : Colors.transparent,
                              ),
                              const Spacer(),
                              Text(
                                'Counter',
                                style: AppFonts.body(
                                  color: activeTab == 'dashboard'
                                      ? Colors.white
                                      : const Color(0xFF71717A),
                                  fontSize: 13,
                                  fontWeight: activeTab == 'dashboard'
                                      ? FontWeight.w700
                                      : FontWeight.w500,
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
                            if (_screen != 'verifying') {
                              setState(() => _screen = 'scanner');
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 2,
                                width: 36,
                                color: activeTab == 'scanner'
                                    ? TEDxColors.tedRed
                                    : Colors.transparent,
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner_rounded,
                                    size: 16,
                                    color: activeTab == 'scanner'
                                        ? Colors.white
                                        : const Color(0xFF71717A),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Scan',
                                    style: AppFonts.body(
                                      color: activeTab == 'scanner'
                                          ? Colors.white
                                          : const Color(0xFF71717A),
                                      fontSize: 13,
                                      fontWeight: activeTab == 'scanner'
                                          ? FontWeight.w700
                                          : FontWeight.w500,
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
                            if (_screen != 'verifying') {
                              ref
                                  .read(redemptionHistoryProvider.notifier)
                                  .refresh();
                              setState(() => _screen = 'history');
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 2,
                                width: 36,
                                color: activeTab == 'history'
                                    ? TEDxColors.tedRed
                                    : Colors.transparent,
                              ),
                              const Spacer(),
                              Text(
                                'History',
                                style: AppFonts.body(
                                  color: activeTab == 'history'
                                      ? Colors.white
                                      : const Color(0xFF71717A),
                                  fontSize: 13,
                                  fontWeight: activeTab == 'history'
                                      ? FontWeight.w700
                                      : FontWeight.w500,
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
