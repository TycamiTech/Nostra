import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/mirello_theme.dart';

class PromptCategory {
  final String title;
  final String shortTitle;
  final String badge;
  final Color accentColor;
  final IconData icon;
  final String template;

  const PromptCategory({
    required this.title,
    required this.shortTitle,
    required this.badge,
    required this.accentColor,
    required this.icon,
    required this.template,
  });
}

class PromptGuideSheet extends StatefulWidget {
  const PromptGuideSheet({super.key});

  static const String promptEksakta = r'''Ubah seluruh materi/catatan UTBK (Pengetahuan Kuantitatif / Penalaran Matematika) yang saya berikan menjadi format "Nostra Editorial Markdown".

ATURAN UTAMA (WAJIB DIIKUTI):
1. Bungkus SELURUH hasil di dalam satu blok kode Markdown tunggal (```markdown ... ```) agar tanda format tidak hilang saat disalin. Jangan sertakan tag sitasi internal apapun.
2. PEMBAGIAN HALAMAN ADAPTIF: Gunakan `---` pada baris baru untuk memisahkan halaman. Jangan memadatkan materi secara paksa! Buat jumlah halaman mengikuti banyaknya sub-materi asli (1 halaman = 1 sub-topik utuh yang dibahas tuntas dan jelas).
3. STRUKTUR FLEKSIBEL & DINAMIS: Jangan gunakan urutan komponen yang kaku/sama di setiap halaman! Susun tata letak setiap halaman secara mengalir menyesuaikan isi sub-topik menggunakan komponen yang tersedia di bawah.
4. ATURAN RUMUS 2D (LaTeX):
   - Rumus di tengah kalimat (inline): bungkus dengan `$ ... $` (contoh: $\frac{a}{b}$, $\sqrt{x}$, $x^2$).
   - Rumus utama, pecahan bersusun, matriks, sistem persamaan, atau penurunan rumus: WAJIB gunakan blok `$$ ... $$` pada baris tersendiri agar dirender 2 dimensi secara proporsional:
     * Matriks: `\begin{bmatrix} a & b \\ c & d \end{bmatrix}`
     * Sistem Persamaan: `\begin{cases} ax + by = c \\ dx - ey = f \end{cases}`
     * Penurunan Aljabar Vertikal: susun langkah demi langkah menurun ke bawah dengan `\begin{aligned} ... \end{aligned}` agar alur hitungan mudah dipahami.

KATALOG KOMPONEN VISUAL (Pilih & kombinasikan sesuai kebutuhan tiap halaman):
- `[MODUL 01 | PK/PM]` -> Tulis di baris paling atas halaman sebagai label modul.
- `# Judul Topik Utama`, `## Sub-Bagian`, `### Poin Materi` -> Hierarki judul.
- `==frasa kunci==` -> Stabilo kuning (gunakan HANYA pada 2-5 kata kunci/syarat mutlak, maksimal 3 per paragraf).
- `- ` atau `1. ` -> Daftar sifat, syarat, atau langkah berurutan.
- Tabel Markdown (`| Kolom 1 | Kolom 2 |`) -> Untuk perbandingan sifat bangun datar/ruang atau nilai khusus.
- `:::metode JUDUL RUMUS / KONSEP` ... `:::` -> Kotak khusus rumus inti & langkah penyelesaian (bisa berisi blok `$$...$$`).
- `:::soal LATIHAN UTBK` ... `:::` -> Kotak contoh soal beserta pembahasan vertikal langkah demi langkah.
- `:::tips TRIK CEPAT` ... `:::` -> Kartu hijau untuk cara cepat / substitusi angka.
- `:::peringatan JEBAKAN SOAL` ... `:::` -> Kartu koral untuk kesalahan hitung/konsep yang sering terjadi.
- `:::ringkasan INTISARI` ... `:::` -> Kartu oker untuk rangkuman sifat.''';

  static const String promptLogika = r'''Ubah seluruh materi/catatan UTBK (Penalaran Umum: Logika Formal, Analitik, & Kuantitatif Dasar) yang saya berikan menjadi format "Nostra Editorial Markdown".

ATURAN UTAMA (WAJIB DIIKUTI):
1. Bungkus SELURUH hasil di dalam satu blok kode Markdown tunggal (```markdown ... ```). Jangan sertakan tag sitasi internal apapun.
2. PEMBAGIAN HALAMAN ADAPTIF: Gunakan `---` pada baris baru untuk memisahkan halaman. Buat jumlah halaman mengikuti banyaknya sub-topik asli secara menyeluruh (1 halaman = 1 sub-topik utuh).
3. STRUKTUR FLEKSIBEL: Susun komponen halaman secara dinamis mengikuti jenis materi (apakah sedang membahas silogisme, tabel kebenaran, urutan posisi analitik, atau barisan angka).
4. ATURAN SIMBOL LOGIKA & SKEMA:
   - Untuk simbol logika di tengah kalimat, gunakan `$ \sim P $`, `$ P \Rightarrow Q $`, `$ P \wedge Q $`, `$ P \vee Q $`, `$ P \equiv Q $`, `$ \forall $`, `$ \exists $`.
   - Untuk skema penarikan kesimpulan (Modus Ponens, Tollens, Silogisme) atau pola barisan bilangan, susun secara vertikal menggunakan blok `$$ \begin{aligned} ... \end{aligned} $$` atau daftar terstruktur agar premis 1, premis 2, dan kesimpulan ($\therefore$) terlihat jelas tingkatannya.
   - Gunakan Tabel Markdown (`| P | Q | P ⇒ Q |`) secara aktif untuk menyajikan Tabel Kebenaran atau pemetaan syarat Penalaran Analitik.

KATALOG KOMPONEN VISUAL (Pilih & kombinasikan secara bebas sesuai konteks halaman):
- `[MODUL 01 | PU]` -> Label di baris pertama setiap halaman.
- `# Judul Topik`, `## Sub-Topik`, `### Bagian` -> Hierarki judul.
- `==kata kunci==` -> Stabilo kuning untuk kata kunci aturan logika (maksimal 2-5 kata per stabilo).
- `> Kutipan premis atau pernyataan argumen` -> Blockquote untuk menyorot pernyataan teks yang dianalisis.
- Tabel Markdown (`| ... |`) -> Untuk Tabel Kebenaran, aturan ekuivalensi, atau matriks posisi duduk analitik.
- `:::metode ATURAN PENARIKAN KESIMPULAN` ... `:::` -> Kotak skema rumus logika / deret.
- `:::soal BEDAH SOAL PU` ... `:::` -> Kotak contoh soal penalaran beserta analisis eliminasi opsi.
- `:::tips STRATEGI ANALITIK` ... `:::` -> Kartu hijau untuk trik mengeliminasi jawaban.
- `:::peringatan KESALAHAN LOGIKA` ... `:::` -> Kartu koral untuk jebakan negasi atau kesimpulan tidak sah.''';

  static const String promptBahasa = r'''Ubah seluruh materi/catatan UTBK (PBM, PPU, Literasi Bahasa Indonesia / Bahasa Inggris) yang saya berikan menjadi format "Nostra Editorial Markdown".

ATURAN UTAMA (WAJIB DIIKUTI):
1. Bungkus SELURUH hasil di dalam satu blok kode Markdown tunggal (```markdown ... ```). Jangan sertakan tag sitasi internal apapun.
2. TANPA RUMUS MATEMATIKA: JANGAN gunakan kode LaTeX matematika (`$...$` atau `$$...$$`). Fokus sepenuhnya pada tata letak tipografi editorial, kutipan teks bacaan, tabel perbandingan bahasa, dan bedah struktur kalimat!
3. PEMBAGIAN HALAMAN ADAPTIF & STRUKTUR DINAMIS:
   - Pisahkan tiap sub-topik menjadi halaman tersendiri menggunakan `---` pada baris baru.
   - Jangan gunakan struktur yang kaku! Susun elemen halaman secara bebas dan bervariasi menyesuaikan materi (misal: halaman ejaan fokus menggunakan Tabel Baku vs Tidak Baku; halaman ide pokok fokus menggunakan Kutipan Paragraf `>` dan rincian poin).
4. GAYA TIPOGRAFI ANALISIS BAHASA:
   - Gunakan `==stabilo kuning==` untuk menyorot kalimat utama, kata hubung (konjungsi), atau inti aturan ejaan (maksimal 2-5 kata per stabilo).
   - Gunakan `~~teks dicoret~~` untuk mencontohkan kata tidak baku, kalimat tidak efektif, atau kesalahan grammar yang harus diperbaiki.
   - Gunakan inline code ` `S` `, ` `P` `, ` `O` `, ` `K` ` atau ` `V1 + ing` ` untuk menandai jabatan kalimat dan pola struktur bahasa.

KATALOG KOMPONEN VISUAL (Pilih & susun secara mengalir sesuai isi materi):
- `[MODUL 01 | BAHASA]` -> Label di baris pertama setiap halaman.
- `# Judul Bab`, `## Sub-Materi`, `### Poin Aturan` -> Hierarki judul.
- `> Cuplikan paragraf wacana / contoh kalimat utuh...` -> Blockquote untuk menampilkan teks bacaan yang sedang dibedah.
- Tabel Markdown (`| Bentuk Salah | Bentuk Baku |` atau `| Tense | Pola & Fungsi |`) -> Sangat direkomendasikan untuk merangkum kosakata, PUEBI/EYD, imbuhan, dan grammar.
- `:::catatan KAIDAH BAHASA` ... `:::` -> Kartu biru untuk aturan kebahasaan/grammar penting.
- `:::tips TRIK SKIMMING & SCANNING` ... `:::` -> Kartu hijau untuk cara cepat menemukan jawaban di teks panjang.
- `:::peringatan JEBAKAN OPSI` ... `:::` -> Kartu koral untuk pengecoh yang sering muncul di soal literasi.
- `:::soal CONTOH SOAL WACANA` ... `:::` -> Kotak contoh soal lengkap dengan bedah alasan mengapa opsi tersebut benar.
- `:::ringkasan INTISARI` ... `:::` -> Kartu oker untuk rangkuman bab.''';

  static const String promptTemplate = promptEksakta;

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PromptGuideSheet(),
    );
  }

  @override
  State<PromptGuideSheet> createState() => _PromptGuideSheetState();
}

class _PromptGuideSheetState extends State<PromptGuideSheet> {
  int _selectedIndex = 0;

  List<PromptCategory> get _categories => [
    PromptCategory(
      title: AppStrings.catMathTitle,
      shortTitle: AppStrings.catMathShort,
      badge: AppStrings.catMathBadge,
      accentColor: const Color(0xFFDCE2EA), // Soft Blue
      icon: LucideIcons.sigma,
      template: PromptGuideSheet.promptEksakta,
    ),
    PromptCategory(
      title: AppStrings.catLogicTitle,
      shortTitle: AppStrings.catLogicShort,
      badge: AppStrings.catLogicBadge,
      accentColor: const Color(0xFFE8E1EB), // Lavender
      icon: LucideIcons.gitBranch,
      template: PromptGuideSheet.promptLogika,
    ),
    PromptCategory(
      title: AppStrings.catLanguageTitle,
      shortTitle: AppStrings.catLanguageShort,
      badge: AppStrings.catLanguageBadge,
      accentColor: const Color(0xFFEFE5CD), // Warm Ochre
      icon: LucideIcons.bookOpen,
      template: PromptGuideSheet.promptBahasa,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppSettingsService.instance.languageNotifier,
      builder: (context, language, _) {
        final currentCategory = _categories[_selectedIndex];

        return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      decoration: const BoxDecoration(
        color: MirelloColors.paperSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: MirelloColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: MirelloColors.borderCard,
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  LucideIcons.bookOpen,
                  size: 20,
                  color: MirelloColors.primaryInk,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.promptGuideTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: MirelloColors.primaryInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.promptGuideSubtitleShort,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: MirelloColors.secondaryMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  LucideIcons.x,
                  size: 20,
                  color: MirelloColors.secondaryMuted,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: MirelloColors.borderSubtle, thickness: 1),
          const SizedBox(height: 14),

          // 3-Category Selector
          SizedBox(
            height: 62,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < _categories.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIndex = i;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedIndex == i
                              ? _categories[i].accentColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedIndex == i
                                ? MirelloColors.primaryInk
                                : MirelloColors.borderCard,
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _categories[i].icon,
                              size: 18,
                              color: _selectedIndex == i
                                  ? MirelloColors.primaryInk
                                  : MirelloColors.secondaryMuted,
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _categories[i].title,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: _selectedIndex == i
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: _selectedIndex == i
                                      ? MirelloColors.primaryInk
                                      : MirelloColors.secondaryMuted,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Subtest Badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: currentCategory.accentColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: MirelloColors.borderCard,
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  currentCategory.icon,
                  size: 14,
                  color: MirelloColors.primaryInk,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentCategory.badge,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: MirelloColors.primaryInk,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3-Step Tutorial
                  Text(
                    AppStrings.quickGuide3Steps,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: MirelloColors.primaryInk,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildStepItem(
                    number: '1',
                    title: AppStrings.step1,
                    subtitle: AppStrings.step1Desc,
                  ),
                  const SizedBox(height: 10),
                  _buildStepItem(
                    number: '2',
                    title: AppStrings.step2,
                    subtitle: AppStrings.step2Desc,
                  ),
                  const SizedBox(height: 10),
                  _buildStepItem(
                    number: '3',
                    title: AppStrings.step3,
                    subtitle: AppStrings.step3Desc,
                  ),

                  const SizedBox(height: 18),

                  // Prompt Code Box Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.promptTemplateLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: MirelloColors.primaryInk,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: currentCategory.accentColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: MirelloColors.borderCard,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          currentCategory.shortTitle.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: MirelloColors.primaryInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Code Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: MirelloColors.borderCard,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      currentCategory.template.trim(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11.5,
                        color: MirelloColors.primaryInk,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),

          // Prominent Copy Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: MirelloColors.primaryInk,
                foregroundColor: MirelloColors.paperSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: currentCategory.template));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: MirelloColors.primaryInk,
                    behavior: SnackBarBehavior.floating,
                    content: Row(
                      children: [
                        const Icon(
                          LucideIcons.checkCircle2,
                          color: Color(0xFFF6E08E),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppStrings.isIndonesian
                                ? 'Template Prompt ${currentCategory.title} berhasil disalin!'
                                : '${currentCategory.title} Prompt template copied successfully!',
                            style: GoogleFonts.plusJakartaSans(
                              color: MirelloColors.paperSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(LucideIcons.copy, size: 18),
              label: Text(
                AppStrings.copyPromptBtn(currentCategory.shortTitle),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildStepItem({
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: MirelloColors.primaryInk,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: GoogleFonts.jetBrainsMono(
              color: MirelloColors.paperSurface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: MirelloColors.primaryInk,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: MirelloColors.secondaryMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
