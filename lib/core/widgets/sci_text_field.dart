import 'package:flutter/material.dart';

class SciTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isObscure;
  final bool isArabic;

  const SciTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isObscure = false,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final labelColor = isDark ? Colors.white38 : Colors.black38;
    // For light mode, grey[100] is good.
    // User said "strange frame", often meaning border is too thick or contrasted.
    // Let's make border very subtle.
    final fillColor =
        isDark ? const Color(0xFF141414) : const Color(0xFFF7F7F7);
    final borderColor = isDark
        ? Colors.transparent
        : Colors
            .transparent; // Minimalist approach: No border if filled, or very subtle.
    // Actually, user might prefer flat look. Let's try transparent border but rely on fill.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: labelColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(12),
            // Removing explicit border if fill is sufficient, or very light border.
            // Let's use a very light border only for dark mode definition, or none.
            border: Border.all(
                color:
                    isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(right: 8, left: 4),
                child: Icon(icon, color: labelColor, size: 18),
              ),

              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: isObscure,
                  style: TextStyle(color: textColor, fontSize: 16),
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  cursorColor: textColor,
                  // Ensure no default underlining
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
