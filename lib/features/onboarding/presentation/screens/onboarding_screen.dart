import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scisolve/main.dart'; // To access setLocale/setThemeMode

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLanguageSelected = false;

  final Map<String, String> _languages = {
    'en': 'English',
    'ar': 'العربية',
    'de': 'Deutsch',
    'ja': '日本語',
    'zh': '简体中文',
    'hi': 'हिन्दी',
    'ru': 'Русский',
    'es': 'Español',
    'fr': 'Français',
    'tr': 'Türkçe',
    'it': 'Italiano',
    'pt': 'Português',
    'ko': '한국어',
    'id': 'Bahasa Indonesia',
    'ur': 'اردو',
    'ps': 'پښتو',
    'fa': 'فارسی',
  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _addPostFrameCallback(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }

  void _setLanguage(String code) {
    SciSolveApp.setLocale(context, Locale(code));
    setState(() => _isLanguageSelected = true);
    // REMOVED future.delayed navigation – should stay on first onboarding page.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Background gradient for premium feel
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter)
        : const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter);

    final fgColor = isDark ? Colors.white : Colors.black;

    // Separate language page from content pages for better flow
    if (!_isLanguageSelected) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: bgGradient),
          child: Stack(children: [
            Opacity(
                opacity: 0.15,
                child: const _GridPattern()), // Light Grid Pattern
            SafeArea(child: _buildLanguageSelection(fgColor)),
          ]),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Stack(
          children: [
            Opacity(
                opacity: 0.15,
                child: const _GridPattern()), // Light Grid Pattern
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                              isDark ? Icons.light_mode : Icons.dark_mode,
                              color: fgColor.withOpacity(0.7)),
                          onPressed: () => SciSolveApp.setThemeMode(context,
                              isDark ? ThemeMode.light : ThemeMode.dark),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _isLanguageSelected = false;
                            // Reset controller ? No, keep state.
                          }),
                          child: Text(l10n.language,
                              style: TextStyle(
                                  color: fgColor.withOpacity(0.7),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (idx) =>
                          setState(() => _currentPage = idx),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildContentPage(
                          title: l10n.onboardingTitle1,
                          desc: l10n.onboardingDesc1,
                          icon: FontAwesomeIcons.atom,
                          fgColor: fgColor,
                        ),
                        _buildContentPage(
                          title: l10n.onboardingTitle2,
                          desc: l10n.onboardingDesc2,
                          icon: FontAwesomeIcons.cameraRetro,
                          fgColor: fgColor,
                        ),
                        _buildAuthPage(l10n, fgColor),
                      ],
                    ),
                  ),

                  // Bottom Indicator & Controls
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Smooth Page Indicator
                        Row(
                          children: List.generate(3, (index) {
                            final isActive = index == _currentPage;
                            return AnimatedContainer(
                              duration: 300.ms,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: isActive ? 24 : 8,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? fgColor
                                    : fgColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        // Next Button
                        if (_currentPage < 2)
                          FloatingActionButton(
                            onPressed: () {
                              _pageController.nextPage(
                                  duration: 500.ms, curve: Curves.easeInOut);
                            },
                            backgroundColor: fgColor,
                            foregroundColor:
                                isDark ? Colors.black : Colors.white,
                            elevation: 0,
                            mini: false,
                            shape: const CircleBorder(),
                            child: const Icon(Icons.arrow_forward),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelection(Color fgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Icon(FontAwesomeIcons.globe, size: 48, color: fgColor),
        const SizedBox(height: 24),
        Text("Select Language",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: fgColor, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Choose your preferred language to continue",
            textAlign: TextAlign.center,
            style: TextStyle(color: fgColor.withOpacity(0.5), fontSize: 14)),
        const SizedBox(height: 40),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _languages.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (ctx, index) {
              final code = _languages.keys.elementAt(index);
              final name = _languages.values.elementAt(index);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: fgColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: fgColor.withOpacity(0.1)),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(name,
                      style: TextStyle(
                          color: fgColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 14, color: fgColor.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  onTap: () => _setLanguage(code),
                ),
              ).animate().fadeIn(delay: (50 * index).ms).slideX();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentPage(
      {required String title,
      required String desc,
      required IconData icon,
      required Color fgColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fgColor.withOpacity(0.05),
            ),
            child: FaIcon(icon, size: 80, color: fgColor),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 48),
          Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: fgColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2))
              .animate()
              .fadeIn()
              .slideY(begin: 0.3, end: 0, delay: 200.ms),
          const SizedBox(height: 16),
          Text(desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: fgColor.withOpacity(0.6),
                      fontSize: 16,
                      height: 1.5))
              .animate()
              .fadeIn()
              .slideY(begin: 0.3, end: 0, delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildAuthPage(AppLocalizations l10n, Color fgColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.rocket, size: 80, color: fgColor)
              .animate()
              .shake(duration: 800.ms),
          const SizedBox(height: 40),
          Text(l10n.startJourney,
              style: TextStyle(
                  color: fgColor, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(l10n.onboardingAuthDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: fgColor.withOpacity(0.6), fontSize: 16)),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: fgColor,
                  foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              child: Text(l10n.login),
            ),
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: fgColor,
                  side: BorderSide(color: fgColor.withOpacity(0.3), width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              child: Text(l10n.createAccount),
            ),
          ).animate().fadeIn(delay: 700.ms),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// Simple Grid Pattern Painter
class _GridPattern extends StatelessWidget {
  const _GridPattern();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _GridPainter(context),
    );
  }
}

class _GridPainter extends CustomPainter {
  final BuildContext context;
  _GridPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.05)
      ..strokeWidth = 1;

    final step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
