import 'package:flutter_test/flutter_test.dart';
import 'package:mirello_utbk/features/library/models/subject_notebook.dart';

void main() {
  test('SubjectNotebook default subjects count and data integrity', () {
    final subjects = SubjectNotebook.defaultSubjects;
    expect(subjects.length, 4);

    final tps = subjects[0];
    expect(tps.title, 'Tes Potensi Skolastik');
    expect(tps.code, 'TPS-01');
    expect(tps.cardColorHex, '#E8E1EB');
    expect(tps.isFavorite, isTrue);

    final pk = subjects[1];
    expect(pk.title, 'Pengetahuan Kuantitatif');
    expect(pk.code, 'PK-02');
    expect(pk.cardColorHex, '#DCE2EA');

    final lbi = subjects[2];
    expect(lbi.title, 'Literasi B. Indonesia');
    expect(lbi.code, 'LBI-03');
    expect(lbi.cardColorHex, '#EFE5CD');

    final pm = subjects[3];
    expect(pm.title, 'Penalaran Matematika');
    expect(pm.code, 'PM-04');
    expect(pm.cardColorHex, '#DCE6DF');
  });

  test('SubjectNotebook serialization and copyWith', () {
    final fixedTime = DateTime(2026, 11, 7, 22, 50);
    final original = SubjectNotebook.defaultSubjects.first.copyWith(
      updatedAt: fixedTime,
    );
    final map = original.toMap();
    final restored = SubjectNotebook.fromMap(map);

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.code, original.code);
    expect(restored.cardColorHex, original.cardColorHex);
    expect(restored.updatedAt, fixedTime);

    final updated = restored.copyWith(
      pdfFilePath: '/storage/sample.pdf',
      currentPage: 25,
      totalPages: 48,
      isFavorite: false,
    );

    expect(updated.pdfFilePath, '/storage/sample.pdf');
    expect(updated.currentPage, 25);
    expect(updated.isFavorite, isFalse);
    expect(updated.progressFraction, closeTo(25 / 48, 0.001));
    expect(updated.updatedAt, fixedTime);
  });

  test('SubjectNotebook formattedLastOpened relative time logic', () {
    final now = DateTime.now();
    final todayNotebook = SubjectNotebook.defaultSubjects.first.copyWith(
      updatedAt: DateTime(now.year, now.month, now.day, 22, 50),
    );
    expect(todayNotebook.formattedLastOpened, 'Hari ini, 22:50');

    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayNotebook = SubjectNotebook.defaultSubjects.first.copyWith(
      updatedAt: DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 30),
    );
    expect(yesterdayNotebook.formattedLastOpened, 'Kemarin, 14:30');
  });
}

