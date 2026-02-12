import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:scisolve/core/utils/sci_toast.dart';
import 'package:scisolve/core/services/auth_service.dart';
import 'reset_password_screen.dart';




class VerificationCodeScreen extends StatefulWidget {
  final String email;
  final OtpType otpType;

  const VerificationCodeScreen({
    super.key, 
    required this.email, 
    this.otpType = OtpType.signup
  });

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;

  void _verify() async {
    String code = _controllers.map((c) => c.text).join();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (code.length < 6) {
      SciToast.show(context, isArabic ? "رمز غير مكتمل" : "Incomplete code",
          isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      await authService.verifyOtp(
          email: widget.email, token: code, type: widget.otpType);

      if (mounted) {
        if (widget.otpType == OtpType.signup) {
          SciToast.show(
              context, isArabic ? "تم التحقق بنجاح" : "Verified successfully");
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/chat', (route) => false);
        } else if (widget.otpType == OtpType.recovery) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
        }
      }
    } catch (e) {
      if (mounted) {
        SciToast.show(context, isArabic ? "رمز خاطئ" : "Invalid code: $e",
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final boxColor = isDark ? const Color(0xFF141414) : Colors.grey.shade100;
    final borderColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(isArabic ? "تحقق" : "Verify",
            style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(isArabic ? "أدخل الرمز المرسل إلى" : "Enter code sent to",
                style:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
            Text(widget.email,
                style:
                    TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return RawKeyboardListener(
                  focusNode: FocusNode(), // Consumes key events
                  onKey: (event) {
                    if (event is RawKeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.backspace) {
                        if (_controllers[index].text.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      }
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 56,
                    decoration: BoxDecoration(
                      color: boxColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                color: textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                            // maxLength: 1, // Removed to allow pasting
                            decoration: const InputDecoration(
                                counterText: "", border: InputBorder.none),
                            onChanged: (val) {
                              if (val.isEmpty) {
                                if (index > 0) _focusNodes[index - 1].requestFocus();
                                return;
                              }
                              
                              // Handle Paste (6 digits)
                              if (val.length == 6) {
                                for (int i = 0; i < 6; i++) {
                                  _controllers[i].text = val[i];
                                }
                                _verify();
                                return;
                              }

                              // Handle normal input (keep only last char if multiple entered manually)
                              if (val.length > 1) {
                                _controllers[index].text = val.substring(val.length - 1);
                                val = val.substring(val.length - 1); // update val for next check
                              }

                              if (index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else {
                                // Last digit filled
                                FocusScope.of(context).unfocus();
                                _verify();
                              }
                            },
                          ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(isArabic ? "تأكيد" : "Confirm",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
