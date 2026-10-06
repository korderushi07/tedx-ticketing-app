import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';

class NetworkErrorScreen extends StatefulWidget {
  final VoidCallback onRetry;
  final VoidCallback onBackToScanner;

  const NetworkErrorScreen({
    super.key,
    required this.onRetry,
    required this.onBackToScanner,
  });

  @override
  State<NetworkErrorScreen> createState() => _NetworkErrorScreenState();
}

class _NetworkErrorScreenState extends State<NetworkErrorScreen> {
  bool _isRetrying = false;

  void _handleRetry() async {
    setState(() => _isRetrying = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() => _isRetrying = false);
      widget.onRetry();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Warning Wifi Icon Box
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: TEDxColors.warningBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: TEDxColors.warningBorder, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 48,
                    color: TEDxColors.warning,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Connection Lost',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'We couldn\'t connect to the server. Please check your Wi-Fi or cellular network connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TEDxColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Status Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: TEDxColors.textMuted, size: 18),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Offline Cache Mode: Scans recorded while offline will automatically sync once connection is restored.',
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
                text: 'Retry Connection',
                icon: Icons.refresh_rounded,
                isLoading: _isRetrying,
                onPressed: _handleRetry,
              ),
              const SizedBox(height: 12),
              TEDxButton(
                text: 'Back to Scanner',
                isPrimary: false,
                onPressed: widget.onBackToScanner,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
