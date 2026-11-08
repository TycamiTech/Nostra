import '../services/app_settings_service.dart';

/// Centralized localization strings for Nostra.
/// Supports Indonesian (default) and English, while preserving integrated
/// English terms (such as "Library", "Project By TycamiTech", "Nostra", "Vault", "Markdown", "Pro")
/// as specified by design.
class AppStrings {
  AppStrings._();

  static AppLanguage get _current => AppSettingsService.instance.currentLanguage;
  static bool get isIndonesian => _current == AppLanguage.id;

  // ===========================================================================
  // 1. Brand & General
  // ===========================================================================
  static const String appName = 'Nostra';
  static const String projectCredit = 'Project By TycamiTech'; // Kept in English

  // ===========================================================================
  // 2. Navigation & Main Tabs
  // ===========================================================================
  static const String tabLibrary = 'Library'; // Kept in English
  static String get tabFreeNotes => isIndonesian ? 'Catatan' : 'Notes';
  static String get tabFreeNotesFull => isIndonesian ? 'Catatan Bebas' : 'Free Notes';
  static String get tabFavorites => isIndonesian ? 'Favorit' : 'Favorites';

  // ===========================================================================
  // 3. Home Screen (Library Tab & Favorites Tab)
  // ===========================================================================
  static String get readyToStudy =>
      isIndonesian ? 'Siap belajar UTBK hari ini?' : 'Ready to study for UTBK today?';
  static String get readyToStudySubtitle => isIndonesian
      ? 'Pilih catatan subtes untuk membaca dengan tata letak editorial.'
      : 'Select a subject notebook to read with editorial layout.';

  static String get all => isIndonesian ? 'Semua' : 'All';
  static String get recentlyRead => isIndonesian ? 'Baru Dibaca' : 'Recently Read';
  static String get lastRead => isIndonesian ? 'Terakhir: Baru dibaca' : 'Last: Recently read';
  static String get pagePrefix => isIndonesian ? 'Hlm.' : 'Pg.';

  static String get noSubjectsYet => isIndonesian ? 'Belum ada mata pelajaran' : 'No subjects yet';
  static String get noSubjectsDesc => isIndonesian
      ? 'Tekan tombol + di pojok kanan atas untuk menambahkan mata pelajaran baru.'
      : 'Tap the + button in the top right to add a new subject.';
  static String get addSubject => isIndonesian ? 'Tambah Mata Pelajaran' : 'Add Subject';
  static String get menuNostra => isIndonesian ? 'Pengaturan' : 'Settings';

  // Favorites Tab
  static String get favoritesCollection => isIndonesian ? 'Koleksi Favorit' : 'Favorite Collection';
  static String get favoritesCollectionSubtitle => isIndonesian
      ? 'Akses cepat modul UTBK dan catatan yang telah kamu tandai.'
      : 'Quick access to UTBK modules and notes you have bookmarked.';
  static String get filterUtbkModules => isIndonesian ? 'Modul UTBK' : 'UTBK Modules';
  static String get filterNotes => isIndonesian ? 'Catatan' : 'Notes';
  static String get favoriteNotesTitle => isIndonesian ? 'Catatan Favorit' : 'Favorite Notes';
  static String get favoriteNotesSubtitle => isIndonesian
      ? 'Daftar catatan yang kamu tandai sebagai favorit.'
      : 'List of notes you have marked as favorites.';
  static String get noFavoriteNotesYet => isIndonesian ? 'Belum ada catatan favorit' : 'No favorite notes yet';
  static String get noFavoriteNotesDesc => isIndonesian
      ? 'Tandai catatan dengan ikon hati untuk melihatnya di sini.'
      : 'Mark notes with the heart icon to see them here.';

  // ===========================================================================
  // 4. Free Notes Tab
  // ===========================================================================
  static String get dailyNotes => isIndonesian ? 'Catatan Harian' : 'Daily Notes';
  static String get dailyNotesSubtitleNormal => isIndonesian
      ? 'Tulis ide, rumus cepat, atau coretan belajar harian.'
      : 'Write ideas, quick formulas, or daily study scribbles.';
  static String get dailyNotesSubtitleExpert => isIndonesian
      ? 'Catatan terstruktur dengan dukungan Markdown & Obsidian Vault.'
      : 'Structured notes with Markdown & Obsidian Vault support.';
  static String get newNote => isIndonesian ? 'Catatan Baru' : 'New Note';
  static String get searchNotes => isIndonesian ? 'Cari catatan...' : 'Search notes...';
  static String get untitledNote => isIndonesian ? 'Catatan Tanpa Judul' : 'Untitled Note';
  static String get imageAttached => isIndonesian ? '(Gambar terlampir)' : '(Image attached)';
  static String get noAdditionalText => isIndonesian ? '(Belum ada teks tambahan)' : '(No additional text)';
  static String get noNotesYet => isIndonesian ? 'Belum Ada Catatan' : 'No Notes Yet';
  static String get noNotesDesc => isIndonesian
      ? 'Tekan tombol Catatan Baru di bawah untuk mulai menulis.'
      : 'Tap the New Note button below to start writing.';
  static String get noNotesFound => isIndonesian ? 'Catatan tidak ditemukan' : 'No notes found';
  static String get tryAnotherKeyword => isIndonesian
      ? 'Coba gunakan kata kunci pencarian yang lain.'
      : 'Try using different search keywords.';
  static String get dailyNotesEmptyDesc => isIndonesian
      ? 'Ketik catatan harian, rumus kilat les, atau to-do belajarmu di sini.'
      : 'Type your daily notes, quick study formulas, or to-do lists here.';
  static String get createFirstNote => isIndonesian ? 'Buat Catatan Pertama' : 'Create First Note';

  // Note Action Sheet
  static String get pinToTop => isIndonesian ? 'Sematkan ke Atas' : 'Pin to Top';
  static String get unpin => isIndonesian ? 'Lepas Sematan' : 'Unpin';
  static String get addToFavorites => isIndonesian ? 'Tambah ke Favorit' : 'Add to Favorites';
  static String get removeFromFavorites => isIndonesian ? 'Hapus dari Favorit' : 'Remove from Favorites';
  static String get archiveNote => isIndonesian ? 'Arsipkan Catatan' : 'Archive Note';
  static String get unarchiveNote => isIndonesian ? 'Batalkan Arsip' : 'Unarchive Note';
  static String get moveToTrash => isIndonesian ? 'Hapus ke Sampah' : 'Move to Trash';

  // Snackbars
  static String get noteArchived => isIndonesian ? 'Catatan berhasil diarsipkan' : 'Note successfully archived';
  static String get noteUnarchived => isIndonesian ? 'Catatan dikembalikan dari arsip' : 'Note restored from archive';
  static String get noteMovedToTrash => isIndonesian ? 'Catatan dipindahkan ke Sampah' : 'Note moved to Trash';

  // ===========================================================================
  // 5. Settings Bottom Sheet
  // ===========================================================================
  static String get settings => isIndonesian ? 'Pengaturan' : 'Settings';
  static String get appMode => isIndonesian ? 'Mode Aplikasi' : 'App Mode';
  static String get normalModeBadge => 'Normal';
  static String get expertModeBadge => isIndonesian ? 'Ahli (Pro)' : 'Expert (Pro)';
  static String get normalModeSubtitle =>
      isIndonesian ? 'Mode Catatan Bersih & Santai' : 'Clean & Casual Note Mode';
  static String get expertModeSubtitle =>
      isIndonesian ? 'Toolbar Format Lengkap & Markdown' : 'Full Formatting Toolbar & Markdown';

  // Language Setting
  static String get language => isIndonesian ? 'Bahasa' : 'Language';
  static String get languageBadge => isIndonesian ? 'Indonesia' : 'English';
  static String get languageSubtitle =>
      isIndonesian ? 'Pilih bahasa aplikasi (Indonesia / English)' : 'Choose app language (Indonesia / English)';
  static String get chooseLanguageTitle => isIndonesian ? 'Pilih Bahasa' : 'Choose Language';
  static String get chooseLanguageDesc => isIndonesian
      ? 'Bahasa antarmuka pengguna aplikasi Nostra.'
      : 'Display language for the Nostra application.';
  static String get indonesianLang => 'Bahasa Indonesia';
  static String get englishLang => 'English';

  // Archive & Trash Tiles
  static String get archive => isIndonesian ? 'Arsip' : 'Archive';
  static String get archiveSubtitle => isIndonesian
      ? 'Catatan & mata pelajaran yang diarsipkan'
      : 'Archived notes & subject notebooks';
  static String get trash => isIndonesian ? 'Sampah' : 'Trash';
  static String get trashSubtitle => isIndonesian
      ? 'Item terhapus disimpan 7 hari sebelum dibersihkan'
      : 'Deleted items kept for 7 days before auto-purge';
  static String get promptGuide =>
      isIndonesian ? 'Panduan & Template Prompt AI' : 'AI Prompt Guide & Templates';
  static String get promptGuideSubtitle => isIndonesian
      ? 'Format prompt otomatis untuk Gemini & ChatGPT'
      : 'Automatic prompt formatting for Gemini & ChatGPT';
  static String get localVault =>
      isIndonesian ? 'Cadangan & Berkas Lokal (Vault)' : 'Backup & Local Files (Vault)';
  static String get localVaultSubtitle => isIndonesian
      ? 'Sinkronisasi file nyata (.md) seperti Obsidian'
      : 'Sync real Markdown (.md) files like Obsidian';

  // ===========================================================================
  // 6. App Mode Screen
  // ===========================================================================
  static String get appModeTitle => isIndonesian ? 'Mode Aplikasi' : 'App Mode';
  static String get customizeNoteStyle => isIndonesian ? 'Sesuaikan Gaya Catatan' : 'Customize Note Style';
  static String get customizeNoteStyleDesc => isIndonesian
      ? 'Pilih mode yang paling nyaman untuk kegiatan belajarmu. Kamu bebas beralih mode ini kapan saja tanpa kehilangan data catatan.'
      : 'Choose the mode that best fits your study routine. You can switch between modes anytime without losing any notes.';

  // Normal Card
  static String get normalCardBadge => isIndonesian ? 'Default / Rekomendasi Pemula' : 'Default / Recommended';
  static String get normalCardTitle => isIndonesian ? 'Mode Normal (Standar)' : 'Normal Mode (Standard)';
  static String get normalCardTagline => isIndonesian
      ? 'Visual Langsung (WYSIWYG) Tanpa Kode'
      : 'Direct Visual (WYSIWYG) Without Code';
  static String get normalCardDesc => isIndonesian
      ? 'Fitur esensial (H1, H2, Bold, Italic, Foto) langsung tampil visual di layar tanpa menampilkan kode Markdown (seperti ** atau ##). Sangat ramah bagi orang awam.'
      : 'Essential styling (H1, H2, Bold, Italic, Photo) displays directly on screen without Markdown codes (like ** or ##). Simple and friendly.';
  static List<String> get normalCardFeatures => isIndonesian
      ? [
          'Toolbar simpel: H1, H2, Tebal (B), Miring (I), dan Foto',
          'Teks tebal & miring langsung tampak tanpa tanda kode markdown',
          'Judul otomatis membesar tanpa menampilkan simbol #',
          'File fisik di memori tetap tersimpan rapi sebagai file .md',
        ]
      : [
          'Simple toolbar: H1, H2, Bold (B), Italic (I), and Photos',
          'Bold and italic text formatted visually without markdown syntax',
          'Headings enlarge automatically without # symbols',
          'Physical files safely mirrored as readable .md files',
        ];

  // Expert Card
  static String get expertCardBadge => 'Obsidian & Markdown Pro';
  static String get expertCardTitle => isIndonesian ? 'Mode Ahli (Markdown & Pro)' : 'Expert Mode (Markdown & Pro)';
  static String get expertCardTagline => isIndonesian
      ? 'Sintaks Bebas Tanpa Batas & Dual Preview'
      : 'Unlimited Markdown Syntax & Dual Preview';
  static String get expertCardDesc => isIndonesian
      ? 'Untuk kamu yang terbiasa dengan Markdown murni atau Obsidian. Bebas menulis sintaks apa saja (Tabel, Checklist, Quote, Code) dengan toolbar lengkap dan pratinjau baca.'
      : 'For power users accustomed to pure Markdown or Obsidian. Freely write any syntax (Tables, Checklists, Quotes, Code) with a full formatting toolbar and live preview.';
  static List<String> get expertCardFeatures => isIndonesian
      ? [
          'Dukungan bebas semua kode Markdown yang kamu ketik',
          'Toolbar developer lengkap (H1-H2, B, I, U, S, Stabilo, Checklist, Foto)',
          'Mode Pratinjau Baca ganda (Dual Edit/Rendered View)',
          'Kompatibilitas penuh Obsidian Vault & ekspor .md',
        ]
      : [
          'Full support for all Markdown syntax you type',
          'Comprehensive power toolbar (H1-H2, B, I, U, S, Highlight, Checklist, Photo)',
          'Dual Edit / Rendered reading preview toggle',
          '100% Obsidian Vault compatibility & .md export',
        ];

  static String get modeSafetyNotice => isIndonesian
      ? 'Semua catatan yang sudah kamu buat tetap tersimpan utuh dan aman saat kamu berpindah antar mode kapan pun.'
      : 'All your notes remain completely intact and safe whenever you switch between modes.';

  static String normalModeActivatedSnackBar = isIndonesian
      ? 'Mode Normal (Standar) aktif. Catatan tampil bersih dan sederhana.'
      : 'Normal Mode active. Notes display clean and simple.';
  static String expertModeActivatedSnackBar = isIndonesian
      ? 'Mode Ahli (Markdown) aktif. Toolbar format lengkap & pratinjau siap digunakan.'
      : 'Expert Mode active. Full formatting toolbar & preview are ready.';

  // ===========================================================================
  // 7. Prompt Guide Sheet
  // ===========================================================================
  static String get promptGuideTitle => isIndonesian ? 'Panduan & Template Prompt' : 'AI Prompt Guide & Templates';
  static String get promptGuideSubtitleShort => isIndonesian
      ? 'Pilih kategori subtes untuk menghasilkan catatan yang akurat'
      : 'Select a subject category to generate accurate study notes';

  static String get catMathTitle => isIndonesian ? 'Eksakta & Rumus' : 'Math & Formulas';
  static String get catMathShort => isIndonesian ? 'Eksakta' : 'Math';
  static String get catMathBadge => isIndonesian
      ? 'Khusus: Pengetahuan Kuantitatif (PK) & Penalaran Matematika (PM)'
      : 'Quantitative Knowledge (PK) & Math Reasoning (PM)';

  static String get catLogicTitle => isIndonesian ? 'Logika & Analitik' : 'Logic & Reasoning';
  static String get catLogicShort => isIndonesian ? 'Logika' : 'Logic';
  static String get catLogicBadge => isIndonesian ? 'Khusus: Penalaran Umum (PU)' : 'General Reasoning (PU)';

  static String get catLanguageTitle => isIndonesian ? 'Bahasa & Wacana' : 'Language & Reading';
  static String get catLanguageShort => isIndonesian ? 'Bahasa' : 'Language';
  static String get catLanguageBadge => isIndonesian
      ? 'Khusus: PBM, PPU, Literasi B. Indonesia & B. Inggris'
      : 'Reading Comprehension & Language Literacy';

  static String get quickGuide3Steps => isIndonesian ? 'Langkah Cepat (3 Langkah):' : 'Quick Guide (3 Steps):';
  static String get step1 => isIndonesian
      ? 'Pilih kategori & salin prompt di bawah ini.'
      : 'Choose a category & copy the prompt below.';
  static String get step1Desc => isIndonesian
      ? 'Gunakan tombol "Salin Template Prompt" untuk menyalin teks format otomatis.'
      : 'Use the "Copy Prompt Template" button below to copy the prompt.';
  static String get step2 => isIndonesian
      ? 'Buka AI (Gemini / ChatGPT) & kirim catatan.'
      : 'Open AI (Gemini / ChatGPT) & send notes.';
  static String get step2Desc => isIndonesian
      ? 'Lampirkan PDF materi atau foto buku catatan UTBK Anda, lalu tempelkan prompt.'
      : 'Attach your PDF/notes or study photos, then paste this prompt.';
  static String get step3 => isIndonesian
      ? 'Tempel hasil ke aplikasi Nostra.'
      : 'Paste results into the Nostra app.';
  static String get step3Desc => isIndonesian
      ? 'Salin respons Markdown dari AI, lalu pilih "Tempel Teks Markdown" pada mata pelajaran yang sesuai.'
      : 'Copy the AI Markdown response, then choose "Paste Markdown" on the matching subject.';

  static String get promptTemplateLabel => isIndonesian ? 'Template Prompt AI:' : 'AI Prompt Template:';
  static String copyPromptBtn(String cat) =>
      isIndonesian ? 'Salin Template Prompt ($cat)' : 'Copy Prompt Template ($cat)';
  static String get promptCopied => isIndonesian
      ? 'Template prompt berhasil disalin! Buka Gemini atau ChatGPT sekarang.'
      : 'Prompt template copied! Open Gemini or ChatGPT now.';

  // ===========================================================================
  // 8. Vault & Local Files Sheet
  // ===========================================================================
  static String get vaultTitle => isIndonesian ? 'Cadangan & Berkas Lokal (Vault)' : 'Backup & Local Files (Vault)';
  static String get vaultSubtitleShort => isIndonesian
      ? 'Tersimpan sebagai berkas nyata (.md) layaknya Obsidian / Notepad'
      : 'Stored as real Markdown (.md) files like Obsidian / Notepad';
  static String get autoMirroringActive => isIndonesian ? 'AUTO-MIRRORING AKTIF' : 'AUTO-MIRRORING ACTIVE';
  static String get autoMirroringDesc => isIndonesian
      ? 'Setiap kali Anda membuat atau mengedit catatan, berkas fisiknya otomatis tersimpan di folder:'
      : 'Whenever you create or edit notes, physical files are automatically mirrored to:';
  static String get vaultSafetyTip => isIndonesian
      ? 'Jika aplikasi terhapus atau di-install ulang, berkas di folder ini tetap ada di HP Anda!'
      : 'If the app is uninstalled or reinstalled, files in this folder remain on your device!';

  static String get fileOperations => isIndonesian ? 'Operasi Berkas & Cadangan:' : 'File & Backup Operations:';
  static String get syncAllTitle => isIndonesian ? 'Sinkronkan & Perbarui Seluruh Berkas' : 'Sync & Update All Files';
  static String get syncAllSubtitle => isIndonesian
      ? 'Menulis ulang semua modul UTBK dan Catatan ke folder lokal.'
      : 'Rewrites all UTBK modules and Notes into the local folder.';
  static String get shareAllTitle => isIndonesian ? 'Bagikan Semua Berkas (.md)' : 'Share All Files (.md)';
  static String get shareAllSubtitle => isIndonesian
      ? 'Kirim seluruh berkas catatan ke Google Drive, WhatsApp, atau laptop.'
      : 'Send all note files to Google Drive, WhatsApp, or computer.';
  static String get restoreTitle => isIndonesian ? 'Pulihkan Catatan dari Berkas .md / .txt' : 'Restore Notes from .md / .txt';
  static String get restoreSubtitle => isIndonesian
      ? 'Pilih satu atau banyak file dari memori HP untuk dimasukkan kembali ke aplikasi.'
      : 'Pick one or multiple files from device storage to import back into the app.';
  static String get vaultCompatibilityFooter => isIndonesian
      ? 'Berkas menggunakan standar Markdown dan YAML frontmatter. 100% kompatibel dibuka langsung di Obsidian, Notepad, VS Code, dan iA Writer.'
      : 'Files use standard Markdown and YAML frontmatter. 100% compatible with Obsidian, Notepad, VS Code, and iA Writer.';

  static String backupSuccess(int count) => isIndonesian
      ? '$count berkas berhasil dicadangkan ke folder lokal!'
      : '$count files successfully backed up to local folder!';
  static String restoreSuccess(int count) => isIndonesian
      ? '$count catatan berhasil dipulihkan ke aplikasi!'
      : '$count notes successfully restored to the app!';
  static String get loadingFolderLocation => isIndonesian ? 'Memuat lokasi folder...' : 'Loading folder location...';

  // ===========================================================================
  // 9. Archive & Trash Screens
  // ===========================================================================
  static String get archiveHeaderTitle => isIndonesian ? 'Arsip' : 'Archive';
  static String get archiveHeaderSubtitle => isIndonesian
      ? 'Kelola catatan dan mata pelajaran yang diarsipkan'
      : 'Manage archived notes and subject notebooks';
  static String get noArchivedItems => isIndonesian ? 'Belum ada arsip' : 'No archived items';
  static String get noArchivedItemsDesc => isIndonesian
      ? 'Catatan atau mata pelajaran yang diarsipkan akan tampil di sini.'
      : 'Archived notes or subject notebooks will appear here.';

  static String get trashHeaderTitle => isIndonesian ? 'Sampah' : 'Trash';
  static String get trashHeaderSubtitle => isIndonesian
      ? 'Item yang terhapus akan dibersihkan otomatis setelah 7 hari'
      : 'Deleted items will be automatically cleared after 7 days';
  static String get emptyTrashPrompt => isIndonesian ? 'Kosongkan Sampah?' : 'Empty Trash?';
  static String get emptyTrashPromptDesc => isIndonesian
      ? 'Semua catatan dan mata pelajaran di dalam sampah akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.'
      : 'All notes and subject notebooks in Trash will be permanently deleted. This action cannot be undone.';
  static String get trashEmptied => isIndonesian ? 'Sampah berhasil dikosongkan.' : 'Trash successfully emptied.';
  static String get deletePermanentPrompt => isIndonesian ? 'Hapus Permanen?' : 'Delete Permanently?';
  static String deletePermanentDesc(String title) => isIndonesian
      ? '"$title" akan dihapus secara permanen dari perangkat dan tidak dapat dipulihkan.'
      : '"$title" will be permanently deleted from device storage and cannot be restored.';
  static String deletePermanentSuccess(String title) => isIndonesian
      ? '"$title" telah dihapus secara permanen.'
      : '"$title" has been permanently deleted.';
  static String restoreSubjectSuccess(String title) => isIndonesian
      ? '"$title" berhasil dipulihkan.'
      : '"$title" successfully restored.';
  static String get noteRestored => isIndonesian ? 'Catatan berhasil dipulihkan.' : 'Note successfully restored.';
  static String get trashEmptyTitle => isIndonesian ? 'Sampah Kosong' : 'Trash is Empty';
  static String get trashEmptyDesc => isIndonesian
      ? 'Item yang dihapus akan tersimpan di sini selama 7 hari sebelum dihapus permanen.'
      : 'Items you delete will be kept here for 7 days before permanent deletion.';

  // ===========================================================================
  // 10. Add Subject Modal
  // ===========================================================================
  static String get addNewSubjectTitle => isIndonesian ? 'Tambah Mata Pelajaran Baru' : 'Add New Subject';
  static String get addNewSubjectSubtitle => isIndonesian
      ? 'Buat subjek kustom untuk catatan UTBK atau materi belajar lainnya.'
      : 'Create a custom subject for study notes or exam preparation.';
  static String get subjectNameLabel => isIndonesian ? 'Nama Mata Pelajaran' : 'Subject Name';
  static String get subjectNameHint => isIndonesian
      ? 'cth: Bahasa Inggris, Fisika, Kimia...'
      : 'e.g.: English, Physics, Chemistry...';
  static String get shortCodeLabel => isIndonesian ? 'Kode Singkat' : 'Short Code';
  static String get shortCodeHint => isIndonesian ? 'cth: BIG-05, FIS-06...' : 'e.g.: ENG-05, PHY-06...';
  static String get cardColorLabel => isIndonesian ? 'Warna Kartu' : 'Card Color';
  static String get cardIllustrationLabel => isIndonesian ? 'Ilustrasi Kartu' : 'Card Illustration';
  static String get addSubjectBtn => isIndonesian ? 'Tambah Mata Pelajaran' : 'Add Subject';
  static String get subjectNameEmptyError => isIndonesian
      ? 'Nama mata pelajaran tidak boleh kosong.'
      : 'Subject name cannot be empty.';
  static String subjectAddedSuccess(String title) => isIndonesian
      ? '"$title" berhasil ditambahkan!'
      : '"$title" successfully added!';

  // ===========================================================================
  // 11. Common Actions
  // ===========================================================================
  static String get getStarted => isIndonesian ? 'Mulai Sekarang' : 'Get Started';
  static String get cancel => isIndonesian ? 'Batal' : 'Cancel';
  static String get save => isIndonesian ? 'Simpan' : 'Save';
  static String get delete => isIndonesian ? 'Hapus' : 'Delete';
  static String get restore => isIndonesian ? 'Pulihkan' : 'Restore';
  static String get empty => isIndonesian ? 'Kosongkan' : 'Empty';
  static String get deletePermanently => isIndonesian ? 'Hapus Permanen' : 'Delete Permanently';

  // Dynamic formatting
  static String wordsCount(int count) => isIndonesian ? '$count kata' : '$count words';
  static String daysRemaining(int days) =>
      isIndonesian ? 'Tersisa $days hari' : '$days days left';
}
