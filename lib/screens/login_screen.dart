import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController(text: 'VOL-024');
  final _passwordController = TextEditingController(text: '••••••••');
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      widget.onLoginSuccess();
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
              const SizedBox(height: 20),
              // Top Brand Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TEDxColors.tedRedSubtle,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: TEDxColors.tedRed.withOpacity(0.3)),
                ),
                child: const Text(
                  'INTERNAL OPERATIONS PORTAL',
                  style: TextStyle(
                    color: TEDxColors.tedRed,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const TEDxLogo(fontSize: 36, subtitle: 'YCCE 2026'),
              const SizedBox(height: 36),
              const Text(
                'Volunteer Login',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in with your assigned volunteer credentials to begin scanning attendee passes.',
                style: TextStyle(
                  color: TEDxColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),
              // Form Fields
              const Text(
                'Volunteer ID / Email',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _idController,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.badge_outlined, color: TEDxColors.textSecondary, size: 20),
                  hintText: 'e.g. VOL-024',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Password',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: TEDxColors.textSecondary, size: 20),
                  hintText: 'Enter password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: TEDxColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contact your Desk Lead to reset volunteer password.'),
                        backgroundColor: TEDxColors.cardDark,
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: TEDxColors.textSecondary,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TEDxButton(
                text: 'Sign In',
                icon: Icons.arrow_forward_rounded,
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 32),
              // Security info box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: TEDxColors.textMuted, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Authorized Personnel Only. All scan actions are logged with Volunteer ID and Counter Timestamp.',
                        style: TextStyle(
                          color: TEDxColors.textMuted,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
