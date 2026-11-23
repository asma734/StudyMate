// ══════════════════════════════════════════════════════════════
// RichNotebookController — StudyMate AI Companion
// True Microsoft Word-style visual text formatting inside TextField:
// - Colors & Highlighters apply directly to characters (NO raw tags on screen!)
// - Full caret, selection, and typing support
// - Automatic parser for legacy markup (<color>, <mark>, ![image])
// ══════════════════════════════════════════════════════════════

import 'dart:math';
import 'package:flutter/material.dart';

class NotebookStyleSpan {
  int start;
  int end;
  Color? color;
  Color? backgroundColor;
  bool isBold;
  bool isItalic;
  double? fontSize;

  NotebookStyleSpan({
    required this.start,
    required this.end,
    this.color,
    this.backgroundColor,
    this.isBold = false,
    this.isItalic = false,
    this.fontSize,
  });

  NotebookStyleSpan copyWith({
    int? start,
    int? end,
    Color? color,
    Color? backgroundColor,
    bool? isBold,
    bool? isItalic,
    double? fontSize,
  }) {
    return NotebookStyleSpan(
      start: start ?? this.start,
      end: end ?? this.end,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toMap() => {
    'start': start,
    'end': end,
    'color': color?.value,
    'bg': backgroundColor?.value,
    'bold': isBold,
    'italic': isItalic,
    'fontSize': fontSize,
  };
}

class RichNotebookController extends TextEditingController {
  final List<NotebookStyleSpan> _spans = [];

  List<NotebookStyleSpan> get spans => List.unmodifiable(_spans);

  RichNotebookController({String? text, List<NotebookStyleSpan>? initialSpans})
      : super(text: text) {
    if (initialSpans != null) {
      _spans.addAll(initialSpans);
    }
  }

  /// Factory that parses legacy raw markup like <color=#HEX>, <mark=#HEX>, **bold**, and ![alt](url)
  /// and returns a clean controller with NO raw tags visible, plus a list of any extracted images.
  factory RichNotebookController.fromMarkup(String rawMarkup, {required void Function(List<String> images) onImagesExtracted}) {
    final List<String> extractedImages = [];
    String workingText = rawMarkup;

    // 1. Extract markdown images: ![caption](url)
    final imageRegex = RegExp(r'!\[(.*?)\]\((.*?)\)');
    final matches = imageRegex.allMatches(workingText).toList();
    for (final m in matches) {
      final url = m.group(2) ?? '';
      if (url.isNotEmpty) {
        extractedImages.add(url);
      }
    }
    workingText = workingText.replaceAll(imageRegex, '').trim();

    // 2. Parse styled tags: <color=#HEX>text</color> and <mark=#HEX>text</mark>
    final List<NotebookStyleSpan> parsedSpans = [];

    // Parse loop to extract inner text and record indices
    final tagRegex = RegExp(r'<(color|mark)=(#[0-9a-fA-F]{6})>(.*?)</\1>');
    while (tagRegex.hasMatch(workingText)) {
      final match = tagRegex.firstMatch(workingText)!;
      final type = match.group(1);
      final hex = match.group(2)!;
      final innerText = match.group(3) ?? '';
      final start = match.start;
      final end = start + innerText.length;

      final colorInt = int.tryParse(hex.replaceFirst('#', '0xFF')) ?? 0xFF000000;
      final color = Color(colorInt);

      if (type == 'color') {
        parsedSpans.add(NotebookStyleSpan(start: start, end: end, color: color));
      } else if (type == 'mark') {
        parsedSpans.add(NotebookStyleSpan(start: start, end: end, backgroundColor: color));
      }

      workingText = workingText.replaceRange(match.start, match.end, innerText);
    }

    if (extractedImages.isNotEmpty) {
      onImagesExtracted(extractedImages);
    }

    return RichNotebookController(
      text: workingText,
      initialSpans: parsedSpans,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 🎨 Style Actions on Selected Text
  // ══════════════════════════════════════════════════════════════

  void applyColor(Color color) {
    if (!selection.isValid || selection.isCollapsed) return;
    _addOrUpdateSpan((span) => span.color = color, defaultSpan: (s, e) => NotebookStyleSpan(start: s, end: e, color: color));
  }

  void applyHighlight(Color color) {
    if (!selection.isValid || selection.isCollapsed) return;
    _addOrUpdateSpan((span) => span.backgroundColor = color, defaultSpan: (s, e) => NotebookStyleSpan(start: s, end: e, backgroundColor: color));
  }

  void toggleBold() {
    if (!selection.isValid || selection.isCollapsed) return;
    _addOrUpdateSpan((span) => span.isBold = !span.isBold, defaultSpan: (s, e) => NotebookStyleSpan(start: s, end: e, isBold: true));
  }

  void toggleItalic() {
    if (!selection.isValid || selection.isCollapsed) return;
    _addOrUpdateSpan((span) => span.isItalic = !span.isItalic, defaultSpan: (s, e) => NotebookStyleSpan(start: s, end: e, isItalic: true));
  }

  void applyHeading(int level) {
    if (!selection.isValid || selection.isCollapsed) return;
    final size = level == 1 ? 22.0 : 18.0;
    _addOrUpdateSpan((span) {
      span.fontSize = size;
      span.isBold = true;
    }, defaultSpan: (s, e) => NotebookStyleSpan(start: s, end: e, fontSize: size, isBold: true));
  }

  void clearFormatting() {
    if (!selection.isValid || selection.isCollapsed) return;
    final start = min(selection.start, selection.end);
    final end = max(selection.start, selection.end);
    _spans.removeWhere((span) => span.start >= start && span.end <= end);
    notifyListeners();
  }

  void _addOrUpdateSpan(void Function(NotebookStyleSpan) updater, {required NotebookStyleSpan Function(int, int) defaultSpan}) {
    final start = min(selection.start, selection.end);
    final end = max(selection.start, selection.end);
    if (start >= end) return;

    bool updated = false;
    for (final span in _spans) {
      if (span.start == start && span.end == end) {
        updater(span);
        updated = true;
        break;
      }
    }

    if (!updated) {
      _spans.add(defaultSpan(start, end));
    }

    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════
  // ✍️ Text Change Handling & Range Adjustment
  // ══════════════════════════════════════════════════════════════

  @override
  set value(TextEditingValue newValue) {
    final oldText = text;
    final newText = newValue.text;

    if (oldText != newText) {
      final delta = newText.length - oldText.length;
      final changePos = selection.isValid ? selection.start : oldText.length;

      // Adjust spans around change position
      for (int i = _spans.length - 1; i >= 0; i--) {
        final span = _spans[i];
        if (span.start >= changePos) {
          span.start = (span.start + delta).clamp(0, newText.length);
          span.end = (span.end + delta).clamp(0, newText.length);
        } else if (span.end > changePos) {
          span.end = (span.end + delta).clamp(span.start, newText.length);
        }

        if (span.start >= span.end || span.start >= newText.length) {
          _spans.removeAt(i);
        }
      }
    }

    super.value = newValue;
  }

  // ══════════════════════════════════════════════════════════════
  // 🔤 Rendering TextSpans directly in TextField
  // ══════════════════════════════════════════════════════════════

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final defaultStyle = style ?? const TextStyle(fontSize: 15, color: Color(0xFF2D3436), height: 1.6);
    final rawText = text;

    if (rawText.isEmpty || _spans.isEmpty) {
      return TextSpan(text: rawText, style: defaultStyle);
    }

    // Collect all unique boundary points
    final Set<int> points = {0, rawText.length};
    for (final s in _spans) {
      if (s.start >= 0 && s.start <= rawText.length) points.add(s.start);
      if (s.end >= 0 && s.end <= rawText.length) points.add(s.end);
    }
    final sortedPoints = points.toList()..sort();

    final List<TextSpan> children = [];

    for (int i = 0; i < sortedPoints.length - 1; i++) {
      final segStart = sortedPoints[i];
      final segEnd = sortedPoints[i + 1];
      if (segStart >= segEnd) continue;

      final segment = rawText.substring(segStart, segEnd);

      // Find all spans covering this segment
      TextStyle segStyle = defaultStyle;
      for (final span in _spans) {
        if (span.start <= segStart && span.end >= segEnd) {
          segStyle = segStyle.copyWith(
            color: span.color ?? segStyle.color,
            backgroundColor: span.backgroundColor ?? segStyle.backgroundColor,
            fontWeight: span.isBold ? FontWeight.bold : segStyle.fontWeight,
            fontStyle: span.isItalic ? FontStyle.italic : segStyle.fontStyle,
            fontSize: span.fontSize ?? segStyle.fontSize,
          );
        }
      }

      children.add(TextSpan(text: segment, style: segStyle));
    }

    return TextSpan(children: children);
  }

  /// Exports clean text with markup tags only for saving / reading
  String exportToMarkup() {
    if (_spans.isEmpty) return text;

    // Sort spans by start descending so inserting tags doesn't displace earlier indices
    String exported = text;
    final sorted = List<NotebookStyleSpan>.from(_spans)
      ..sort((a, b) => b.start.compareTo(a.start));

    for (final span in sorted) {
      if (span.start >= exported.length || span.end > exported.length || span.start >= span.end) continue;

      final target = exported.substring(span.start, span.end);
      String wrapped = target;

      if (span.isBold) wrapped = '**$wrapped**';
      if (span.isItalic) wrapped = '*$wrapped*';
      if (span.color != null) {
        final hex = '#${span.color!.value.toRadixString(16).substring(2).toUpperCase()}';
        wrapped = '<color=$hex>$wrapped</color>';
      }
      if (span.backgroundColor != null) {
        final hex = '#${span.backgroundColor!.value.toRadixString(16).substring(2).toUpperCase()}';
        wrapped = '<mark=$hex>$wrapped</mark>';
      }

      exported = exported.replaceRange(span.start, span.end, wrapped);
    }

    return exported;
  }
}
