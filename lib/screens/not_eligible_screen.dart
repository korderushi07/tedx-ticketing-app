import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';

class NotEligibleScreen extends StatelessWidget {
  final String attendeeName;
  final String ticketType;
  final String item;
  final String message;
  final VoidCallback onScanNext;

  const NotEligibleScreen({
    super.key,
    required this.attendeeName,
    required this.ticketType,
    required this.item,
    required this.message,
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
              // Red Error Icon Box
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: TEDxColors.errorBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: TEDxColors.errorBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: TEDxColors.error.withOpacity(0.2),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.block_rounded,
                    size: 52,
                    color: TEDxColors.error,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Not Eligible',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This item is not included in the attendee\'s ticket tier.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TEDxColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Detail Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TEDxColors.errorBorder.withOpacity(0.5)),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: TEDxColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Ticket: $ticketType Tier',
                        style: const TextStyle(
                          color: TEDxColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: TEDxColors.cardBorder, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Requested Item',
                          style: TextStyle(color: TEDxColors.textMuted, fontSize: 12),
                        ),
                        Text(
                          item,
                          style: const TextStyle(
                            color: TEDxColors.error,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TEDxColors.errorBg.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: TEDxColors.error,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
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
}
