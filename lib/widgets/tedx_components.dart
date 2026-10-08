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
          bottom: BorderSide(color: Color(0xFF222225), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                style: AppFonts.heading(fontSize: 17, fontWeight: FontWeight.w800),
                children: [
                  TextSpan(
                    text: 'TEDx',
                    style: AppFonts.heading(color: TEDxColors.tedRed, fontWeight: FontWeight.w900),
                  ),
                  TextSpan(text: ' Nagpur ', style: AppFonts.heading(color: Colors.white, fontWeight: FontWeight.w800)),
                  TextSpan(
                    text: '2026',
                    style: AppFonts.heading(color: const Color(0xFF71717A), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fiber_manual_record, size: 7, color: Color(0xFF10B981)),
                const SizedBox(width: 6),
                Text(
                  'EVENT LIVE',
                  style: AppFonts.mono(
                    color: const Color(0xFF8E8E93),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
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
                style: AppFonts.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              if (trailingArrow != null) ...[
                const SizedBox(width: 6),
                Text(
                  trailingArrow!,
                  style: AppFonts.body(color: TEDxColors.textMuted, fontSize: 16),
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
                    style: AppFonts.body(
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
                style: AppFonts.body(fontSize: 18, fontWeight: FontWeight.w700),
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
          style: AppFonts.mono(
            color: TEDxColors.tedRed,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppFonts.heading(
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
            style: AppFonts.body(
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
          final isCodeOrId = entry.key.toLowerCase().contains('id') ||
              entry.key.toLowerCase().contains('code') ||
              entry.key.toLowerCase().contains('time') ||
              entry.key.toLowerCase().contains('counter');

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: AppFonts.body(
                        color: TEDxColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      entry.value,
                      style: isCodeOrId
                          ? AppFonts.mono(
                              color: TEDxColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            )
                          : AppFonts.body(
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
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Column(
          children: [
            const Icon(Icons.qr_code_scanner_rounded, size: 32, color: Color(0xFF71717A)),
            const SizedBox(height: 10),
            Text(
              'No scans yet today',
              style: AppFonts.heading(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Scan records will appear here live.',
              style: AppFonts.body(
                color: const Color(0xFFA1A1AA),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: scans.asMap().entries.map((entry) {
        final index = entry.key;
        final scan = entry.value;
        final isApproved = scan.outcome == Outcome.approved;
        final markColor = isApproved ? TEDxColors.success : TEDxColors.error;
        final markIcon = isApproved ? '✓' : '×';

        return Column(
          children: [
            InkWell(
              onTap: () => onSelect(scan),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 12),
                      child: Text(
                        markIcon,
                        style: TextStyle(
                          color: markColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scan.name,
                            style: AppFonts.heading(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: scan.ticketId,
                                  style: AppFonts.mono(
                                    color: const Color(0xFFA1A1AA),
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: '  ·  ${scan.benefit}',
                                  style: AppFonts.body(
                                    color: const Color(0xFFA1A1AA),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            getOutcomeLabel(scan.outcome),
                            style: AppFonts.mono(
                              color: markColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          scan.time,
                          style: AppFonts.mono(
                            color: const Color(0xFF71717A),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '>',
                          style: AppFonts.mono(
                            color: const Color(0xFF71717A),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (index < scans.length - 1)
              const Divider(color: Color(0xFF1F1F23), height: 1),
          ],
        );
      }).toList(),
    );
  }
}
