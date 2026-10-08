import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';

class CounterAssignmentScreen extends StatelessWidget {
  final CounterInfo counter;
  final VoidCallback onStartScanning;

  const CounterAssignmentScreen({
    super.key,
    required this.counter,
    required this.onStartScanning,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading(
                label: 'VOLUNTEER ACCESS',
                title: 'Your counter. Your shift.',
                support: 'Everything you need to keep the line moving.',
              ),
              const SizedBox(height: 24),

              // Assigned Counter Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TEDxColors.tedRed.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: TEDxColors.tedRed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            counter.code,
                            style: AppFonts.mono(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'YOUR ASSIGNED COUNTER',
                      style: AppFonts.mono(
                        color: TEDxColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      counter.name,
                      style: AppFonts.heading(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${counter.benefit} redemption · Ground floor',
                      style: AppFonts.body(
                        color: TEDxColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Volunteer Profile Item Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: TEDxColors.tedRed,
                      child: Text(
                        'RS',
                        style: AppFonts.heading(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rahul Sharma',
                          style: AppFonts.heading(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'VOL–014',
                                style: AppFonts.mono(
                                  color: TEDxColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: ' · Counter volunteer',
                                style: AppFonts.body(
                                  color: TEDxColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Counter Permissions Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COUNTER PERMISSIONS',
                      style: AppFonts.mono(
                        color: TEDxColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _permissionRow('Scan attendee QR codes'),
                    const SizedBox(height: 8),
                    _permissionRow('Redeem ${counter.benefit}'),
                    const SizedBox(height: 8),
                    _permissionRow('View counter scan history'),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              ActionButton(
                text: 'START SCANNING',
                trailingArrow: '→',
                onPressed: onStartScanning,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Assigned by the event operations team',
                  style: AppFonts.body(
                    color: TEDxColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _permissionRow(String text) {
    return Row(
      children: [
        Text(
          '✓',
          style: AppFonts.body(
            color: TEDxColors.success,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppFonts.body(
            color: TEDxColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
