import 'package:hive_flutter/hive_flutter.dart';
import '../models/sticky_note.dart';

class ReaderRepository {
  static const String bookmarksBoxName = 'mirello_bookmarks';
  static const String notesBoxName = 'mirello_stickynotes';
  static ReaderRepository? _instance;

  late Box _bookmarksBox;
  late Box _notesBox;

  ReaderRepository._();

  static ReaderRepository get instance {
    _instance ??= ReaderRepository._();
    return _instance!;
  }

  Future<void> init() async {
    _bookmarksBox = await Hive.openBox(bookmarksBoxName);
    _notesBox = await Hive.openBox(notesBoxName);
  }

  bool isBookmarked(String subjectId, int pageNumber) {
    final key = '$subjectId:$pageNumber';
    return _bookmarksBox.get(key, defaultValue: false) as bool;
  }

  Future<bool> toggleBookmark(String subjectId, int pageNumber) async {
    final key = '$subjectId:$pageNumber';
    final current = isBookmarked(subjectId, pageNumber);
    final newState = !current;
    if (newState) {
      await _bookmarksBox.put(key, true);
    } else {
      await _bookmarksBox.delete(key);
    }
    return newState;
  }

  List<StickyNote> getNotesForPage(String subjectId, int pageNumber) {
    final list = <StickyNote>[];
    for (var key in _notesBox.keys) {
      final data = _notesBox.get(key);
      if (data is Map) {
        final note = StickyNote.fromMap(data);
        if (note.subjectId == subjectId && note.pageNumber == pageNumber) {
          list.add(note);
        }
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> addStickyNote(StickyNote note) async {
    await _notesBox.put(note.id, note.toMap());
  }

  Future<void> deleteStickyNote(String id) async {
    await _notesBox.delete(id);
  }
}

