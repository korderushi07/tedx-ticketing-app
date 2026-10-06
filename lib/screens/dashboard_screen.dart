import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';

class DashboardScreen extends StatelessWidget {
  final VolunteerModel volunteer;
  final CounterStats stats;
  final VoidCallback onOpenScanner;
  final Function(int) onTabSelected;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenStats;

  const DashboardScreen({
    super.key,
    required this.volunteer,
    required this.stats,
    required this.onOpenScanner,
    required this.onTabSelected,
    this.onOpenProfile,
    this.onOpenStats,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const TEDxLogo(fontSize: 18, subtitle: ''),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: TEDxColors.cardDark,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: TEDxColors.cardBorder),
              ),
              child: Text(
                volunteer.counterId,
                style: const TextStyle(
                  color: TEDxColors.tedRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: TEDxColors.cardDark,
                shape: BoxShape.circle,
                border: Border.all(color: TEDxColors.cardBorder),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: TEDxColors.textPrimary,
                size: 18,
              ),
            ),
            onPressed: onOpenStats,
            tooltip: 'Counter Performance',
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: TEDxColors.tedRed,
              child: Text(
                volunteer.avatarInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            onPressed: onOpenProfile,
            tooltip: 'Volunteer Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Operational Overview',
                        style: TextStyle(
                          color: TEDxColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        volunteer.name,
                        style: const TextStyle(
                          color: TEDxColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: TEDxColors.successBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: TEDxColors.successBorder.withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record, size: 8, color: TEDxColors.success),
                        SizedBox(width: 6),
                        Text(
                          'LIVE SESSION',
                          style: TextStyle(
                            color: TEDxColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Today's Operations Section
              const Text(
                "Today's Operations",
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // 2x2 Metric Grid
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
                    onTap: () => onTabSelected(2), // History tab
                  ),
                  MetricCard(
                    title: 'Successful Claims',
                    value: stats.successfulClaims.toString(),
                    icon: Icons.check_circle_rounded,
                    accentColor: TEDxColors.success,
                    onTap: () => onTabSelected(2),
                  ),
                  MetricCard(
                    title: 'Already Claimed',
                    value: stats.alreadyClaimed.toString(),
                    icon: Icons.warning_amber_rounded,
                    accentColor: TEDxColors.warning,
                    onTap: () => onTabSelected(2),
                  ),
                  MetricCard(
                    title: 'Not Eligible',
                    value: stats.notEligible.toString(),
                    icon: Icons.block_rounded,
                    accentColor: TEDxColors.error,
                    onTap: () => onTabSelected(2),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Assigned Counter Card
              const Text(
                'Assigned Counter',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: TEDxColors.tedRedSubtle,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                color: TEDxColors.tedRed,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  volunteer.counterName,
                                  style: const TextStyle(
                                    color: TEDxColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Station ID: ${volunteer.counterId}',
                                  style: const TextStyle(
                                    color: TEDxColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        StatusBadge.active(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Inventory Claimed',
                          style: TextStyle(
                            color: TEDxColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${stats.successfulClaims} / ${stats.itemGoal}',
                          style: const TextStyle(
                            color: TEDxColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: stats.successfulClaims / stats.itemGoal,
                        minHeight: 8,
                        backgroundColor: TEDxColors.inputBg,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          TEDxColors.tedRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Large Primary Action Banner
              GestureDetector(
                onTap: onOpenScanner,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [TEDxColors.tedRed, TEDxColors.tedRedDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: TEDxColors.tedRed.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan Attendee QR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Tap to launch high-speed scanner',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
