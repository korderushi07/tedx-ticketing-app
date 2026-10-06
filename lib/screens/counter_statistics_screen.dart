import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';

class CounterStatisticsScreen extends StatelessWidget {
  final VolunteerModel volunteer;
  final CounterStats stats;
  final VoidCallback onBackPressed;

  const CounterStatisticsScreen({
    super.key,
    required this.volunteer,
    required this.stats,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double claimRatio = (stats.successfulClaims / stats.itemGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      appBar: AppBar(
        title: const Text('Counter Performance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBackPressed,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Station Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          volunteer.counterName,
                          style: const TextStyle(
                            color: TEDxColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Counter ID: ${volunteer.counterId} • Event Ops',
                          style: const TextStyle(
                            color: TEDxColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    StatusBadge.active(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Operational Metrics Summary
              const Text(
                'Scans & Distribution Summary',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  MetricCard(
                    title: 'Total Scans',
                    value: stats.totalScans.toString(),
                    icon: Icons.qr_code_scanner_rounded,
                    accentColor: TEDxColors.textPrimary,
                  ),
                  MetricCard(
                    title: 'Successful Claims',
                    value: stats.successfulClaims.toString(),
                    icon: Icons.check_circle_rounded,
                    accentColor: TEDxColors.success,
                  ),
                  MetricCard(
                    title: 'Already Claimed',
                    value: stats.alreadyClaimed.toString(),
                    icon: Icons.warning_amber_rounded,
                    accentColor: TEDxColors.warning,
                  ),
                  MetricCard(
                    title: 'Not Eligible',
                    value: stats.notEligible.toString(),
                    icon: Icons.block_rounded,
                    accentColor: TEDxColors.error,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Distribution Progress Bar Section
              const Text(
                "Today's T-Shirt Distribution Progress",
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Inventory Claimed',
                          style: TextStyle(
                            color: TEDxColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${stats.successfulClaims} / ${stats.itemGoal} (${(claimRatio * 100).toStringAsFixed(1)}%)',
                          style: const TextStyle(
                            color: TEDxColors.tedRed,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: claimRatio,
                        minHeight: 12,
                        backgroundColor: TEDxColors.inputBg,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          TEDxColors.tedRed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Remaining Inventory:',
                          style: TextStyle(color: TEDxColors.textMuted, fontSize: 12),
                        ),
                        Text(
                          '${stats.itemGoal - stats.successfulClaims} items remaining',
                          style: const TextStyle(
                            color: TEDxColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Simple Hourly Scan Velocity Bar Visualization
              const Text(
                'Hourly Scan Activity',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _barItem('09 AM', 0.4),
                    _barItem('10 AM', 0.95),
                    _barItem('11 AM', 0.7),
                    _barItem('12 PM', 0.3),
                    _barItem('01 PM', 0.5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barItem(String timeLabel, double ratio) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 100 * ratio,
          decoration: BoxDecoration(
            color: ratio > 0.8 ? TEDxColors.tedRed : TEDxColors.surfaceElevated,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          timeLabel,
          style: const TextStyle(
            color: TEDxColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
