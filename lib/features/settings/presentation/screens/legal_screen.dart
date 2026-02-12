import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: MarkdownBody(
            data: content,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                  color: textColor.withOpacity(0.8), fontSize: 16, height: 1.6),
              h1: TextStyle(
                  color: textColor, fontSize: 22, fontWeight: FontWeight.bold),
              h2: TextStyle(
                  color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
              h3: TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
              listBullet: TextStyle(color: textColor.withOpacity(0.6)),
              blockSpacing: 16,
            ),
          ),
        ),
      ),
    );
  }
}
