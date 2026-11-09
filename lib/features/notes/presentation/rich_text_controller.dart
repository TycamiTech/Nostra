import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/nostra_theme.dart';

/// Formatting attributes applied per-character in [GoogleKeepRichTextController].
class CharFormat {
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final bool highlight;

  const CharFormat({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.highlight = false,
  });

  CharFormat copyWith({
    bool? bold,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    bool? highlight,
  }) {
    return CharFormat(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      highlight: highlight ?? this.highlight,
    );
  }

  bool get isPlain => !bold && !italic && !underline && !strikethrough && !highlight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharFormat &&
          runtimeType == other.runtimeType &&
          bold == other.bold &&
          italic == other.italic &&
          underline == other.underline &&
          strikethrough == other.strikethrough &&
          highlight == other.highlight;

  @override
  int get hashCode => Object.hash(bold, italic, underline, strikethrough, highlight);
}

/// Line-level styling for headings.
enum LineType {
  normal,
  h1,
  h2,
}

/// A true WYSIWYG Rich Text controller inspired by Google Keep.
///
/// Features:
/// 1. Pure text in buffer: NO markdown symbols (`**`, `*`, `<u>`, `#`) are ever stored in [text].
/// 2. Sticky typing state: When a toggle (e.g. Bold) is activated with no selection,
///    subsequent typed characters automatically continue to be bold until toggled off.
/// 3. Native selection formatting: Selecting a span of text and tapping formatting toggles
///    only that selection.
/// 4. Headings (H1/H2), Bullet List (`• `), and Checklist (`☐ ` / `☑ `).
/// 5. Auto-continuation: Pressing Enter on bullet or checklist lines continues the list.
/// 6. Bidirectional Markdown conversion: Lossless translation to/from Markdown (.md)
///    for storage and Obsidian compatibility behind the scenes.
class GoogleKeepRichTextController extends TextEditingController {
  List<CharFormat> _charFormats;
  List<LineType> _lineStyles;

  // Active sticky typing states
  bool isBoldActive = false;
  bool isItalicActive = false;
  bool isUnderlineActive = false;
  bool isStrikethroughActive = false;
  bool isHighlightActive = false;

  int? _stickyToggledOffset;

  GoogleKeepRichTextController({
    super.text,
    List<CharFormat>? formats,
    List<LineType>? lineStyles,
  })  : _charFormats = formats != null
            ? List<CharFormat>.from(formats)
            : List<CharFormat>.filled((text ?? '').length, const CharFormat(), growable: true),
        _lineStyles = lineStyles != null
            ? List<LineType>.from(lineStyles)
            : List<LineType>.filled((text ?? '').split('\n').length, LineType.normal, growable: true) {
    _ensureFormatsLength();
    _ensureLineStylesLength();
  }

  List<CharFormat> get charFormats => List.unmodifiable(_charFormats);
  List<LineType> get lineStyles => List.unmodifiable(_lineStyles);

  CharFormat get _activeFormat => CharFormat(
        bold: isBoldActive,
        italic: isItalicActive,
        underline: isUnderlineActive,
        strikethrough: isStrikethroughActive,
        highlight: isHighlightActive,
      );

  void _ensureFormatsLength([int? targetLen]) {
    final len = targetLen ?? text.length;
    if (_charFormats.length < len) {
      _charFormats.addAll(List.filled(len - _charFormats.length, const CharFormat()));
    } else if (_charFormats.length > len) {
      _charFormats = _charFormats.sublist(0, len);
    }
  }

  void _ensureLineStylesLength([int? targetNumLines]) {
    final numLines = targetNumLines ?? text.split('\n').length;
    if (_lineStyles.length < numLines) {
      _lineStyles.addAll(List.filled(numLines - _lineStyles.length, LineType.normal));
    } else if (_lineStyles.length > numLines) {
      _lineStyles = _lineStyles.sublist(0, numLines);
    }
  }

  @override
  set value(TextEditingValue newValue) {
    final oldText = value.text;
    var newText = newValue.text;
    var newSelection = newValue.selection;

    // Handle Smart Enter on bullet or checklist lines
    if (newText.length == oldText.length + 1 && newSelection.isCollapsed) {
      final insertPos = newSelection.baseOffset - 1;
      if (insertPos >= 0 && insertPos < newText.length && newText[insertPos] == '\n') {
        int lineStart = 0;
        if (insertPos > 0) {
          final lastNl = oldText.lastIndexOf('\n', insertPos - 1);
          if (lastNl != -1) lineStart = lastNl + 1;
        }
        final prevLine = oldText.substring(lineStart, insertPos);

        if (prevLine == '• ' || prevLine == '•') {
          // Empty bullet line -> Exit list
          newText = '${oldText.replaceRange(lineStart, insertPos, '')}\n';
          newSelection = TextSelection.collapsed(offset: lineStart + 1);
        } else if (prevLine == '☐ ' || prevLine == '☐' || prevLine == '☑ ' || prevLine == '☑') {
          // Empty checklist line -> Exit checklist
          newText = '${oldText.replaceRange(lineStart, insertPos, '')}\n';
          newSelection = TextSelection.collapsed(offset: lineStart + 1);
        } else if (prevLine.startsWith('• ')) {
          // Continue bullet list
          newText = newText.replaceRange(insertPos + 1, insertPos + 1, '• ');
          newSelection = TextSelection.collapsed(offset: insertPos + 3);
        } else if (prevLine.startsWith('☐ ') || prevLine.startsWith('☑ ')) {
          // Continue checklist with unchecked item
          newText = newText.replaceRange(insertPos + 1, insertPos + 1, '☐ ');
          newSelection = TextSelection.collapsed(offset: insertPos + 3);
        }
      }
    }

    if (oldText != newText) {
      _syncFormats(oldText, newText);
      _syncLineStyles(oldText, newText);
    }

    super.value = TextEditingValue(
      text: newText,
      selection: newSelection,
      composing: newValue.composing,
    );

    _syncActiveStatesWithSelection();
  }

  void _syncFormats(String oldText, String newText) {
    if (newText.isEmpty) {
      _charFormats.clear();
      return;
    }

    if (oldText.isEmpty) {
      _charFormats = List.filled(newText.length, _activeFormat, growable: true);
      return;
    }

    // Common prefix
    int prefix = 0;
    final minLen = math.min(oldText.length, newText.length);
    while (prefix < minLen && oldText[prefix] == newText[prefix]) {
      prefix++;
    }

    // Common suffix
    int suffix = 0;
    while (suffix < (minLen - prefix) &&
        oldText[oldText.length - 1 - suffix] == newText[newText.length - 1 - suffix]) {
      suffix++;
    }

    final deletedCount = oldText.length - prefix - suffix;
    final insertedCount = newText.length - prefix - suffix;

    if (deletedCount > 0) {
      _charFormats.removeRange(prefix, prefix + deletedCount);
    }

    if (insertedCount > 0) {
      final fmt = _activeFormat;
      _charFormats.insertAll(prefix, List.filled(insertedCount, fmt));
    }

    _ensureFormatsLength(newText.length);
  }

  void _syncLineStyles(String oldText, String newText) {
    final oldLines = oldText.split('\n');
    final newLines = newText.split('\n');

    if (newLines.length != oldLines.length) {
      int prefix = 0;
      final minLen = math.min(oldText.length, newText.length);
      while (prefix < minLen && oldText[prefix] == newText[prefix]) {
        prefix++;
      }

      int lineIndex = 0;
      int charAccum = 0;
      for (int i = 0; i < oldLines.length; i++) {
        charAccum += oldLines[i].length + 1;
        if (prefix < charAccum) {
          lineIndex = i;
          break;
        }
      }

      final diff = newLines.length - oldLines.length;
      if (diff > 0) {
        _lineStyles.insertAll(
          (lineIndex + 1).clamp(0, _lineStyles.length),
          List.filled(diff, LineType.normal),
        );
      } else if (diff < 0) {
        final removeCount = -diff;
        final startIdx = (lineIndex + 1).clamp(0, _lineStyles.length);
        final endIdx = (startIdx + removeCount).clamp(0, _lineStyles.length);
        if (endIdx > startIdx) {
          _lineStyles.removeRange(startIdx, endIdx);
        }
      }
      _ensureLineStylesLength(newLines.length);
    }
  }

  void _syncActiveStatesWithSelection() {
    if (!selection.isValid) return;

    if (selection.isCollapsed) {
      final offset = selection.baseOffset;
      if (_stickyToggledOffset != null && _stickyToggledOffset != offset) {
        _stickyToggledOffset = null;
        if (offset > 0 && offset <= _charFormats.length) {
          final fmt = _charFormats[offset - 1];
          isBoldActive = fmt.bold;
          isItalicActive = fmt.italic;
          isUnderlineActive = fmt.underline;
          isStrikethroughActive = fmt.strikethrough;
          isHighlightActive = fmt.highlight;
        } else {
          isBoldActive = false;
          isItalicActive = false;
          isUnderlineActive = false;
          isStrikethroughActive = false;
          isHighlightActive = false;
        }
      }
    } else {
      _stickyToggledOffset = null;
      final start = selection.start;
      final end = selection.end;
      isBoldActive = _areAllBold(start, end);
      isItalicActive = _areAllItalic(start, end);
      isUnderlineActive = _areAllUnderline(start, end);
      isStrikethroughActive = _areAllStrikethrough(start, end);
      isHighlightActive = _areAllHighlight(start, end);
    }
  }

  // --- Formatting Toggles ---

  void toggleBold() {
    if (!selection.isValid) return;
    if (selection.isCollapsed) {
      isBoldActive = !isBoldActive;
      _stickyToggledOffset = selection.baseOffset;
      notifyListeners();
    } else {
      final start = selection.start;
      final end = selection.end;
      final allBold = _areAllBold(start, end);
      _setFormatRange(start, end, (f) => f.copyWith(bold: !allBold));
      isBoldActive = !allBold;
      notifyListeners();
    }
  }

  void toggleItalic() {
    if (!selection.isValid) return;
    if (selection.isCollapsed) {
      isItalicActive = !isItalicActive;
      _stickyToggledOffset = selection.baseOffset;
      notifyListeners();
    } else {
      final start = selection.start;
      final end = selection.end;
      final allItalic = _areAllItalic(start, end);
      _setFormatRange(start, end, (f) => f.copyWith(italic: !allItalic));
      isItalicActive = !allItalic;
      notifyListeners();
    }
  }

  void toggleUnderline() {
    if (!selection.isValid) return;
    if (selection.isCollapsed) {
      isUnderlineActive = !isUnderlineActive;
      _stickyToggledOffset = selection.baseOffset;
      notifyListeners();
    } else {
      final start = selection.start;
      final end = selection.end;
      final allUnderline = _areAllUnderline(start, end);
      _setFormatRange(start, end, (f) => f.copyWith(underline: !allUnderline));
      isUnderlineActive = !allUnderline;
      notifyListeners();
    }
  }

  void toggleStrikethrough() {
    if (!selection.isValid) return;
    if (selection.isCollapsed) {
      isStrikethroughActive = !isStrikethroughActive;
      _stickyToggledOffset = selection.baseOffset;
      notifyListeners();
    } else {
      final start = selection.start;
      final end = selection.end;
      final allStrike = _areAllStrikethrough(start, end);
      _setFormatRange(start, end, (f) => f.copyWith(strikethrough: !allStrike));
      isStrikethroughActive = !allStrike;
      notifyListeners();
    }
  }

  void toggleHighlight() {
    if (!selection.isValid) return;
    if (selection.isCollapsed) {
      isHighlightActive = !isHighlightActive;
      _stickyToggledOffset = selection.baseOffset;
      notifyListeners();
    } else {
      final start = selection.start;
      final end = selection.end;
      final allHighlight = _areAllHighlight(start, end);
      _setFormatRange(start, end, (f) => f.copyWith(highlight: !allHighlight));
      isHighlightActive = !allHighlight;
      notifyListeners();
    }
  }

  void _setFormatRange(int start, int end, CharFormat Function(CharFormat) updater) {
    final s = start.clamp(0, _charFormats.length);
    final e = end.clamp(0, _charFormats.length);
    for (int i = s; i < e; i++) {
      _charFormats[i] = updater(_charFormats[i]);
    }
  }

  bool _areAllBold(int start, int end) {
    final s = start.clamp(0, _charFormats.length);
    final e = end.clamp(0, _charFormats.length);
    if (s >= e) return false;
    for (int i = s; i < e; i++) {
      if (!_charFormats[i].bold) return false;
    }
    return true;
  }

  bool _areAllItalic(int start, int end) {
    final s = start.clamp(0, _charFormats.length);
    final e = end.clamp(0, _charFormats.length);
    if (s >= e) return false;
    for (int i = s; i < e; i++) {
      if (!_charFormats[i].italic) return false;
    }
    return true;
  }

  bool _areAllUnderline(int start, int end) {
    final s = start.clamp(0, _charFormats.length);
    final e = end.clamp(0, _charFormats.length);
    if (s >= e) return false;
    for (int i = s; i < e; i++) {
      if (!_charFormats[i].underline) return false;
    }
    return true;
  }

  bool _areAllStrikethrough(int start, int end) {
    final s = start.clamp(0, _charFormats.length);
    final e = end.clamp(0, _charFormats.length);
    if (s >= e) return false;
    for (int i = s; i < e; i++) {
      if (!_charFormats[i].strikethrough) return false;
    }
    return true;
  }

  bool _areAllHighlight(int start, int end) {
    final s = start.clamp(0, _charFormats.length);
    final e = end.clamp(0, _charFormats.length);
    if (s >= e) return false;
    for (int i = s; i < e; i++) {
      if (!_charFormats[i].highlight) return false;
    }
    return true;
  }

  // --- Line & Block Formatting ---

  int get currentLineIndex {
    if (!selection.isValid) return 0;
    final cursor = selection.baseOffset.clamp(0, text.length);
    return '\n'.allMatches(text.substring(0, cursor)).length;
  }

  (int, int) get currentLineBounds {
    if (!selection.isValid) return (0, text.length);
    final cursor = selection.baseOffset.clamp(0, text.length);
    int lineStart = 0;
    if (cursor > 0) {
      final lastNl = text.lastIndexOf('\n', cursor - 1);
      if (lastNl != -1) lineStart = lastNl + 1;
    }
    int lineEnd = text.indexOf('\n', cursor);
    if (lineEnd == -1) lineEnd = text.length;
    return (lineStart, lineEnd);
  }

  bool get isH1Active {
    final idx = currentLineIndex;
    return idx < _lineStyles.length && _lineStyles[idx] == LineType.h1;
  }

  bool get isH2Active {
    final idx = currentLineIndex;
    return idx < _lineStyles.length && _lineStyles[idx] == LineType.h2;
  }

  bool get isBulletActive {
    final bounds = currentLineBounds;
    final line = text.substring(bounds.$1, bounds.$2);
    return line.startsWith('• ');
  }

  bool get isChecklistActive {
    final bounds = currentLineBounds;
    final line = text.substring(bounds.$1, bounds.$2);
    return line.startsWith('☐ ') || line.startsWith('☑ ');
  }

  void toggleH1() {
    final idx = currentLineIndex;
    if (idx >= _lineStyles.length) return;
    if (_lineStyles[idx] == LineType.h1) {
      _lineStyles[idx] = LineType.normal;
    } else {
      _lineStyles[idx] = LineType.h1;
    }
    notifyListeners();
  }

  void toggleH2() {
    final idx = currentLineIndex;
    if (idx >= _lineStyles.length) return;
    if (_lineStyles[idx] == LineType.h2) {
      _lineStyles[idx] = LineType.normal;
    } else {
      _lineStyles[idx] = LineType.h2;
    }
    notifyListeners();
  }

  void toggleBulletList() {
    final bounds = currentLineBounds;
    final lineStart = bounds.$1;
    final lineEnd = bounds.$2;
    final currentLine = text.substring(lineStart, lineEnd);
    final cursor = selection.baseOffset;

    if (currentLine.startsWith('• ')) {
      final newText = text.replaceRange(lineStart, lineStart + 2, '');
      _charFormats.removeRange(lineStart, lineStart + 2);
      final newCursor = math.max(lineStart, cursor - 2);
      value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor),
      );
    } else {
      int stripLen = 0;
      if (currentLine.startsWith('☐ ') || currentLine.startsWith('☑ ')) {
        stripLen = 2;
      }
      final newText = text.replaceRange(lineStart, lineStart + stripLen, '• ');
      if (stripLen > 0) {
        _charFormats.removeRange(lineStart, lineStart + stripLen);
      }
      _charFormats.insertAll(lineStart, const [CharFormat(), CharFormat()]);
      final newCursor = cursor - stripLen + 2;
      value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor.clamp(0, newText.length)),
      );
    }
  }

  void toggleChecklist() {
    final bounds = currentLineBounds;
    final lineStart = bounds.$1;
    final lineEnd = bounds.$2;
    final currentLine = text.substring(lineStart, lineEnd);
    final cursor = selection.baseOffset;

    if (currentLine.startsWith('☐ ')) {
      // Toggle to checked
      final newText = text.replaceRange(lineStart, lineStart + 2, '☑ ');
      value = TextEditingValue(
        text: newText,
        selection: selection,
      );
    } else if (currentLine.startsWith('☑ ')) {
      // Remove checklist
      final newText = text.replaceRange(lineStart, lineStart + 2, '');
      _charFormats.removeRange(lineStart, lineStart + 2);
      final newCursor = math.max(lineStart, cursor - 2);
      value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor),
      );
    } else {
      int stripLen = 0;
      if (currentLine.startsWith('• ')) {
        stripLen = 2;
      }
      final newText = text.replaceRange(lineStart, lineStart + stripLen, '☐ ');
      if (stripLen > 0) {
        _charFormats.removeRange(lineStart, lineStart + stripLen);
      }
      _charFormats.insertAll(lineStart, const [CharFormat(), CharFormat()]);
      final newCursor = cursor - stripLen + 2;
      value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor.clamp(0, newText.length)),
      );
    }
  }

  /// Toggles the checkbox state of the line at [cursorOffset].
  /// If line starts with '☐ ', changes to '☑ '.
  /// If line starts with '☑ ', changes to '☐ '.
  /// Returns true if a toggle occurred.
  bool toggleCheckboxAtOffset(int cursorOffset) {
    if (text.isEmpty) return false;
    final lines = text.split('\n');
    int currentOffset = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineStart = currentOffset;
      final lineEnd = lineStart + line.length;

      final isLastLine = i == lines.length - 1;
      if (cursorOffset >= lineStart && (cursorOffset <= lineEnd || (isLastLine && cursorOffset <= lineEnd + 1))) {
        if (line.startsWith('☐ ')) {
          final newText = text.replaceRange(lineStart, lineStart + 2, '☑ ');
          value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: cursorOffset.clamp(0, newText.length)),
          );
          return true;
        } else if (line.startsWith('☑ ')) {
          final newText = text.replaceRange(lineStart, lineStart + 2, '☐ ');
          value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: cursorOffset.clamp(0, newText.length)),
          );
          return true;
        }
        return false;
      }

      currentOffset += line.length + 1;
    }
    return false;
  }

  // --- Rendering TextSpan ---

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final rawText = value.text;
    if (rawText.isEmpty) {
      return TextSpan(style: style, text: '');
    }

    final baseDefaultStyle = style ??
        const TextStyle(
          fontSize: 16,
          height: 1.6,
          color: NostraColors.primaryInk,
          fontWeight: FontWeight.w400,
        );

    final spans = <TextSpan>[];
    final lines = rawText.split('\n');
    int charIndex = 0;

    for (int l = 0; l < lines.length; l++) {
      final line = lines[l];
      final isLastLine = l == lines.length - 1;
      final lineType = l < _lineStyles.length ? _lineStyles[l] : LineType.normal;

      TextStyle lineStyle = baseDefaultStyle;
      if (lineType == LineType.h1) {
        lineStyle = baseDefaultStyle.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.3,
        );
      } else if (lineType == LineType.h2) {
        lineStyle = baseDefaultStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.35,
        );
      }

      final isCheckedLine = line.startsWith('☑ ');
      final isPrefixLine = line.startsWith('☑ ') || line.startsWith('☐ ') || line.startsWith('• ');

      if (line.isNotEmpty) {
        int runStart = 0;
        CharFormat? currentRunFormat;

        if (isPrefixLine) {
          // Emit the prefix separately without strikethrough
          spans.add(_createTextSpan(
            text: line.substring(0, 2),
            baseStyle: lineStyle,
            format: const CharFormat(),
            isCheckedLine: false,
            isPrefix: true,
          ));
          runStart = 2;
        }

        for (int c = runStart; c < line.length; c++) {
          final globalIndex = charIndex + c;
          final fmt = globalIndex < _charFormats.length ? _charFormats[globalIndex] : const CharFormat();

          if (currentRunFormat == null) {
            currentRunFormat = fmt;
            runStart = c;
          } else if (fmt != currentRunFormat) {
            spans.add(_createTextSpan(
              text: line.substring(runStart, c),
              baseStyle: lineStyle,
              format: currentRunFormat,
              isCheckedLine: isCheckedLine,
            ));
            currentRunFormat = fmt;
            runStart = c;
          }
        }

        if (currentRunFormat != null && runStart < line.length) {
          spans.add(_createTextSpan(
            text: line.substring(runStart),
            baseStyle: lineStyle,
            format: currentRunFormat,
            isCheckedLine: isCheckedLine,
          ));
        }
      }

      if (!isLastLine) {
        spans.add(TextSpan(text: '\n', style: lineStyle));
        charIndex += line.length + 1;
      } else {
        charIndex += line.length;
      }
    }

    return TextSpan(children: spans);
  }

  TextSpan _createTextSpan({
    required String text,
    required TextStyle baseStyle,
    required CharFormat format,
    required bool isCheckedLine,
    bool isPrefix = false,
  }) {
    TextStyle effectiveStyle = baseStyle;

    if (format.bold) {
      effectiveStyle = effectiveStyle.copyWith(fontWeight: FontWeight.bold);
    }
    if (format.italic) {
      effectiveStyle = effectiveStyle.copyWith(fontStyle: FontStyle.italic);
    }

    final decorations = <TextDecoration>[];
    if (format.underline) {
      decorations.add(TextDecoration.underline);
    }
    if (!isPrefix && (format.strikethrough || isCheckedLine)) {
      decorations.add(TextDecoration.lineThrough);
    }

    if (decorations.isNotEmpty) {
      effectiveStyle = effectiveStyle.copyWith(
        decoration: TextDecoration.combine(decorations),
        decorationColor: isCheckedLine ? NostraColors.secondaryMuted : null,
      );
    }

    if (isCheckedLine) {
      effectiveStyle = effectiveStyle.copyWith(
        color: NostraColors.secondaryMuted,
      );
    }

    if (format.highlight) {
      effectiveStyle = effectiveStyle.copyWith(
        backgroundColor: const Color(0xFFF6E08E),
      );
    }

    return TextSpan(text: text, style: effectiveStyle);
  }

  // --- Bidirectional Markdown Serialization ---

  String toMarkdown() {
    if (text.isEmpty) return '';

    final lines = text.split('\n');
    final buffer = StringBuffer();
    int charAccum = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineType = i < _lineStyles.length ? _lineStyles[i] : LineType.normal;

      String prefix = '';
      if (lineType == LineType.h1) {
        prefix = '# ';
      } else if (lineType == LineType.h2) {
        prefix = '## ';
      }

      String content = line;
      int contentStart = charAccum;
      int contentEnd = charAccum + line.length;

      if (content.startsWith('• ')) {
        prefix = '- ';
        content = content.substring(2);
        contentStart += 2;
      } else if (content.startsWith('☐ ')) {
        prefix = '- [ ] ';
        content = content.substring(2);
        contentStart += 2;
      } else if (content.startsWith('☑ ')) {
        prefix = '- [x] ';
        content = content.substring(2);
        contentStart += 2;
      }

      buffer.write(prefix);
      buffer.write(_serializeInline(contentStart, contentEnd));

      if (i < lines.length - 1) {
        buffer.write('\n');
        charAccum += line.length + 1;
      } else {
        charAccum += line.length;
      }
    }

    return buffer.toString();
  }

  String _serializeInline(int start, int end) {
    if (start >= end) return '';
    final buffer = StringBuffer();

    int runStart = start;
    CharFormat? currentFmt;

    for (int i = start; i < end; i++) {
      final fmt = i < _charFormats.length ? _charFormats[i] : const CharFormat();
      if (currentFmt == null) {
        currentFmt = fmt;
        runStart = i;
      } else if (fmt != currentFmt) {
        buffer.write(_wrapFormat(text.substring(runStart, i), currentFmt));
        currentFmt = fmt;
        runStart = i;
      }
    }

    if (currentFmt != null && runStart < end) {
      buffer.write(_wrapFormat(text.substring(runStart, end), currentFmt));
    }

    return buffer.toString();
  }

  String _wrapFormat(String slice, CharFormat fmt) {
    if (fmt.isPlain || slice.isEmpty) return slice;

    String result = slice;
    if (fmt.bold && fmt.italic) {
      result = '***$result***';
    } else if (fmt.bold) {
      result = '**$result**';
    } else if (fmt.italic) {
      result = '*$result*';
    }

    if (fmt.underline) {
      result = '<u>$result</u>';
    }
    if (fmt.strikethrough) {
      result = '~~$result~~';
    }
    if (fmt.highlight) {
      result = '==$result==';
    }

    return result;
  }

  /// Deserializes standard Markdown text into a WYSIWYG [GoogleKeepRichTextController].
  static GoogleKeepRichTextController fromMarkdown(String markdown) {
    if (markdown.isEmpty) {
      return GoogleKeepRichTextController(text: '');
    }

    final lines = markdown.split('\n');
    final plainTextBuffer = StringBuffer();
    final formats = <CharFormat>[];
    final lineStyles = <LineType>[];

    for (int i = 0; i < lines.length; i++) {
      final rawLine = lines[i];
      final isLast = i == lines.length - 1;

      String content = rawLine;
      LineType lineType = LineType.normal;

      if (content.startsWith('# ')) {
        lineType = LineType.h1;
        content = content.substring(2);
      } else if (content.startsWith('## ')) {
        lineType = LineType.h2;
        content = content.substring(3);
      } else if (content.startsWith('### ')) {
        lineType = LineType.h2;
        content = content.substring(4);
      } else if (content.startsWith('- [ ] ') || content.startsWith('* [ ] ')) {
        plainTextBuffer.write('☐ ');
        formats.addAll(const [CharFormat(), CharFormat()]);
        content = content.substring(6);
      } else if (content.startsWith('- [x] ') ||
          content.startsWith('* [x] ') ||
          content.startsWith('- [X] ') ||
          content.startsWith('* [X] ')) {
        plainTextBuffer.write('☑ ');
        formats.addAll(const [CharFormat(), CharFormat()]);
        content = content.substring(6);
      } else if (content.startsWith('- ') || content.startsWith('* ')) {
        plainTextBuffer.write('• ');
        formats.addAll(const [CharFormat(), CharFormat()]);
        content = content.substring(2);
      }

      lineStyles.add(lineType);

      _parseInlineMarkdown(content, plainTextBuffer, formats);

      if (!isLast) {
        plainTextBuffer.write('\n');
        formats.add(const CharFormat());
      }
    }

    return GoogleKeepRichTextController(
      text: plainTextBuffer.toString(),
      formats: formats,
      lineStyles: lineStyles,
    );
  }

  static void _parseInlineMarkdown(
    String input,
    StringBuffer outText,
    List<CharFormat> outFormats, {
    CharFormat currentFormat = const CharFormat(),
  }) {
    if (input.isEmpty) return;

    final regex = RegExp(
      r'(!\[(.*?)\]\(.*?\))|' // image ![alt](url)
      r'(\[(.*?)\]\(.*?\))|' // link [text](url)
      r'(\*\*\*(.+?)\*\*\*)|' // bold+italic ***
      r'(\_\_\_(.+?)\_\_\_)|' // bold+italic ___
      r'(\*\*(.+?)\*\*)|' // bold **
      r'(\_\_(.+?)\_\_)|' // bold __
      r'(\*(.+?)\*)|' // italic *
      r'(\_([^_]+)\_)|' // italic _
      r'(<u>(.+?)<\/u>)|' // underline
      r'(~~(.+?)~~)|' // strikethrough ~~
      r'(<s>(.+?)<\/s>)|' // strikethrough <s>
      r'(<del>(.+?)<\/del>)|' // strikethrough <del>
      r'(==(.+?)==)|' // highlight ==
      r'(<mark>(.+?)<\/mark>)|' // highlight <mark>
      r'(`([^`]+)`)', // inline code
      dotAll: true,
    );

    int currentIndex = 0;
    for (final match in regex.allMatches(input)) {
      if (match.start > currentIndex) {
        final plainSlice = input.substring(currentIndex, match.start);
        outText.write(plainSlice);
        outFormats.addAll(List.filled(plainSlice.length, currentFormat));
      }

      final fullMatch = match.group(0)!;
      if (fullMatch.startsWith('![') && fullMatch.contains('](')) {
        final altMatch = RegExp(r'!\[(.*?)\]').firstMatch(fullMatch);
        final alt = altMatch?.group(1) ?? 'Gambar';
        final label = alt.isNotEmpty ? '[$alt]' : '[Gambar]';
        outText.write(label);
        outFormats.addAll(List.filled(label.length, currentFormat.copyWith(italic: true)));
      } else if (fullMatch.startsWith('[') && fullMatch.contains('](')) {
        final textMatch = RegExp(r'\[(.*?)\]').firstMatch(fullMatch);
        final linkText = textMatch?.group(1) ?? '';
        _parseInlineMarkdown(
          linkText,
          outText,
          outFormats,
          currentFormat: currentFormat.copyWith(underline: true),
        );
      } else if (fullMatch.startsWith('`') && fullMatch.endsWith('`') && fullMatch.length >= 2) {
        final inner = fullMatch.substring(1, fullMatch.length - 1);
        outText.write(inner);
        outFormats.addAll(List.filled(inner.length, currentFormat));
      } else if (fullMatch.startsWith('***') && fullMatch.endsWith('***') && fullMatch.length >= 6) {
        final inner = fullMatch.substring(3, fullMatch.length - 3);
        _parseInlineMarkdown(
          inner,
          outText,
          outFormats,
          currentFormat: currentFormat.copyWith(bold: true, italic: true),
        );
      } else if (fullMatch.startsWith('___') && fullMatch.endsWith('___') && fullMatch.length >= 6) {
        final inner = fullMatch.substring(3, fullMatch.length - 3);
        _parseInlineMarkdown(
          inner,
          outText,
          outFormats,
          currentFormat: currentFormat.copyWith(bold: true, italic: true),
        );
      } else if (fullMatch.startsWith('**') && fullMatch.endsWith('**') && fullMatch.length >= 4) {
        final inner = fullMatch.substring(2, fullMatch.length - 2);
        _parseInlineMarkdown(
          inner,
          outText,
          outFormats,
          currentFormat: currentFormat.copyWith(bold: true),
        );
      } else if (fullMatch.startsWith('__') && fullMatch.endsWith('__') && fullMatch.length >= 4) {
        final inner = fullMatch.substring(2, fullMatch.length - 2);
        _parseInlineMarkdown(
          inner,
          outText,
          outFormats,
          currentFormat: currentFormat.copyWith(bold: true),
        );
      } else if (fullMatch.startsWith('*') && fullMatch.endsWith('*') && fullMatch.length >= 2) {
        final inner = fullMatch.substring(1, fullMatch.length - 1);
        _parseInlineMarkdown(
          inner,
          outText,
          outFormats,
          currentFormat: currentFormat.copyWith(italic: true),
        );
      } else if (fullMatch.startsWith('_') && fullMatch.endsWith('_') && fullMatch.length >= 2) {
        final inner = fullMatch.substring(1, fullMatch.length - 1);
        _parseInlineMarkdown(
          inner,
          outText,
          outFormats,
          currentFormat: currentFormat.copyWith(italic: true),
        );
      } else if (fullMatch.startsWith('<u>') && fullMatch.endsWith('</u>') && fullMatch.length >= 7) {
        final inner = fullMatch.substring(3, fullMatch.length - 4);
        _parseInlineMarkdown(
          inner,
          outText,
          outFormats,
          currentFormat: currentFormat.copyWith(underline: true),
        );
      } else if (fullMatch.startsWith('~~') && fullMatch.endsWith('~~') && fullMatch.length >= 4) {
        final inner = fullMatch.substring(2, fullMatch.length - 2);
        _parseInlineMarkdown(
          inner,
          outText,
          outFormats,
          currentFormat: currentFormat.copyWith(strikethrough: true),
        );
      } else if ((fullMatch.startsWith('<s>') && fullMatch.endsWith('</s>')) ||
          (fullMatch.startsWith('<del>') && fullMatch.endsWith('</del>'))) {
        final tagLen = fullMatch.startsWith('<s>') ? 3 : 5;
        final closeLen = fullMatch.startsWith('<s>') ? 4 : 6;
        final inner = fullMatch.substring(tagLen, fullMatch.length - closeLen);
        _parseInlineMarkdown(
          inner,
          outText,
          outFormats,
          currentFormat: currentFormat.copyWith(strikethrough: true),
        );
      } else if (fullMatch.startsWith('==') && fullMatch.endsWith('==') && fullMatch.length >= 4) {
        final inner = fullMatch.substring(2, fullMatch.length - 2);
        _parseInlineMarkdown(
          inner,
          outText,
          outFormats,
          currentFormat: currentFormat.copyWith(highlight: true),
        );
      } else if (fullMatch.startsWith('<mark>') && fullMatch.endsWith('</mark>') && fullMatch.length >= 13) {
        final inner = fullMatch.substring(6, fullMatch.length - 7);
        _parseInlineMarkdown(
          inner,
          outText,
          outFormats,
          currentFormat: currentFormat.copyWith(highlight: true),
        );
      }

      currentIndex = match.end;
    }

    if (currentIndex < input.length) {
      final plainSlice = input.substring(currentIndex);
      outText.write(plainSlice);
      outFormats.addAll(List.filled(plainSlice.length, currentFormat));
    }
  }

  /// Builds a scaled rich [TextSpan] representation for card snippets and previews.
  TextSpan buildPreviewSpan({
    TextStyle? baseStyle,
  }) {
    final rawText = value.text;
    if (rawText.isEmpty) {
      return TextSpan(style: baseStyle, text: '');
    }

    final defaultStyle = baseStyle ??
        const TextStyle(
          fontSize: 12,
          height: 1.45,
          color: NostraColors.primaryInk,
          fontWeight: FontWeight.w400,
        );

    final spans = <InlineSpan>[];
    final lines = rawText.split('\n');
    int charIndex = 0;

    for (int l = 0; l < lines.length; l++) {
      final line = lines[l];
      final isLastLine = l == lines.length - 1;
      final lineType = l < _lineStyles.length ? _lineStyles[l] : LineType.normal;

      TextStyle lineStyle = defaultStyle;
      if (lineType == LineType.h1) {
        lineStyle = defaultStyle.copyWith(
          fontSize: (defaultStyle.fontSize ?? 12) + 1.5,
          fontWeight: FontWeight.w700,
        );
      } else if (lineType == LineType.h2) {
        lineStyle = defaultStyle.copyWith(
          fontSize: (defaultStyle.fontSize ?? 12) + 0.5,
          fontWeight: FontWeight.w700,
        );
      }

      final isCheckedLine = line.startsWith('☑ ');
      final isUncheckedLine = line.startsWith('☐ ');
      final isBulletLine = line.startsWith('• ');

      if (isCheckedLine || isUncheckedLine) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 1),
              child: Icon(
                isCheckedLine ? LucideIcons.checkSquare2 : LucideIcons.square,
                size: 13,
                color: isCheckedLine
                    ? NostraColors.secondaryMuted
                    : NostraColors.primaryInk.withValues(alpha: 0.75),
              ),
            ),
          ),
        );
      } else if (isBulletLine) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 1),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: NostraColors.primaryInk.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      }

      final startC = (isCheckedLine || isUncheckedLine || isBulletLine) ? 2 : 0;

      if (line.length > startC) {
        int runStart = startC;
        CharFormat? currentRunFormat;

        for (int c = startC; c < line.length; c++) {
          final globalIndex = charIndex + c;
          final fmt = globalIndex < _charFormats.length
              ? _charFormats[globalIndex]
              : const CharFormat();

          if (currentRunFormat == null) {
            currentRunFormat = fmt;
            runStart = c;
          } else if (currentRunFormat != fmt) {
            final runText = line.substring(runStart, c);
            final List<TextDecoration> decorations = [];
            if (currentRunFormat.underline) decorations.add(TextDecoration.underline);
            if (currentRunFormat.strikethrough || isCheckedLine) {
              decorations.add(TextDecoration.lineThrough);
            }

            spans.add(
              TextSpan(
                text: runText,
                style: lineStyle.copyWith(
                  fontWeight: currentRunFormat.bold ? FontWeight.w700 : lineStyle.fontWeight,
                  fontStyle: currentRunFormat.italic ? FontStyle.italic : FontStyle.normal,
                  decoration: decorations.isNotEmpty
                      ? TextDecoration.combine(decorations)
                      : TextDecoration.none,
                  backgroundColor:
                      currentRunFormat.highlight ? const Color(0xFFF6E08E) : null,
                  color: isCheckedLine
                      ? NostraColors.secondaryMuted
                      : (currentRunFormat.highlight ? Colors.black : lineStyle.color),
                ),
              ),
            );
            currentRunFormat = fmt;
            runStart = c;
          }
        }

        if (currentRunFormat != null) {
          final runText = line.substring(runStart);
          final List<TextDecoration> decorations = [];
          if (currentRunFormat.underline) decorations.add(TextDecoration.underline);
          if (currentRunFormat.strikethrough || isCheckedLine) {
            decorations.add(TextDecoration.lineThrough);
          }

          spans.add(
            TextSpan(
              text: runText,
              style: lineStyle.copyWith(
                fontWeight: currentRunFormat.bold ? FontWeight.w700 : lineStyle.fontWeight,
                fontStyle: currentRunFormat.italic ? FontStyle.italic : FontStyle.normal,
                decoration: decorations.isNotEmpty
                    ? TextDecoration.combine(decorations)
                    : TextDecoration.none,
                backgroundColor:
                    currentRunFormat.highlight ? const Color(0xFFF6E08E) : null,
                color: isCheckedLine
                    ? NostraColors.secondaryMuted
                    : (currentRunFormat.highlight ? Colors.black : lineStyle.color),
              ),
            ),
          );
        }
      }

      charIndex += line.length;
      if (!isLastLine) {
        spans.add(TextSpan(text: '\n', style: lineStyle));
        charIndex += 1;
      }
    }

    return TextSpan(children: spans);
  }

  /// Builds a rendered rich [TextSpan] from Markdown text for card previews,
  /// concealing raw Markdown tags (`**`, `~~`, `==`, `<u>`, `#`, etc.) in both modes.
  static TextSpan buildRichPreviewSpan(String markdown, {TextStyle? baseStyle}) {
    if (markdown.trim().isEmpty) {
      return TextSpan(style: baseStyle, text: '');
    }
    final slice = markdown.length > 800 ? markdown.substring(0, 800) : markdown;
    final controller = GoogleKeepRichTextController.fromMarkdown(slice);
    return controller.buildPreviewSpan(baseStyle: baseStyle);
  }
}
