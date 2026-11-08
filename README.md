# Nostra ✍️📖

> **Minimalist Editorial Notes & Modular Study Deck for Modern Learners.**  
> *Project By TycamiTech*

---

## 💡 About Nostra

**Nostra** adalah aplikasi catatan dan *study deck* modern yang menjembatani kemudahan menulis harian (ala Google Keep) dengan kekuatan kedaulatan data Markdown lokal (ala Obsidian), dibalut dalam estetika tata letak editorial yang hangat, tenang, dan elegan (*Warm Editorial Design*).

Didesain khusus untuk pelajar, akademisi, dan *power-user*, Nostra mengorganisir catatan ke dalam bab-bab modular horizontal (*page-by-page swipe*) tanpa *infinite vertical scroll* yang melelahkan.

---

## ✨ Key Features

### 1. 🔄 Dual Mode (Casual vs Power-User)
- **Mode Normal (Standar)**: Pengalaman menulis cepat & ramah pemula (WYSIWYG). Menampilkan teks tebal (*bold*), miring (*italic*), stabilo (*highlight*), dan checklist secara visual tanpa menampilkan simbol Markdown mentah (`**`, `##`, `- [ ]`).
- **Mode Ahli (Markdown & Pro)**: Toolbar Markdown lengkap, sintaks mentah bebas tanpa batas, checklist interaktif, serta pratinjau baca ganda (*dual preview*).

### 2. 📖 Editorial Study Deck & E-Reader
- **Horizontal Page Swiping**: Navigasi halaman ala buku/majalah fisik (*flat swipe 120fps*) yang meningkatkan retensi memori visual saat mempelajari rangkuman subtes atau materi ujian.
- **LaTeX Math 2D Rendering**: Mendukung rumus inline (`$...$`) dan persamaan blok 2 dimensi terstruktur (`$$...$$`, `\begin{bmatrix}`, `\begin{cases}`, `\begin{aligned}`).
- **Interactive Callouts & Modul**: Kotak khusus rumus inti (`:::metode`), pembahasan soal bertahap (`:::soal`), trik cepat (`:::tips`), dan peringatan jebakan ujian (`:::peringatan`).

### 3. 📌 Floating Sticky Notes
- Tempelkan catatan mini mengambang langsung di atas halaman materi yang sedang dibaca.
- Dapat digeser (*drag & drop*) bebas di layar, diedit, atau dihapus layaknya kertas Post-it fisik di buku teks.

### 4. 🤖 Built-in AI Prompt Guide & Templates
- Pilihan template prompt otomatis terkurasi untuk AI (ChatGPT, Gemini, Claude) yang mencakup:
  - **Eksakta & Rumus** (Pengetahuan Kuantitatif / Penalaran Matematika)
  - **Logika & Analitik** (Silogisme, Tabel Logika, Analitis)
  - **Bahasa & Wacana** (Literasi Bahasa Indonesia & Inggris)
- Cukup salin satu klik, kirim ke AI bersama materi/foto, lalu tempel (*paste*) ke Nostra untuk otomatis menjadi halaman modular yang rapi.

### 5. 🗄️ Obsidian-Compatible Local Vault & Zero Lock-in
- **File Fisik Nyata**: Seluruh catatan dan modul tersimpan sebagai file `.md` asli di memori internal (`/Documents/Nostra/`).
- **YAML Frontmatter**: Metadata terstruktur (judul, tanggal dibuat, status pin, warna, bookmark).
- **Auto-Mirroring & Share**: Otomatis tersinkronisasi ke penyimpanan lokal HP, kompatibel dibuka langsung di Obsidian, VS Code, iA Writer, atau Notepad.

### 6. 🗃️ Archive & Smart Trash
- **Arsip**: Pisahkan catatan harian atau modul subtes lama tanpa menghapusnya dari koleksi.
- **Sampah (Trash)**: Sistem pemulihan (*restore*) cerdas dengan *auto-purge* otomatis setelah 7 hari.

### 7. 🌐 Bilingual & Real-time Language Switch
- Mendukung **Bahasa Indonesia** dan **English** yang tersinkronisasi secara instan di seluruh layar.
- Tetap mempertahankan terminologi orisinal (*Library, Project By TycamiTech, Nostra, Vault, Markdown, Pro*).

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev/) (Channel Stable, Dart 3)
- **Local Database**: [Hive Flutter](https://pub.dev/packages/hive_flutter) (NoSQL local key-value storage)
- **Typography**: [Google Fonts](https://pub.dev/packages/google_fonts) (*Pacifico* untuk brand script, *Plus Jakarta Sans* untuk keterbacaan editorial)
- **Iconography**: [Lucide Icons](https://pub.dev/packages/lucide_icons_flutter)
- **Markdown & Math**: `flutter_math_fork` (KaTeX 2D rendering) & custom live parser
- **File Access**: `path_provider` & `file_picker`

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.2.0)
- Android SDK (API level 21+)

### Installation
1. Clone repository ini:
   ```bash
   git clone https://github.com/TycamiTech/Nostra.git
   cd Nostra
   ```
2. Pasang dependencies:
   ```bash
   flutter pub get
   ```
3. Jalankan automated test:
   ```bash
   flutter test
   ```
4. Jalankan aplikasi di perangkat Android atau emulator:
   ```bash
   flutter run
   ```

### Build Release APK
Untuk mengompilasi APK rilis:
```bash
flutter build apk --release
```
File APK siap instal akan berada di `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<p align="center">
  <b>Nostra</b> — Crafted with care by <b>TycamiTech</b>.
</p>
