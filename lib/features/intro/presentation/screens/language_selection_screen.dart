import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scisolve/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  const LanguageSelectionScreen({super.key, required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    // Current Locale
    final currentLocale = Localizations.localeOf(context);
    final isArabic = currentLocale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              const Center(
                child: FaIcon(
                  FontAwesomeIcons.atom,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Dynamic Welcome Message
              Text(
                isArabic ? "مرحباً بك في SciSolve" : "Welcome to SciSolve",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                isArabic
                    ? "المساعد الذكي للرياضيات والعلوم"
                    : "Your AI Assistant for Math & Science",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              Text(
                isArabic ? "اختر تفضيلاتك" : "Choose your preferences",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // English Option
              _buildLanguageOption(
                context,
                title: "English",
                subtitle: "Hello",
                isSelected: !isArabic,
                onTap: () {
                  onLocaleChange(const Locale('en'));
                  // Small delay to let UI update
                  Future.delayed(const Duration(milliseconds: 300), () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => const OnboardingScreen()));
                  });
                },
              ),

              const SizedBox(height: 16),

              // Arabic Option
              _buildLanguageOption(
                context,
                title: "العربية",
                subtitle: "مرحباً",
                isSelected: isArabic,
                onTap: () {
                  onLocaleChange(const Locale('ar'));
                  Future.delayed(const Duration(milliseconds: 300), () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => const OnboardingScreen()));
                  });
                },
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context,
      {required String title,
      required String subtitle,
      required bool isSelected,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.white : Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.black54 : Colors.white54,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const FaIcon(FontAwesomeIcons.check,
                  size: 16, color: Colors.black)
            else
              const FaIcon(FontAwesomeIcons.chevronRight,
                  size: 16, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
