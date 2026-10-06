import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';

class AttendeeDetailsScreen extends StatelessWidget {
  final ScanModel scan;
  final VoidCallback onBackPressed;

  const AttendeeDetailsScreen({
    super.key,
    required this.scan,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = scan.outcome == Outcome.approved;
    final statusColor = isApproved ? TEDxColors.success : TEDxColors.error;

    final metadataRows = [
      MapEntry('Benefit', scan.benefit),
      MapEntry('Counter', scan.counter),
      MapEntry('Time', scan.time),
      const MapEntry('Volunteer', 'Rahul Sharma'),
      MapEntry('Record ID', scan.id),
    ];

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onBackPressed,
                child: const Row(
                  children: [
                    Text(
                      '← Back to scan history',
                      style: TextStyle(
                        color: TEDxColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SectionHeading(
                label: 'SCAN RECORD',
                title: scan.name,
                support: '${scan.ticketId} · ${scan.pass} pass',
              ),
              const SizedBox(height: 16),

              // Status Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  getOutcomeLabel(scan.outcome),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              MetadataList(rows: metadataRows),
              const SizedBox(height: 16),

              Center(
                child: Text(
                  isApproved
                      ? 'Benefit issued and recorded.'
                      : 'No benefit was issued for this attempt.',
                  style: const TextStyle(
                    color: TEDxColors.textMuted,
                    fontSize: 12,
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
}
