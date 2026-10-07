import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const LoginScreen({super.key, required this.onContinue});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'rahul@volunteer.tedxnagpur.in');
  final _pinController = TextEditingController(text: '1234');
  String _errorMsg = '';
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _pinController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = 'Enter your volunteer ID and PIN to continue.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      final res = await ApiService().login(email, password);
      if (mounted) {
        setState(() => _isLoading = false);
        if (res.containsKey('access_token')) {
          widget.onContinue();
        } else {
          setState(() => _errorMsg = res['message']?.toString() ?? 'Login failed');
        }
      }
    } catch (e) {
      debugPrint('[LOGIN EXCEPTION] $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'API Connection Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'EVENT OPERATIONS / VOLUNTEER',
                style: TextStyle(
                  color: TEDxColors.tedRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    height: 1.1,
                  ),
                  children: [
                    TextSpan(text: 'Keep the\nday moving'),
                    TextSpan(
                      text: '.',
                      style: TextStyle(color: TEDxColors.tedRed),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'One scan. A clear decision.\nA better event for everyone.',
                style: TextStyle(
                  color: TEDxColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),

              // Form Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Volunteer sign in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '18 OCT 2026',
                          style: TextStyle(
                            color: TEDxColors.tedRed.withValues(alpha: 0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Email or volunteer ID',
                      style: TextStyle(
                        color: TEDxColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'Your volunteer ID',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'PIN',
                      style: TextStyle(
                        color: TEDxColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'Enter your PIN',
                      ),
                    ),
                    if (_errorMsg.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMsg,
                        style: const TextStyle(
                          color: TEDxColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ActionButton(
                      text: _isLoading ? 'SIGNING IN...' : 'CONTINUE',
                      trailingArrow: _isLoading ? null : '→',
                      onPressed: _isLoading ? null : _handleSubmit,
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Use the credentials shared by your counter lead.',
                        style: TextStyle(
                          color: TEDxColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TEDx Event Operations',
                    style: TextStyle(color: TEDxColors.textMuted, fontSize: 11),
                  ),
                  Text(
                    'VOLUNTEER ACCESS',
                    style: TextStyle(color: TEDxColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
