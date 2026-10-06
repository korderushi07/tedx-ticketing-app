import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';

class AttendeeDetailsScreen extends StatelessWidget {
  final AttendeeModel attendee;
  final VoidCallback onBackPressed;
  final Function(String itemName)? onClaimItem;

  const AttendeeDetailsScreen({
    super.key,
    required this.attendee,
    required this.onBackPressed,
    this.onClaimItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      appBar: AppBar(
        title: const Text('Attendee Profile'),
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
              // Attendee Header Card
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
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: TEDxColors.tedRed,
                      child: Text(
                        attendee.name.split(' ').map((e) => e[0]).join(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      attendee.name,
                      style: const TextStyle(
                        color: TEDxColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: TEDxColors.tedRedSubtle,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${attendee.ticketType} TICKET',
                        style: const TextStyle(
                          color: TEDxColors.tedRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Personal Information Section
              const Text(
                'Attendee Information',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.confirmation_number_outlined, 'Ticket ID', attendee.ticketId),
                    const Divider(color: TEDxColors.cardBorder, height: 24),
                    _infoRow(Icons.email_outlined, 'Email Address', attendee.email),
                    const Divider(color: TEDxColors.cardBorder, height: 24),
                    _infoRow(Icons.phone_outlined, 'Phone Number', attendee.phone),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Entitlements List Section
              const Text(
                'Ticket Entitlements',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Live status of items associated with this ticket pass.',
                style: TextStyle(
                  color: TEDxColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: attendee.entitlements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = attendee.entitlements[index];
                  return _buildEntitlementCard(item);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: TEDxColors.textSecondary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: TEDxColors.textMuted, fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: TEDxColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEntitlementCard(EntitlementItem item) {
    StatusBadge badge;
    String statusDetail = '';
    Color iconColor;
    IconData leadingIcon;

    switch (item.state) {
      case EntitlementState.available:
        badge = StatusBadge.available();
        statusDetail = 'Ready to collect at Counter';
        iconColor = TEDxColors.success;
        leadingIcon = Icons.radio_button_unchecked_rounded;
        break;
      case EntitlementState.claimed:
        badge = StatusBadge.claimed();
        statusDetail = 'Claimed at ${item.claimedTime ?? "10:42 AM"} (${item.claimedCounter ?? "C-03"})';
        iconColor = TEDxColors.warning;
        leadingIcon = Icons.check_circle_rounded;
        break;
      case EntitlementState.notIncluded:
        badge = StatusBadge.notIncluded();
        statusDetail = 'Not included in tier';
        iconColor = TEDxColors.textMuted;
        leadingIcon = Icons.remove_circle_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TEDxColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TEDxColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(leadingIcon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: TEDxColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusDetail,
                  style: const TextStyle(
                    color: TEDxColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          badge,
        ],
      ),
    );
  }
}
