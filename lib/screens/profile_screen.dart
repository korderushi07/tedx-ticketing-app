import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/tedx_components.dart';
import '../models/app_models.dart';

class ProfileScreen extends StatelessWidget {
  final VolunteerModel volunteer;
  final VoidCallback onLogout;
  final VoidCallback onSwitchCounter;
  final VoidCallback? onTriggerOfflineDemo;
  final VoidCallback? onTriggerExpiredDemo;

  const ProfileScreen({
    super.key,
    required this.volunteer,
    required this.onLogout,
    required this.onSwitchCounter,
    this.onTriggerOfflineDemo,
    this.onTriggerExpiredDemo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TEDxColors.bgDark,
      appBar: AppBar(
        title: const Text('Volunteer Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: TEDxColors.tedRed,
                      child: Text(
                        volunteer.avatarInitials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            volunteer.name,
                            style: const TextStyle(
                              color: TEDxColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${volunteer.id} • ${volunteer.role}',
                            style: const TextStyle(
                              color: TEDxColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            volunteer.eventName,
                            style: const TextStyle(
                              color: TEDxColors.tedRed,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Active Assignment Section
              const Text(
                'Active Assignment',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          volunteer.counterName,
                          style: const TextStyle(
                            color: TEDxColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Station Code: ${volunteer.counterId}',
                          style: const TextStyle(
                            color: TEDxColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: onSwitchCounter,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TEDxColors.tedRed,
                        side: const BorderSide(color: TEDxColors.tedRed),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: const Text('Switch Station'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // System Settings & Options
              const Text(
                'Account & Operations Options',
                style: TextStyle(
                  color: TEDxColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: TEDxColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: TEDxColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _menuTile(
                      icon: Icons.settings_outlined,
                      title: 'Account Settings',
                      subtitle: 'Volunteer profile & sync preferences',
                      onTap: () {},
                    ),
                    const Divider(color: TEDxColors.cardBorder, height: 1),
                    _menuTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Security Password',
                      subtitle: 'Update operational access key',
                      onTap: () {},
                    ),
                    const Divider(color: TEDxColors.cardBorder, height: 1),
                    _menuTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Operational Desk',
                      subtitle: 'Contact Lead Volunteer / Tech Support',
                      onTap: () {},
                    ),
                    const Divider(color: TEDxColors.cardBorder, height: 1),
                    _menuTile(
                      icon: Icons.wifi_off_rounded,
                      title: 'Test Connection Lost State',
                      subtitle: 'Simulate network error screen',
                      onTap: onTriggerOfflineDemo ?? () {},
                    ),
                    const Divider(color: TEDxColors.cardBorder, height: 1),
                    _menuTile(
                      icon: Icons.lock_clock_outlined,
                      title: 'Test Session Expired State',
                      subtitle: 'Simulate auth session expiration',
                      onTap: onTriggerExpiredDemo ?? () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Logout Button
              TEDxButton(
                text: 'Log Out Session',
                isPrimary: false,
                icon: Icons.logout_rounded,
                onPressed: onLogout,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: TEDxColors.textSecondary, size: 20),
      title: Text(
        title,
        style: const TextStyle(
          color: TEDxColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: TEDxColors.textMuted,
          fontSize: 11,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: TEDxColors.textMuted,
        size: 18,
      ),
    );
  }
}
