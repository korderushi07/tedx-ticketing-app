import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';

class AttendeeVerificationScreen extends StatelessWidget {
  final AttendeeModel attendee;
  final String currentCounterItem;
  final VoidCallback onConfirmClaim;
  final VoidCallback onCancel;
  final VoidCallback onViewFullProfile;

  const AttendeeVerificationScreen({
    super.key,
    required this.attendee,
    this.currentCounterItem = 'T-Shirt',
    required this.onConfirmClaim,
    required this.onCancel,
    required this.onViewFullProfile,
  });

  @override
  Widget build(BuildContext context) {
    final entitlement = attendee.getEntitlement(currentCounterItem);
    final isAvailable = entitlement?.state == EntitlementState.available;

    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      appBar: AppBar(
        title: const Text('Attendee Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onCancel,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Verified Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: TEDxColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TEDxColors.successBorder.withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: TEDxColors.success, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Valid QR Code Verified • TEDx YCCE Pass',
                      style: TextStyle(
                        color: TEDxColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Attendee Info Card
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: TEDxColors.surfaceElevated,
                          child: Text(
                            attendee.name.split(' ').map((e) => e[0]).join(),
                            style: const TextStyle(
                              color: TEDxColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attendee.name,
                                style: const TextStyle(
                                  color: TEDxColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TEDxColors.tedRedSubtle,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      attendee.ticketType,
                                      style: const TextStyle(
                                        color: TEDxColors.tedRed,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    attendee.ticketId,
                                    style: const TextStyle(
                                      color: TEDxColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: TEDxColors.cardBorder, height: 1),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: onViewFullProfile,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View Full Attendee Entitlements',
                            style: TextStyle(
                              color: TEDxColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded, size: 16, color: TEDxColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Requested Counter Entitlement Box
              const Text(
                'Current Counter Entitlement',
                style: TextStyle(
                  color: TEDxColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isAvailable ? TEDxColors.cardDark : TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isAvailable
                        ? TEDxColors.successBorder
                        : TEDxColors.warningBorder,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentCounterItem.toUpperCase(),
                          style: const TextStyle(
                            color: TEDxColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        isAvailable
                            ? StatusBadge.available()
                            : StatusBadge.claimed(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          isAvailable
                              ? Icons.check_circle_rounded
                              : Icons.warning_amber_rounded,
                          size: 16,
                          color: isAvailable
                              ? TEDxColors.success
                              : TEDxColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isAvailable
                              ? 'Included in ${attendee.ticketType} Ticket Tier'
                              : 'Already Claimed at Counter C-03',
                          style: const TextStyle(
                            color: TEDxColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TEDxColors.bgDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Item Specification:',
                            style: TextStyle(
                              color: TEDxColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Standard Unisex • Size L',
                            style: TextStyle(
                              color: TEDxColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Primary Action: Mark as Claimed
              TEDxButton(
                text: 'Mark as Claimed',
                icon: Icons.check_circle_rounded,
                onPressed: isAvailable ? onConfirmClaim : null,
              ),
              const SizedBox(height: 12),

              // Secondary Action: Cancel
              TEDxButton(
                text: 'Cancel Scan',
                isPrimary: false,
                onPressed: onCancel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
