import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';

class DashboardScreen extends StatefulWidget {
  final CounterInfo counter;
  final int addedCount;
  final List<ScanModel> recentScans;
  final VoidCallback onScanClick;
  final VoidCallback onViewHistoryClick;
  final ValueChanged<ScanModel> onSelectScan;
  final ValueChanged<CounterKey> onSwitchCounter;

  const DashboardScreen({
    super.key,
    required this.counter,
    required this.addedCount,
    required this.recentScans,
    required this.onScanClick,
    required this.onViewHistoryClick,
    required this.onSelectScan,
    required this.onSwitchCounter,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showDemoControls = false;

  @override
  Widget build(BuildContext context) {
    final successfulTotal = widget.counter.total + widget.addedCount;
    final remainingEligible = (widget.counter.key == CounterKey.food ? 398 : 279) - widget.addedCount;

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(
                label: 'COUNTER ${widget.counter.code}',
                title: widget.counter.name,
                support: 'Rahul Sharma · Volunteer',
              ),
              const SizedBox(height: 16),

              // Counter Operational Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.fiber_manual_record, size: 8, color: TEDxColors.success),
                        SizedBox(width: 6),
                        Text(
                          'Counter operational',
                          style: TextStyle(
                            color: TEDxColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.counter.benefit.toUpperCase(),
                      style: const TextStyle(
                        color: TEDxColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SCAN QR Large Action Card
              GestureDetector(
                onTap: widget.onScanClick,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: TEDxColors.tedRed,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: TEDxColors.tedRed.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SCAN QR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Scan an attendee’s event pass',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '→',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Totals 2-column Grid
              Row(
                children: [
                  Expanded(
                    child: _totalCard(
                      value: successfulTotal.toString(),
                      label: 'Successful scans today',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _totalCard(
                      value: remainingEligible.clamp(0, 9999).toString(),
                      label: 'Remaining eligible',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section Header: Last scans
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Last scans',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onViewHistoryClick,
                    style: TextButton.styleFrom(
                      foregroundColor: TEDxColors.tedRed,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'View history →',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Scans list
              ScanListWidget(
                scans: widget.recentScans.take(3).toList(),
                onSelect: widget.onSelectScan,
              ),
              const SizedBox(height: 20),

              // Shift Note Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ON YOUR SHIFT',
                      style: TextStyle(
                        color: TEDxColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Scan the pass. Check the result.\nOnly issue a benefit when it’s approved.',
                      style: TextStyle(
                        color: TEDxColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Demo Switch Counter Accordion
              Container(
                decoration: BoxDecoration(
                  color: TEDxColors.inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _showDemoControls = !_showDemoControls),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Demo · switch assigned counter',
                              style: TextStyle(
                                color: TEDxColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              _showDemoControls ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: TEDxColors.textMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showDemoControls)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: ActionButton(
                                text: 'Food Counter 01',
                                secondary: true,
                                isPressed: widget.counter.key == CounterKey.food,
                                onPressed: () => widget.onSwitchCounter(CounterKey.food),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ActionButton(
                                text: 'Merchandise Counter',
                                secondary: true,
                                isPressed: widget.counter.key == CounterKey.merch,
                                onPressed: () => widget.onSwitchCounter(CounterKey.merch),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _totalCard({required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TEDxColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TEDxColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: TEDxColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
