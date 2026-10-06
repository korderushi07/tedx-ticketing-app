import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';

class SessionExpiredScreen extends StatelessWidget {
  final VoidCallback onSignIn;

  const SessionExpiredScreen({
    super.key,
    required this.onSignIn,
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
              // Lock Icon Container
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: TEDxColors.errorBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: TEDxColors.tedRed, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock_clock_rounded,
                    size: 48,
                    color: TEDxColors.tedRed,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Session Expired',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your volunteer security session has expired. Please sign in again to continue operating the counter.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TEDxColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: TEDxColors.textMuted, size: 18),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Security Notice: Volunteer sessions expire after inactive periods to maintain event data integrity.',
                        style: TextStyle(
                          color: TEDxColors.textMuted,
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
                text: 'Sign In Again',
                icon: Icons.login_rounded,
                onPressed: onSignIn,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
