import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';

class AlreadyClaimedScreen extends StatelessWidget {
  final String attendeeName;
  final String item;
  final String claimedTime;
  final String counterId;
  final String volunteerId;
  final VoidCallback onScanNext;

  const AlreadyClaimedScreen({
    super.key,
    required this.attendeeName,
    required this.item,
    required this.claimedTime,
    required this.counterId,
    required this.volunteerId,
    required this.onScanNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Warning Icon Box
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: TEDxColors.warningBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: TEDxColors.warningBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: TEDxColors.warning.withOpacity(0.2),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 52,
                    color: TEDxColors.warning,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Already Claimed',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This item has already been collected and cannot be issued again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TEDxColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Metadata Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TEDxColors.warningBorder.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      attendeeName,
                      style: const TextStyle(
                        color: TEDxColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Requested Item: $item',
                      style: const TextStyle(
                        color: TEDxColors.warning,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: TEDxColors.cardBorder, height: 1),
                    const SizedBox(height: 16),
                    _detailRow('Redemption Status', 'CLAIMED'),
                    const SizedBox(height: 10),
                    _detailRow('Time of Claim', claimedTime),
                    const SizedBox(height: 10),
                    _detailRow('Counter Station', counterId),
                    const SizedBox(height: 10),
                    _detailRow('Issued By', volunteerId),
                  ],
                ),
              ),

              const Spacer(),

              TEDxButton(
                text: 'Scan Next Attendee',
                icon: Icons.qr_code_scanner_rounded,
                onPressed: onScanNext,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: TEDxColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: TEDxColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
