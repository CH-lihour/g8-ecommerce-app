import 'package:flutter/material.dart';

import '../../../auth/data/auth_service.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../home/presentation/models/shop_data.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'language_screen.dart';
import 'legal_policies_screen.dart';
import 'toggle_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  /// When false the leading back arrow is hidden (used when this screen is the
  /// root of the "My Profile" bottom-nav tab rather than a pushed route).
  final bool showBack;

  const SettingsScreen({super.key, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _sectionTitle('General'),
                  const SizedBox(height: 8),
                  _SettingsTile(
                    icon: Icons.person_outline,
                    label: 'Edit Profile',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_none,
                    label: 'Notifications',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ToggleSettingsScreen(
                          title: 'Notifications',
                          options: {
                            'Payment': true,
                            'Tracking': true,
                            'Complete Order': true,
                            'Notification': true,
                          },
                        ),
                      ),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.shield_outlined,
                    label: 'Security',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ToggleSettingsScreen(
                          title: 'Security',
                          options: {
                            'Face ID': true,
                            'Remember Password': true,
                            'Touch ID': true,
                          },
                        ),
                      ),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.language,
                    label: 'Language',
                    trailingText: 'English',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LanguageScreen()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Preferences'),
                  const SizedBox(height: 8),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    label: 'Legal and Policies',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LegalPoliciesScreen(),
                      ),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportScreen(),
                      ),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.logout,
                    label: 'Logout',
                    danger: true,
                    showChevron: false,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => const _LogoutDialog(),
    );
    if (shouldLogout != true || !context.mounted) return;

    await AuthService().signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child:
                    Icon(Icons.arrow_back_ios_new, size: 18, color: kDarkText),
              ),
            )
          else
            const SizedBox(width: 40),
          const Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: kDarkText,
              ),
            ),
          ),
          const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.more_vert, color: kDarkText),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: kDarkText,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final bool danger;
  final bool showChevron;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailingText,
    this.danger = false,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFF05A5A) : kDarkText;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              ),
              const SizedBox(width: 8),
            ],
            if (showChevron)
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }
}

/// Centered confirmation dialog for logout. Pops `true` on confirm, `false`
/// (or null) on cancel/dismiss.
class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Icon(Icons.close, color: Colors.grey.shade600, size: 22),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kDarkText,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(true),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF05A5A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
