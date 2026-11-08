import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mirello_utbk/features/backup/services/local_vault_service.dart';
import 'package:mirello_utbk/features/notes/data/free_notes_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalVaultService Tests', () {
    test('sanitizeFileName removes illegal filesystem characters', () {
      expect(LocalVaultService.sanitizeFileName('Catatan: Belajar / UTBK * HOT?'), 'Catatan_ Belajar _ UTBK _ HOT_');
      expect(LocalVaultService.sanitizeFileName(''), 'Tanpa_Judul');
      expect(LocalVaultService.sanitizeFileName('   Judul Rapi   '), 'Judul Rapi');
    });

    test('formatForPlainText formats bold without asterisks using Unicode bold', () {
      const markdown = '# Judul Catatan\n'
          'Teks ini **Penting Sekali** dan *miring*.\n'
          'Ada juga ==stabilo== dan <u>garis</u>.\n'
          '- [ ] Tugas 1\n'
          '- [x] Tugas 2';

      final formatted = LocalVaultService.formatForPlainText(markdown, title: 'Judul Dokumen');

      // Zero markdown asterisks, hashes, tags
      expect(formatted, isNot(contains('**')));
      expect(formatted, isNot(contains('*')));
      expect(formatted, isNot(contains('# ')));
      expect(formatted, isNot(contains('==')));
      expect(formatted, isNot(contains('<u>')));

      // Check Unicode bold conversion
      final expectedBold = LocalVaultService.toUnicodeBold('Penting Sekali');
      expect(formatted, contains(expectedBold));

      // Check checklists
      expect(formatted, contains('☐ Tugas 1'));
      expect(formatted, contains('☑ Tugas 2'));
    });

    test('LocalVaultService restores notes from markdown text with frontmatter', () async {
      final tempDir = Directory.systemTemp.createTempSync('nostra_test_vault_');
      final testFile = File('${tempDir.path}/test_note.md');

      const fileContent = '''---
id: "test_restore_01"
title: "Rumus Integral Parsial"
created: "2026-11-07T12:00:00.000Z"
updated: "2026-11-07T12:00:00.000Z"
color: "#F6E08E"
pinned: true
favorite: true
images: ["/test/img1.jpg"]
---

Integral u dv = u v - integral v du''';

      await testFile.writeAsString(fileContent);

      // Initialize Hive in temp directory for test
      Hive.init(tempDir.path);
      await FreeNotesRepository.instance.init();

      final count = await LocalVaultService.instance.restoreFromFiles([testFile.path]);
      expect(count, 1);

      final restored = FreeNotesRepository.instance.getById('test_restore_01');
      expect(restored, isNotNull);
      expect(restored!.title, 'Rumus Integral Parsial');
      expect(restored.content, 'Integral u dv = u v - integral v du');
      expect(restored.colorHex, '#F6E08E');
      expect(restored.isPinned, isTrue);
      expect(restored.isFavorite, isTrue);
      expect(restored.imagePaths, ['/test/img1.jpg']);

      await Hive.close();
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });
  });
}
