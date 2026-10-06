import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/app_models.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/counter_assignment_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/attendee_verification_screen.dart';
import 'screens/success_redemption_screen.dart';
import 'screens/already_claimed_screen.dart';
import 'screens/not_eligible_screen.dart';
import 'screens/attendee_details_screen.dart';
import 'screens/redemption_history_screen.dart';
import 'screens/counter_statistics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/confirmation_modal.dart';
import 'screens/network_error_screen.dart';
import 'screens/session_expired_screen.dart';

void main() {
  runApp(const TEDxEventOpsApp());
}

class TEDxEventOpsApp extends StatelessWidget {
  const TEDxEventOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEDx Event Ops',
      debugShowCheckedModeBanner: false,
      theme: TEDxTheme.darkTheme,
      home: const MainNavigationController(),
    );
  }
}

enum AppStateView {
  splash, // 1
  login, // 2
  counterAssignment, // 3
  dashboard, // 4 (Main Shell)
  qrScanner, // 5
  verification, // 6
  successRedemption, // 7
  alreadyClaimed, // 8
  notEligible, // 9
  attendeeDetails, // 10
  redemptionHistory, // 11
  counterStatistics, // 12
  profile, // 13
  networkError, // 15
  sessionExpired, // 16
}

class MainNavigationController extends StatefulWidget {
  const MainNavigationController({super.key});

  @override
  State<MainNavigationController> createState() => _MainNavigationControllerState();
}

class _MainNavigationControllerState extends State<MainNavigationController> {
  AppStateView _currentView = AppStateView.splash;
  int _bottomNavIndex = 0; // 0: Home, 1: Scan, 2: History, 3: Profile

  // Active Volunteer State
  VolunteerModel _volunteer = const VolunteerModel(
    id: 'VOL-024',
    name: 'Rushikesh Korde',
    role: 'Counter Volunteer',
    counterId: 'C-03',
    counterName: 'T-Shirt Counter',
    eventName: 'TEDx YCCE 2026',
    avatarInitials: 'RK',
  );

  // Counter Statistics
  CounterStats _stats = const CounterStats(
    totalScans: 248,
    successfulClaims: 192,
    alreadyClaimed: 31,
    notEligible: 25,
    itemGoal: 500,
  );

  // Mock Attendees
  final Map<String, AttendeeModel> _attendeeDb = {
    'TDX-2026-10482': const AttendeeModel(
      ticketId: 'TDX-2026-10482',
      name: 'Rahul Sharma',
      email: 'rahul.sharma@example.com',
      phone: '+91 98765 43210',
      ticketType: 'PREMIUM',
      entitlements: [
        EntitlementItem(
          id: '1',
          name: 'Food',
          state: EntitlementState.claimed,
          claimedTime: '09:15 AM',
          claimedCounter: 'C-01',
        ),
        EntitlementItem(
          id: '2',
          name: 'Goodie Bag',
          state: EntitlementState.claimed,
          claimedTime: '09:20 AM',
          claimedCounter: 'C-02',
        ),
        EntitlementItem(
          id: '3',
          name: 'T-Shirt',
          state: EntitlementState.available,
        ),
        EntitlementItem(
          id: '4',
          name: 'VIP Workshop',
          state: EntitlementState.notIncluded,
        ),
      ],
    ),
    'TDX-2026-CLAIMED': const AttendeeModel(
      ticketId: 'TDX-2026-CLAIMED',
      name: 'Rahul Sharma',
      email: 'rahul.sharma@example.com',
      phone: '+91 98765 43210',
      ticketType: 'PREMIUM',
      entitlements: [
        EntitlementItem(
          id: '3',
          name: 'T-Shirt',
          state: EntitlementState.claimed,
          claimedTime: '10:42 AM',
          claimedCounter: 'C-03',
        ),
      ],
    ),
    'TDX-2026-NOT-ELIGIBLE': const AttendeeModel(
      ticketId: 'TDX-2026-NOT-ELIGIBLE',
      name: 'Sneha Joshi',
      email: 'sneha.j@example.com',
      phone: '+91 98123 45678',
      ticketType: 'STANDARD',
      entitlements: [
        EntitlementItem(id: '1', name: 'Food', state: EntitlementState.claimed),
        EntitlementItem(
            id: '3', name: 'T-Shirt', state: EntitlementState.notIncluded),
      ],
    ),
  };

  late AttendeeModel _currentAttendee;

  // History Logs
  final List<HistoryLogItem> _historyLogs = [
    const HistoryLogItem(
      id: 'L-101',
      attendeeName: 'Rahul Sharma',
      ticketId: 'TDX-2026-10482',
      item: 'T-Shirt',
      time: '10:42 AM',
      status: RedemptionStatus.success,
      counterId: 'C-03',
      volunteerId: 'VOL-024',
    ),
    const HistoryLogItem(
      id: 'L-102',
      attendeeName: 'Amit Patil',
      ticketId: 'TDX-2026-10483',
      item: 'T-Shirt',
      time: '10:44 AM',
      status: RedemptionStatus.success,
      counterId: 'C-03',
      volunteerId: 'VOL-024',
    ),
    const HistoryLogItem(
      id: 'L-103',
      attendeeName: 'Sneha Joshi',
      ticketId: 'TDX-2026-10484',
      item: 'T-Shirt',
      time: '10:48 AM',
      status: RedemptionStatus.alreadyClaimed,
      counterId: 'C-03',
      volunteerId: 'VOL-014',
    ),
    const HistoryLogItem(
      id: 'L-104',
      attendeeName: 'Priya Nair',
      ticketId: 'TDX-2026-10485',
      item: 'T-Shirt',
      time: '10:52 AM',
      status: RedemptionStatus.notEligible,
      counterId: 'C-03',
      volunteerId: 'VOL-024',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentAttendee = _attendeeDb['TDX-2026-10482']!;
  }

  void _processScannedCode(String scannedId) {
    if (scannedId == 'TDX-2026-CLAIMED') {
      setState(() {
        _currentAttendee = _attendeeDb['TDX-2026-CLAIMED']!;
        _currentView = AppStateView.alreadyClaimed;
      });
    } else if (scannedId == 'TDX-2026-NOT-ELIGIBLE') {
      setState(() {
        _currentAttendee = _attendeeDb['TDX-2026-NOT-ELIGIBLE']!;
        _currentView = AppStateView.notEligible;
      });
    } else {
      final attendee = _attendeeDb[scannedId] ?? _attendeeDb['TDX-2026-10482']!;
      setState(() {
        _currentAttendee = attendee;
        _currentView = AppStateView.verification;
      });
    }
  }

  void _onConfirmClaimAction() async {
    final confirmed = await ConfirmationModal.show(
      context,
      attendeeName: _currentAttendee.name,
      ticketType: _currentAttendee.ticketType,
      item: _volunteer.counterName.replaceAll(' Counter', ''),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _stats = CounterStats(
          totalScans: _stats.totalScans + 1,
          successfulClaims: _stats.successfulClaims + 1,
          alreadyClaimed: _stats.alreadyClaimed,
          notEligible: _stats.notEligible,
          itemGoal: _stats.itemGoal,
        );
        _currentView = AppStateView.successRedemption;
      });
    }
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
          initialChildSize: 0.7,
          maxChildSize: 0.9,
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
                        'Direct 16-Screen Preview Navigator',
                        style: TextStyle(
                          color: TEDxColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select any of the 16 required screens to test immediately:',
                    style: TextStyle(color: TEDxColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      children: [
                        _screenTile(ctx, '1. Splash Screen', AppStateView.splash),
                        _screenTile(ctx, '2. Volunteer Login', AppStateView.login),
                        _screenTile(ctx, '3. Counter Assignment', AppStateView.counterAssignment),
                        _screenTile(ctx, '4. Volunteer Dashboard', AppStateView.dashboard, navTab: 0),
                        _screenTile(ctx, '5. QR Scanner Screen', AppStateView.qrScanner),
                        _screenTile(ctx, '6. Attendee Verification', AppStateView.verification),
                        _screenTile(ctx, '7. Successful Redemption', AppStateView.successRedemption),
                        _screenTile(ctx, '8. Already Claimed Screen', AppStateView.alreadyClaimed),
                        _screenTile(ctx, '9. Not Eligible Screen', AppStateView.notEligible),
                        _screenTile(ctx, '10. Attendee Details Screen', AppStateView.attendeeDetails),
                        _screenTile(ctx, '11. Redemption History', AppStateView.redemptionHistory, navTab: 2),
                        _screenTile(ctx, '12. Counter Statistics', AppStateView.counterStatistics),
                        _screenTile(ctx, '13. Volunteer Profile', AppStateView.profile, navTab: 3),
                        ListTile(
                          onTap: () {
                            Navigator.pop(ctx);
                            _onConfirmClaimAction();
                          },
                          leading: const Icon(Icons.touch_app_rounded, color: TEDxColors.tedRed, size: 20),
                          title: const Text('14. Confirmation Modal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: const Text('Triggers bottom sheet modal', style: TextStyle(color: TEDxColors.textMuted, fontSize: 11)),
                        ),
                        _screenTile(ctx, '15. Network Error State', AppStateView.networkError),
                        _screenTile(ctx, '16. Session Expired State', AppStateView.sessionExpired),
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

  Widget _screenTile(BuildContext ctx, String name, AppStateView view, {int navTab = 0}) {
    final isCurrent = _currentView == view;
    return ListTile(
      onTap: () {
        Navigator.pop(ctx);
        setState(() {
          _currentView = view;
          _bottomNavIndex = navTab;
        });
      },
      leading: Icon(
        isCurrent ? Icons.check_circle_rounded : Icons.smartphone_rounded,
        color: isCurrent ? TEDxColors.tedRed : TEDxColors.textSecondary,
        size: 20,
      ),
      title: Text(
        name,
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
    Widget bodyWidget;
    bool showBottomBar = false;

    switch (_currentView) {
      case AppStateView.splash:
        bodyWidget = SplashScreen(
          onFinish: () => setState(() => _currentView = AppStateView.login),
        );
        break;

      case AppStateView.login:
        bodyWidget = LoginScreen(
          onLoginSuccess: () => setState(() => _currentView = AppStateView.counterAssignment),
        );
        break;

      case AppStateView.counterAssignment:
        bodyWidget = CounterAssignmentScreen(
          onStartCounter: () => setState(() {
            _currentView = AppStateView.dashboard;
            _bottomNavIndex = 0;
          }),
        );
        break;

      case AppStateView.dashboard:
        showBottomBar = true;
        if (_bottomNavIndex == 0) {
          bodyWidget = DashboardScreen(
            volunteer: _volunteer,
            stats: _stats,
            onOpenScanner: () => setState(() => _currentView = AppStateView.qrScanner),
            onTabSelected: (index) => setState(() => _bottomNavIndex = index),
            onOpenProfile: () => setState(() {
              _currentView = AppStateView.profile;
              _bottomNavIndex = 3;
            }),
            onOpenStats: () => setState(() => _currentView = AppStateView.counterStatistics),
          );
        } else if (_bottomNavIndex == 1) {
          bodyWidget = QRScannerScreen(
            volunteer: _volunteer,
            onClose: () => setState(() => _bottomNavIndex = 0),
            onScanComplete: _processScannedCode,
          );
        } else if (_bottomNavIndex == 2) {
          bodyWidget = RedemptionHistoryScreen(
            logs: _historyLogs,
            onItemTap: (log) {
              setState(() {
                _currentAttendee = _attendeeDb['TDX-2026-10482']!;
                _currentView = AppStateView.attendeeDetails;
              });
            },
          );
        } else {
          bodyWidget = ProfileScreen(
            volunteer: _volunteer,
            onLogout: () => setState(() => _currentView = AppStateView.login),
            onSwitchCounter: () => setState(() => _currentView = AppStateView.counterAssignment),
            onTriggerOfflineDemo: () => setState(() => _currentView = AppStateView.networkError),
            onTriggerExpiredDemo: () => setState(() => _currentView = AppStateView.sessionExpired),
          );
        }
        break;

      case AppStateView.qrScanner:
        bodyWidget = QRScannerScreen(
          volunteer: _volunteer,
          onClose: () => setState(() => _currentView = AppStateView.dashboard),
          onScanComplete: _processScannedCode,
        );
        break;

      case AppStateView.verification:
        bodyWidget = AttendeeVerificationScreen(
          attendee: _currentAttendee,
          currentCounterItem: 'T-Shirt',
          onConfirmClaim: _onConfirmClaimAction,
          onCancel: () => setState(() => _currentView = AppStateView.qrScanner),
          onViewFullProfile: () => setState(() => _currentView = AppStateView.attendeeDetails),
        );
        break;

      case AppStateView.successRedemption:
        bodyWidget = SuccessRedemptionScreen(
          attendeeName: _currentAttendee.name,
          ticketType: _currentAttendee.ticketType,
          item: 'T-Shirt',
          time: '10:42 AM',
          counterId: _volunteer.counterId,
          onScanNext: () => setState(() => _currentView = AppStateView.qrScanner),
          onViewDetails: () => setState(() => _currentView = AppStateView.attendeeDetails),
        );
        break;

      case AppStateView.alreadyClaimed:
        bodyWidget = AlreadyClaimedScreen(
          attendeeName: _currentAttendee.name,
          item: 'T-Shirt',
          claimedTime: '10:42 AM',
          counterId: _volunteer.counterId,
          volunteerId: 'VOL-014',
          onScanNext: () => setState(() => _currentView = AppStateView.qrScanner),
        );
        break;

      case AppStateView.notEligible:
        bodyWidget = NotEligibleScreen(
          attendeeName: _currentAttendee.name,
          ticketType: _currentAttendee.ticketType,
          item: 'T-Shirt',
          message: 'This item is not included in the attendee\'s ticket. Standard tickets only include Food & Goodie Bag.',
          onScanNext: () => setState(() => _currentView = AppStateView.qrScanner),
        );
        break;

      case AppStateView.attendeeDetails:
        bodyWidget = AttendeeDetailsScreen(
          attendee: _currentAttendee,
          onBackPressed: () => setState(() => _currentView = AppStateView.dashboard),
        );
        break;

      case AppStateView.redemptionHistory:
        bodyWidget = RedemptionHistoryScreen(
          logs: _historyLogs,
          onItemTap: (log) => setState(() => _currentView = AppStateView.attendeeDetails),
        );
        break;

      case AppStateView.counterStatistics:
        bodyWidget = CounterStatisticsScreen(
          volunteer: _volunteer,
          stats: _stats,
          onBackPressed: () => setState(() => _currentView = AppStateView.dashboard),
        );
        break;

      case AppStateView.profile:
        bodyWidget = ProfileScreen(
          volunteer: _volunteer,
          onLogout: () => setState(() => _currentView = AppStateView.login),
          onSwitchCounter: () => setState(() => _currentView = AppStateView.counterAssignment),
          onTriggerOfflineDemo: () => setState(() => _currentView = AppStateView.networkError),
          onTriggerExpiredDemo: () => setState(() => _currentView = AppStateView.sessionExpired),
        );
        break;

      case AppStateView.networkError:
        bodyWidget = NetworkErrorScreen(
          onRetry: () => setState(() => _currentView = AppStateView.dashboard),
          onBackToScanner: () => setState(() => _currentView = AppStateView.qrScanner),
        );
        break;

      case AppStateView.sessionExpired:
        bodyWidget = SessionExpiredScreen(
          onSignIn: () => setState(() => _currentView = AppStateView.login),
        );
        break;
    }

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: Stack(
        children: [
          bodyWidget,

          // Global Floating Quick Screen Switcher Trigger Button
          Positioned(
            bottom: showBottomBar ? 76 : 16,
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
                '16 Screens',
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
      bottomNavigationBar: showBottomBar
          ? Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: TEDxColors.cardBorder, width: 1),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _bottomNavIndex,
                onTap: (index) {
                  setState(() {
                    _bottomNavIndex = index;
                    if (index == 1) {
                      _currentView = AppStateView.qrScanner;
                    } else if (index == 2) {
                      _currentView = AppStateView.redemptionHistory;
                    } else if (index == 3) {
                      _currentView = AppStateView.profile;
                    } else {
                      _currentView = AppStateView.dashboard;
                    }
                  });
                },
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_filled),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _bottomNavIndex == 1
                            ? TEDxColors.tedRed
                            : TEDxColors.tedRedSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: _bottomNavIndex == 1
                            ? Colors.white
                            : TEDxColors.tedRed,
                        size: 22,
                      ),
                    ),
                    label: 'Scan',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.history_rounded),
                    label: 'History',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
