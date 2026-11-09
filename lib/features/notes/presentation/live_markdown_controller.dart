import 'package:flutter/material.dart';

import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/nostra_theme.dart';

/// A custom [TextEditingController] that performs live inline markdown rendering.
///
/// In [AppMode.normal]:
/// Markdown symbols (such as `**`, `*`, `##`, `<u>`, `~~`, `==`) are styled
/// with transparent, near-zero size so that ordinary users see pure visual formatting
/// (bold is bold, italic is italic, headings are large) without confusing syntax markers.
///
/// In [AppMode.expert]:
/// Syntax markers are visible with subtle tinted styling for power-users who prefer
/// editing raw markdown.
class LiveMarkdownEditingController extends TextEditingController {
  LiveMarkdownEditingController({super.text});

  static const TextStyle _hiddenStyle = TextStyle(
    fontSize: 0.001,
    color: Colors.transparent,
    letterSpacing: -1.0,
  );

  static final RegExp _inlineRegex = RegExp(
    r'(\*\*[^\*\n]+?\*\*)|' // Bold
    r'(\*[^\*\n]+?\*)|' // Italic
    r'(<u>[\s\S]*?<\/u>)|' // Underline
    r'(~~[\s\S]*?~~)|' // Strikethrough
    r'(==[\s\S]*?==)|' // Highlight
    r'(`[^`\n]+?`)', // Inline code
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = style ?? const TextStyle(fontSize: 16, color: NostraColors.primaryInk);
    final isNormal = AppSettingsService.instance.isNormal;

    final syntaxMarkerStyle = baseStyle.copyWith(
      color: NostraColors.secondaryMuted.withValues(alpha: 0.65),
      fontWeight: FontWeight.w400,
    );

    final rawText = value.text;
    if (rawText.isEmpty) {
      return TextSpan(style: baseStyle, text: '');
    }

    final spans = <TextSpan>[];
    final lines = rawText.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isLastLine = i == lines.length - 1;

      _parseLine(
        line: line,
        baseStyle: baseStyle,
        isNormal: isNormal,
        syntaxMarkerStyle: syntaxMarkerStyle,
        spans: spans,
      );

      if (!isLastLine) {
        spans.add(TextSpan(text: '\n', style: baseStyle));
      }
    }

    return TextSpan(children: spans);
  }

  void _parseLine({
    required String line,
    required TextStyle baseStyle,
    required bool isNormal,
    required TextStyle syntaxMarkerStyle,
    required List<TextSpan> spans,
  }) {
    if (line.isEmpty) return;

    // Check Heading 1: `# `
    if (line.startsWith('# ')) {
      const marker = '# ';
      final content = line.substring(2);
      final h1Style = baseStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: NostraColors.primaryInk,
        height: 1.3,
      );

      spans.add(
        TextSpan(
          text: marker,
          style: isNormal ? _hiddenStyle : syntaxMarkerStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      );
      _parseInline(
        text: content,
        baseStyle: h1Style,
        isNormal: isNormal,
        syntaxMarkerStyle: syntaxMarkerStyle,
        spans: spans,
      );
      return;
    }

    // Check Heading 2: `## `
    if (line.startsWith('## ')) {
      const marker = '## ';
      final content = line.substring(3);
      final h2Style = baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: NostraColors.primaryInk,
        height: 1.35,
      );

      spans.add(
        TextSpan(
          text: marker,
          style: isNormal ? _hiddenStyle : syntaxMarkerStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      );
      _parseInline(
        text: content,
        baseStyle: h2Style,
        isNormal: isNormal,
        syntaxMarkerStyle: syntaxMarkerStyle,
        spans: spans,
      );
      return;
    }

    // Standard line with inline formatting
    _parseInline(
      text: line,
      baseStyle: baseStyle,
      isNormal: isNormal,
      syntaxMarkerStyle: syntaxMarkerStyle,
      spans: spans,
    );
  }

  void _parseInline({
    required String text,
    required TextStyle baseStyle,
    required bool isNormal,
    required TextStyle syntaxMarkerStyle,
    required List<TextSpan> spans,
  }) {
    if (text.isEmpty) return;

    int currentIndex = 0;
    final matches = _inlineRegex.allMatches(text);

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      final fullMatch = match.group(0)!;

      if (fullMatch.startsWith('**') && fullMatch.endsWith('**') && fullMatch.length >= 4) {
        final inner = fullMatch.substring(2, fullMatch.length - 2);
        spans.add(TextSpan(text: '**', style: isNormal ? _hiddenStyle : syntaxMarkerStyle));
        spans.add(TextSpan(text: inner, style: baseStyle.copyWith(fontWeight: FontWeight.bold)));
        spans.add(TextSpan(text: '**', style: isNormal ? _hiddenStyle : syntaxMarkerStyle));
      } else if (fullMatch.startsWith('*') && fullMatch.endsWith('*') && fullMatch.length >= 2) {
        final inner = fullMatch.substring(1, fullMatch.length - 1);
        spans.add(TextSpan(text: '*', style: isNormal ? _hiddenStyle : syntaxMarkerStyle));
        spans.add(TextSpan(text: inner, style: baseStyle.copyWith(fontStyle: FontStyle.italic)));
        spans.add(TextSpan(text: '*', style: isNormal ? _hiddenStyle : syntaxMarkerStyle));
      } else if (fullMatch.startsWith('<u>') && fullMatch.endsWith('</u>') && fullMatch.length >= 7) {
        final inner = fullMatch.substring(3, fullMatch.length - 4);
        spans.add(TextSpan(text: '<u>', style: isNormal ? _hiddenStyle : syntaxMarkerStyle));
        spans.add(TextSpan(text: inner, style: baseStyle.copyWith(decoration: TextDecoration.underline)));
        spans.add(TextSpan(text: '</u>', style: isNormal ? _hiddenStyle : syntaxMarkerStyle));
      } else if (fullMatch.startsWith('~~') && fullMatch.endsWith('~~') && fullMatch.length >= 4) {
        final inner = fullMatch.substring(2, fullMatch.length - 2);
        spans.add(TextSpan(text: '~~', style: isNormal ? _hiddenStyle : syntaxMarkerStyle));
        spans.add(TextSpan(text: inner, style: baseStyle.copyWith(decoration: TextDecoration.lineThrough)));
        spans.add(TextSpan(text: '~~', style: isNormal ? _hiddenStyle : syntaxMarkerStyle));
      } else if (fullMatch.startsWith('==') && fullMatch.endsWith('==') && fullMatch.length >= 4) {
        final inner = fullMatch.substring(2, fullMatch.length - 2);
        spans.add(TextSpan(text: '==', style: isNormal ? _hiddenStyle : syntaxMarkerStyle));
        spans.add(TextSpan(text: inner, style: baseStyle.copyWith(backgroundColor: const Color(0xFFF6E08E))));
        spans.add(TextSpan(text: '==', style: isNormal ? _hiddenStyle : syntaxMarkerStyle));
      } else if (fullMatch.startsWith('`') && fullMatch.endsWith('`') && fullMatch.length >= 2) {
        final inner = fullMatch.substring(1, fullMatch.length - 1);
        spans.add(TextSpan(text: '`', style: isNormal ? _hiddenStyle : syntaxMarkerStyle));
        spans.add(
          TextSpan(
            text: inner,
            style: baseStyle.copyWith(
              fontFamily: 'monospace',
              backgroundColor: Colors.black.withValues(alpha: 0.06),
            ),
          ),
        );
        spans.add(TextSpan(text: '`', style: isNormal ? _hiddenStyle : syntaxMarkerStyle));
      } else {
        spans.add(TextSpan(text: fullMatch, style: baseStyle));
      }

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: baseStyle,
        ),
      );
    }
  }
}

