import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/verification_screen.dart';
import 'phone_verification_screen.dart';
import '../widgets/link_facebook_sheet.dart';
import '../../../home/presentation/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade600),
    );
  }

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final contact = _emailController.text.trim();

    if (username.isEmpty || contact.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }

    if (AuthService.looksLikeEmail(contact)) {
      await _registerWithEmail(username: username, email: contact);
    } else {
      await _registerWithPhone(
        username: username,
        phone: AuthService.normalizePhone(contact),
      );
    }
  }

  Future<void> _registerWithEmail({
    required String username,
    required String email,
  }) async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      _showError('Please enter a password.');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.register(
        username: username,
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerificationScreen(email: email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(AuthService.messageFromError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _registerWithPhone({
    required String username,
    required String phone,
  }) async {
    setState(() => _loading = true);
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phone,
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _loading = false);
          _showError(AuthService.messageFromError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() => _loading = false);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PhoneVerificationScreen(
                username: username,
                phone: phone,
                verificationId: verificationId,
                resendToken: resendToken,
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(AuthService.messageFromError(e));
    }
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _signUpWithFacebook() async {
    setState(() => _loading = true);
    try {
      await _authService.signInWithFacebook();
      if (!mounted) return;
      _goHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'account-exists-with-different-credential' &&
          e.credential != null &&
          (e.email ?? '').isNotEmpty) {
        final linked = await showLinkFacebookSheet(
          context: context,
          email: e.email!,
          pendingCredential: e.credential!,
        );
        if (linked && mounted) _goHome();
      } else {
        _showError(AuthService.messageFromError(e));
      }
    } catch (e) {
      if (!mounted) return;
      _showError(AuthService.messageFromError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kDarkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Start learning with create your account',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 32),
              const AuthFieldLabel('Username'),
              const SizedBox(height: 8),
              AuthInputField(
                controller: _usernameController,
                hintText: 'Create your username',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              const AuthFieldLabel('Email or Phone Number'),
              const SizedBox(height: 8),
              AuthInputField(
                controller: _emailController,
                hintText: 'Enter your email or phone number',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              const AuthFieldLabel('Password'),
              const SizedBox(height: 8),
              AuthInputField(
                controller: _passwordController,
                hintText: 'Create your password',
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
              const SizedBox(height: 8),
              Text(
                'Password is used for email sign-up. With a phone number we '
                'send a one-time SMS code instead.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 24),
              AuthPrimaryButton(
                label: 'Create Account',
                loading: _loading,
                onPressed: _register,
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Or using other method',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ),
              const SizedBox(height: 20),
              AuthSocialButton(
                label: 'Sign Up with Google',
                icon: const GoogleLogo(),
                onPressed: () {},
              ),
              const SizedBox(height: 14),
              AuthSocialButton(
                label: 'Sign Up with Facebook',
                icon: const Icon(
                  Icons.facebook,
                  color: Color(0xFF1877F2),
                  size: 24,
                ),
                onPressed: _loading ? () {} : _signUpWithFacebook,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
