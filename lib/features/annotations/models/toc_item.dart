/// Represents a chapter entry in the Table of Contents or a user bookmark.
class TocItem {
  final String title;
  final int pageNumber;
  final String? subtitle;
  final bool isBookmark;

  const TocItem({
    required this.title,
    required this.pageNumber,
    this.subtitle,
    this.isBookmark = false,
  });

  /// Default high-yield UTBK syllabus table of contents
  static List<TocItem> getChaptersForSubject(String subjectId) {
    switch (subjectId) {
      case 'utbk_pk':
        return const [
          TocItem(title: 'BAB 01: Persamaan Kuadrat & Analisis Vieta', pageNumber: 1),
          TocItem(title: 'BAB 02: Aljabar Polinomial & Faktorisasi', pageNumber: 7),
          TocItem(title: 'BAB 03: Geometri Lingkaran & Garis Singgung', pageNumber: 14),
          TocItem(title: 'BAB 04: Teori Bilangan & Keterbagian', pageNumber: 22),
          TocItem(title: 'BAB 05: Matriks & Sistem Linear 3 Variabel', pageNumber: 30),
        ];
      case 'utbk_pm':
        return const [
          TocItem(title: 'BAB 01: Pemodelan Fungsi & Grafik Real-World', pageNumber: 1),
          TocItem(title: 'BAB 02: Laju Perubahan & Optimasi Turunan', pageNumber: 10),
          TocItem(title: 'BAB 03: Peluang & Analisis Data Statistik', pageNumber: 21),
          TocItem(title: 'BAB 04: Barisan, Deret & Pertumbuhan Eksponensial', pageNumber: 31),
        ];
      case 'utbk_lbi':
        return const [
          TocItem(title: 'BAB 01: Gagasan Utama & Ide Pokok Paragraf', pageNumber: 1),
          TocItem(title: 'BAB 02: Makna Konotatif, Denotatif & Majas', pageNumber: 9),
          TocItem(title: 'BAB 03: Kohesi, Koherensi & Kalimat Efektif', pageNumber: 18),
          TocItem(title: 'BAB 04: Evaluasi Teks & Rekonstruksi Argumen', pageNumber: 32),
          TocItem(title: 'BAB 05: Kaidah EYD V & Penyerapan Istilah', pageNumber: 44),
        ];
      case 'utbk_tps':
      default:
        return const [
          TocItem(title: 'BAB 01: Logika Proposisi & Penalaran Deduktif', pageNumber: 1),
          TocItem(title: 'BAB 02: Silogisme Kategorik & Modus Tollens', pageNumber: 8),
          TocItem(title: 'BAB 03: Penalaran Analitis & Pengurutan Posisi', pageNumber: 15),
          TocItem(title: 'BAB 04: Pemahaman Bacaan & Makna Tersirat', pageNumber: 26),
          TocItem(title: 'BAB 05: Simpulan Logis & Falasi Argumentasi', pageNumber: 38),
        ];
    }
  }
}

