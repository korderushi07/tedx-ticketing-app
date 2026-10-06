import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';

class SuccessRedemptionScreen extends StatelessWidget {
  final String attendeeName;
  final String ticketType;
  final String item;
  final String time;
  final String counterId;
  final VoidCallback onScanNext;
  final VoidCallback onViewDetails;

  const SuccessRedemptionScreen({
    super.key,
    required this.attendeeName,
    required this.ticketType,
    required this.item,
    required this.time,
    required this.counterId,
    required this.onScanNext,
    required this.onViewDetails,
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
              // Success Animated Icon Container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: TEDxColors.successBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: TEDxColors.successBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: TEDxColors.success.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 60,
                    color: TEDxColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Successfully Claimed',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Item issued and recorded in server log.',
                style: TextStyle(
                  color: TEDxColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TEDxColors.cardBorder),
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
                      '$ticketType Ticket Tier',
                      style: const TextStyle(
                        color: TEDxColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: TEDxColors.tedRedSubtle,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: TEDxColors.tedRed.withOpacity(0.3)),
                      ),
                      child: Text(
                        'ITEM: ${item.toUpperCase()}',
                        style: const TextStyle(
                          color: TEDxColors.tedRed,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: TEDxColors.cardBorder, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Claim Time',
                              style: TextStyle(color: TEDxColors.textMuted, fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              time,
                              style: const TextStyle(
                                color: TEDxColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 28, color: TEDxColors.cardBorder),
                        Column(
                          children: [
                            const Text(
                              'Station ID',
                              style: TextStyle(color: TEDxColors.textMuted, fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              counterId,
                              style: const TextStyle(
                                color: TEDxColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              TEDxButton(
                text: 'Scan Next Attendee',
                icon: Icons.qr_code_scanner_rounded,
                onPressed: onScanNext,
              ),
              const SizedBox(height: 12),
              TEDxButton(
                text: 'View Attendee Details',
                isPrimary: false,
                onPressed: onViewDetails,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
