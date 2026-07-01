import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/auth_service.dart';
import 'auth_widgets.dart';

Future<bool> showLinkFacebookSheet({
  required BuildContext context,
  required String email,
  required AuthCredential pendingCredential,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _LinkFacebookSheet(
      email: email,
      pendingCredential: pendingCredential,
    ),
  ).then((value) => value ?? false);
}

class _LinkFacebookSheet extends StatefulWidget {
  const _LinkFacebookSheet({
    required this.email,
    required this.pendingCredential,
  });

  final String email;
  final AuthCredential pendingCredential;

  @override
  State<_LinkFacebookSheet> createState() => _LinkFacebookSheetState();
}

class _LinkFacebookSheetState extends State<_LinkFacebookSheet> {
  final _authService = AuthService();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _link() async {
    final password = _passwordController.text;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (password.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Please enter your password.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.linkPendingCredential(
        email: widget.email,
        password: password,
        pendingCredential: widget.pendingCredential,
      );
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(AuthService.messageFromError(e)),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Link your account',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.email} already has an account with a password. Enter it '
            'once to connect Facebook to that account.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          const AuthFieldLabel('Password'),
          const SizedBox(height: 8),
          AuthInputField(
            controller: _passwordController,
            hintText: 'Enter your password',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffix: IconButton(
              splashRadius: 20,
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey.shade500,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 28),
          AuthPrimaryButton(
            label: 'Link & Continue',
            loading: _loading,
            onPressed: _link,
          ),
        ],
      ),
    );
  }
}
