import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/widgets/doodle_illustrations.dart';
import '../../backup/services/local_vault_service.dart';
import '../models/subject_notebook.dart';

class NotebookRepository {
  static const String boxName = 'mirello_notebooks';
  static NotebookRepository? _instance;
  late Box _box;

  NotebookRepository._();

  static NotebookRepository get instance {
    _instance ??= NotebookRepository._();
    return _instance!;
  }

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
    final isInitialized = _box.get('__initialized', defaultValue: false) as bool;
    if (!isInitialized) {
      if (_box.isEmpty) {
        for (final subject in SubjectNotebook.defaultSubjects) {
          await _box.put(subject.id, subject.toMap());
        }
      }
      await _box.put('__initialized', true);
    } else {
      // Migrate or update default subjects with markdown content if missing
      final defaultMap = {for (var s in SubjectNotebook.defaultSubjects) s.id: s};
      for (var key in _box.keys) {
        if (key.toString().startsWith('__')) continue;
        final data = _box.get(key);
        if (data is Map) {
          final notebook = SubjectNotebook.fromMap(data);
          final defaultMatch = defaultMap[notebook.id];

          if (defaultMatch != null &&
              (notebook.markdownContent == null || notebook.markdownContent!.isEmpty)) {
            await _box.put(
              key,
              notebook.copyWith(
                markdownContent: defaultMatch.markdownContent,
                totalPages: defaultMatch.totalPages,
                currentPage: 1,
              ).toMap(),
            );
          } else if (notebook.currentPage > notebook.totalPages) {
            await _box.put(
              key,
              notebook.copyWith(currentPage: 1).toMap(),
            );
          }
        }
      }
    }
    // Auto-clean any subjects in trash older than 7 days
    await purgeOldTrash();
  }

  /// Automatically delete notebooks that have been in trash for >= 7 days
  Future<void> purgeOldTrash() async {
    final now = DateTime.now();
    final toRemove = <String>[];
    for (var key in _box.keys) {
      if (key.toString().startsWith('__')) continue;
      final data = _box.get(key);
      if (data is Map) {
        final notebook = SubjectNotebook.fromMap(data);
        if (notebook.isDeleted && notebook.deletedAt != null) {
          if (now.difference(notebook.deletedAt!).inDays >= 7) {
            toRemove.add(notebook.id);
          }
        }
      }
    }
    for (final id in toRemove) {
      await permanentlyDelete(id);
    }
  }

  ValueListenable<Box> get listenable => _box.listenable();

  List<SubjectNotebook> getAll({
    bool includeArchived = false,
    bool includeDeleted = false,
  }) {
    final items = <SubjectNotebook>[];
    for (var key in _box.keys) {
      if (key.toString().startsWith('__')) continue;
      final data = _box.get(key);
      if (data is Map) {
        final notebook = SubjectNotebook.fromMap(data);
        if (!includeDeleted && notebook.isDeleted) continue;
        if (!includeArchived && notebook.isArchived) continue;
        items.add(notebook);
      }
    }
    return items;
  }

  List<SubjectNotebook> getArchived() {
    final items = <SubjectNotebook>[];
    for (var key in _box.keys) {
      if (key.toString().startsWith('__')) continue;
      final data = _box.get(key);
      if (data is Map) {
        final notebook = SubjectNotebook.fromMap(data);
        if (notebook.isArchived && !notebook.isDeleted) {
          items.add(notebook);
        }
      }
    }
    return items;
  }

  List<SubjectNotebook> getTrash() {
    final items = <SubjectNotebook>[];
    for (var key in _box.keys) {
      if (key.toString().startsWith('__')) continue;
      final data = _box.get(key);
      if (data is Map) {
        final notebook = SubjectNotebook.fromMap(data);
        if (notebook.isDeleted) {
          items.add(notebook);
        }
      }
    }
    items.sort((a, b) => (b.deletedAt ?? DateTime.now()).compareTo(a.deletedAt ?? DateTime.now()));
    return items;
  }

  SubjectNotebook? getById(String id) {
    final data = _box.get(id);
    if (data is Map) {
      return SubjectNotebook.fromMap(data);
    }
    return null;
  }

  Future<void> save(SubjectNotebook notebook) async {
    await _box.put(notebook.id, notebook.toMap());
    if (notebook.markdownContent != null &&
        notebook.markdownContent!.trim().isNotEmpty &&
        !notebook.isDeleted) {
      await LocalVaultService.instance.syncNotebook(notebook);
    }
  }

  /// Soft delete: moves subject to Trash
  Future<void> moveToTrash(String notebookId) async {
    final notebook = getById(notebookId);
    if (notebook != null) {
      final updated = notebook.copyWith(
        isDeleted: true,
        deletedAt: DateTime.now(),
      );
      await _box.put(updated.id, updated.toMap());
    }
  }

  /// Default delete action is to move to Trash
  Future<void> delete(String notebookId) async {
    await moveToTrash(notebookId);
  }

  /// Restore subject from Trash
  Future<void> restoreFromTrash(String notebookId) async {
    final notebook = getById(notebookId);
    if (notebook != null) {
      final updated = notebook.copyWith(
        isDeleted: false,
        clearDeletedAt: true,
        updatedAt: DateTime.now(),
      );
      await save(updated);
    }
  }

  /// Permanently delete subject from storage
  Future<void> permanentlyDelete(String notebookId) async {
    await _box.delete(notebookId);
  }

  /// Empty all subjects in trash
  Future<void> emptyTrash() async {
    final trashItems = getTrash();
    for (final nb in trashItems) {
      await permanentlyDelete(nb.id);
    }
  }

  /// Archive subject
  Future<void> archive(String notebookId) async {
    final notebook = getById(notebookId);
    if (notebook != null) {
      final updated = notebook.copyWith(
        isArchived: true,
        updatedAt: DateTime.now(),
      );
      await save(updated);
    }
  }

  /// Unarchive subject
  Future<void> unarchive(String notebookId) async {
    final notebook = getById(notebookId);
    if (notebook != null) {
      final updated = notebook.copyWith(
        isArchived: false,
        updatedAt: DateTime.now(),
      );
      await save(updated);
    }
  }

  /// Toggle archive state
  Future<void> toggleArchive(String notebookId) async {
    final notebook = getById(notebookId);
    if (notebook != null) {
      if (notebook.isArchived) {
        await unarchive(notebookId);
      } else {
        await archive(notebookId);
      }
    }
  }

  Future<void> updateMarkdown(
    String notebookId,
    String content, {
    int? totalPages,
  }) async {
    final existingData = _box.get(notebookId);
    SubjectNotebook notebook;
    if (existingData is Map) {
      notebook = SubjectNotebook.fromMap(existingData);
    } else {
      final defaults =
          SubjectNotebook.defaultSubjects.where((s) => s.id == notebookId);
      if (defaults.isNotEmpty) {
        notebook = defaults.first;
      } else {
        notebook = SubjectNotebook(
          id: notebookId,
          title: 'Catatan',
          code: 'UTBK',
          cardColorHex: '#E8E1EB',
          doodleType: SubjectDoodleType.logic,
        );
      }
    }
    final updated = notebook.copyWith(
      markdownContent: content,
      totalPages: totalPages ?? notebook.totalPages,
      currentPage: 1,
      lastOpenedText: 'Baru diperbarui',
      updatedAt: DateTime.now(),
    );
    await save(updated);
  }

  Future<void> updateCurrentPage(String notebookId, int page) async {
    final existingData = _box.get(notebookId);
    if (existingData is Map) {
      final notebook = SubjectNotebook.fromMap(existingData);
      final updated = notebook.copyWith(
        currentPage: page,
        lastOpenedText: 'Baru dibaca',
        updatedAt: DateTime.now(),
      );
      await save(updated);
    }
  }

  Future<void> updatePdfPath(String notebookId, String? path, {int? totalPages}) async {
    final existingData = _box.get(notebookId);
    if (existingData is Map) {
      final notebook = SubjectNotebook.fromMap(existingData);
      final updated = notebook.copyWith(
        pdfFilePath: path,
        clearPdfFilePath: path == null,
        totalPages: totalPages ?? notebook.totalPages,
        lastOpenedText: 'Baru diperbarui',
        updatedAt: DateTime.now(),
      );
      await save(updated);
    }
  }

  Future<void> toggleFavorite(String notebookId) async {
    final existingData = _box.get(notebookId);
    if (existingData is Map) {
      final notebook = SubjectNotebook.fromMap(existingData);
      final updated = notebook.copyWith(isFavorite: !notebook.isFavorite);
      await save(updated);
    }
  }

  Future<void> resetToDefaults() async {
    await _box.clear();
    for (final subject in SubjectNotebook.defaultSubjects) {
      await _box.put(subject.id, subject.toMap());
    }
    await _box.put('__initialized', true);
  }
}

