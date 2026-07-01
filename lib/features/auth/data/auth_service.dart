import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(username.trim());

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'username': username.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await credential.user?.sendEmailVerification();

    return credential;
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No signed-in user.');
    if (user.emailVerified) return;
    await user.sendEmailVerification();
  }

  Future<bool> reloadAndCheckEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  static const String defaultCountryCode = '+855'; 

  static bool looksLikeEmail(String input) => input.contains('@');

  static String normalizePhone(String input) {
    final trimmed = input.trim();
    if (trimmed.startsWith('+')) {
      return '+${trimmed.substring(1).replaceAll(RegExp(r'\D'), '')}';
    }
    var digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = digits.substring(1);
    return '$defaultCountryCode$digits';
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(FirebaseAuthException e) verificationFailed,
    void Function(PhoneAuthCredential credential)? verificationCompleted,
    int? forceResendingToken,
  }) {
    return _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: forceResendingToken,
      verificationCompleted: verificationCompleted ?? (_) {},
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> confirmPhoneSignUp({
    required String verificationId,
    required String smsCode,
    required String username,
    required String phone,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    );
    final result = await _auth.signInWithCredential(credential);

    await result.user?.updateDisplayName(username.trim());
    await _firestore.collection('users').doc(result.user!.uid).set({
      'uid': result.user!.uid,
      'username': username.trim(),
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return result;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserCredential> signInWithFacebook() async {
    if (kIsWeb) {
      final provider = FacebookAuthProvider()..addScope('email');
      final result = await _auth.signInWithPopup(provider);
      await _upsertSocialUser(result.user);
      return result;
    }

    final loginResult = await FacebookAuth.instance.login(
      permissions: const ['email', 'public_profile'],
    );

    switch (loginResult.status) {
      case LoginStatus.success:
        final accessToken = loginResult.accessToken;
        if (accessToken == null) {
          throw FirebaseAuthException(
            code: 'facebook-no-token',
            message: 'Facebook did not return an access token.',
          );
        }
        final credential =
            FacebookAuthProvider.credential(accessToken.tokenString);
        final result = await _auth.signInWithCredential(credential);
        // Firebase doesn't always populate photoURL/displayName from a
        // Facebook credential, so pull the profile directly and sync it.
        Map<String, dynamic>? fbProfile;
        try {
          fbProfile = await FacebookAuth.instance.getUserData(
            fields: 'name,email,picture.width(400).height(400)',
          );
        } catch (_) {
          // Ignore: fall back to whatever Firebase already provided.
        }
        await _syncFacebookProfile(result.user, fbProfile);
        return result;
      case LoginStatus.cancelled:
        throw FirebaseAuthException(
          code: 'facebook-login-cancelled',
          message: 'Facebook sign-in was cancelled.',
        );
      case LoginStatus.failed:
      case LoginStatus.operationInProgress:
        throw FirebaseAuthException(
          code: 'facebook-login-failed',
          message: loginResult.message ?? 'Facebook sign-in failed.',
        );
    }
  }

  Future<UserCredential> linkPendingCredential({
    required String email,
    required String password,
    required AuthCredential pendingCredential,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await result.user?.linkWithCredential(pendingCredential);
    await _upsertSocialUser(result.user);
    return result;
  }

  /// Writes the Facebook name/photo onto the Firebase user (so
  /// `currentUser.displayName`/`photoURL` are populated for the UI) and then
  /// mirrors the profile into the `users/{uid}` doc.
  Future<void> _syncFacebookProfile(
    User? user,
    Map<String, dynamic>? profile,
  ) async {
    if (user == null) return;

    final name = (profile?['name'] as String?)?.trim();
    final photoUrl =
        (profile?['picture'] as Map?)?['data']?['url'] as String?;

    if (name != null && name.isNotEmpty && name != user.displayName) {
      await user.updateDisplayName(name);
    }
    if (photoUrl != null &&
        photoUrl.isNotEmpty &&
        photoUrl != user.photoURL) {
      await user.updatePhotoURL(photoUrl);
    }
    await user.reload();

    await _upsertSocialUser(_auth.currentUser ?? user);
  }

  Future<void> _upsertSocialUser(User? user) async {
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'username': user.displayName ?? '',
      'email': user.email ?? '',
      'photoUrl': user.photoURL ?? '',
      'provider': 'facebook',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateProfile({
    required String username,
    required String contact,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No signed-in user.');

    final name = username.trim();
    if (name.isNotEmpty && name != user.displayName) {
      await user.updateDisplayName(name);
    }

    await _firestore.collection('users').doc(user.uid).set({
      'username': name,
      'email': contact.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No signed-in user.');
    final email = user.email;
    if (email == null) {
      throw StateError('This account has no email/password sign-in.');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await FacebookAuth.instance.logOut();
      } catch (_) {
        // Ignore: no active Facebook session to clear.
      }
    }
    await _auth.signOut();
  }

  static String messageFromError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'That email address looks invalid.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'weak-password':
          return 'Password is too weak (use at least 6 characters).';
        case 'requires-recent-login':
          return 'For security, please sign out and sign in again before '
              'changing your password.';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a moment and try again.';
        case 'invalid-phone-number':
        case 'missing-phone-number':
          return 'That phone number looks invalid. Include the country code, '
              'e.g. +85512345678.';
        case 'invalid-verification-code':
          return 'That code is incorrect. Check the SMS and try again.';
        case 'invalid-verification-id':
        case 'session-expired':
          return 'This code has expired. Request a new one.';
        case 'quota-exceeded':
          return 'SMS limit reached. Please try again later.';
        case 'captcha-check-failed':
          return 'reCAPTCHA verification failed. Please try again.';
        case 'operation-not-allowed':
        case 'configuration-not-found':
          return 'This sign-in method is not enabled in Firebase. '
              'Enable it in Firebase Console > Authentication > Sign-in method.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email but a '
              'different sign-in method. Sign in with that method instead.';
        case 'facebook-login-cancelled':
          return 'Facebook sign-in was cancelled.';
        case 'facebook-login-failed':
        case 'facebook-no-token':
          return error.message ??
              'Facebook sign-in failed. Please try again.';
        default:
          return 'Auth error [${error.code}]: '
              '${error.message ?? 'please try again.'}';
      }
    }
    return 'Something went wrong: $error';
  }
}
