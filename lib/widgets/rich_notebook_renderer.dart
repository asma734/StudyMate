// ══════════════════════════════════════════════════════════════
// RichNotebookRenderer — StudyMate AI Companion
// Renders student notebook text with:
// - Word-style individual text colors: <color=#HEX>text</color>
// - Word-style individual highlighters: <mark=#HEX>text</mark>
// - Inline images placed at exact positions: ![alt](url)
// - Bold, Italic, Headings, Quotes, and Checklists
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class RichNotebookRenderer extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;

  const RichNotebookRenderer({
    super.key,
    required this.text,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const Text(
        'Cette page de cahier est vide pour l\'instant.',
        style: TextStyle(color: Colors.black38, fontStyle: FontStyle.italic, fontSize: 14),
      );
    }

    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // 1. Check for image tag: ![caption](url)
      final imageMatch = RegExp(r'!\[(.*?)\]\((.*?)\)').firstMatch(line.trim());
      if (imageMatch != null) {
        final caption = imageMatch.group(1) ?? '';
        final url = imageMatch.group(2) ?? '';

        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 680),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Color(0x15000000), blurRadius: 14, offset: Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          color: const Color(0xFFF3EFFF),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.image_outlined, color: Color(0xFF8B72DE)),
                                const SizedBox(width: 8),
                                Text(
                                  caption.isNotEmpty ? caption : 'Image de cours',
                                  style: const TextStyle(color: Color(0xFF8B72DE), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (caption.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          color: const Color(0xFFFBF9F5),
                          child: Text(
                            '📷 $caption',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF7E7092), fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        continue;
      }

      // 2. Check for Headings: # Titre 1 or ## Titre 2
      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
            child: _buildRichText(
              line.substring(2),
              const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2D3436), letterSpacing: -0.4),
            ),
          ),
        );
        continue;
      }

      if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 6.0),
            child: _buildRichText(
              line.substring(3),
              const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF6C5CE7)),
            ),
          ),
        );
        continue;
      }

      // 3. Check for Quote / Definition: >
      if (line.startsWith('> ')) {
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF7F5FC),
              border: Border(left: BorderSide(color: Color(0xFF8B72DE), width: 3.5)),
              borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
            ),
            child: _buildRichText(
              line.substring(2),
              const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF4A3B69), height: 1.5),
            ),
          ),
        );
        continue;
      }

      // 4. Check for Checklist: [ ] or [x]
      if (line.startsWith('[ ] ') || line.startsWith('[x] ') || line.startsWith('[X] ')) {
        final isChecked = line.startsWith('[x] ') || line.startsWith('[X] ');
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  size: 18,
                  color: isChecked ? const Color(0xFF43A047) : Colors.black38,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRichText(
                    line.substring(4),
                    TextStyle(
                      fontSize: 14,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked ? Colors.black38 : const Color(0xFF2D3436),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // 5. Standard paragraph line with inline colors, marks, bold, italic
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: _buildRichText(
            line,
            baseStyle ?? const TextStyle(fontSize: 14.5, height: 1.75, color: Color(0xFF2D3436)),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  // Parses inline tags: <color=#HEX>text</color>, <mark=#HEX>text</mark>, **bold**, *italic*
  Widget _buildRichText(String text, TextStyle defaultStyle) {
    final spans = _parseInlineSpans(text, defaultStyle);
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  List<InlineSpan> _parseInlineSpans(String text, TextStyle style) {
    final List<InlineSpan> spans = [];

    // Regex to match <color=...>, <mark=...>, **bold**, *italic*
    final regex = RegExp(
      r'(<color=(#[0-9a-fA-F]{6})>(.*?)</color>)|(<mark=(#[0-9a-fA-F]{6})>(.*?)</mark>)|(\*\*(.*?)\*\*)|(\*(.*?)\*)',
    );

    int lastIndex = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start), style: style));
      }

      if (match.group(1) != null) {
        // Color match: <color=#HEX>text</color>
        final hex = match.group(2)!;
        final innerText = match.group(3)!;
        final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
        spans.add(TextSpan(
          text: innerText,
          style: style.copyWith(color: color, fontWeight: FontWeight.w600),
        ));
      } else if (match.group(4) != null) {
        // Mark / Highlighter match: <mark=#HEX>text</mark>
        final hex = match.group(5)!;
        final innerText = match.group(6)!;
        final bg = Color(int.parse(hex.replaceFirst('#', '0xFF')));
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: bg.withOpacity(0.45),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(innerText, style: style.copyWith(fontWeight: FontWeight.w600)),
          ),
        ));
      } else if (match.group(7) != null) {
        // Bold: **text**
        final innerText = match.group(8)!;
        spans.add(TextSpan(
          text: innerText,
          style: style.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(9) != null) {
        // Italic: *text*
        final innerText = match.group(10)!;
        spans.add(TextSpan(
          text: innerText,
          style: style.copyWith(fontStyle: FontStyle.italic),
        ));
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: style));
    }

    return spans;
  }
}
