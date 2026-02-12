import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scisolve/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:scisolve/main.dart'; // import for accessing main locale logic if needed, or we just navigate using arguments

class SplashScreen extends StatefulWidget {
  final Function(Locale) onLocaleFound;

  const SplashScreen({super.key, required this.onLocaleFound});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Simulate Asset Loading / Auth Check
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // 2. Detect System Locale logic is handled by MaterialApp in main,
      // but here we can explicitly confirm or just pass through.
      // For now, we assume first run -> Onboarding

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: const FaIcon(
                FontAwesomeIcons.atom,
                size: 64,
                color: Colors.white,
              )
                  .animate()
                  .scale(duration: 1.seconds, curve: Curves.easeInOut)
                  .then()
                  .shimmer(duration: 2.seconds),
            ),
            const SizedBox(height: 32),
            const Text(
              "SciSolve",
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
