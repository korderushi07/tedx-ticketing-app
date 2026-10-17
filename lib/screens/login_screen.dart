import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const LoginScreen({super.key, required this.onContinue});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(
    text: 'rahul@volunteer.tedxnagpur.in',
  );
  final _pinController = TextEditingController();
  String _errorMsg = '';
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _pinController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(
        () => _errorMsg = 'Enter your email and password or PIN to continue.',
      );
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
          setState(
            () => _errorMsg = res['message']?.toString() ?? 'Login failed',
          );
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'EVENT OPERATIONS  /  VOLUNTEER',
                style: AppFonts.mono(
                  color: const Color(0xFF71717A),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              RichText(
                text: TextSpan(
                  style: AppFonts.heading(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                    height: 1.05,
                  ),
                  children: [
                    const TextSpan(text: 'Keep the\nday moving'),
                    TextSpan(
                      text: '.',
                      style: AppFonts.heading(color: TEDxColors.tedRed),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'One scan. A clear decision.\nA better event for everyone.',
                style: AppFonts.body(
                  color: const Color(0xFFA1A1AA),
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 44),

              // Sign in section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Volunteer sign in',
                    style: AppFonts.heading(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '18 OCT 2026',
                    style: AppFonts.mono(
                      color: const Color(0xFF71717A),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Email label & input
              Text(
                'Volunteer email',
                style: AppFonts.body(
                  color: const Color(0xFFA1A1AA),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: AppFonts.body(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF101012),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Color(0xFF26262A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(
                      color: TEDxColors.tedRed,
                      width: 1.5,
                    ),
                  ),
                  hintText: 'rahul@volunteer.tedxnagpur.in',
                  hintStyle: AppFonts.body(color: const Color(0xFF52525B)),
                ),
              ),
              const SizedBox(height: 20),

              // Password / PIN label & input
              Text(
                'Password / PIN',
                style: AppFonts.body(
                  color: const Color(0xFFA1A1AA),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
                enableSuggestions: false,
                style: AppFonts.body(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF101012),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Color(0xFF26262A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(
                      color: TEDxColors.tedRed,
                      width: 1.5,
                    ),
                  ),
                  hintText: 'Enter your password or PIN',
                  hintStyle: AppFonts.body(color: const Color(0xFF52525B)),
                ),
              ),

              if (_errorMsg.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMsg,
                  style: AppFonts.body(
                    color: TEDxColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TEDxColors.tedRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isLoading ? 'SIGNING IN...' : 'CONTINUE',
                        style: AppFonts.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (!_isLoading)
                        Text(
                          '→',
                          style: AppFonts.body(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Use the credentials shared by your counter lead.',
                  style: AppFonts.body(
                    color: const Color(0xFF71717A),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
