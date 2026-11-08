import '../../../core/widgets/doodle_illustrations.dart';
import '../models/subject_notebook.dart';

/// Seed data and initial editorial Markdown notes for Nostra UTBK subjects
class DefaultSubjectsSeed {
  DefaultSubjectsSeed._();

  // ==========================================
  // 1. TES POTENSI SKOLASTIK (TPS)
  // ==========================================
  static const String defaultTpsMarkdown = '''
[MODUL 01 | TPS-01]
# Silogisme Kategorik & Modus Tollens

==Hukum Ekuivalensi Implikasi== menyatakan bahwa suatu implikasi p → q selalu memiliki nilai kebenaran yang persis sama dengan bentuk kontraposisinya (~q → ~p) serta bentuk disjungsi (~p ∨ q). Kesalahan paling umum peserta UTBK adalah menyamakannya dengan bentuk konvers (q → p) yang bukan merupakan ekuivalensi sah.

:::metode FORMULA EKUIVALENSI LOGIKA UTBK
1. Implikasi:      p → q  ≡  ~p ∨ q  ≡  ~q → ~p
2. Negasi:         ~(p → q) ≡  p ∧ ~q
3. De Morgan:      ~(p ∧ q) ≡  ~p ∨ ~q
4. Silogisme:      (p → q) ∧ (q → r)  ⇒  (p → r)
:::

:::soal HOT 2026
Premis 1: Jika Budi lolos UTBK, maka ia rajin mengerjakan latihan soal.
Premis 2: Budi tidak rajin mengerjakan latihan soal.
Kesimpulan yang sah dan sahih adalah...

Solusi:
Berdasarkan aturan Modus Tollens: (p → q) ∧ ~q ⇒ ~p.
Kesimpulan sah: "Budi tidak lolos UTBK".
:::

---

[MODUL 02 | TPS-01]
# Hukum Ekuivalensi & De Morgan

Pada proposisi majemuk, ==Hukum De Morgan== digunakan untuk mencari ingkaran dari pernyataan konjungsi dan disjungsi. Ingat bahwa negasi dari "dan" berubah menjadi "atau", sedangkan negasi dari pernyataan berkuantor universal ("semua") berubah menjadi eksistensial ("ada/beberapa").

:::metode RUMUS INGKARAN KUANTOR & DE MORGAN
1. Negasi Konjungsi: ~(p ∧ q) ≡ ~p ∨ ~q
2. Negasi Disjungsi: ~(p ∨ q) ≡ ~p ∧ ~q
3. Kuantor Umum:    ~[∀x, P(x)] ≡ ∃x, ~P(x)
4. Trik Cepat: "Semua A adalah B" ingkarannya "Ada A yang bukan B".
:::

:::soal HOT 2026
Tentukan ingkaran dari kalimat:
"Semua siswa memakai seragam putih abu-abu dan membawa kartu ujian."

Solusi:
Menggunakan De Morgan kuantor:
"Ada siswa yang tidak memakai seragam putih abu-abu atau tidak membawa kartu ujian."
:::

---

[MODUL 03 | TPS-01]
# Penalaran Analitis & Pengurutan Posisi

Soal analitis sering memuat kendala posisi linear atau meja bundar. ==Metode Diagram Garis Posisi== adalah cara paling efektif untuk mencegah redundansi informasi. Selalu mulai dari petunjuk yang memberikan posisi pasti (anchor point), bukan petunjuk relatif.

:::metode ALGORITMA PENYELESAIAN ANALITIS
1. Buat slot nomor posisi 1 sampai n.
2. Tempatkan elemen dengan posisi mutlak terlebih dahulu.
3. Hubungkan petunjuk bersyarat ke elemen yang telah terplot.
4. Uji kemungkinan tersisa (branching diagram).
:::

:::soal HOT 2026
Enam pelari A, B, C, D, E, F finis berurutan.
A finis tepat sebelum B. C finis setelah D namun sebelum A.
Jika F adalah pelari terakhir, siapakah yang berada di posisi ke-2?

Solusi:
Urutan yang memenuhi: D - C - A - B - E - F.
Maka pelari pada posisi ke-2 adalah C.
:::

---

[MODUL 04 | TPS-01]
# Pemahaman Bacaan & Falasi Logika

Dalam teks argumentatif, bedakan antara fakta, opini, dan ==Falasi Strawman== (menyerang argumen lawan yang dilebih-lebihkan). UTBK kerap menguji validitas simpulan berdasarkan teks tanpa memasukkan asumsi dari luar konteks bacaan.

:::metode DETEKSI FALASI DAN BIAS
1. Ad Hominem: Menyerang karakter pembuat argumen.
2. Post Hoc: Menganggap urutan waktu sebagai hubungan sebab-akibat.
3. Slippery Slope: Mengasumsikan rantai bencana tanpa bukti kausal.
:::

:::soal HOT 2026
Teks: "Penggunaan gawai meningkat 40% tahun ini. Pada periode yang sama, nilai literasi menurun. Maka gawai menyebabkan penurunan literasi."
Kelemahan argumen tersebut adalah...

Solusi:
Argumen melakukan falasi korelasi-kausasi (False Cause). Hubungan simultan belum tentu membuktikan hubungan sebab-akibat langsung.
:::
''';

  // ==========================================
  // 2. PENGETAHUAN KUANTITATIF (PK)
  // ==========================================
  static const String defaultPkMarkdown = '''
[MODUL 01 | PK-02]
# Persamaan Kuadrat & Analisis Akar Vieta

Untuk sembarang persamaan kuadrat ax² + bx + c = 0 dengan a ≠ 0 dan akar-akar x₁ serta x₂, ==Teorema Vieta & Diskriminan== memungkinkan kita mencari sifat dan operasi akar tanpa perlu mencari akar secara faktorisasi langsung. Nilai D > 0 menghasilkan dua akar real berlainan, D = 0 akar kembar, dan D < 0 akar imajiner.

:::metode HUBUNGAN KOEFISIEN & AKAR (VIETA)
• Jumlah Akar:     x₁ + x₂ = -b / a
• Hasil Kali Akar: x₁ · x₂ =  c / a
• Selisih Akar:    |x₁ - x₂| = √D / |a|
• Kuadrat Jumlah:  x₁² + x₂² = (x₁ + x₂)² - 2(x₁·x₂)
• Jumlah Kubik:    x₁³ + x₂³ = (x₁ + x₂)³ - 3(x₁·x₂)(x₁ + x₂)
:::

:::soal HOT 2026
Diketahui persamaan 2x² - 8x + 3 = 0 memiliki akar-akar α dan β.
Berapakah nilai dari (1/α) + (1/β)?

Solusi:
(1/α) + (1/β) = (α + β) / (α·β).
α + β = -(-8)/2 = 4, dan α·β = 3/2.
Maka hasilnya = 4 / (3/2) = 8/3.
:::

---

[MODUL 02 | PK-02]
# Fungsi Invers, Komposisi & Nilai Mutlak

==Fungsi Komposisi (f ∘ g)(x)== berarti menerapkan aturan g terlebih dahulu baru kemudian f. Untuk mencari invers dari fungsi rasional f(x) = (ax + b)/(cx + d), terdapat rumus kilat yang langsung menukar koefisien diagonal utama.

:::metode RUMUS CEPAT INVERS FUNGSI RASIONAL
• Jika f(x) = (ax + b) / (cx + d),
  maka f⁻¹(x) = (-dx + b) / (cx - a).
• Sifat: (f ∘ g)⁻¹(x) = (g⁻¹ ∘ f⁻¹)(x).
• Nilai Mutlak: |x - a| < b  ekuivalen dengan  -b < x - a < b.
:::

:::soal HOT 2026
Jika f(x) = (3x + 5)/(2x - 7), tentukan nilai f⁻¹(4).

Solusi:
Gunakan rumus kilat: f⁻¹(x) = (7x + 5)/(2x - 3).
f⁻¹(4) = (7(4) + 5)/(2(4) - 3) = 33 / 5 = 6.6.
:::

---

[MODUL 03 | PK-02]
# Geometri Lingkaran & Garis Singgung

Pada geometri lingkaran UTBK, ==Sudut Keliling & Sudut Pusat== adalah materi berulang. Besar sudut pusat selalu dua kali besar sudut keliling yang menghadap busur yang sama. Panjang garis singgung persekutuan luar dan dalam dapat dicari dengan teorema Pythagoras.

:::metode RUMUS GARIS SINGGUNG LINGKARAN
• Garis Singgung Luar:  d = √(p² - (R - r)²)
• Garis Singgung Dalam: d = √(p² - (R + r)²)
• Luas Tembereng: L_juring - L_segitiga
• Segi Empat Tali Busur: Sudut berhadapan berjumlah 180°.
:::

:::soal HOT 2026
Dua lingkaran berjari-jari 9 cm dan 4 cm memiliki jarak antar pusat 13 cm.
Tentukan panjang garis singgung persekutuan luar kedua lingkaran!

Solusi:
d = √(13² - (9 - 4)²) = √(169 - 25) = √144 = 12 cm.
:::

---

[MODUL 04 | PK-02]
# Teori Bilangan & Keterbagian Aljabar

==Aritmetika Modulo & Uji Keterbagian== sering muncul dalam bentuk sisa pembagian bilangan berpangkat besar. Ingat bahwa bilangan habis dibagi 3 jika jumlah digitnya habis dibagi 3, dan habis dibagi 4 jika dua digit terakhirnya kelipatan 4.

:::metode TEOREMA SISA & SIKLUS SATUAN
• Siklus digit satuan 2: 2, 4, 8, 6 (periode 4)
• Siklus digit satuan 3: 3, 9, 7, 1 (periode 4)
• Siklus digit satuan 7: 7, 9, 3, 1 (periode 4)
• Teorema Sisa: P(x) = H(x)·B(x) + S(x)
:::

:::soal HOT 2026
Berapakah digit satuan dari 3²⁰²⁶?

Solusi:
Eksponen 2026 mod 4 = 2 (karena 2024 kelipatan 4).
Maka digit satuannya sama dengan 3² = 9.
:::
''';

  // ==========================================
  // 3. LITERASI B. INDONESIA (LBI)
  // ==========================================
  static const String defaultLbiMarkdown = '''
[MODUL 01 | LBI-03]
# Analisis Gagasan Utama & Ide Pokok

==Ide Pokok & Kalimat Utama== adalah inti sari dari suatu paragraf yang menjiwai seluruh kalimat penjelas. Paragraf deduktif menempatkan ide pokok di awal, sedangkan induktif di akhir. Pada soal UTBK terkini, ide pokok kerap dikemas dalam bentuk parafrasa tersirat yang menguji penalaran pembaca secara utuh.

:::metode METODE 3-LANGKAH MENEMUKAN GAGASAN UTAMA
1. Eliminasi kalimat yang memuat contoh/data numerik spesifik.
2. Identifikasi kata kunci pengulang (repetisi/anafora).
3. Rumuskan intisari kalimat pengendali dalam 1 proposisi komprehensif.
:::

:::soal HOT 2026
"Peralihan ke energi terbarukan di Indonesia menghadapi kendala investasi infrastruktur awal yang masif. Kendati demikian, potensi jangka panjang dalam menurunkan emisi karbon dan biaya operasional menjadikannya keharusan strategis."
Ide pokok paragraf tersebut adalah...

Solusi:
Urgensi strategis transisi energi terbarukan di Indonesia di balik kendala investasinya.
:::

---

[MODUL 02 | LBI-03]
# Makna Konotatif, Denotatif & Majas

==Makna Konotatif== adalah makna kiasan atau asosiatif yang ditambahkan pada makna dasar (denotatif). Dalam teks sastra atau opini UTBK, pilihan diksi metaforis kerap mencerminkan sikap emosional penulis terhadap isu yang dibahas.

:::metode KLASIFIKASI GAYA BAHASA & DIKSI
• Metafora: Perbandingan langsung tanpa kata pembanding.
• Personifikasi: Menggambarkan benda mati memiliki sifat manusia.
• Eufemisme: Penghalusan ungkapan untuk kesantunan.
• Sarkasme: Sindiran langsung yang tajam.
:::

:::soal HOT 2026
Frasa "menjadi anak emas dewan direksi" memiliki makna...

Solusi:
Makna konotatif yang berarti orang yang paling disayangi atau diutamakan oleh para pimpinan.
:::

---

[MODUL 03 | LBI-03]
# Struktur Kalimat Efektif & Konjungsi

Kalimat efektif harus memenuhi syarat keparalelan bentuk, kehematan kata, kelogisan makna, serta ketepatan struktur SPOK. ==Kesalahan Konjungsi Ganda== seperti "Karena ... maka ..." sering mengecoh peserta.

:::metode CEKLIST KALIMAT EFEKTIF UTBK
1. Tidak ada subjek ganda tanpa konjungsi.
2. Hindari pleonasme: "sangat amat", "para hadirin sekalian".
3. Paralelisme predikat: "Pemerintah bertugas merancang dan menyosialisasikan..." (bukan 'sosialisasi').
4. Konjungsi intrakalimat vs antarkalimat harus tepat penempatannya.
:::

:::soal HOT 2026
Manakah kalimat yang efektif?
A. Meskipun lelah, namun mereka tetap belajar.
B. Walaupun lelah, mereka tetap belajar giat.

Solusi:
Kalimat B efektif. Kalimat A salah karena menggabungkan konjungsi bertingkat "meskipun" dan koordinatif "namun" dalam satu anak kalimat.
:::

---

[MODUL 04 | LBI-03]
# Pernyataan Implisit & Makna Teks

Pada soal pemahaman kritis, pertanyaan sering meminta ==Simpulan yang Paling Didukung Teks==. Kunci utamanya adalah tidak membuat lonjakan logika (*logical leap*) yang melebihi bukti yang dipaparkan dalam teks.

:::metode TRIK MENJAWAB PERNYATAAN IMPLISIT
1. Singkirkan opsi yang menggunakan kata mutlak: "selalu", "pasti", "semua" jika teks bernada probabilitas.
2. Pastikan opsi jawaban tidak bertentangan dengan premis teks.
3. Pilih opsi yang paling proporsional dengan ruang lingkup bacaan.
:::

:::soal HOT 2026
Teks: "Sebagian besar siswa yang rutin berolahraga memiliki konsentrasi belajar lebih stabil."
Pernyataan yang tepat:
A. Olahraga menjamin kelulusan ujian.
B. Siswa yang tidak berolahraga pasti gagal.
C. Aktivitas fisik berkorelasi positif dengan stabilitas fokus belajar.

Solusi:
Jawaban C tepat dan proporsional tanpa menambahkan asumsi yang berlebihan.
:::
''';

  // ==========================================
  // 4. PENALARAN MATEMATIKA (PM)
  // ==========================================
  static const String defaultPmMarkdown = '''
[MODUL 01 | PM-04]
# Laju Perubahan & Optimasi Turunan

Pada Penalaran Matematika, turunan pertama f'(x) merepresentasikan ==Laju Perubahan Sesaat==. Titik stasioner diperoleh ketika f'(x) = 0. Dalam soal cerita kontekstual (misalnya biaya minimum atau laba maksimum), rumuskan fungsi laba L(x) = R(x) - C(x) terlebih dahulu.

:::metode RUMUS OPTIMASI EKONOMI & FISIKA
• Kecepatan:     v(t) = s'(t)
• Percepatan:    a(t) = v'(t) = s''(t)
• Laba Maksimum: L'(x) = 0  dengan L''(x) < 0
• Biaya Rata-rata Minimum: AC(x) = C(x) / x
:::

:::soal HOT 2026
Sebuah pabrik memproduksi x unit barang dengan fungsi biaya C(x) = x² - 40x + 600 (ribu rupiah).
Berapa unit produksi agar total biaya mencapai minimum?

Solusi:
Biaya minimum saat C'(x) = 0.
2x - 40 = 0  ⇒  2x = 40  ⇒  x = 20 unit.
Total biaya minimum = 20² - 40(20) + 600 = 200 ribu rupiah.
:::

---

[MODUL 02 | PM-04]
# Geometri Ruang & Pemodelan Vektor

Menghitung jarak titik ke garis atau bidang pada kubus sering keluar di UTBK. Gunakan ==Aturan Proyeksi & Luas Segitiga== untuk mencari tinggi segitiga yang ditarik ke sisi miring tanpa perlu rumus dimensi tiga yang rumit.

:::metode TRIK JARAK RUANG KUBUS (RUSUK = a)
• Diagonal Bidang:  d_b = a√2
• Diagonal Ruang:   d_r = a√3
• Titik Sudut ke Diagonal Ruang Berhadapan:  (a√6) / 3
• Titik Sudut ke Bidang Diagonal: (a√3) / 3
:::

:::soal HOT 2026
Diketahui kubus ABCD.EFGH dengan panjang rusuk 6 cm.
Berapakah jarak dari titik C ke diagonal ruang AG?

Solusi:
Segitiga ACG siku-siku di C. AC = 6√2, CG = 6, AG = 6√3.
Jarak d = (AC × CG) / AG = (6√2 × 6) / (6√3) = 6√6 / 3 = 2√6 cm.
:::

---

[MODUL 03 | PM-04]
# Peluang & Analisis Data Statistik

==Kombinasi vs Permutasi== sering membingungkan peserta. Ingat: jika urutan diperhatikan (juara 1, 2, 3), gunakan Permutasi. Jika urutan tidak berpengaruh (memilih delegasi tim), gunakan Kombinasi. Rata-rata gabungan dapat dihitung dengan rata-rata terbobot.

:::metode FORMULA KOMBINATORIKA & STATISTIK
• Kombinasi: nCr = n! / (r! · (n - r)!)
• Permutasi: nPr = n! / (n - r)!
• Peluang Komplemen: P(A') = 1 - P(A)
• Rata-rata Gabungan: x̄_gab = (n₁x̄₁ + n₂x̄₂) / (n₁ + n₂)
:::

:::soal HOT 2026
Dari 5 siswa putra dan 4 siswa putri, akan dibentuk tim beranggotakan 3 orang yang terdiri dari setidaknya 2 siswa putri.
Ada berapa banyak susunan tim yang mungkin?

Solusi:
Kasus 1 (2 putri, 1 putra): 4C2 × 5C1 = 6 × 5 = 30.
Kasus 2 (3 putri): 4C3 = 4.
Total kemungkinan = 30 + 4 = 34 susunan tim.
:::

---

[MODUL 04 | PM-04]
# Barisan, Deret & Pertumbuhan Bunga

Model pertumbuhan penduduk dan bunga majemuk mengikuti ==Deret Geometri Exponensial==. Nilai di masa depan dapat dinyatakan sebagai M_n = M₀(1 + i)ⁿ, di mana i adalah tingkat bunga dan n adalah periode.

:::metode RUMUS BUNGA & DERET UTBK
• Bunga Tunggal:  M_n = M₀(1 + n·i)
• Bunga Majemuk:  M_n = M₀(1 + i)ⁿ
• Deret Aritmetika: S_n = n/2 (2a + (n - 1)b)
• Deret Geometri Tak Hingga: S_∞ = a / (1 - r) untuk |r| < 1
:::

:::soal HOT 2026
Sebuah modal Rp10.000.000 disimpan dengan bunga majemuk 10% per tahun.
Berapa modal akhir setelah 2 tahun?

Solusi:
M₂ = 10.000.000 × (1 + 0.1)² = 10.000.000 × 1.21 = Rp12.100.000.
:::
''';

  /// The 4 default UTBK subjects styled in Mirello Soft Warm pastels
  static List<SubjectNotebook> get defaultSubjects => [
        const SubjectNotebook(
          id: 'utbk_tps',
          title: 'Tes Potensi Skolastik',
          code: 'TPS-01',
          cardColorHex: '#E8E1EB', // Lavender
          doodleType: SubjectDoodleType.logic,
          markdownContent: defaultTpsMarkdown,
          lastOpenedText: 'Baru saja',
          currentPage: 1,
          totalPages: 4,
          isFavorite: true,
        ),
        const SubjectNotebook(
          id: 'utbk_pk',
          title: 'Pengetahuan Kuantitatif',
          code: 'PK-02',
          cardColorHex: '#DCE2EA', // Soft Blue
          doodleType: SubjectDoodleType.math,
          markdownContent: defaultPkMarkdown,
          lastOpenedText: 'Baru saja',
          currentPage: 1,
          totalPages: 4,
          isFavorite: false,
        ),
        const SubjectNotebook(
          id: 'utbk_lbi',
          title: 'Literasi B. Indonesia',
          code: 'LBI-03',
          cardColorHex: '#EFE5CD', // Warm Ochre
          doodleType: SubjectDoodleType.reading,
          markdownContent: defaultLbiMarkdown,
          lastOpenedText: 'Baru saja',
          currentPage: 1,
          totalPages: 4,
          isFavorite: true,
        ),
        const SubjectNotebook(
          id: 'utbk_pm',
          title: 'Penalaran Matematika',
          code: 'PM-04',
          cardColorHex: '#DCE6DF', // Sage Green
          doodleType: SubjectDoodleType.calculus,
          markdownContent: defaultPmMarkdown,
          lastOpenedText: 'Baru saja',
          currentPage: 1,
          totalPages: 4,
          isFavorite: false,
        ),
      ];
}

