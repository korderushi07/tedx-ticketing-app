import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TEDxLogo extends StatelessWidget {
  final double fontSize;
  final String subtitle;
  final bool showSubtitle;

  const TEDxLogo({
    super.key,
    this.fontSize = 24.0,
    this.subtitle = 'YCCE 2026',
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext me) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'TED',
                style: TextStyle(
                  color: TEDxColors.tedRed,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                ),
              ),
              TextSpan(
                text: 'x',
                style: TextStyle(
                  color: TEDxColors.tedRed,
                  fontSize: fontSize * 0.9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        if (showSubtitle && subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle.toUpperCase(),
            style: TextStyle(
              color: TEDxColors.textSecondary,
              fontSize: fontSize * 0.38,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
    this.icon,
  });

  factory StatusBadge.available() {
    return const StatusBadge(
      label: 'AVAILABLE',
      textColor: TEDxColors.success,
      bgColor: TEDxColors.successBg,
      borderColor: TEDxColors.successBorder,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  factory StatusBadge.claimed() {
    return const StatusBadge(
      label: 'CLAIMED',
      textColor: TEDxColors.warning,
      bgColor: TEDxColors.warningBg,
      borderColor: TEDxColors.warningBorder,
      icon: Icons.history_toggle_off_rounded,
    );
  }

  factory StatusBadge.notIncluded() {
    return const StatusBadge(
      label: 'NOT INCLUDED',
      textColor: TEDxColors.error,
      bgColor: TEDxColors.errorBg,
      borderColor: TEDxColors.errorBorder,
      icon: Icons.remove_circle_outline_rounded,
    );
  }

  factory StatusBadge.active() {
    return const StatusBadge(
      label: 'ACTIVE',
      textColor: TEDxColors.success,
      bgColor: TEDxColors.successBg,
      borderColor: TEDxColors.successBorder,
      icon: Icons.fiber_manual_record,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TEDxColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TEDxColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: TEDxColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 16, color: accentColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TEDxButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;
  final bool isLoading;

  const TEDxButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: TEDxColors.tedRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: TEDxColors.textPrimary,
            side: const BorderSide(color: TEDxColors.cardBorder, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
