import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scisolve/features/chat/presentation/screens/chat_screen.dart';
import 'package:scisolve/core/widgets/sci_text_field.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'package:scisolve/core/services/auth_service.dart';
import 'package:scisolve/core/utils/sci_toast.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;

    if (email.isEmpty || password.isEmpty) {
      SciToast.show(context, l10n.fillAllFields, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      await authService.signIn(email: email, password: password);

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/chat', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        SciToast.show(context, isArabic ? "فشل تسجيل الدخول" : "Login Failed: $e",
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Dynamic
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.login,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic ? "مرحباً بعودتك" : "Welcome back",
                style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 16),
              ),
              const SizedBox(height: 60),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SciTextField(
                        controller: _emailController,
                        label: isArabic ? "البريد الإلكتروني" : "Email",
                        icon: FontAwesomeIcons.envelope,
                        isArabic: isArabic,
                      ),
                      const SizedBox(height: 20),
                      SciTextField(
                        controller: _passwordController,
                        label: isArabic ? "كلمة المرور" : "Password",
                        icon: FontAwesomeIcons.lock,
                        isObscure: true,
                        isArabic: isArabic,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: isArabic
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ForgotPasswordScreen())),
                          child: Text(
                            isArabic ? "نسيت كلمة المرور؟" : "Forgot Password?",
                            style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        // Style handled by Theme typically, but preserving shape
                        style: ElevatedButton.styleFrom(
                          // In light mode we want black button (inverse), in dark mode white button (inverse)
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(isArabic ? "دخول" : "Log In",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Icon(
                                      isArabic
                                          ? Icons.arrow_back
                                          : Icons.arrow_forward,
                                      size: 18)
                                ],
                              ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => const SignupScreen())),
                          child: RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54),
                                children: [
                                  TextSpan(
                                      text: isArabic
                                          ? "جديد هنا؟ "
                                          : "New here? "),
                                  TextSpan(
                                      text: isArabic
                                          ? "أنشئ حساباً"
                                          : "Create Account",
                                      style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold))
                                ]),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
