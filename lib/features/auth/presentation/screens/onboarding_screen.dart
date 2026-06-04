import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'login_screen.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _OnboardPage(
                    title: 'Various Collections Of The Latest Products',
                    image: 'assets/images/onboarding1.png',
                    controller: _controller,
                    index: 0,
                  ),
                  _OnboardPage(
                    title: 'Complete Collection Of Colors And Sizes',
                    image: 'assets/images/onboarding2.png',
                    controller: _controller,
                    index: 1,
                  ),
                  _OnboardPage(
                    title: 'Find The Most Suitable Outfit For You',
                    image: 'assets/images/onboarding3.png',
                    controller: _controller,
                    index: 2,
                  ),
                ],
              ),
            ),
            // Animated page indicator driven by PageController.page
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double page = (_controller.hasClients && _controller.page != null)
                    ? _controller.page!
                    : _page.toDouble();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final double selectedness = (1.0 - (page - i).abs()).clamp(0.0, 1.0);
                    final double width = lerpDouble(8, 8, selectedness)!;
                    final Color color = Color.lerp(Colors.grey.shade300, Colors.deepPurple, selectedness)!;
                    return Container(
                      margin: const EdgeInsets.all(6),
                      width: width,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: const Color(0xFF5B4DE6),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  'Create Account',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              style: ButtonStyle(
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent)
              ),
              child: const Text('Already have an account'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String title;
  final String image;
  final PageController? controller;
  final int index;

  const _OnboardPage({
    required this.title,
    this.image = 'assets/images/onboarding1.png',
    this.controller,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: controller == null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                : AnimatedBuilder(
                    animation: controller!,
                    builder: (context, child) {
                      final double page = (controller!.hasClients && controller!.page != null)
                          ? controller!.page!
                          : index.toDouble();
                      final double delta = (page - index).abs();
                      // scale between 0.92 and 1.0
                      final double scale = (1 - math.min(delta * 0.08, 0.08));
                      final double translateX = (page - index) * 24; // slight parallax
                      return Transform.translate(
                        offset: Offset(translateX, 0),
                        child: Transform.scale(
                          scale: scale,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(56),
                            child: Image.asset(
                              image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
