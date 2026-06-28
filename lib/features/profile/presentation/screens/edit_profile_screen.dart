import 'package:flutter/material.dart';

import '../../../auth/data/auth_service.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';
import '../../../home/presentation/models/shop_data.dart' show kPrimary;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = AuthService();
  late final TextEditingController _username;
  late final TextEditingController _email;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _username = TextEditingController(
      text: (user?.displayName?.trim().isNotEmpty ?? false)
          ? user!.displayName!.trim()
          : 'Magdalena Succrose',
    );
    _email = TextEditingController(
      text: user?.email ?? 'magdalena83@mail.com',
    );
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await _auth.updateProfile(
        username: _username.text,
        contact: _email.text,
      );
      if (!mounted) return;
      _snack('Profile saved');
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
            _Header(title: 'Edit Profile'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                children: [
                  Center(child: _buildAvatar()),
                  const SizedBox(height: 28),
                  const AuthFieldLabel('Username'),
                  const SizedBox(height: 8),
                  AuthInputField(
                    hintText: 'Username',
                    icon: Icons.person_outline,
                    controller: _username,
                  ),
                  const SizedBox(height: 20),
                  const AuthFieldLabel('Email or Phone Number'),
                  const SizedBox(height: 8),
                  AuthInputField(
                    hintText: 'Email or Phone Number',
                    icon: Icons.mail_outline,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  const AuthFieldLabel('Account Liked With'),
                  const SizedBox(height: 8),
                  _buildLinkedAccount(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: AuthPrimaryButton(
                label: 'Save Changes',
                onPressed: _save,
                loading: _saving,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFFE0D6C3),
            child: Icon(Icons.person, color: Colors.white, size: 50),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: kPrimary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedAccount() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const GoogleLogo(size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Google',
              style: TextStyle(fontSize: 14, color: kDarkText),
            ),
          ),
          Icon(Icons.link, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
