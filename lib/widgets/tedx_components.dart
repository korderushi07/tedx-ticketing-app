import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class TEDxTopBar extends StatelessWidget {
  const TEDxTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: TEDxColors.bgDark,
        border: Border(
          bottom: BorderSide(color: TEDxColors.cardBorder, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'sans-serif'),
                children: [
                  TextSpan(
                    text: 'TEDx',
                    style: TextStyle(color: TEDxColors.tedRed, fontWeight: FontWeight.w900),
                  ),
                  TextSpan(text: ' Nagpur ', style: TextStyle(color: Colors.white)),
                  TextSpan(
                    text: '2026',
                    style: TextStyle(color: TEDxColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: TEDxColors.tedRedSubtle,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: TEDxColors.tedRed.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fiber_manual_record, size: 8, color: TEDxColors.tedRed),
                  SizedBox(width: 6),
                  Text(
                    'EVENT LIVE',
                    style: TextStyle(
                      color: TEDxColors.tedRed,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool secondary;
  final Widget? icon;
  final String? trailingArrow;
  final Widget? subtitle;
  final bool isPressed;

  const ActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.secondary = false,
    this.icon,
    this.trailingArrow,
    this.subtitle,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (secondary) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: isPressed ? TEDxColors.surfaceElevated : TEDxColors.cardDark,
            foregroundColor: isPressed ? Colors.white : TEDxColors.textPrimary,
            side: BorderSide(
              color: isPressed ? TEDxColors.tedRed : TEDxColors.cardBorder,
              width: isPressed ? 1.5 : 1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              if (trailingArrow != null) ...[
                const SizedBox(width: 6),
                Text(
                  trailingArrow!,
                  style: const TextStyle(color: TEDxColors.textMuted, fontSize: 16),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: TEDxColors.tedRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 10)],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: icon != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  ?subtitle,
                ],
              ),
            ),
            if (trailingArrow != null)
              Text(
                trailingArrow!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
          ],
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  final String label;
  final String title;
  final String? support;

  const SectionHeading({
    super.key,
    required this.label,
    required this.title,
    this.support,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: TEDxColors.tedRed,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: TEDxColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        if (support != null) ...[
          const SizedBox(height: 4),
          Text(
            support!,
            style: const TextStyle(
              color: TEDxColors.textSecondary,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}

class MetadataList extends StatelessWidget {
  final List<MapEntry<String, String>> rows;

  const MetadataList({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TEDxColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TEDxColors.cardBorder),
      ),
      child: Column(
        children: rows.map((entry) {
          final isLast = entry == rows.last;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: TEDxColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      entry.value,
                      style: const TextStyle(
                        color: TEDxColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(color: TEDxColors.cardBorder, height: 12),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class ScanListWidget extends StatelessWidget {
  final List<ScanModel> scans;
  final ValueChanged<ScanModel> onSelect;

  const ScanListWidget({
    super.key,
    required this.scans,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (scans.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: TEDxColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TEDxColors.cardBorder),
        ),
        child: const Column(
          children: [
            Icon(Icons.qr_code_scanner_rounded, size: 36, color: TEDxColors.textMuted),
            SizedBox(height: 12),
            Text(
              'No scans to show',
              style: TextStyle(
                color: TEDxColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Scan records will appear here.',
              style: TextStyle(
                color: TEDxColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: scans.map((scan) {
        final isApproved = scan.outcome == Outcome.approved;
        final markColor = isApproved ? TEDxColors.success : TEDxColors.error;
        final markBg = isApproved ? TEDxColors.successBg : TEDxColors.errorBg;
        final markIcon = isApproved ? '✓' : '×';

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelect(scan),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: markBg,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          markIcon,
                          style: TextStyle(
                            color: markColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scan.name,
                            style: const TextStyle(
                              color: TEDxColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${scan.ticketId} · ${scan.benefit}',
                            style: const TextStyle(
                              color: TEDxColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            getOutcomeLabel(scan.outcome),
                            style: TextStyle(
                              color: markColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      scan.time,
                      style: const TextStyle(
                        color: TEDxColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '›',
                      style: TextStyle(
                        color: TEDxColors.textMuted,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
