import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

class AttendeeVerificationScreen extends StatelessWidget {
  final CounterInfo counter;

  const AttendeeVerificationScreen({
    super.key,
    required this.counter,
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
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(TEDxColors.tedRed),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                counter.name.toUpperCase(),
                style: const TextStyle(
                  color: TEDxColors.tedRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'VERIFYING TICKET',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Checking ticket and benefit availability…',
                style: TextStyle(
                  color: TEDxColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              const Text(
                'Please wait before issuing the benefit.',
                style: TextStyle(
                  color: TEDxColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
