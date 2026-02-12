import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scisolve/core/widgets/sci_text_field.dart';
import 'package:scisolve/core/utils/sci_toast.dart';
import 'package:scisolve/core/services/auth_service.dart';
import 'login_screen.dart';


class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isArabic ? "تعيين كلمة مرور جديدة" : "New Password",
            style: TextStyle(color: textColor)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              isArabic
                  ? "الرجاء إدخال كلمة مرور قوية وجديدة."
                  : "Please enter a strong new password for your account.",
              style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                  height: 1.5),
            ),
            const SizedBox(height: 32),
            SciTextField(
                controller: _passController,
                label: isArabic ? "كلمة المرور الجديدة" : "New Password",
                icon: FontAwesomeIcons.lock,
                isObscure: true,
                isArabic: isArabic),
            const SizedBox(height: 16),
            SciTextField(
                controller: _confirmPassController,
                label: isArabic ? "تأكيد كلمة المرور" : "Confirm Password",
                icon: FontAwesomeIcons.check,
                isObscure: true,
                isArabic: isArabic),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final pass = _passController.text.trim();
                final confirm = _confirmPassController.text.trim();
                
                if (pass != confirm) {
                   SciToast.show(context, isArabic ? "كلمة المرور غير متطابقة" : "Passwords do not match", isError: true);
                   return;
                }
                
                if (pass.length < 6) {
                   SciToast.show(context, isArabic ? "كلمة المرور قصيرة" : "Password too short", isError: true);
                   return;
                }

                try {
                  await AuthService().updateUserPassword(newPassword: pass);
                  if (mounted) {
                    SciToast.show(
                        context,
                        isArabic
                            ? "تم تغيير كلمة المرور بنجاح"
                            : "Password updated successfully");
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false);
                  }
                } catch(e) {
                   if (mounted) {
                     SciToast.show(context, isArabic ? "خطأ في التحديث" : "Update failed: $e", isError: true);
                   }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isArabic ? "تغيير كلمة المرور" : "Reset Password",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
