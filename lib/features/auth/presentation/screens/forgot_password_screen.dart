import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scisolve/core/widgets/sci_text_field.dart';
import 'package:scisolve/core/utils/sci_toast.dart';
import 'package:scisolve/core/services/auth_service.dart';
import 'verification_code_screen.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isArabic ? "استعادة كلمة المرور" : "Reset Password",
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Text(
              isArabic
                  ? "أدخل بريدك الإلكتروني وسنرسل لك رمزاً."
                  : "Enter your email address and we will send you a code.",
              style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 15,
                  height: 1.5),
            ),
            const SizedBox(height: 32),
            SciTextField(
                controller: _emailController,
                label: isArabic ? "البريد الإلكتروني" : "Email",
                icon: FontAwesomeIcons.envelope,
                isArabic: isArabic),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      final email = _emailController.text.trim();
                      if (email.isEmpty) {
                        SciToast.show(
                            context,
                            isArabic
                                ? "الرجاء إدخال البريد الإلكتروني"
                                : "Please enter email",
                            isError: true);
                        return;
                      }

                      setState(() => _isLoading = true);

                      try {
                        final authService = AuthService();
                        await authService.resetPasswordForEmail(email: email);

                        if (mounted) {
                          SciToast.show(
                              context,
                              isArabic
                                  ? "تم إرسال الرمز!"
                                  : "Code sent successfully!");
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => VerificationCodeScreen(
                                    email: email,
                                    otpType: OtpType.recovery,
                                  )));
                        }
                      } catch (e) {
                         if (mounted) {
                          SciToast.show(context, isArabic ? "حدث خطأ" : "Error: $e", isError: true);
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark ? Colors.black : Colors.white))
                  : Text(isArabic ? "إرسال الرمز" : "Send Code",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
