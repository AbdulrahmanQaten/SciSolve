import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SciDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String) onChanged;
  final bool isArabic;

  const SciDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isArabic,
  });

  @override
  State<SciDropdown> createState() => _SciDropdownState();
}

class _SciDropdownState extends State<SciDropdown> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final labelColor = isDark ? Colors.white38 : Colors.black38;
    final fillColor = isDark ? const Color(0xFF141414) : Colors.grey.shade100;
    final borderColor = isDark ? Colors.white10 : Colors.black12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            color: labelColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showSelectionSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: fillColor, // Theme-aware fill
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.value?.isNotEmpty == true
                      ? widget.value!
                      : (widget.isArabic ? "اختر..." : "Select..."),
                  style: TextStyle(
                    color: widget.value?.isNotEmpty == true
                        ? textColor
                        : labelColor,
                    fontSize: 15,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: labelColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSelectionSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? Colors.black : Colors.white;
    final labelColor = isDark ? Colors.white38 : Colors.black38;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: labelColor,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.label,
                style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...widget.items.map((item) => ListTile(
                    title: Text(item, style: TextStyle(color: textColor)),
                    trailing: widget.value == item
                        ? FaIcon(FontAwesomeIcons.check,
                            size: 16, color: textColor)
                        : null,
                    onTap: () {
                      widget.onChanged(item);
                      Navigator.pop(context);
                    },
                    contentPadding: EdgeInsets.zero,
                    shape: Border(
                        bottom: BorderSide(color: labelColor.withOpacity(0.1))),
                  )),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
