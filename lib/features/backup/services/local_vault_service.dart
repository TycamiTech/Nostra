import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../library/models/subject_notebook.dart';
import '../../notes/data/free_notes_repository.dart';
import '../../notes/models/free_note.dart';

class LocalVaultService {
  static LocalVaultService? _instance;
  LocalVaultService._();

  static LocalVaultService get instance {
    _instance ??= LocalVaultService._();
    return _instance!;
  }

  /// Sanitize file name to avoid illegal filesystem characters
  static String sanitizeFileName(String name) {
    var cleaned = name
        .replaceAll(RegExp(r'[\\/:*?"<>|\r\n\t]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) {
      cleaned = 'Tanpa_Judul';
    }
    if (cleaned.length > 60) {
      cleaned = cleaned.substring(0, 60).trim();
    }
    return cleaned;
  }

  /// Get or create the root Nostra Vault directory
  Future<Directory> getVaultDirectory() async {
    Directory? vaultDir;

    // 1. Try public Documents/Nostra on Android
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final publicDocDir = Directory('/storage/emulated/0/Documents/Nostra');
        if (!publicDocDir.existsSync()) {
          publicDocDir.createSync(recursive: true);
        }
        vaultDir = publicDocDir;
      } catch (_) {
        // Fallback to Download/Nostra if Documents fails
        try {
          final publicDownloadDir = Directory('/storage/emulated/0/Download/Nostra');
          if (!publicDownloadDir.existsSync()) {
            publicDownloadDir.createSync(recursive: true);
          }
          vaultDir = publicDownloadDir;
        } catch (_) {
          vaultDir = null;
        }
      }
    }

    // 2. Fallback to app documents directory
    if (vaultDir == null) {
      final appDocDir = await getApplicationDocumentsDirectory();
      vaultDir = Directory('${appDocDir.path}/Nostra_Vault');
      if (!vaultDir.existsSync()) {
        vaultDir.createSync(recursive: true);
      }
    }

    // Ensure subdirectories exist
    final freeNotesDir = Directory('${vaultDir.path}/Catatan');
    if (!freeNotesDir.existsSync()) {
      // Migrate from old "Catatan Bebas" if exists
      final oldDir = Directory('${vaultDir.path}/Catatan Bebas');
      if (oldDir.existsSync()) {
        try {
          oldDir.renameSync(freeNotesDir.path);
        } catch (_) {
          freeNotesDir.createSync(recursive: true);
        }
      } else {
        freeNotesDir.createSync(recursive: true);
      }
    }

    final modulesDir = Directory('${vaultDir.path}/Modul UTBK');
    if (!modulesDir.existsSync()) {
      modulesDir.createSync(recursive: true);
    }

    return vaultDir;
  }

  /// Synchronize a FreeNote into a real .md file (Obsidian-compatible YAML frontmatter)
  Future<File?> syncFreeNote(FreeNote note) async {
    try {
      final vaultDir = await getVaultDirectory();
      final notesDir = Directory('${vaultDir.path}/Catatan');
      final fileName = '${sanitizeFileName(note.title.isNotEmpty ? note.title : 'Catatan_${note.id}')}.md';
      final file = File('${notesDir.path}/$fileName');

      final buffer = StringBuffer();
      buffer.writeln('---');
      buffer.writeln('id: "${note.id}"');
      buffer.writeln('title: "${note.title}"');
      buffer.writeln('created: "${note.createdAt.toIso8601String()}"');
      buffer.writeln('updated: "${note.updatedAt.toIso8601String()}"');
      buffer.writeln('color: "${note.colorHex}"');
      buffer.writeln('pinned: ${note.isPinned}');
      buffer.writeln('favorite: ${note.isFavorite}');
      if (note.imagePaths.isNotEmpty) {
        buffer.writeln('images: [${note.imagePaths.map((p) => '"$p"').join(', ')}]');
      }
      buffer.writeln('---');
      buffer.writeln();
      buffer.write(note.content);

      await file.writeAsString(buffer.toString());
      return file;
    } catch (e) {
      debugPrint('Error syncing free note to file: $e');
      return null;
    }
  }

  /// Remove the physical file when a note is deleted
  Future<void> deleteFreeNoteFile(String id, {String? title}) async {
    try {
      final vaultDir = await getVaultDirectory();
      final notesDir = Directory('${vaultDir.path}/Catatan');
      if (!notesDir.existsSync()) return;

      final files = notesDir.listSync();
      for (final f in files) {
        if (f is File && f.path.endsWith('.md')) {
          try {
            final content = await f.readAsString();
            if (content.contains('id: "$id"')) {
              await f.delete();
              return;
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Error deleting note file: $e');
    }
  }

  /// Synchronize an UTBK Subject Notebook to a real .md file
  Future<File?> syncNotebook(SubjectNotebook notebook) async {
    try {
      if (notebook.markdownContent == null || notebook.markdownContent!.trim().isEmpty) {
        return null;
      }

      final vaultDir = await getVaultDirectory();
      final modulesDir = Directory('${vaultDir.path}/Modul UTBK');
      final fileName = '${notebook.code} - ${sanitizeFileName(notebook.title)}.md';
      final file = File('${modulesDir.path}/$fileName');

      await file.writeAsString(notebook.markdownContent!);
      return file;
    } catch (e) {
      debugPrint('Error syncing notebook to file: $e');
      return null;
    }
  }

  /// Export & Share a single note via Android Share Sheet
  Future<void> exportSingleNote(FreeNote note, {bool asTxt = false}) async {
    final ext = asTxt ? 'txt' : 'md';
    final fileName = '${sanitizeFileName(note.title.isNotEmpty ? note.title : 'Catatan')}.$ext';
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');

    final text = asTxt
        ? formatForPlainText(note.content, title: note.title)
        : '''---
title: "${note.title}"
date: "${note.updatedAt.toIso8601String()}"
---

# ${note.title}

${note.content}''';

    await file.writeAsString(text);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Catatan dari Nostra: ${note.title}',
      ),
    );
  }

  /// Converts Markdown formatted note text into clean plain text for .txt export,
  /// replacing **bold** with true Unicode Bold characters (e.g. 𝗕𝗼𝗹𝗱) and stripping
  /// raw markdown syntax characters so it looks genuinely formatted without asterisks.
  static String formatForPlainText(String markdown, {String title = ''}) {
    final buffer = StringBuffer();
    if (title.trim().isNotEmpty) {
      buffer.writeln(toUnicodeBold(title.trim()));
      buffer.writeln();
    }

    final lines = markdown.split('\n');
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // Convert headings to bold
      if (line.startsWith('# ')) {
        line = toUnicodeBold(line.substring(2).trim());
      } else if (line.startsWith('## ')) {
        line = toUnicodeBold(line.substring(3).trim());
      } else if (line.startsWith('### ')) {
        line = toUnicodeBold(line.substring(4).trim());
      } else if (line.startsWith('- [ ] ') || line.startsWith('* [ ] ')) {
        line = '☐ ${line.substring(6)}';
      } else if (line.startsWith('- [x] ') || line.startsWith('- [X] ') || line.startsWith('* [x] ')) {
        line = '☑ ${line.substring(6)}';
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        line = '• ${line.substring(2)}';
      }

      // Bold+Italic ***text*** or ___text___
      line = line.replaceAllMapped(RegExp(r'\*\*\*(.+?)\*\*\*|\_\_\_(.+?)\_\_\_'), (m) {
        final inner = m.group(1) ?? m.group(2) ?? '';
        return toUnicodeBold(inner);
      });

      // Bold **text** or __text__ -> Unicode Bold
      line = line.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*|\_\_(.+?)\_\_'), (m) {
        final inner = m.group(1) ?? m.group(2) ?? '';
        return toUnicodeBold(inner);
      });

      // Italic *text* or _text_ -> Unicode Italic
      line = line.replaceAllMapped(RegExp(r'\*([^*]+)\*|\_([^_]+)\_'), (m) {
        final inner = m.group(1) ?? m.group(2) ?? '';
        return toUnicodeItalic(inner);
      });

      // Highlight ==text== or <mark>text</mark> -> Clean text
      line = line.replaceAllMapped(RegExp(r'==(.+?)==|<mark>(.+?)<\/mark>'), (m) {
        return m.group(1) ?? m.group(2) ?? '';
      });

      // Underline <u>text</u> -> Clean text
      line = line.replaceAllMapped(RegExp(r'<u>(.+?)<\/u>'), (m) {
        return m.group(1) ?? '';
      });

      // Strikethrough ~~text~~ or <s>text</s> -> Clean text
      line = line.replaceAllMapped(RegExp(r'~~(.+?)~~|<s>(.+?)<\/s>|<del>(.+?)<\/del>'), (m) {
        return m.group(1) ?? m.group(2) ?? m.group(3) ?? '';
      });

      buffer.writeln(line);
    }

    return buffer.toString().trimRight();
  }

  /// Converts standard ASCII alphanumeric characters to Unicode Sans-Serif Bold glyphs
  static String toUnicodeBold(String input) {
    final sb = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 65 && rune <= 90) {
        // A-Z -> Sans-Serif Bold
        sb.writeCharCode(0x1D5D4 + (rune - 65));
      } else if (rune >= 97 && rune <= 122) {
        // a-z -> Sans-Serif Bold
        sb.writeCharCode(0x1D5EE + (rune - 97));
      } else if (rune >= 48 && rune <= 57) {
        // 0-9 -> Sans-Serif Bold
        sb.writeCharCode(0x1D7EC + (rune - 48));
      } else {
        sb.writeCharCode(rune);
      }
    }
    return sb.toString();
  }

  /// Converts standard ASCII alphabetic characters to Unicode Sans-Serif Italic glyphs
  static String toUnicodeItalic(String input) {
    final sb = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 65 && rune <= 90) {
        // A-Z -> Sans-Serif Italic
        sb.writeCharCode(0x1D608 + (rune - 65));
      } else if (rune >= 97 && rune <= 122) {
        // a-z -> Sans-Serif Italic
        sb.writeCharCode(0x1D622 + (rune - 97));
      } else {
        sb.writeCharCode(rune);
      }
    }
    return sb.toString();
  }

  /// Backup all notebooks and all free notes to the local vault
  Future<int> backupAll({
    required List<SubjectNotebook> notebooks,
    required List<FreeNote> freeNotes,
  }) async {
    int count = 0;
    for (final note in freeNotes) {
      final res = await syncFreeNote(note);
      if (res != null) count++;
    }
    for (final nb in notebooks) {
      final res = await syncNotebook(nb);
      if (res != null) count++;
    }
    return count;
  }

  /// Share all notes at once as individual .md files
  Future<void> shareAllNotes({
    required List<SubjectNotebook> notebooks,
    required List<FreeNote> freeNotes,
  }) async {
    final xfiles = <XFile>[];
    final tempDir = await getTemporaryDirectory();

    for (final note in freeNotes) {
      final name = '${sanitizeFileName(note.title.isNotEmpty ? note.title : 'Catatan_${note.id}')}.md';
      final f = File('${tempDir.path}/$name');
      await f.writeAsString('''---
id: "${note.id}"
title: "${note.title}"
updated: "${note.updatedAt.toIso8601String()}"
---

${note.content}''');
      xfiles.add(XFile(f.path));
    }

    for (final nb in notebooks) {
      if (nb.markdownContent != null && nb.markdownContent!.trim().isNotEmpty) {
        final name = '${nb.code} - ${sanitizeFileName(nb.title)}.md';
        final f = File('${tempDir.path}/$name');
        await f.writeAsString(nb.markdownContent!);
        xfiles.add(XFile(f.path));
      }
    }

    if (xfiles.isNotEmpty) {
      await SharePlus.instance.share(
        ShareParams(
          files: xfiles,
          text: 'Cadangan Seluruh Catatan Nostra',
        ),
      );
    }
  }

  /// Restore notes from chosen files (handles frontmatter or plain text)
  Future<int> restoreFromFiles(List<String> filePaths) async {
    int restoredCount = 0;
    final repo = FreeNotesRepository.instance;

    for (final path in filePaths) {
      try {
        final file = File(path);
        if (!file.existsSync()) continue;

        final raw = await file.readAsString();
        if (raw.trim().isEmpty) continue;

        String title = '';
        String content = raw;
        String colorHex = FreeNote.presetColors[0];
        bool isPinned = false;
        bool isFavorite = false;
        List<String> imagePaths = [];
        String id = DateTime.now().millisecondsSinceEpoch.toString() + (restoredCount).toString();

        // Check if YAML frontmatter exists
        if (raw.startsWith('---')) {
          final endIdx = raw.indexOf('---', 3);
          if (endIdx != -1) {
            final fmMatter = raw.substring(3, endIdx);
            content = raw.substring(endIdx + 3).trim();

            for (final line in fmMatter.split('\n')) {
              final trim = line.trim();
              if (trim.startsWith('title:')) {
                title = trim.replaceFirst('title:', '').replaceAll('"', '').trim();
              } else if (trim.startsWith('color:')) {
                colorHex = trim.replaceFirst('color:', '').replaceAll('"', '').trim();
              } else if (trim.startsWith('id:')) {
                id = trim.replaceFirst('id:', '').replaceAll('"', '').trim();
              } else if (trim.startsWith('pinned:')) {
                isPinned = trim.contains('true');
              } else if (trim.startsWith('favorite:')) {
                isFavorite = trim.contains('true');
              } else if (trim.startsWith('images:')) {
                final match = RegExp(r'\[(.*)\]').firstMatch(trim);
                if (match != null) {
                  final listStr = match.group(1) ?? '';
                  imagePaths = listStr
                      .split(',')
                      .map((s) => s.replaceAll('"', '').trim())
                      .where((s) => s.isNotEmpty)
                      .toList();
                }
              }
            }
          }
        }

        // If title still empty, deduce from filename or first line
        if (title.isEmpty) {
          final baseName = file.uri.pathSegments.last;
          title = baseName.replaceAll(RegExp(r'\.(md|txt|markdown)$', caseSensitive: false), '');
        }

        final note = FreeNote(
          id: id,
          title: title,
          content: content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          colorHex: colorHex,
          isPinned: isPinned,
          isFavorite: isFavorite,
          imagePaths: imagePaths,
        );

        await repo.save(note);
        restoredCount++;
      } catch (e) {
        debugPrint('Error restoring file $path: $e');
      }
    }

    return restoredCount;
  }
}
