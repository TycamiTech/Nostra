import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/mirello_theme.dart';
import '../../library/models/subject_notebook.dart';

/// Data structure representing parsed blocks within an editorial page
sealed class PageElement {}

class BadgeElement extends PageElement {
  final String text;
  BadgeElement(this.text);
}

class HeadingElement extends PageElement {
  final String title;
  final int level; // 1 = #, 2 = ##, 3 = ###, 4 = ####
  HeadingElement(this.title, {this.level = 1});
}

class ParagraphElement extends PageElement {
  final String text;
  ParagraphElement(this.text);
}

class BulletListElement extends PageElement {
  final List<String> items;
  BulletListElement(this.items);
}

class NumberedListElement extends PageElement {
  final List<String> items;
  final int startNumber;
  NumberedListElement(this.items, {this.startNumber = 1});
}

class BlockquoteElement extends PageElement {
  final String text;
  BlockquoteElement(this.text);
}

class CodeBlockElement extends PageElement {
  final String code;
  final String? language;
  CodeBlockElement({required this.code, this.language});
}

class TableElement extends PageElement {
  final List<String> headers;
  final List<List<String>> rows;
  TableElement({required this.headers, required this.rows});
}

class DividerElement extends PageElement {}

class BlockMathElement extends PageElement {
  final String latex;
  BlockMathElement(this.latex);
}

sealed class MethodStepItem {}

class TextStepItem extends MethodStepItem {
  final String text;
  TextStepItem(this.text);
}

class MathStepItem extends MethodStepItem {
  final String latex;
  MathStepItem(this.latex);
}

class BulletStepItem extends MethodStepItem {
  final String text;
  BulletStepItem(this.text);
}

class NumberedStepItem extends MethodStepItem {
  final int number;
  final String text;
  NumberedStepItem({required this.number, required this.text});
}

class QuoteStepItem extends MethodStepItem {
  final String text;
  QuoteStepItem(this.text);
}

class TableStepItem extends MethodStepItem {
  final List<String> headers;
  final List<List<String>> rows;
  TableStepItem({required this.headers, required this.rows});
}

class MethodBlockElement extends PageElement {
  final String title;
  final List<MethodStepItem> steps;
  MethodBlockElement({required this.title, required this.steps});
}

class QuestionBlockElement extends PageElement {
  final String badge;
  final List<MethodStepItem> contentSteps;
  final List<MethodStepItem>? solutionSteps;
  QuestionBlockElement({
    required this.badge,
    required this.contentSteps,
    this.solutionSteps,
  });
}

enum CalloutType {
  tip, // Sage green
  warning, // Warm coral / peach
  note, // Soft blue
  summary, // Warm ochre
}

class CalloutBlockElement extends PageElement {
  final String title;
  final List<MethodStepItem> steps;
  final CalloutType type;
  CalloutBlockElement({
    required this.title,
    required this.steps,
    required this.type,
  });
}

/// Nostra Editorial Markdown Engine (Fault-Tolerant, Rich, Adaptable & Comprehensive)
/// Parses full CommonMark, GitHub-Flavored Markdown, 2D LaTeX Math,
/// and custom editorial blocks into 100% native 120fps Flutter widgets.
class MirelloMarkdownParser {
  MirelloMarkdownParser._();

  /// Pre-Parse Text Sanitizer:
  /// Automatically strips AI grounding/citation tags from Gemini / ChatGPT
  static String sanitizeText(String input) {
    var s = input;
    // 1. Strip grounding tags like [span_1](start_span) or [span_2](end_span)
    s = s.replaceAll(
      RegExp(r'\[\s*span_\d+\s*\]\(\s*(?:start_span|end_span)\s*\)', caseSensitive: false),
      '',
    );
    // 2. Strip cite tags like [cite: 1, 2]
    s = s.replaceAll(
      RegExp(r'\[\s*cite:\s*[\d,\s]+\]', caseSensitive: false),
      '',
    );
    // 3. Strip Chinese / LLM footnote brackets like 【...】
    s = s.replaceAll(
      RegExp(r'【[^】]*】'),
      '',
    );
    return s;
  }

  /// Strips outer markdown code block fences (```markdown ... ```) if present
  static String stripCodeFences(String raw) {
    var s = sanitizeText(raw).trim();
    if (s.startsWith('```')) {
      final firstNewline = s.indexOf('\n');
      if (firstNewline != -1) {
        s = s.substring(firstNewline + 1);
      }
    }
    if (s.endsWith('```')) {
      final lastFence = s.lastIndexOf('```');
      if (lastFence != -1) {
        s = s.substring(0, lastFence);
      }
    }
    return s.trim();
  }

  /// Splits raw markdown document into individual pages using '---' as delimiter.
  static List<String> splitPages(String rawMarkdown) {
    final sanitizedDoc = sanitizeText(rawMarkdown);
    final cleanedDoc = stripCodeFences(sanitizedDoc);
    if (cleanedDoc.isEmpty) return [''];

    // Split on standalone --- or *** or ___ with optional surrounding whitespace
    final rawPages = cleanedDoc.split(
      RegExp(r'(\r?\n|\r)\s*(?:---|---|\*\*\*|___)\s*(\r?\n|\r)'),
    );
    final cleaned = rawPages
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return cleaned.isEmpty ? [cleanedDoc] : cleaned;
  }

  /// Extracts the title of a page for Table of Contents / Header
  static String extractPageTitle(String pageMarkdown, {int pageIndex = 0}) {
    final sanitized = sanitizeText(pageMarkdown);
    final lines = sanitized.split(RegExp(r'\r?\n'));
    bool seenBadge = false;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (RegExp(r'^\[(.*?)\]$').hasMatch(trimmed)) {
        seenBadge = true;
        continue;
      }

      if (trimmed.startsWith('#')) {
        return trimmed.replaceFirst(RegExp(r'^#+\s*'), '').trim();
      }

      // If we saw a badge on line 1, this line is the automatic heading
      if (seenBadge &&
          !trimmed.startsWith(':::') &&
          !trimmed.startsWith('```') &&
          !trimmed.startsWith(r'$$')) {
        return trimmed;
      }
    }

    return 'Halaman ${pageIndex + 1}';
  }

  static List<String> _parseTableRow(String line) {
    var trimmed = line.trim();
    if (trimmed.startsWith('|')) trimmed = trimmed.substring(1);
    if (trimmed.endsWith('|')) trimmed = trimmed.substring(0, trimmed.length - 1);
    return trimmed.split('|').map((c) => c.trim()).toList();
  }

  /// Parses lines inside a block (method, question, callouts) into sequentially aligned steps,
  /// supporting free mixing of text steps, bullet points, numbered items, tables, and multi-line $$...$$ math blocks.
  static List<MethodStepItem> parseSubSteps(List<String> rawLines) {
    final steps = <MethodStepItem>[];
    int i = 0;

    final bulletRegex = RegExp(r'^[-*+]\s+(.+)$');
    final numberedRegex = RegExp(r'^(\d+)[\.\)]\s+(.+)$');
    final blockquoteRegex = RegExp(r'^>\s?(.*)$');
    final tableDividerRegex = RegExp(r'^\|(?:\s*:?-+:?\s*\|)+\s*$');

    while (i < rawLines.length) {
      final line = rawLines[i].trim();
      if (line.isEmpty) {
        i++;
        continue;
      }

      // 1. Block math detection ($$ ... $$)
      if (line.startsWith(r'$$')) {
        if (line.length > 2 && line.substring(2).contains(r'$$')) {
          final endIdx = line.indexOf(r'$$', 2);
          final mathContent = line.substring(2, endIdx).trim();
          steps.add(MathStepItem(mathContent));
          i++;
          continue;
        } else {
          // Multi-line block math
          final mathLines = <String>[];
          final first = line.substring(2).trim();
          if (first.isNotEmpty) mathLines.add(first);
          i++;
          while (i < rawLines.length) {
            final cur = rawLines[i].trim();
            if (cur.contains(r'$$')) {
              final closeIdx = cur.indexOf(r'$$');
              final before = cur.substring(0, closeIdx).trim();
              if (before.isNotEmpty) mathLines.add(before);
              i++;
              break;
            } else {
              mathLines.add(rawLines[i]);
              i++;
            }
          }
          steps.add(MathStepItem(mathLines.join('\n').trim()));
          continue;
        }
      }

      // 2. Table inside card: | ... |
      if (line.startsWith('|') &&
          line.endsWith('|') &&
          i + 1 < rawLines.length &&
          tableDividerRegex.hasMatch(rawLines[i + 1].trim())) {
        final headers = _parseTableRow(line);
        i += 2;
        final rows = <List<String>>[];
        while (i < rawLines.length &&
            rawLines[i].trim().startsWith('|') &&
            rawLines[i].trim().endsWith('|')) {
          rows.add(_parseTableRow(rawLines[i].trim()));
          i++;
        }
        steps.add(TableStepItem(headers: headers, rows: rows));
        continue;
      }

      // 3. Blockquote inside card: > ...
      if (blockquoteRegex.hasMatch(line)) {
        final quoteLines = <String>[];
        while (i < rawLines.length && blockquoteRegex.hasMatch(rawLines[i].trim())) {
          final m = blockquoteRegex.firstMatch(rawLines[i].trim())!;
          quoteLines.add(m.group(1)!);
          i++;
        }
        steps.add(QuoteStepItem(quoteLines.join(' ')));
        continue;
      }

      // 4. Bullet list item inside card: - ... or * ...
      if (bulletRegex.hasMatch(line)) {
        final m = bulletRegex.firstMatch(line)!;
        steps.add(BulletStepItem(m.group(1)!));
        i++;
        continue;
      }

      // 5. Numbered list item inside card: 1. ...
      if (numberedRegex.hasMatch(line)) {
        final m = numberedRegex.firstMatch(line)!;
        final num = int.tryParse(m.group(1)!) ?? 1;
        steps.add(NumberedStepItem(number: num, text: m.group(2)!));
        i++;
        continue;
      }

      // 6. Normal text step (supports inline $...$, ==...==, ~~...~~, `...`, **...**, etc.)
      steps.add(TextStepItem(line));
      i++;
    }

    return steps;
  }

  /// Parses an individual page markdown string into a rich list of PageElements
  static List<PageElement> parsePage(String pageMarkdown) {
    final sanitized = sanitizeText(pageMarkdown);
    final elements = <PageElement>[];
    final lines = sanitized.split(RegExp(r'\r?\n'));
    int i = 0;
    bool hasSeenBadge = false;
    bool hasSeenHeading = false;

    final bulletRegex = RegExp(r'^[-*+]\s+(.+)$');
    final numberedRegex = RegExp(r'^(\d+)[\.\)]\s+(.+)$');
    final blockquoteRegex = RegExp(r'^>\s?(.*)$');
    final tableDividerRegex = RegExp(r'^\|(?:\s*:?-+:?\s*\|)+\s*$');
    final closeBlockRegex = RegExp(r'^\s*:::\s*$');

    while (i < lines.length) {
      final rawLine = lines[i];
      final trimmed = rawLine.trim();

      if (trimmed.isEmpty) {
        i++;
        continue;
      }

      // 1. Badge Pill: [MODUL XX | CODE]
      final badgeMatch = RegExp(r'^\[(.*?)\]$').firstMatch(trimmed);
      if (badgeMatch != null && !hasSeenBadge) {
        elements.add(BadgeElement(badgeMatch.group(1)!.trim()));
        hasSeenBadge = true;
        i++;
        continue;
      }

      // 2. Block Math: $$ ... $$ (Display Math / 2D Matrices / Multi-line fractions)
      if (trimmed.startsWith(r'$$')) {
        if (trimmed.length > 2 && trimmed.substring(2).contains(r'$$')) {
          final endIdx = trimmed.indexOf(r'$$', 2);
          final mathContent = trimmed.substring(2, endIdx).trim();
          elements.add(BlockMathElement(mathContent));
          i++;
          continue;
        } else {
          final mathLines = <String>[];
          final firstContent = trimmed.substring(2).trim();
          if (firstContent.isNotEmpty) {
            mathLines.add(firstContent);
          }
          i++;
          while (i < lines.length) {
            final currentLine = lines[i];
            final currentTrimmed = currentLine.trim();
            if (currentTrimmed.contains(r'$$')) {
              final closeIdx = currentTrimmed.indexOf(r'$$');
              final lineBefore = currentTrimmed.substring(0, closeIdx).trim();
              if (lineBefore.isNotEmpty) {
                mathLines.add(lineBefore);
              }
              i++;
              break;
            } else {
              mathLines.add(currentLine);
              i++;
            }
          }
          elements.add(BlockMathElement(mathLines.join('\n').trim()));
          continue;
        }
      }

      // 3. Headings: # (H1), ## (H2), ### (H3), #### (H4)
      if (trimmed.startsWith('#')) {
        int level = 0;
        while (level < trimmed.length && trimmed[level] == '#') {
          level++;
        }
        final headingText = trimmed.substring(level).trim();
        elements.add(
          HeadingElement(headingText, level: level),
        );
        hasSeenHeading = true;
        i++;
        continue;
      }

      // 3b. Auto-Heading fallback
      if (hasSeenBadge &&
          !hasSeenHeading &&
          !trimmed.startsWith(':::') &&
          !trimmed.startsWith('```') &&
          !trimmed.startsWith(r'$$') &&
          !bulletRegex.hasMatch(trimmed) &&
          !numberedRegex.hasMatch(trimmed)) {
        elements.add(HeadingElement(trimmed, level: 1));
        hasSeenHeading = true;
        i++;
        continue;
      }

      // 4. Fenced Code Block: ```lang ... ```
      if (trimmed.startsWith('```')) {
        final lang = trimmed.substring(3).trim();
        final codeLines = <String>[];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        if (i < lines.length && lines[i].trim().startsWith('```')) {
          i++; // Skip closing ```
        }
        elements.add(
          CodeBlockElement(
            code: codeLines.join('\n'),
            language: lang.isEmpty ? null : lang,
          ),
        );
        continue;
      }

      // 5. Custom Blocks: :::metode, :::soal, :::tips, :::peringatan, :::catatan, :::ringkasan
      final customBlockMatch =
          RegExp(r'^:::\s*([a-zA-Z0-9_-]+)\s*(.*)$').firstMatch(trimmed);
      if (customBlockMatch != null) {
        final tag = customBlockMatch.group(1)!.toLowerCase();
        final titleOrBadge = customBlockMatch.group(2)?.trim() ?? '';
        final blockLines = <String>[];
        i++;

        while (i < lines.length && !closeBlockRegex.hasMatch(lines[i].trim())) {
          blockLines.add(lines[i]);
          i++;
        }
        if (i < lines.length && closeBlockRegex.hasMatch(lines[i].trim())) {
          i++; // Skip closing :::
        }

        if (tag == 'metode' || tag == 'method' || tag == 'rumus') {
          elements.add(MethodBlockElement(
            title: titleOrBadge.isEmpty ? 'METODE / RUMUS INTI' : titleOrBadge,
            steps: parseSubSteps(blockLines),
          ));
        } else if (tag == 'soal' || tag == 'problem' || tag == 'question') {
          final fullText = blockLines.join('\n');
          final splitRegex = RegExp(
            r'\n(?=(?:Solusi|Pembahasan|Kunci|Jawaban)\s*:)',
            caseSensitive: false,
          );
          final splitMatch = splitRegex.firstMatch(fullText);

          List<MethodStepItem> qSteps;
          List<MethodStepItem>? sSteps;

          if (splitMatch != null) {
            final qText = fullText.substring(0, splitMatch.start).trim();
            final sText = fullText.substring(splitMatch.start).trim();
            qSteps = parseSubSteps(qText.split('\n'));
            sSteps = parseSubSteps(sText.split('\n'));
          } else {
            qSteps = parseSubSteps(blockLines);
          }

          elements.add(QuestionBlockElement(
            badge: titleOrBadge.isEmpty ? 'HOT 2026' : titleOrBadge,
            contentSteps: qSteps,
            solutionSteps: sSteps,
          ));
        } else if (tag == 'tips' || tag == 'tip' || tag == 'trik') {
          elements.add(CalloutBlockElement(
            title: titleOrBadge.isEmpty ? 'TIPS CEPAT' : titleOrBadge,
            steps: parseSubSteps(blockLines),
            type: CalloutType.tip,
          ));
        } else if (tag == 'peringatan' ||
            tag == 'warning' ||
            tag == 'alert' ||
            tag == 'perhatian') {
          elements.add(CalloutBlockElement(
            title: titleOrBadge.isEmpty ? 'JEBAKAN SOAL' : titleOrBadge,
            steps: parseSubSteps(blockLines),
            type: CalloutType.warning,
          ));
        } else if (tag == 'ringkasan' || tag == 'summary' || tag == 'kesimpulan') {
          elements.add(CalloutBlockElement(
            title: titleOrBadge.isEmpty ? 'INTISARI' : titleOrBadge,
            steps: parseSubSteps(blockLines),
            type: CalloutType.summary,
          ));
        } else {
          // Default: note / info / catatan
          elements.add(CalloutBlockElement(
            title: titleOrBadge.isEmpty ? 'CATATAN PENTING' : titleOrBadge,
            steps: parseSubSteps(blockLines),
            type: CalloutType.note,
          ));
        }
        continue;
      }

      // 6. Blockquote: > Quotation text
      if (blockquoteRegex.hasMatch(trimmed)) {
        final quoteLines = <String>[];
        while (i < lines.length && blockquoteRegex.hasMatch(lines[i].trim())) {
          final match = blockquoteRegex.firstMatch(lines[i].trim())!;
          quoteLines.add(match.group(1)!);
          i++;
        }
        elements.add(BlockquoteElement(quoteLines.join(' ')));
        continue;
      }

      // 7. Markdown Table: | Header | Header |
      if (trimmed.startsWith('|') &&
          trimmed.endsWith('|') &&
          i + 1 < lines.length &&
          tableDividerRegex.hasMatch(lines[i + 1].trim())) {
        final headers = _parseTableRow(trimmed);
        i += 2; // Skip header and divider line
        final rows = <List<String>>[];
        while (i < lines.length &&
            lines[i].trim().startsWith('|') &&
            lines[i].trim().endsWith('|')) {
          rows.add(_parseTableRow(lines[i].trim()));
          i++;
        }
        elements.add(TableElement(headers: headers, rows: rows));
        continue;
      }

      // 8. Bullet List: - item, * item, + item
      if (bulletRegex.hasMatch(trimmed)) {
        final items = <String>[];
        while (i < lines.length && bulletRegex.hasMatch(lines[i].trim())) {
          final m = bulletRegex.firstMatch(lines[i].trim())!;
          items.add(m.group(1)!);
          i++;
        }
        elements.add(BulletListElement(items));
        continue;
      }

      // 9. Numbered List: 1. item, 2. item
      if (numberedRegex.hasMatch(trimmed)) {
        final items = <String>[];
        final firstMatch = numberedRegex.firstMatch(trimmed)!;
        final startNum = int.tryParse(firstMatch.group(1)!) ?? 1;

        while (i < lines.length && numberedRegex.hasMatch(lines[i].trim())) {
          final m = numberedRegex.firstMatch(lines[i].trim())!;
          items.add(m.group(2)!);
          i++;
        }
        elements.add(NumberedListElement(items, startNumber: startNum));
        continue;
      }

      // 10. In-page Divider: *** or ___ or ---
      if (RegExp(r'^(?:---|---|\*\*\*|___)$').hasMatch(trimmed)) {
        elements.add(DividerElement());
        i++;
        continue;
      }

      // 11. Fallback Standard or Highlighted Paragraph
      final paragraphLines = <String>[trimmed];
      i++;
      while (i < lines.length) {
        final nextTrimmed = lines[i].trim();
        if (nextTrimmed.isEmpty ||
            nextTrimmed.startsWith('#') ||
            nextTrimmed.startsWith('```') ||
            nextTrimmed.startsWith(r'$$') ||
            RegExp(r'^:::\s*[a-zA-Z0-9_-]+').hasMatch(nextTrimmed) ||
            RegExp(r'^\[(.*?)\]$').hasMatch(nextTrimmed) ||
            bulletRegex.hasMatch(nextTrimmed) ||
            numberedRegex.hasMatch(nextTrimmed) ||
            blockquoteRegex.hasMatch(nextTrimmed) ||
            nextTrimmed.startsWith('|')) {
          break;
        }
        paragraphLines.add(nextTrimmed);
        i++;
      }
      elements.add(ParagraphElement(paragraphLines.join(' ')));
    }

    return elements;
  }
}

/// Native editorial page renderer widget with dynamic subject pastel background
class MirelloEditorialPageView extends StatelessWidget {
  final SubjectNotebook notebook;
  final String pageMarkdown;
  final int pageIndex;

  const MirelloEditorialPageView({
    super.key,
    required this.notebook,
    required this.pageMarkdown,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final elements = MirelloMarkdownParser.parsePage(pageMarkdown);

    return Container(
      color: notebook.cardColor, // Dynamic paper color matching subject pastel
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        // Ample bottom space so text/bottom cards are NEVER covered by toolbar or page indicator
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 165),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < elements.length; i++) ...[
              _buildElement(elements[i]),
              if (i < elements.length - 1) const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildElement(PageElement element) {
    switch (element) {
      case BadgeElement(:final text):
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: MirelloColors.borderCard,
              width: 0.8,
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: MirelloColors.primaryInk,
              letterSpacing: 0.5,
            ),
          ),
        );

      case HeadingElement(:final title, :final level):
        return _buildHeading(title, level);

      case BlockMathElement(:final latex):
        return _buildBlockMath(latex);

      case ParagraphElement(:final text):
        return _buildRichText(text, fontSize: 15.5);

      case BulletListElement(:final items):
        return _buildBulletList(items);

      case NumberedListElement(:final items, :final startNumber):
        return _buildNumberedList(items, startNumber);

      case BlockquoteElement(:final text):
        return _buildBlockquote(text);

      case CodeBlockElement(:final code, :final language):
        return _buildCodeBlock(code, language);

      case TableElement(:final headers, :final rows):
        return _buildTable(headers, rows);

      case DividerElement():
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Divider(
            color: MirelloColors.borderCard,
            thickness: 1,
            height: 1,
          ),
        );

      case MethodBlockElement(:final title, :final steps):
        return _buildMethodCard(title, steps);

      case QuestionBlockElement(:final badge, :final contentSteps, :final solutionSteps):
        return _buildQuestionCard(badge, contentSteps, solutionSteps);

      case CalloutBlockElement(:final title, :final steps, :final type):
        return _buildCalloutCard(title, steps, type);
    }
  }

  /// Multi-level Heading Renderer
  Widget _buildHeading(String title, int level) {
    switch (level) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRichText(
              title,
              fontSize: 24,
              isSerif: true,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 10),
            const Divider(
              color: MirelloColors.borderCard,
              thickness: 1,
              height: 1,
            ),
          ],
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: _buildRichText(
            title,
            fontSize: 19,
            isSerif: true,
            fontWeight: FontWeight.w700,
          ),
        );
      case 3:
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 2),
          child: _buildRichText(
            title,
            fontSize: 16.5,
            isSerif: true,
            fontWeight: FontWeight.w700,
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.only(top: 2),
          child: _buildRichText(
            title,
            fontSize: 14.5,
            isSerif: false,
            fontWeight: FontWeight.w700,
          ),
        );
    }
  }

  /// 2D Display Math Renderer (Matrices, Complex Fractions, Systems of Equations)
  /// Horizontally scrollable so wide matrices never cause overflow
  Widget _buildBlockMath(String latex) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Math.tex(
            latex.trim(),
            mathStyle: MathStyle.display,
            textStyle: const TextStyle(
              fontSize: 16.5,
              color: Color(0xFF1E1E1E),
            ),
            onErrorFallback: (err) => SelectableText(
              latex,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                color: const Color(0xFF1E1E1E),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(MethodStepItem item, {bool isSerif = false}) {
    switch (item) {
      case TextStepItem(:final text):
        return _buildRichText(
          text,
          fontSize: 14.5,
          isSerif: isSerif,
        );
      case MathStepItem(:final latex):
        return _buildBlockMath(latex);
      case BulletStepItem(:final text):
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, right: 8),
                width: 4.5,
                height: 4.5,
                decoration: const BoxDecoration(
                  color: MirelloColors.primaryInk,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: _buildRichText(
                  text,
                  fontSize: 14.0,
                  isSerif: isSerif,
                ),
              ),
            ],
          ),
        );
      case NumberedStepItem(:final number, :final text):
        return Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  '$number.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: MirelloColors.primaryInk,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildRichText(
                  text,
                  fontSize: 14.0,
                  isSerif: isSerif,
                ),
              ),
            ],
          ),
        );
      case QuoteStepItem(:final text):
        return _buildBlockquote(text);
      case TableStepItem(:final headers, :final rows):
        return _buildTable(headers, rows);
    }
  }

  /// Comprehensive Inline Markdown & Math Parser:
  /// Supports:
  /// - `==highlight==` (Strict double-equals yellow marker)
  /// - `$inline math$` (Real 2D LaTeX rendering via Math.tex)
  /// - `***bold italic***`, `**bold**`, `*italic*`, `~~strikethrough~~`, `` `inline code` ``
  Widget _buildRichText(
    String text, {
    double fontSize = 15.5,
    Color? baseColor,
    bool isSerif = true,
    FontWeight? fontWeight,
  }) {
    final spans = <InlineSpan>[];
    final inlineRegex = RegExp(
      r'(==[^=\n]+==|' // 1. ==highlight== (strictly double-equals)
      r'\$(?!\$)([^\$\n]+)\$|' // 2. $inline math$
      r'\*\*\*[^\*\n]+\*\*\*|' // 3. ***bold italic***
      r'\*\*[^\*\n]+\*\*|' // 4. **bold**
      r'___[^_\n]+___|' // 5. ___bold italic___
      r'__[^_\n]+__|' // 6. __bold__
      r'~~[^~\n]+~~|' // 7. ~~strikethrough~~
      r'`[^`\n]+`|' // 8. `inline code`
      r'\*[^\*\n]+\*|' // 9. *italic*
      r'(?<!\w)_[^_\n]+_(?!\w))', // 10. _italic_
    );

    int lastMatchEnd = 0;
    final defaultStyle = isSerif
        ? GoogleFonts.lora(
            fontSize: fontSize,
            color: baseColor ?? MirelloColors.primaryInk,
            height: 1.65,
            fontWeight: fontWeight,
          )
        : GoogleFonts.plusJakartaSans(
            fontSize: fontSize,
            color: baseColor ?? MirelloColors.primaryInk,
            height: 1.55,
            fontWeight: fontWeight,
          );

    for (final match in inlineRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: defaultStyle,
        ));
      }

      final matchedText = match.group(0)!;

      // 1. Yellow Highlight: ==...== (rounded stroke container)
      if (matchedText.startsWith('==') && matchedText.endsWith('==')) {
        final innerText = matchedText.substring(2, matchedText.length - 2);
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFF6E08E),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              innerText,
              style: isSerif
                  ? GoogleFonts.lora(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E1E),
                    )
                  : GoogleFonts.plusJakartaSans(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E1E),
                    ),
            ),
          ),
        ));
      }
      // 2. Real Inline 2D LaTeX Math: $...$
      else if (matchedText.startsWith(r'$') &&
          matchedText.endsWith(r'$') &&
          !matchedText.startsWith(r'$$')) {
        final latex = matchedText.substring(1, matchedText.length - 1).trim();
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            latex,
            mathStyle: MathStyle.text,
            textStyle: TextStyle(
              fontSize: fontSize,
              color: const Color(0xFF1E1E1E),
            ),
            onErrorFallback: (err) => Text(
              latex,
              style: GoogleFonts.jetBrainsMono(
                fontSize: fontSize * 0.9,
                color: const Color(0xFF1E1E1E),
              ),
            ),
          ),
        ));
      }
      // 3. Inline Code: `...`
      else if (matchedText.startsWith('`') && matchedText.endsWith('`')) {
        final codeText = matchedText.substring(1, matchedText.length - 1);
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: MirelloColors.primaryInk.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: MirelloColors.borderCard,
                width: 0.7,
              ),
            ),
            child: Text(
              codeText,
              style: GoogleFonts.jetBrainsMono(
                fontSize: fontSize * 0.88,
                fontWeight: FontWeight.w600,
                color: MirelloColors.primaryInk,
              ),
            ),
          ),
        ));
      }
      // 4. Bold Italic (*** or ___)
      else if ((matchedText.startsWith('***') && matchedText.endsWith('***')) ||
          (matchedText.startsWith('___') && matchedText.endsWith('___'))) {
        final innerText = matchedText.substring(3, matchedText.length - 3);
        spans.add(TextSpan(
          text: innerText,
          style: defaultStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        ));
      }
      // 5. Bold (** or __)
      else if ((matchedText.startsWith('**') && matchedText.endsWith('**')) ||
          (matchedText.startsWith('__') && matchedText.endsWith('__'))) {
        final innerText = matchedText.substring(2, matchedText.length - 2);
        spans.add(TextSpan(
          text: innerText,
          style: defaultStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ));
      }
      // 6. Strikethrough (~~)
      else if (matchedText.startsWith('~~') && matchedText.endsWith('~~')) {
        final innerText = matchedText.substring(2, matchedText.length - 2);
        spans.add(TextSpan(
          text: innerText,
          style: defaultStyle.copyWith(
            decoration: TextDecoration.lineThrough,
            decorationColor: baseColor ?? MirelloColors.primaryInk,
          ),
        ));
      }
      // 7. Italic (* or _)
      else if ((matchedText.startsWith('*') && matchedText.endsWith('*')) ||
          (matchedText.startsWith('_') && matchedText.endsWith('_'))) {
        final innerText = matchedText.substring(1, matchedText.length - 1);
        spans.add(TextSpan(
          text: innerText,
          style: defaultStyle.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: defaultStyle,
      ));
    }

    return Text.rich(TextSpan(children: spans));
  }

  /// Bullet List Renderer with beautiful circular bullets
  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 10, left: 4),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: MirelloColors.primaryInk,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: _buildRichText(item, fontSize: 15.0),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Numbered List Renderer with clean styled numbers
  Widget _buildNumberedList(List<String> items, int startNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${startNumber + i}.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: MirelloColors.primaryInk,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildRichText(items[i], fontSize: 15.0),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Blockquote Renderer with left vertical accent bar
  Widget _buildBlockquote(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        border: const Border(
          left: BorderSide(
            color: MirelloColors.primaryInk,
            width: 3.5,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: _buildRichText(
        text,
        fontSize: 14.5,
        baseColor: MirelloColors.primaryInk,
      ),
    );
  }

  /// Fenced Code Block Renderer
  Widget _buildCodeBlock(String code, String? language) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MirelloColors.borderCard, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (language != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MirelloColors.primaryInk.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                border: const Border(
                  bottom: BorderSide(color: MirelloColors.borderCard, width: 0.8),
                ),
              ),
              child: Text(
                language.toUpperCase(),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: MirelloColors.secondaryMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                code,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: MirelloColors.primaryInk,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Markdown Table Renderer with horizontal scroll support
  Widget _buildTable(List<String> headers, List<List<String>> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MirelloColors.borderCard, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder(
              horizontalInside: BorderSide(
                color: MirelloColors.borderCard.withValues(alpha: 0.7),
                width: 0.8,
              ),
              verticalInside: BorderSide(
                color: MirelloColors.borderCard.withValues(alpha: 0.7),
                width: 0.8,
              ),
            ),
            children: [
              if (headers.isNotEmpty)
                TableRow(
                  decoration: BoxDecoration(
                    color: MirelloColors.primaryInk.withValues(alpha: 0.06),
                  ),
                  children: headers
                      .map((h) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Text(
                              h,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: MirelloColors.primaryInk,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              for (final row in rows)
                TableRow(
                  children: row
                      .map((cell) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            child: _buildRichText(
                              cell,
                              fontSize: 13,
                              isSerif: false,
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Rounded method/formula card with vertical step alignment & 2D Math support
  Widget _buildMethodCard(String title, List<MethodStepItem> steps) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: MirelloColors.borderCard,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.code2,
                size: 14,
                color: MirelloColors.primaryInk,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: MirelloColors.primaryInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < steps.length; i++) ...[
            _buildStepItem(steps[i], isSerif: false),
            if (i < steps.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  /// Standard UTBK problem example box with badge & vertical step alignment
  Widget _buildQuestionCard(
    String badge,
    List<MethodStepItem> contentSteps,
    List<MethodStepItem>? solutionSteps,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MirelloColors.borderCard,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CONTOH SOAL STANDAR UTBK-SNBT',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: MirelloColors.secondaryMuted,
                  letterSpacing: 0.4,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: MirelloColors.borderCard,
                    width: 0.6,
                  ),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: MirelloColors.primaryInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < contentSteps.length; i++) ...[
            _buildStepItem(contentSteps[i], isSerif: true),
            if (i < contentSteps.length - 1) const SizedBox(height: 8),
          ],
          if (solutionSteps != null && solutionSteps.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: MirelloColors.borderCard,
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.checkCircle2,
                        size: 16,
                        color: MirelloColors.primaryInk,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PEMBAHASAN',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: MirelloColors.primaryInk,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (int i = 0; i < solutionSteps.length; i++) ...[
                    _buildStepItem(solutionSteps[i], isSerif: false),
                    if (i < solutionSteps.length - 1) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Varied Pastel Callout Cards (Tips, Peringatan, Catatan, Ringkasan)
  Widget _buildCalloutCard(String title, List<MethodStepItem> steps, CalloutType type) {
    Color surfaceColor;
    Color borderColor;
    IconData icon;

    switch (type) {
      case CalloutType.tip:
        surfaceColor = const Color(0xFFDCE6DF); // Sage Green
        borderColor = const Color(0xFFB5C9BB);
        icon = LucideIcons.lightbulb;
        break;
      case CalloutType.warning:
        surfaceColor = const Color(0xFFF5C6AA); // Warm Peach / Coral
        borderColor = const Color(0xFFE8AD8E);
        icon = LucideIcons.alertTriangle;
        break;
      case CalloutType.note:
        surfaceColor = const Color(0xFFDCE2EA); // Soft Blue
        borderColor = const Color(0xFFBCC7D6);
        icon = LucideIcons.info;
        break;
      case CalloutType.summary:
        surfaceColor = const Color(0xFFEFE5CD); // Warm Ochre
        borderColor = const Color(0xFFD9CCAA);
        icon = LucideIcons.bookOpen;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 15,
                color: MirelloColors.primaryInk,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: MirelloColors.primaryInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < steps.length; i++) ...[
            _buildStepItem(steps[i], isSerif: false),
            if (i < steps.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
