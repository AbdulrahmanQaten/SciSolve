import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scisolve/core/widgets/sci_text_field.dart';
import 'package:scisolve/core/widgets/sci_dropdown.dart';
import 'package:scisolve/features/settings/presentation/screens/legal_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scisolve/core/services/auth_service.dart';
import 'package:scisolve/core/utils/sci_toast.dart';
import 'verification_code_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedEducationLevel = "";

  bool _isLoading = false;

  void _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final education = _selectedEducationLevel;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        education.isEmpty) {
      SciToast.show(context, l10n.fillAllFields, isError: true);
      return;
    }

    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      SciToast.show(
          context, isArabic ? "البريد الإلكتروني غير صالح" : "Invalid email",
          isError: true);
      return;
    }

    if (password.length < 6) {
      SciToast.show(context,
          isArabic ? "كلمة المرور قصيرة جداً (6+)" : "Password too short (6+)",
          isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      await authService.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'education_level': education,
        },
      );

      if (mounted) {
        SciToast.show(
            context,
            isArabic
                ? "تم التسجيل! يرجى التحقق من بريدك."
                : "Signed up! Please verify your email.");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationCodeScreen(email: email),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        String message = e.message;
        if (message.contains("User already registered") ||
            message.contains("already exists")) {
          message = isArabic
              ? "هذا البريد مستخدم بالفعل"
              : "Email already registered";
        }
        SciToast.show(context, message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        // You might want to parse 'e' to show better messages (e.g. user already exists)
        SciToast.show(context, l10n.errorOccurred + " $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedEducationLevel.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      _selectedEducationLevel = l10n.university;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black;
    final linkColor = isDark ? Colors.blue.shade200 : Colors.blue.shade700;

    final List<String> eduOptions = [
      l10n.university,
      l10n.highSchool,
      l10n.researcher,
      l10n.hobbyist
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.createAccount,
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              SciTextField(
                controller: _nameController,
                label: l10n.fullName,
                icon: FontAwesomeIcons.user,
                isArabic: isArabic,
              ),
              const SizedBox(height: 16),
              SciTextField(
                controller: _emailController,
                label: l10n.email,
                icon: FontAwesomeIcons.envelope,
                isArabic: isArabic,
              ),
              const SizedBox(height: 16),
              SciTextField(
                controller: _passwordController,
                label: l10n.password,
                icon: FontAwesomeIcons.lock,
                isObscure: true,
                isArabic: isArabic,
              ),
              const SizedBox(height: 16),
              SciDropdown(
                label: l10n.educationLevel,
                value: _selectedEducationLevel,
                items: eduOptions,
                onChanged: (val) =>
                    setState(() => _selectedEducationLevel = val),
                isArabic: isArabic,
              ),
              const SizedBox(height: 24),

              // Legal Agreement Text
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                        color: textColor.withOpacity(0.6),
                        fontSize: 12,
                        height: 1.5),
                    children: [
                      TextSpan(text: l10n.legalAgree),
                      TextSpan(
                          text: l10n.termsConditions,
                          style: TextStyle(
                              color: linkColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => LegalScreen(
                                          title: l10n.termsConditions,
                                          content: l10n.termsContent)));
                            }),
                      TextSpan(text: l10n.legalAnd),
                      TextSpan(
                          text: l10n.privacyPolicy,
                          style: TextStyle(
                              color: linkColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => LegalScreen(
                                          title: l10n.privacyPolicy,
                                          content: l10n.privacyPolicyContent)));
                            }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          l10n.signUp,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.alreadyHaveAccount,
                    style: TextStyle(color: textColor.withOpacity(0.6)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: Text(
                      l10n.login,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
