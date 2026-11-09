import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nostra/features/library/data/notebook_repository.dart';
import 'package:nostra/features/notes/data/free_notes_repository.dart';
import 'package:nostra/features/notes/models/free_note.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('nostra_archive_trash_test_');
    Hive.init(tempDir.path);
    await FreeNotesRepository.instance.init();
    await NotebookRepository.instance.init();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Arsip & Sampah (Trash) Feature Tests', () {
    test('FreeNote archiving and unarchiving', () async {
      final note = FreeNote(
        id: 'test_archive_note',
        title: 'Catatan Arsip Test',
        content: 'Isi catatan arsip',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await FreeNotesRepository.instance.save(note);

      // Active list contains it
      expect(FreeNotesRepository.instance.getAll().any((n) => n.id == note.id), isTrue);
      expect(FreeNotesRepository.instance.getArchived().any((n) => n.id == note.id), isFalse);

      // Archive it
      await FreeNotesRepository.instance.archive(note.id);
      expect(FreeNotesRepository.instance.getAll().any((n) => n.id == note.id), isFalse);
      expect(FreeNotesRepository.instance.getArchived().any((n) => n.id == note.id), isTrue);

      // Unarchive it
      await FreeNotesRepository.instance.unarchive(note.id);
      expect(FreeNotesRepository.instance.getAll().any((n) => n.id == note.id), isTrue);
      expect(FreeNotesRepository.instance.getArchived().any((n) => n.id == note.id), isFalse);
    });

    test('FreeNote trash, restore, and 7-day auto-purge', () async {
      final note = FreeNote(
        id: 'test_trash_note',
        title: 'Catatan Sampah Test',
        content: 'Isi catatan sampah',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await FreeNotesRepository.instance.save(note);

      // Move to trash
      await FreeNotesRepository.instance.moveToTrash(note.id);
      expect(FreeNotesRepository.instance.getAll().any((n) => n.id == note.id), isFalse);
      expect(FreeNotesRepository.instance.getTrash().any((n) => n.id == note.id), isTrue);

      // Restore
      await FreeNotesRepository.instance.restoreFromTrash(note.id);
      expect(FreeNotesRepository.instance.getAll().any((n) => n.id == note.id), isTrue);
      expect(FreeNotesRepository.instance.getTrash().any((n) => n.id == note.id), isFalse);

      // Put in trash with 8 days old timestamp
      final eightDaysAgo = DateTime.now().subtract(const Duration(days: 8));
      final oldTrashNote = note.copyWith(
        isDeleted: true,
        deletedAt: eightDaysAgo,
      );
      await FreeNotesRepository.instance.save(oldTrashNote);

      expect(FreeNotesRepository.instance.getTrash().any((n) => n.id == note.id), isTrue);

      // Run purgeOldTrash
      await FreeNotesRepository.instance.purgeOldTrash();
      expect(FreeNotesRepository.instance.getTrash().any((n) => n.id == note.id), isFalse);
      expect(FreeNotesRepository.instance.getById(note.id), isNull);
    });

    test('SubjectNotebook archiving and unarchiving', () async {
      final allSubjects = NotebookRepository.instance.getAll();
      final subject = allSubjects.first;

      // Archive subject
      await NotebookRepository.instance.archive(subject.id);
      expect(NotebookRepository.instance.getAll().any((s) => s.id == subject.id), isFalse);
      expect(NotebookRepository.instance.getArchived().any((s) => s.id == subject.id), isTrue);

      // Unarchive subject
      await NotebookRepository.instance.unarchive(subject.id);
      expect(NotebookRepository.instance.getAll().any((s) => s.id == subject.id), isTrue);
      expect(NotebookRepository.instance.getArchived().any((s) => s.id == subject.id), isFalse);
    });

    test('SubjectNotebook trash, restore, and 7-day auto-purge', () async {
      final allSubjects = NotebookRepository.instance.getAll();
      final subject = allSubjects.last;

      // Move to trash
      await NotebookRepository.instance.moveToTrash(subject.id);
      expect(NotebookRepository.instance.getAll().any((s) => s.id == subject.id), isFalse);
      expect(NotebookRepository.instance.getTrash().any((s) => s.id == subject.id), isTrue);

      // Restore
      await NotebookRepository.instance.restoreFromTrash(subject.id);
      expect(NotebookRepository.instance.getAll().any((s) => s.id == subject.id), isTrue);
      expect(NotebookRepository.instance.getTrash().any((s) => s.id == subject.id), isFalse);

      // Put in trash 8 days old
      final eightDaysAgo = DateTime.now().subtract(const Duration(days: 8));
      final oldTrashSubject = subject.copyWith(
        isDeleted: true,
        deletedAt: eightDaysAgo,
      );
      await NotebookRepository.instance.save(oldTrashSubject);

      expect(NotebookRepository.instance.getTrash().any((s) => s.id == subject.id), isTrue);

      // Purge
      await NotebookRepository.instance.purgeOldTrash();
      expect(NotebookRepository.instance.getTrash().any((s) => s.id == subject.id), isFalse);
      expect(NotebookRepository.instance.getById(subject.id), isNull);
    });
  });
}

