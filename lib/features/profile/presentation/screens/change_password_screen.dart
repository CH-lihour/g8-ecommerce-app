import 'package:flutter/material.dart';

import '../../../auth/data/auth_service.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _auth = AuthService();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changeNow() async {
    FocusScope.of(context).unfocus();
    final current = _currentController.text;
    final pwd = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty) {
      _snack('Enter your current password');
      return;
    }
    if (pwd.length < 6) {
      _snack('Password must be at least 6 characters');
      return;
    }
    if (pwd != confirm) {
      _snack('Passwords do not match');
      return;
    }

    setState(() => _saving = true);
    try {
      await _auth.changePassword(currentPassword: current, newPassword: pwd);
      if (!mounted) return;
      _snack('Password changed');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _snack(AuthService.messageFromError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                children: [
                  const AuthFieldLabel('Current Password'),
                  const SizedBox(height: 8),
                  AuthInputField(
                    hintText: 'Enter current password',
                    icon: Icons.lock_outline,
                    controller: _currentController,
                    obscureText: _obscureCurrent,
                    suffix: _eyeButton(
                      _obscureCurrent,
                      () => setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const AuthFieldLabel('New Password'),
                  const SizedBox(height: 8),
                  AuthInputField(
                    hintText: 'Enter new password',
                    icon: Icons.lock_outline,
                    controller: _newController,
                    obscureText: _obscureNew,
                    suffix: _eyeButton(
                      _obscureNew,
                      () => setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const AuthFieldLabel('Confirm Password'),
                  const SizedBox(height: 8),
                  AuthInputField(
                    hintText: 'Confirm your new password',
                    icon: Icons.lock_outline,
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    suffix: _eyeButton(
                      _obscureConfirm,
                      () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: AuthPrimaryButton(
                label: 'Change Now',
                onPressed: _changeNow,
                loading: _saving,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eyeButton(bool obscured, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: Colors.grey.shade400,
        size: 20,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.arrow_back, size: 22, color: kDarkText),
            ),
          ),
          const Expanded(
            child: Text(
              'Change Password',
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
}
