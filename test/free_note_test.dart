import 'package:flutter_test/flutter_test.dart';
import 'package:nostra/features/notes/models/free_note.dart';

void main() {
  group('FreeNote Model Tests', () {
    test('FreeNote serialization toMap and fromMap', () {
      final now = DateTime.now();
      final note = FreeNote(
        id: 'note_123',
        title: 'Catatan Rumus PK',
        content: 'x^2 + y^2 = r^2 persamaan lingkaran berpusat di (0,0)',
        createdAt: now,
        updatedAt: now,
        colorHex: '#F6E08E',
        isPinned: true,
        isFavorite: true,
        imagePaths: const ['/storage/img1.jpg', '/storage/img2.png'],
      );

      final map = note.toMap();
      final reconstructed = FreeNote.fromMap(map);

      expect(reconstructed.id, 'note_123');
      expect(reconstructed.title, 'Catatan Rumus PK');
      expect(reconstructed.content, 'x^2 + y^2 = r^2 persamaan lingkaran berpusat di (0,0)');
      expect(reconstructed.colorHex, '#F6E08E');
      expect(reconstructed.isPinned, isTrue);
      expect(reconstructed.isFavorite, isTrue);
      expect(reconstructed.imagePaths, ['/storage/img1.jpg', '/storage/img2.png']);
    });

    test('FreeNote copyWith preserves or updates attributes', () {
      final now = DateTime.now();
      final note = FreeNote(
        id: 'note_abc',
        title: 'Judul Asli',
        content: 'Isi Asli',
        createdAt: now,
        updatedAt: now,
      );

      final updated = note.copyWith(
        title: 'Judul Baru',
        isPinned: true,
        colorHex: '#DCE6DF',
      );

      expect(updated.id, 'note_abc');
      expect(updated.title, 'Judul Baru');
      expect(updated.content, 'Isi Asli');
      expect(updated.isPinned, isTrue);
      expect(updated.colorHex, '#DCE6DF');
      expect(updated.isFavorite, isFalse);
    });

    test('FreeNote presetColors contains signature Nostra pastel tones', () {
      expect(FreeNote.presetColors.length, greaterThanOrEqualTo(5));
      expect(FreeNote.presetColors, contains('#FFFDF8'));
      expect(FreeNote.presetColors, contains('#F6E08E'));
      expect(FreeNote.presetColors, contains('#DCE6DF'));
    });
  });
}

