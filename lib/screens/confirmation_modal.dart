import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';

class ConfirmationModal extends StatelessWidget {
  final String attendeeName;
  final String ticketType;
  final String item;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationModal({
    super.key,
    required this.attendeeName,
    required this.ticketType,
    required this.item,
    required this.onConfirm,
    required this.onCancel,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String attendeeName,
    required String ticketType,
    required String item,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: TEDxColors.cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return ConfirmationModal(
          attendeeName: attendeeName,
          ticketType: ticketType,
          item: item,
          onConfirm: () => Navigator.pop(ctx, true),
          onCancel: () => Navigator.pop(ctx, false),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: TEDxColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Confirm Redemption?',
            style: TextStyle(
              color: TEDxColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: TEDxColors.textSecondary, fontSize: 14, height: 1.4),
              children: [
                const TextSpan(text: 'Are you sure you want to mark '),
                TextSpan(
                  text: item,
                  style: const TextStyle(color: TEDxColors.tedRed, fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' as claimed for '),
                TextSpan(
                  text: attendeeName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Detail Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TEDxColors.bgDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: TEDxColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ticket Tier', style: TextStyle(color: TEDxColors.textMuted, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      ticketType,
                      style: const TextStyle(
                        color: TEDxColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 24, color: TEDxColors.cardBorder),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Item to Issue', style: TextStyle(color: TEDxColors.textMuted, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      item,
                      style: const TextStyle(
                        color: TEDxColors.tedRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: TEDxButton(
                  text: 'Cancel',
                  isPrimary: false,
                  onPressed: onCancel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TEDxButton(
                  text: 'Confirm Claim',
                  icon: Icons.check_circle_rounded,
                  onPressed: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
