import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../backup/services/local_vault_service.dart';
import '../models/free_note.dart';

class FreeNotesRepository {
  static const String boxName = 'nostra_free_notes';
  static FreeNotesRepository? _instance;
  late Box _box;

  FreeNotesRepository._();

  static FreeNotesRepository get instance {
    _instance ??= FreeNotesRepository._();
    return _instance!;
  }

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
    final isInitialized = _box.get('__initialized', defaultValue: false) as bool;
    if (!isInitialized) {
      if (_box.isEmpty) {
        // Seed initial friendly sample note
        final initialNote = FreeNote(
          id: 'note_welcome',
          title: 'Selamat Datang di Catatan!',
          content:
              'Ruang ini khusus untuk kamu yang ingin mengetik cepat, menulis ide mendadak, rumus les, atau to-do list harian tanpa harus memikirkan format Markdown atau AI.\n\nTips:\n• Ketik teks sesuka hati selayaknya aplikasi catatan biasa.\n• Ubah warna pastel kartu catatan sesuai mood kamu.\n• Sematkan (pin) catatan penting agar selalu tampil paling atas.',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          colorHex: '#F6E08E',
          isPinned: true,
          isFavorite: false,
        );
        await _box.put(initialNote.id, initialNote.toMap());
      }
      await _box.put('__initialized', true);
    }
    // Auto-clean any notes in trash older than 7 days
    await purgeOldTrash();
  }

  /// Automatically delete notes that have been in trash for >= 7 days
  Future<void> purgeOldTrash() async {
    final now = DateTime.now();
    final toRemove = <String>[];
    for (var key in _box.keys) {
      if (key.toString().startsWith('__')) continue;
      final data = _box.get(key);
      if (data is Map) {
        final note = FreeNote.fromMap(data);
        if (note.isDeleted && note.deletedAt != null) {
          if (now.difference(note.deletedAt!).inDays >= 7) {
            toRemove.add(note.id);
          }
        }
      }
    }
    for (final id in toRemove) {
      await permanentlyDelete(id);
    }
  }

  ValueListenable<Box> get listenable => _box.listenable();

  List<FreeNote> getAll({
    String searchQuery = '',
    bool onlyFavorites = false,
    bool includeArchived = false,
    bool includeDeleted = false,
  }) {
    final list = <FreeNote>[];
    for (var key in _box.keys) {
      if (key.toString().startsWith('__')) continue;
      final data = _box.get(key);
      if (data is Map) {
        final note = FreeNote.fromMap(data);
        if (!includeDeleted && note.isDeleted) continue;
        if (!includeArchived && note.isArchived) continue;
        if (onlyFavorites && !note.isFavorite) continue;

        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase().trim();
          final matchesTitle = note.title.toLowerCase().contains(query);
          final matchesContent = note.content.toLowerCase().contains(query);
          if (!matchesTitle && !matchesContent) continue;
        }

        list.add(note);
      }
    }

    // Sort: pinned first, then newest updatedAt
    list.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return list;
  }

  List<FreeNote> getArchived() {
    final list = <FreeNote>[];
    for (var key in _box.keys) {
      if (key.toString().startsWith('__')) continue;
      final data = _box.get(key);
      if (data is Map) {
        final note = FreeNote.fromMap(data);
        if (note.isArchived && !note.isDeleted) {
          list.add(note);
        }
      }
    }
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  List<FreeNote> getTrash() {
    final list = <FreeNote>[];
    for (var key in _box.keys) {
      if (key.toString().startsWith('__')) continue;
      final data = _box.get(key);
      if (data is Map) {
        final note = FreeNote.fromMap(data);
        if (note.isDeleted) {
          list.add(note);
        }
      }
    }
    list.sort((a, b) => (b.deletedAt ?? b.updatedAt).compareTo(a.deletedAt ?? a.updatedAt));
    return list;
  }

  FreeNote? getById(String id) {
    final data = _box.get(id);
    if (data is Map) {
      return FreeNote.fromMap(data);
    }
    return null;
  }

  Future<void> save(FreeNote note) async {
    await _box.put(note.id, note.toMap());
    // Auto-mirror to local vault file (.md) if not deleted
    if (!note.isDeleted) {
      await LocalVaultService.instance.syncFreeNote(note);
    }
  }

  /// Soft delete: moves note to Trash with deletedAt timestamp
  Future<void> moveToTrash(String id) async {
    final note = getById(id);
    if (note != null) {
      final updated = note.copyWith(
        isDeleted: true,
        deletedAt: DateTime.now(),
        isPinned: false,
      );
      await _box.put(updated.id, updated.toMap());
    }
  }

  /// Default delete action is to move to Trash
  Future<void> delete(String id) async {
    await moveToTrash(id);
  }

  /// Restore note from Trash back to active notes
  Future<void> restoreFromTrash(String id) async {
    final note = getById(id);
    if (note != null) {
      final updated = note.copyWith(
        isDeleted: false,
        clearDeletedAt: true,
        updatedAt: DateTime.now(),
      );
      await save(updated);
    }
  }

  /// Permanently deletes note from database and local vault
  Future<void> permanentlyDelete(String id) async {
    await _box.delete(id);
    await LocalVaultService.instance.deleteFreeNoteFile(id);
  }

  /// Empty all notes currently in Trash
  Future<void> emptyTrash() async {
    final trashNotes = getTrash();
    for (final note in trashNotes) {
      await permanentlyDelete(note.id);
    }
  }

  /// Archive note
  Future<void> archive(String id) async {
    final note = getById(id);
    if (note != null) {
      final updated = note.copyWith(
        isArchived: true,
        isPinned: false,
        updatedAt: DateTime.now(),
      );
      await save(updated);
    }
  }

  /// Unarchive note
  Future<void> unarchive(String id) async {
    final note = getById(id);
    if (note != null) {
      final updated = note.copyWith(
        isArchived: false,
        updatedAt: DateTime.now(),
      );
      await save(updated);
    }
  }

  /// Toggle archive state
  Future<void> toggleArchive(String id) async {
    final note = getById(id);
    if (note != null) {
      if (note.isArchived) {
        await unarchive(id);
      } else {
        await archive(id);
      }
    }
  }

  Future<void> togglePin(String id) async {
    final note = getById(id);
    if (note != null) {
      final updated = note.copyWith(
        isPinned: !note.isPinned,
        updatedAt: DateTime.now(),
      );
      await save(updated);
    }
  }

  Future<void> toggleFavorite(String id) async {
    final note = getById(id);
    if (note != null) {
      final updated = note.copyWith(
        isFavorite: !note.isFavorite,
        updatedAt: DateTime.now(),
      );
      await save(updated);
    }
  }

  Future<void> updateColor(String id, String colorHex) async {
    final note = getById(id);
    if (note != null) {
      final updated = note.copyWith(
        colorHex: colorHex,
        updatedAt: DateTime.now(),
      );
      await save(updated);
    }
  }
}

