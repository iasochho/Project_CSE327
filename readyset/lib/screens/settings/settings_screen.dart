// lib/screens/settings/settings_screen.dart
// OBSERVER PATTERN: watches toggle state providers
// STRATEGY PATTERN: signOut delegates to AuthService which uses the right AuthStrategy

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/shared_widgets.dart';
import '../auth/login_screen.dart';

// FIX: Removed duplicate local provider declarations for notificationsEnabledProvider,
// darkModeEnabledProvider, and metricUnitsProvider — they are now defined in
// app_providers.dart. Declaring them here caused "already defined" errors and made
// authServiceProvider unreachable.

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsEnabledProvider);
    final darkMode      = ref.watch(darkModeEnabledProvider);
    final metric        = ref.watch(metricUnitsProvider);

    return Scaffold(
      appBar: const KZAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text('Manage your experience and security',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 28),

          // ── Preferences ─────────────────────────────────────────────────────
          _SectionLabel('PREFERENCES'),
          const SizedBox(height: 10),
          _SettingsGroup(
            children: [
              _ToggleTile(
                icon: Icons.notifications_outlined,
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: AppColors.primary,
                label: 'Notifications',
                value: notifications,
                onChanged: (v) =>
                    ref.read(notificationsEnabledProvider.notifier).state = v,
              ),
              const _Divider(),
              _ToggleTile(
                icon: Icons.dark_mode_outlined,
                iconBgColor: const Color(0xFFF1F5F9),
                iconColor: AppColors.textPrimary,
                label: 'Dark Mode',
                value: darkMode,
                onChanged: (v) =>
                    ref.read(darkModeEnabledProvider.notifier).state = v,
              ),
              const _Divider(),
              _ToggleTile(
                icon: Icons.straighten_outlined,
                iconBgColor: const Color(0xFFCCFBF1),
                iconColor: AppColors.teal,
                label: 'Metric Units (kg / km)',
                value: metric,
                onChanged: (v) =>
                    ref.read(metricUnitsProvider.notifier).state = v,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Account & Security ───────────────────────────────────────────────
          _SectionLabel('ACCOUNT & SECURITY'),
          const SizedBox(height: 10),
          _SettingsGroup(
            children: [
              _NavTile(
                icon: Icons.lock_reset_outlined,
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: AppColors.primary,
                label: 'Change Password',
                onTap: () async {
                  final user = ref.read(userProvider);
                  if (user.email.isNotEmpty) {
                    await ref
                        .read(authServiceProvider)
                        .sendPasswordReset(user.email);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset email sent!'),
                          backgroundColor: Color(0xFF005DA7),
                        ),
                      );
                    }
                  }
                },
              ),
              const _Divider(),
              _NavTile(
                icon: Icons.shield_outlined,
                iconBgColor: const Color(0xFFCCFBF1),
                iconColor: AppColors.teal,
                label: 'Privacy Policy',
                onTap: () {},
              ),
              const _Divider(),
              _NavTile(
                icon: Icons.help_outline,
                iconBgColor: const Color(0xFFF1F5F9),
                iconColor: AppColors.textSecondary,
                label: 'Help & Support',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Log Out ──────────────────────────────────────────────────────────
          // Strategy pattern: AuthService.signOut picks the correct sign-out strategy
          GestureDetector(
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: AppColors.error, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Log Out',
                    style: TextStyle(
                        color: AppColors.error,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2, color: AppColors.textSecondary),
      );
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 2))
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(label,
                    style: Theme.of(context).textTheme.titleMedium)),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
        height: 1, indent: 70, endIndent: 16, color: Color(0xFFF1F3F5));
}
