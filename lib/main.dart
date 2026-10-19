import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'models/app_models.dart';
import 'widgets/tedx_components.dart';
import 'services/api_service.dart';
import 'services/redemption_batch_service.dart';
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
  CounterInfo _assignedCounter = CounterInfo.unselected;
  String _volunteerName = '';
  String _volunteerCode = '';
  CounterKey get _counterKey => _assignedCounter.key;

  final Map<CounterKey, int> _addedCount = {
    CounterKey.unassigned: 0,
    CounterKey.food: 0,
    CounterKey.merch: 0,
    CounterKey.goodie: 0,
    CounterKey.workshop: 0,
    CounterKey.registration: 0,
  };

  ScanModel? _selectedDetailScan;
  Timer? _verifyingTimer;
  bool _isRedemptionProcessing = false;
  final Set<String> _selectedRedemptionKeys = {};

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
          _screen = api.assignedCounter == null ? 'counter' : 'dashboard';
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
    if (_screen == 'verifying' || _isRedemptionProcessing) return;

    final selectedCounter = _activeCounter;
    final tokenClean = qrToken.trim();

    setState(() {
      _screen = 'verifying';
      _selectedRedemptionKeys.clear();
    });

    Outcome outcome = Outcome.network;
    String name = 'Attendee';
    String ticketId = tokenClean.toUpperCase();
    String pass = 'VIP';
    String? orderId;
    final orderTickets = <AttendeeModel>[];
    int? attendeeId;
    int? addonId;
    String? statusMessage;
    String? previousRedemptionAt;
    String? previousRedemptionCounter;
    String? previousRedemptionVolunteer;
    String? previousRedemptionClaimant;
    final counterId = selectedCounter.id;
    final requiredAddonId = selectedCounter.addonId;
    addonId = requiredAddonId;
    if (counterId == null) {
      debugPrint('[SCAN] Cannot process a scan without a selected counter ID.');
      setState(() => _screen = 'dashboard');
      return;
    }

    try {
      final res = await ApiService().verifyQR(tokenClean, counterId: counterId);
      if (res.containsKey('attendee') && res['attendee'] != null) {
        final att = res['attendee'] as Map<String, dynamic>;
        attendeeId = att['id'] as int?;
        name = att['name']?.toString() ?? name;
        ticketId = att['ticket_id']?.toString() ?? ticketId;
        pass = att['ticket_type']?.toString() ?? pass;
        orderId = att['order_id']?.toString();

        final rawOrderTickets = res['order_tickets'];
        if (rawOrderTickets is List) {
          for (final rawTicket in rawOrderTickets) {
            if (rawTicket is! Map) continue;
            orderTickets.add(
              AttendeeModel(
                attendeeId: rawTicket['id'] as int?,
                ticketId: rawTicket['ticket_id']?.toString() ?? '',
                name: rawTicket['name']?.toString() ?? 'Attendee',
                ticketType: rawTicket['ticket_type']?.toString() ?? 'Ticket',
                benefits: const [],
              ),
            );
          }
        }

        if (requiredAddonId == null) {
          outcome = Outcome.ready;
          statusMessage = 'Ticket verified at ${selectedCounter.name}.';
        } else if (res.containsKey('entitlements') &&
            res['entitlements'] is List) {
          final ents = res['entitlements'] as List<dynamic>;
          bool foundCounterEntitlement = false;

          for (final e in ents) {
            final item = e as Map<String, dynamic>;
            final addonIdVal = item['addon_id'] as int?;
            final remainingQty = item['remaining_quantity'] as int? ?? 0;

            if (addonIdVal == requiredAddonId) {
              foundCounterEntitlement = true;
              addonId = addonIdVal;
              if (remainingQty <= 0) {
                outcome = Outcome.redeemed;
                statusMessage = 'This benefit was already redeemed.';
                previousRedemptionAt = item['claimed_at']?.toString();
                previousRedemptionCounter = item['counter_code']?.toString();
                previousRedemptionVolunteer = item['volunteer_name']
                    ?.toString();
                previousRedemptionClaimant = item['claimant_name']?.toString();
              } else {
                outcome = Outcome.ready;
                statusMessage = 'No redemption has been recorded yet.';
              }
              break;
            }
          }

          if (!foundCounterEntitlement) {
            outcome = Outcome.notEligible;
            statusMessage =
                'This ${pass.toLowerCase()} ticket does not include ${selectedCounter.benefit}.';
          }
        } else {
          outcome = Outcome.network;
          statusMessage = 'The ticket eligibility could not be verified.';
        }
      } else {
        final error = res['error']?.toString();
        statusMessage = res['message']?.toString();
        outcome = switch (error) {
          'INVALID_QR' => Outcome.invalid,
          'NOT_ELIGIBLE' => Outcome.notEligible,
          'ALREADY_CLAIMED' => Outcome.redeemed,
          _ => Outcome.network,
        };
      }
      if (outcome == Outcome.redeemed && attendeeId != null) {
        try {
          final entitlements = await ApiService().getAttendeeEntitlements(
            attendeeId,
          );
          for (final entitlement in entitlements) {
            if (entitlement is Map &&
                entitlement['addon_id'] == requiredAddonId) {
              previousRedemptionAt = entitlement['claimed_at']?.toString();
              previousRedemptionCounter = entitlement['counter_code']
                  ?.toString();
              previousRedemptionVolunteer = entitlement['volunteer_name']
                  ?.toString();
              previousRedemptionClaimant = entitlement['claimant_name']
                  ?.toString();
              break;
            }
          }
        } catch (error) {
          debugPrint('[REDEMPTION DETAILS ERROR] $error');
        }
      }
    } catch (e) {
      debugPrint('[VERIFY QR ERROR] $e');
      final errStr = e.toString();
      if (errStr.contains('INVALID_QR')) {
        outcome = Outcome.invalid;
        statusMessage = 'This QR code is not registered with TEDx.';
        name = 'Unknown';
        ticketId = 'INVALID';
        pass = 'NONE';
      } else if (errStr.contains('403') || errStr.contains('NOT_ELIGIBLE')) {
        outcome = Outcome.notEligible;
        statusMessage = 'This ticket is not eligible for this benefit.';
      } else if (errStr.contains('409') || errStr.contains('ALREADY_CLAIMED')) {
        outcome = Outcome.redeemed;
        statusMessage = 'This benefit was already redeemed.';
      } else {
        outcome = Outcome.network;
        statusMessage =
            'Ticket verification failed. Check your connection and try again.';
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
      orderId: orderId,
      volunteerName: _volunteerName,
      orderTickets: orderTickets,
      orderTicketsLoading: orderTickets.isNotEmpty && addonId != null,
      statusMessage: statusMessage,
      previousRedemptionAt: previousRedemptionAt,
      previousRedemptionCounter: previousRedemptionCounter,
      previousRedemptionVolunteer: previousRedemptionVolunteer,
      previousRedemptionClaimant: previousRedemptionClaimant,
    );

    if (!mounted) return;
    ref.read(currentScanProvider.notifier).setScan(scan);
    setState(() {
      _screen = 'outcome';
    });
    if (scan.orderTickets.isNotEmpty && scan.addonId != null) {
      unawaited(_loadOrderTicketEligibility(scan));
    }
  }

  Future<void> _loadOrderTicketEligibility(
    ScanModel scan, {
    bool retryFailedOnly = false,
  }) async {
    final pending = retryFailedOnly
        ? scan.orderTickets.where((ticket) => ticket.isEligible == null)
        : scan.orderTickets;
    if (pending.isEmpty) return;

    final current = ref.read(currentScanProvider);
    if (current?.id != scan.id) return;
    ref
        .read(currentScanProvider.notifier)
        .setScan(scan.copyWith(orderTicketsLoading: true));

    var hadFailure = false;
    final verified = await Future.wait(
      scan.orderTickets.map((ticket) async {
        if (!pending.any((item) => item.ticketId == ticket.ticketId)) {
          return ticket;
        }
        if (ticket.attendeeId == null || scan.addonId == null) {
          hadFailure = true;
          return ticket.copyWith(
            isEligible: null,
            statusMessage: 'Could not verify this ticket.',
          );
        }

        try {
          final entitlements = await ApiService().getAttendeeEntitlements(
            ticket.attendeeId!,
          );
          Map? selectedEntitlement;
          for (final entitlement in entitlements) {
            if (entitlement is Map && entitlement['addon_id'] == scan.addonId) {
              selectedEntitlement = entitlement;
              break;
            }
          }

          if (selectedEntitlement == null) {
            return ticket.copyWith(
              addonId: scan.addonId,
              isEligible: false,
              isRedeemed: false,
              statusMessage: 'This ticket does not include ${scan.benefit}.',
            );
          }

          final remaining = selectedEntitlement['remaining_quantity'];
          final isRedeemed = remaining is num
              ? remaining <= 0
              : selectedEntitlement['status'] == 'CLAIMED';
          return ticket.copyWith(
            addonId: scan.addonId,
            isEligible: !isRedeemed,
            isRedeemed: isRedeemed,
            statusMessage: isRedeemed
                ? 'Already redeemed'
                : 'Eligible for ${scan.benefit}',
            redeemedAt: selectedEntitlement['claimed_at']?.toString(),
            redeemedCounter: selectedEntitlement['counter_code']?.toString(),
            redeemedBy: selectedEntitlement['volunteer_name']?.toString(),
            claimedBy: selectedEntitlement['claimant_name']?.toString(),
          );
        } catch (error) {
          debugPrint(
            '[RELATED TICKET ELIGIBILITY ERROR] ${ticket.ticketId}: $error',
          );
          hadFailure = true;
          return ticket.copyWith(
            addonId: scan.addonId,
            isEligible: null,
            statusMessage: 'Could not verify this ticket.',
          );
        }
      }),
    );

    final latest = ref.read(currentScanProvider);
    if (!mounted || latest?.id != scan.id) return;
    ref
        .read(currentScanProvider.notifier)
        .setScan(
          latest!.copyWith(
            orderTickets: verified,
            orderTicketsLoading: false,
            orderTicketsLoadFailed: hadFailure,
          ),
        );
  }

  Future<void> _confirmRedemption(ScanModel scan) async {
    if (_isRedemptionProcessing ||
        scan.addonId == null ||
        scan.counterId == null) {
      return;
    }

    final selected = <ScanModel>[];
    if (scan.outcome == Outcome.ready &&
        scan.attendeeId != null &&
        _selectedRedemptionKeys.contains(
          _redemptionKey(scan.ticketId, scan.addonId!),
        )) {
      selected.add(scan);
    }
    for (final ticket in scan.orderTickets) {
      final key = _redemptionKey(ticket.ticketId, scan.addonId!);
      if (!_selectedRedemptionKeys.contains(key) ||
          ticket.attendeeId == null ||
          ticket.isEligible != true ||
          ticket.isRedeemed) {
        continue;
      }
      selected.add(
        scan.copyWith(
          id: '${scan.id}-${ticket.ticketId}',
          name: ticket.name,
          ticketId: ticket.ticketId,
          pass: ticket.ticketType,
          attendeeId: ticket.attendeeId,
          outcome: Outcome.ready,
          statusMessage: null,
          orderTickets: const [],
        ),
      );
    }
    if (selected.isEmpty) return;

    final selectedKeys = selected
        .map((item) => _redemptionKey(item.ticketId, item.addonId!))
        .toList(growable: false);
    setState(() => _isRedemptionProcessing = true);
    final results = <String, AttendeeModel>{};
    try {
      final batchResults = await RedemptionBatchService().redeemSelected(
        tickets: selected,
        claim: (ticket) => ApiService().claimRedemption(
          attendeeId: ticket.attendeeId!,
          addonId: ticket.addonId!,
          counterId: ticket.counterId!,
        ),
        reconcile: _redemptionAppearsInHistory,
      );
      for (final result in batchResults) {
        results[result.ticketId] = result;
      }
    } finally {
      if (mounted) {
        final latest = ref.read(currentScanProvider);
        if (latest?.id == scan.id) {
          final updatedOrderTickets = latest!.orderTickets
              .map((ticket) {
                final result = results[ticket.ticketId];
                return result ?? ticket;
              })
              .toList(growable: false);
          final primaryResult = results[scan.ticketId];
          var updatedScan = latest.copyWith(
            orderTickets: updatedOrderTickets,
            orderTicketsLoading: false,
          );
          if (primaryResult != null) {
            updatedScan = updatedScan.copyWith(
              outcome: primaryResult.redemptionOutcome,
              statusMessage: primaryResult.statusMessage,
              previousRedemptionAt: primaryResult.redeemedAt,
              previousRedemptionCounter: primaryResult.redeemedCounter,
              previousRedemptionVolunteer: primaryResult.redeemedBy,
              previousRedemptionClaimant: primaryResult.claimedBy,
            );
          }
          ref.read(currentScanProvider.notifier).setScan(updatedScan);
          final successes = results.values
              .where((result) => result.redemptionOutcome == Outcome.approved)
              .length;
          _addedCount[_counterKey] =
              (_addedCount[_counterKey] ?? 0) + successes;
          _selectedRedemptionKeys.removeAll(selectedKeys);
          if (successes > 0) {
            ref.read(redemptionHistoryProvider.notifier).refresh();
          }
        }
        setState(() => _isRedemptionProcessing = false);
      }
    }
  }

  String _redemptionKey(String ticketId, int addonId) => '$ticketId::$addonId';

  void _toggleRelatedTicketSelection(AttendeeModel ticket, ScanModel scan) {
    if (_isRedemptionProcessing ||
        ticket.isEligible != true ||
        ticket.isRedeemed ||
        ticket.attendeeId == null ||
        scan.addonId == null) {
      return;
    }
    final key = _redemptionKey(ticket.ticketId, scan.addonId!);
    setState(() {
      if (!_selectedRedemptionKeys.add(key)) {
        _selectedRedemptionKeys.remove(key);
      }
    });
  }

  void _togglePrimaryTicketSelection(ScanModel scan) {
    if (_isRedemptionProcessing ||
        scan.outcome != Outcome.ready ||
        scan.addonId == null) {
      return;
    }
    final key = _redemptionKey(scan.ticketId, scan.addonId!);
    setState(() {
      if (!_selectedRedemptionKeys.add(key)) {
        _selectedRedemptionKeys.remove(key);
      }
    });
  }

  Future<void> _confirmSelectedRedemptions(ScanModel scan) async {
    if (_selectedRedemptionKeys.isEmpty || _isRedemptionProcessing) return;
    await _confirmRedemption(scan);
  }

  Future<void> _retryRelatedTicketEligibility(ScanModel scan) async {
    if (scan.orderTicketsLoadFailed && scan.orderTickets.isEmpty) {
      await _handleScanToken(scan.ticketId);
      return;
    }
    await _loadOrderTicketEligibility(scan, retryFailedOnly: true);
  }

  int _selectedTicketCount(ScanModel scan) {
    final addonId = scan.addonId;
    if (addonId == null) return 0;
    var count = 0;
    if (scan.outcome == Outcome.ready &&
        scan.attendeeId != null &&
        _selectedRedemptionKeys.contains(
          _redemptionKey(scan.ticketId, addonId),
        )) {
      count++;
    }
    for (final ticket in scan.orderTickets) {
      if (ticket.isEligible == true &&
          !ticket.isRedeemed &&
          ticket.attendeeId != null &&
          _selectedRedemptionKeys.contains(
            _redemptionKey(ticket.ticketId, addonId),
          )) {
        count++;
      }
    }
    return count;
  }

  Future<bool> _redemptionAppearsInHistory(ScanModel scan) async {
    try {
      final records = await ApiService().getMyHistory();
      final found = records.any((record) {
        if (record is! Map) return false;
        return record['attendee_id'] == scan.attendeeId &&
            record['addon_id'] == scan.addonId &&
            record['counter_id'] == scan.counterId;
      });
      await ref.read(redemptionHistoryProvider.notifier).refresh();
      return found;
    } catch (error) {
      debugPrint('[REDEMPTION RECONCILIATION ERROR] $error');
      return false;
    }
  }

  void _onScanNext() {
    ref.read(currentScanProvider.notifier).clearScan();
    setState(() {
      _selectedRedemptionKeys.clear();
      _screen = 'scanner';
    });
  }

  void _clearRedemptionSelection() {
    if (_isRedemptionProcessing) return;
    setState(_selectedRedemptionKeys.clear);
  }

  Future<void> _retryCurrentVerification(ScanModel scan) async {
    await _handleScanToken(scan.ticketId);
  }

  @override
  Widget build(BuildContext context) {
    final showNav =
        _screen != 'login' && _screen != 'counter' && _screen != 'loading';
    final historyAsync = ref.watch(redemptionHistoryProvider);
    final currentScan = ref.watch(currentScanProvider);

    final historyScans = historyAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <ScanModel>[],
    );

    final scopedHistory = historyScans
        .where((scan) => scan.counter == _activeCounter.name)
        .toList();

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
        onActionClick: _onScanNext,
        onConfirmRedemption: () => _confirmSelectedRedemptions(currentScan),
        onRetryVerification: () => _retryCurrentVerification(currentScan),
        onToggleRelatedTicket: (ticket) =>
            _toggleRelatedTicketSelection(ticket, currentScan),
        onTogglePrimaryTicket: () => _togglePrimaryTicketSelection(currentScan),
        isPrimarySelected:
            currentScan.addonId != null &&
            _selectedRedemptionKeys.contains(
              _redemptionKey(currentScan.ticketId, currentScan.addonId!),
            ),
        selectedTicketCount: _selectedTicketCount(currentScan),
        selectedRedemptionKeys: Set<String>.unmodifiable(
          _selectedRedemptionKeys,
        ),
        onClearSelection: _clearRedemptionSelection,
        onRetryRelatedEligibility: () =>
            _retryRelatedTicketEligibility(currentScan),
        isConfirming: _isRedemptionProcessing,
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
                            if (!_isRedemptionProcessing &&
                                _selectedRedemptionKeys.isEmpty &&
                                _screen != 'verifying' &&
                                !(_screen == 'outcome' &&
                                    currentScan?.outcome == Outcome.ready)) {
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
                            if (!_isRedemptionProcessing &&
                                _selectedRedemptionKeys.isEmpty &&
                                _screen != 'verifying' &&
                                !(_screen == 'outcome' &&
                                    currentScan?.outcome == Outcome.ready)) {
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
                            if (!_isRedemptionProcessing &&
                                _selectedRedemptionKeys.isEmpty &&
                                _screen != 'verifying') {
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
