import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';
import '../providers/redemption_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final CounterInfo counter;
  final String volunteerName;
  final int addedCount;
  final List<ScanModel> recentScans;
  final VoidCallback onScanClick;
  final VoidCallback onViewHistoryClick;
  final ValueChanged<ScanModel> onSelectScan;
  final VoidCallback? onLogout;
  final VoidCallback? onSwitchCounter;

  const DashboardScreen({
    super.key,
    required this.counter,
    required this.volunteerName,
    required this.addedCount,
    required this.recentScans,
    required this.onScanClick,
    required this.onViewHistoryClick,
    required this.onSelectScan,
    this.onLogout,
    this.onSwitchCounter,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int? _dbSuccessfulScans;
  int? _dbRemainingEligible;
  String? _statsError;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.counter.id != widget.counter.id ||
        oldWidget.addedCount != widget.addedCount) {
      _fetchStats();
    }
  }

  Future<void> _fetchStats() async {
    if (!mounted) return;
    setState(() => _isLoadingStats = true);

    final counterId = widget.counter.id;
    if (counterId == null) {
      setState(() {
        _isLoadingStats = false;
        _statsError = 'Select an active counter to load its statistics.';
      });
      return;
    }

    try {
      final res = await ApiService().getCounterStats(counterId);
      if (mounted) {
        setState(() {
          _dbSuccessfulScans = res['successful_claims'] as int?;
          _dbRemainingEligible = res['remaining_eligible'] as int?;
          _statsError = null;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint('[DashboardScreen] Error fetching DB stats: $e');
      if (mounted) {
        setState(() {
          _dbSuccessfulScans = null;
          _dbRemainingEligible = null;
          _statsError = 'Statistics are unavailable. Pull down to retry.';
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to redemptionHistoryProvider updates to trigger fresh DB stats fetch
    ref.listen(redemptionHistoryProvider, (previous, next) {
      if (next.hasValue && !next.isLoading) {
        _fetchStats();
      }
    });

    final scansToDisplay = widget.recentScans.take(3).toList();

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchStats,
          color: TEDxColors.tedRed,
          backgroundColor: TEDxColors.cardDark,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with Top-Right Logout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COUNTER ${widget.counter.code}',
                            style: AppFonts.mono(
                              color: const Color(0xFF71717A),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.counter.name,
                            style: AppFonts.heading(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.volunteerName} · Volunteer',
                            style: AppFonts.body(
                              color: const Color(0xFFA1A1AA),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.onLogout != null)
                      GestureDetector(
                        onTap: widget.onLogout,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27272A),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF3F3F46)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.logout_rounded,
                                size: 14,
                                color: TEDxColors.tedRed,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'LOGOUT',
                                style: AppFonts.mono(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFF1F1F23), height: 1),
                const SizedBox(height: 16),

                // Operational status bar with Counter Switch button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.fiber_manual_record,
                          size: 7,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Counter operational',
                          style: AppFonts.body(
                            color: const Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          widget.counter.benefit.toUpperCase(),
                          style: AppFonts.mono(
                            color: const Color(0xFF71717A),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (widget.onSwitchCounter != null) ...[
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: widget.onSwitchCounter,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF27272A),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFF3F3F46),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 13,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'SWITCH',
                                    style: AppFonts.mono(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // SCAN QR Hero Button
                GestureDetector(
                  onTap: widget.onScanClick,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: TEDxColors.tedRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SCAN QR',
                                style: AppFonts.heading(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Scan an attendee’s event pass',
                                style: AppFonts.body(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '→',
                          style: AppFonts.body(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Metrics 2-column with center vertical divider
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _dbSuccessfulScans?.toString() ?? '—',
                                style: AppFonts.heading(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              if (_isLoadingStats) ...[
                                const SizedBox(width: 8),
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: TEDxColors.tedRed,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Successful redemptions',
                            style: AppFonts.body(
                              color: const Color(0xFFA1A1AA),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 54,
                      width: 1,
                      color: const Color(0xFF26262A),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _dbRemainingEligible == null
                                ? '—'
                                : _dbRemainingEligible!
                                      .clamp(0, 9999)
                                      .toString(),
                            style: AppFonts.heading(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Remaining eligible',
                            style: AppFonts.body(
                              color: const Color(0xFFA1A1AA),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_statsError != null) ...[
                  Text(
                    _statsError!,
                    style: AppFonts.body(
                      color: TEDxColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const Divider(color: Color(0xFF1F1F23), height: 1),
                const SizedBox(height: 28),

                // Section Header: Last scans
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Last scans',
                      style: AppFonts.heading(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onViewHistoryClick,
                      child: Row(
                        children: [
                          Text(
                            'View history ',
                            style: AppFonts.body(
                              color: const Color(0xFFA1A1AA),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '→',
                            style: AppFonts.body(
                              color: const Color(0xFFA1A1AA),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Scans List
                ScanListWidget(
                  scans: scansToDisplay,
                  onSelect: widget.onSelectScan,
                ),
                const SizedBox(height: 28),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
