// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:g8_eccomerce_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:g8_eccomerce_app/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('Splash shows title and navigates to Onboarding -> Register', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    // Splash should show app title
    expect(find.text('Kutuku'), findsOneWidget);

    // Wait past the splash delay and settle navigation
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    // HomeScreen contains 'Home' text
    expect(find.text('Create Account'), findsOneWidget);

    // Tap Create Account to go to Register screen
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    // Register screen should show Email or Phone Number label
    expect(find.text('Email or Phone Number'), findsWidgets);
  });

  testWidgets('Onboarding sign in opens Login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Login Account'), findsOneWidget);
  });
}
