import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scisolve/core/utils/sci_toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scisolve/core/utils/user_manager.dart';
import 'package:scisolve/features/subscription/presentation/screens/subscription_screen.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final String? imageBase64;
  final bool showActions;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isUser,
    this.imageBase64,
    this.showActions = true,
  });

  TextDirection _getDirection(String text) {
    if (text.isEmpty) return TextDirection.ltr;
    final firstChar = text.trim().codeUnitAt(0);
    return (firstChar >= 0x0600 && firstChar <= 0x06FF)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  void _showProDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF141414) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(l10n.upgradePro, style: TextStyle(color: textColor)),
        content: Text(
          l10n.upgradeToExport,
          style: TextStyle(color: textColor.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel,
                style: TextStyle(color: textColor.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: textColor,
              foregroundColor: bgColor,
            ),
            child: Text(l10n.upgradePro),
          ),
        ],
      ),
    );
  }

  void _showReasonDialog(BuildContext context, bool isLike) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF141414) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    if (isLike) {
      SciToast.show(context, l10n.feedbackThanks);
      return;
    }
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: bgColor,
              title: Text(l10n.feedbackImprove,
                  style: TextStyle(color: textColor)),
              content: TextField(
                controller: controller,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: l10n.reasonOptional,
                  hintStyle: TextStyle(color: textColor.withOpacity(0.3)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: textColor.withOpacity(0.3))),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.skip)),
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      SciToast.show(context, l10n.feedbackThanks);
                    },
                    child: Text(l10n.submit,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    // Lighter grey for light mode bubbles to be distinct from bg
    final bubbleColor = isDark ? const Color(0xFF262626) : Colors.grey[200];
    final appDirection = Directionality.of(context);

    // AI Direction detection based on content
    final aiContentDir = _getDirection(content);

    // AI Alignment Logic
    CrossAxisAlignment aiCrossAlign;
    if (appDirection == TextDirection.ltr) {
      aiCrossAlign = (aiContentDir == TextDirection.rtl)
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start;
    } else {
      aiCrossAlign = (aiContentDir == TextDirection.rtl)
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end;
    }

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageBase64 != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  backgroundColor: Colors.black,
                                  appBar: AppBar(
                                    backgroundColor: Colors.black,
                                    iconTheme: const IconThemeData(
                                        color: Colors.white),
                                  ),
                                  body: Center(
                                    child: InteractiveViewer(
                                      child: Image.memory(
                                        base64Decode(imageBase64!),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              base64Decode(imageBase64!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    if (content.isNotEmpty)
                      MarkdownBody(
                        data: content,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                              color: textColor, fontSize: 16, height: 1.4),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fade().slideY(begin: 0.1, end: 0, duration: 200.ms);
    } else {
      // AI Message
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: aiCrossAlign,
          children: [
            // Header
            Directionality(
              textDirection: aiContentDir,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.atom,
                      size: 12, color: textColor.withOpacity(0.7)),
                  const SizedBox(width: 8),
                  Text(l10n.appTitle, // Localized App Name
                      style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Content (Mixed Rendering)
            Directionality(
              textDirection: aiContentDir,
              child: _buildMixedContent(context, content, textColor, isDark),
            ),

            const SizedBox(height: 12),

            // Actions - Aligned with content
            if (showActions)
              Directionality(
                textDirection: aiContentDir,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MessageAction(
                        icon: Icons.copy_rounded,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: content));
                          SciToast.show(context, l10n.copied);
                        }),
                    const SizedBox(width: 16),
                    _MessageAction(
                        icon: FontAwesomeIcons.fileCode,
                        onTap: () {
                          if (UserManager.isPro) {
                            SciToast.show(context, l10n.exportedLatex);
                          } else {
                            _showProDialog(context);
                          }
                        }),
                    const SizedBox(width: 16),
                    _MessageAction(
                        icon: FontAwesomeIcons.filePdf,
                        onTap: () {
                          if (UserManager.isPro) {
                            SciToast.show(context, l10n.exportPdf);
                          } else {
                            _showProDialog(context);
                          }
                        }),
                    const SizedBox(width: 32),
                    _MessageAction(
                        icon: Icons.thumb_up_outlined,
                        onTap: () => _showReasonDialog(context, true)),
                    const SizedBox(width: 16),
                    _MessageAction(
                        icon: Icons.thumb_down_outlined,
                        onTap: () => _showReasonDialog(context, false)),
                  ],
                ),
              ),
          ],
        ),
      ).animate().fade(duration: 400.ms);
    }
  }

  Widget _buildMixedContent(
      BuildContext context, String content, Color textColor, bool isDark) {
    // 1. Check for markdown tables first
    final lines = content.split('\n');
    final List<Widget> allWidgets = [];
    final List<String> currentBlock = [];
    bool inTable = false;

    for (final line in lines) {
      final trimmed = line.trim();

      // Detect table row (starts with |)
      if (trimmed.startsWith('|') && trimmed.endsWith('|')) {
        if (!inTable) {
          // Process accumulated non-table content
          if (currentBlock.isNotEmpty) {
            allWidgets.add(_buildLatexContent(
                context, currentBlock.join('\n'), textColor, isDark));
            currentBlock.clear();
          }
          inTable = true;
        }
        currentBlock.add(line);
      } else {
        if (inTable) {
          // End of table - render it
          allWidgets.add(
              _buildMarkdownTable(currentBlock.join('\n'), textColor, isDark));
          currentBlock.clear();
          inTable = false;
        }
        currentBlock.add(line);
      }
    }

    // Process remaining content
    if (currentBlock.isNotEmpty) {
      if (inTable) {
        allWidgets.add(
            _buildMarkdownTable(currentBlock.join('\n'), textColor, isDark));
      } else {
        allWidgets.add(_buildLatexContent(
            context, currentBlock.join('\n'), textColor, isDark));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: allWidgets,
    );
  }

  Widget _buildMarkdownTable(
      String tableContent, Color textColor, bool isDark) {
    // Parse markdown table
    final lines =
        tableContent.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.length < 2) return const SizedBox.shrink();

    // Extract rows
    List<List<String>> rows = [];
    int maxColumns = 0;

    for (final line in lines) {
      if (line.contains('|')) {
        final cells = line
            .split('|')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty && !c.contains('---'))
            .toList();
        if (cells.isNotEmpty) {
          rows.add(cells);
          maxColumns = maxColumns > cells.length ? maxColumns : cells.length;
        }
      }
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    // Ensure all rows have the same number of columns
    for (var row in rows) {
      while (row.length < maxColumns) {
        row.add('');
      }
    }

    // Build custom table with LaTeX support
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder.all(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 1,
          ),
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: rows.asMap().entries.map((entry) {
            final isHeader = entry.key == 0;
            final row = entry.value;

            return TableRow(
              decoration: isHeader
                  ? BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[200],
                    )
                  : null,
              children: row.map((cellText) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildTableCell(cellText, textColor, isHeader),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, Color textColor, bool isHeader) {
    // Check if cell contains LaTeX
    if (text.contains(r'$')) {
      // Render with LaTeX support - constrain width to prevent overflow
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _buildInlineMathMixed(text, textColor),
          ),
        ),
      );
    } else {
      // Plain text
      return Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      );
    }
  }

  Widget _buildLatexContent(
      BuildContext context, String content, Color textColor, bool isDark) {
    // Original LaTeX processing logic
    String processed = content
        .replaceAll(RegExp(r'\\\s*\['), r'$$')
        .replaceAll(RegExp(r'\\\s*\]'), r'$$')
        .replaceAll(RegExp(r'\\\s*\('), r'$')
        .replaceAll(RegExp(r'\\\s*\)'), r'$');

    List<Widget> children = [];
    List<String> parts = processed.split(r'$$');

    for (int i = 0; i < parts.length; i++) {
      String part = parts[i];
      if (part.isEmpty) continue;

      if (i % 2 != 0) {
        // Display Math Block
        children.add(Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                part.trim(),
                textStyle: TextStyle(fontSize: 18, color: textColor),
                mathStyle: MathStyle.display,
                onErrorFallback: (err) {
                  return Text(
                    part,
                    style: const TextStyle(color: Colors.red),
                  );
                },
              ),
            )));
      } else {
        // Text Block (may contain $ inline math)
        if (part.trim().isNotEmpty) {
          children.addAll(_buildInlineMathMixed(part, textColor));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  List<Widget> _buildInlineMathMixed(String text, Color textColor) {
    List<Widget> widgets = [];
    // Split by single $
    List<String> segments = text.split(r'$');

    // "Text $ Math $ Text"
    for (int i = 0; i < segments.length; i++) {
      String segment = segments[i];
      if (segment.isEmpty) continue;

      if (i % 2 != 0) {
        // Inline Math
        // We wrap it in a padded container to align nicely?
        // Or just Math.tex.
        // Issues: Inline math in Column won't flow with text.
        // Ideally use Wrap or RichText.
        // But RichText doesn't support generic Widgets easily without WidgetSpan.
        // flutter_markdown doesn't support WidgetSpan easily either.
        // For now, simpler approach: Treat inline math as a block IF it's the only thing on the line?
        // OR: Just render it as Math.tex(mathStyle: text).
        // Since we return List<Widget> to a Column, this breaks the "paragraph flow".
        // This is the trade-off of Manual Rendering without a complex text layout engine.
        // However, most LLMs output math $..$ as part of sentence.
        // If we put it in a Column, it breaks the line.
        // "The velocity is"
        // [v]
        // "which calculated by..."
        // This is ugly.
        // Better solution: Use a Wrap widget for the whole text block?
        // But MarkdownBody is a block.
        // If we really want inline math, we need custom parser for MarkdownBody.
        // flutter_markdown allows `InlineSyntax`.
        // But flutter_math_fork doesn't export an InlineSyntax for flutter_markdown easily.
        //
        // Workaround:
        // Render as MarkdownBody. If the text has $, regex replace it with nothing or generic text?
        // User cares about DISPLAY math ($$) most.
        // For inline $, if we render them as Block Math in a Column, it's Acceptable for now.
        // Or we can try to render standard text.
        // Let's stick to Column for simplicity and robustness.
        // It ensures correctly rendered math.
        widgets.add(Math.tex(
          segment,
          textStyle: TextStyle(fontSize: 16, color: textColor),
          mathStyle: MathStyle.text,
        ));
      } else {
        // Markdown Text
        widgets.add(MarkdownBody(
            data: segment,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(color: textColor, fontSize: 16, height: 1.6),
              listBullet: TextStyle(color: textColor),
              blockquote: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontStyle: FontStyle.italic),
              code: TextStyle(
                  backgroundColor: textColor.withOpacity(0.1),
                  fontFamily: 'monospace',
                  fontSize: 14),
            )));
      }
    }
    return widgets;
  }
}

class _MessageAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MessageAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white38 : Colors.black38;
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 16, color: iconColor),
    );
  }
}
