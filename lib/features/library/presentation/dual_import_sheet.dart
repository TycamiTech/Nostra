import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/mirello_theme.dart';
import '../../reader/services/mirello_markdown_parser.dart';
import '../data/notebook_repository.dart';
import '../models/subject_notebook.dart';
import 'prompt_guide_sheet.dart';

/// Modal bottom sheet allowing users to either directly paste Markdown or pick a .md/.txt file
class DualImportSheet extends StatefulWidget {
  final SubjectNotebook notebook;
  final VoidCallback? onImported;

  const DualImportSheet({
    super.key,
    required this.notebook,
    this.onImported,
  });

  static void show({
    required BuildContext context,
    required SubjectNotebook notebook,
    VoidCallback? onImported,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DualImportSheet(
        notebook: notebook,
        onImported: onImported,
      ),
    );
  }

  @override
  State<DualImportSheet> createState() => _DualImportSheetState();
}

class _DualImportSheetState extends State<DualImportSheet> {
  bool _isPasteMode = false;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.notebook.markdownContent ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPasteMode) {
      return _buildPasteEditorView(context);
    }
    return _buildSelectionView(context);
  }

  /// Initial selection view: choose between Paste Text or Pick File
  Widget _buildSelectionView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: MirelloColors.paperSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag indicator
          Center(
            child: Container(
              width: 36,
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
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: widget.notebook.cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: MirelloColors.borderCard, width: 1),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.notebook.code,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: MirelloColors.secondaryMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.isIndonesian
                ? 'Impor Catatan: ${widget.notebook.title}'
                : 'Import Notes: ${widget.notebook.title}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: MirelloColors.primaryInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.isIndonesian
                ? 'Pilih metode untuk memasukkan materi catatan editorial ke mata pelajaran ini:'
                : 'Choose a method to import editorial notes into this subject:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: MirelloColors.secondaryMuted,
            ),
          ),
          const SizedBox(height: 18),

          // Option 1: Paste Text Directly
          _buildOptionTile(
            icon: LucideIcons.clipboardPaste,
            title: AppStrings.isIndonesian
                ? 'Tempel Teks Markdown (Paste)'
                : 'Paste Markdown Text',
            subtitle: AppStrings.isIndonesian
                ? 'Tempel teks catatan hasil salinan dari AI (Gemini / ChatGPT) langsung ke kotak teks.'
                : 'Paste AI-generated study notes directly into the text editor.',
            onTap: () {
              setState(() {
                _isPasteMode = true;
              });
            },
          ),
          const SizedBox(height: 12),

          // Option 2: Pick File (.md or .txt)
          _buildOptionTile(
            icon: LucideIcons.fileText,
            title: AppStrings.isIndonesian
                ? 'Impor Berkas .md / .txt'
                : 'Import .md / .txt File',
            subtitle: AppStrings.isIndonesian
                ? 'Pilih file Markdown atau teks dari penyimpanan HP Android Anda.'
                : 'Choose a Markdown or text file from device storage.',
            onTap: _pickAndImportFile,
          ),
          const SizedBox(height: 14),

          // Option 3 / Navigation: Panduan & Template Prompt AI
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.pop(context);
                PromptGuideSheet.show(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: MirelloColors.borderCard,
                    width: 0.9,
                  ),
                ),
                child: Row(
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
                        size: 18,
                        color: MirelloColors.primaryInk,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.promptGuide,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: MirelloColors.primaryInk,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.promptGuideSubtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: MirelloColors.secondaryMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: MirelloColors.secondaryMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: MirelloColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: MirelloColors.borderCard, width: 1.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: MirelloColors.borderCard, width: 0.8),
                ),
                child: Icon(icon, size: 20, color: MirelloColors.primaryInk),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: MirelloColors.primaryInk,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: MirelloColors.secondaryMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Full-height paste editor view with direct save flow
  Widget _buildPasteEditorView(BuildContext context) {
    final text = _textController.text.trim();
    final estimatedPages =
        text.isNotEmpty ? MirelloMarkdownParser.splitPages(text).length : 0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: MirelloColors.paperSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: MirelloColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.isIndonesian
                    ? 'Tempel Teks Catatan'
                    : 'Paste Note Text',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: MirelloColors.primaryInk,
                ),
              ),
              if (estimatedPages > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: MirelloColors.highlighterYellow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppStrings.isIndonesian
                        ? '$estimatedPages Hlm Terdeteksi'
                        : '$estimatedPages Pages Detected',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: MirelloColors.primaryInk,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.isIndonesian
                ? 'Pisahkan tiap halaman dengan tanda --- pada baris baru.'
                : 'Separate each page with --- on a new line.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: MirelloColors.secondaryMuted,
            ),
          ),
          const SizedBox(height: 12),

          // "Tempel dari Clipboard" Quick Button
          Row(
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: MirelloColors.primaryInk,
                  side: const BorderSide(
                    color: MirelloColors.borderCard,
                    width: 1.0,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data != null && data.text != null && data.text!.isNotEmpty) {
                    final stripped = MirelloMarkdownParser.stripCodeFences(data.text!);
                    _textController.text = stripped;
                    setState(() {});
                  }
                },
                icon: const Icon(LucideIcons.clipboardCopy, size: 14),
                label: Text(
                  AppStrings.isIndonesian
                      ? 'Tempel dari Clipboard'
                      : 'Paste from Clipboard',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: MirelloColors.primaryInk,
                  side: const BorderSide(
                    color: MirelloColors.borderCard,
                    width: 1.0,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                onPressed: () => PromptGuideSheet.show(context),
                icon: const Icon(LucideIcons.bookOpen, size: 14),
                label: Text(
                  AppStrings.isIndonesian ? 'Panduan' : 'Guide',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (_textController.text.isNotEmpty)
                TextButton(
                  onPressed: () {
                    _textController.clear();
                    setState(() {});
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFBA1A1A),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    AppStrings.delete,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Text Area
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12.5,
                color: MirelloColors.primaryInk,
                height: 1.45,
              ),
              decoration: InputDecoration(
                hintText:
                    '[MODUL 01 | CODE]\n# Judul Materi\n\nPenjelasan dengan ==highlight==...\n\n:::\nmetode RUMUS\n1. Langkah...\n:::\n\n---\n\n[MODUL 02 | CODE]...',
                hintStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: MirelloColors.secondaryMuted.withAlpha(140),
                ),
                filled: true,
                fillColor: const Color(0xFFEBE8DF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons: Batal & Simpan Catatan
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MirelloColors.primaryInk,
                    side: const BorderSide(
                      color: MirelloColors.borderSubtle,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasteMode = false;
                    });
                  },
                  child: Text(
                    AppStrings.cancel,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MirelloColors.primaryInk,
                    foregroundColor: MirelloColors.paperSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: _saveMarkdownNotes,
                  icon: const Icon(LucideIcons.check, size: 16),
                  label: Text(
                    AppStrings.save,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Saves the parsed markdown notes and refreshes caller state
  Future<void> _saveMarkdownNotes() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    try {
      var rawContent = _textController.text.trim();
      if (rawContent.isEmpty) {
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFBA1A1A),
            behavior: SnackBarBehavior.floating,
            content: Text(
              AppStrings.isIndonesian
                  ? 'Teks catatan tidak boleh kosong.'
                  : 'Note text cannot be empty.',
            ),
          ),
        );
        return;
      }

      // Automatically strip markdown code fences if copied as ```markdown ... ```
      rawContent = MirelloMarkdownParser.stripCodeFences(rawContent);
      final pages = MirelloMarkdownParser.splitPages(rawContent);

      await NotebookRepository.instance.updateMarkdown(
        widget.notebook.id,
        rawContent,
        totalPages: pages.length,
      );

      // Notify caller (ReaderScreen or HomeScreen) to refresh state immediately
      widget.onImported?.call();

      // Close this modal
      nav.pop();

      messenger.showSnackBar(
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
                      ? 'Catatan berhasil disimpan!'
                      : 'Notes successfully saved!',
                  style: GoogleFonts.plusJakartaSans(
                    color: MirelloColors.paperSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
          content: Text(
            AppStrings.isIndonesian
                ? 'Gagal menyimpan catatan: $e'
                : 'Failed to save notes: $e',
          ),
        ),
      );
    }
  }

  /// Option 2: Pick File (.md / .txt)
  Future<void> _pickAndImportFile() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md', 'txt', 'markdown'],
      );

      if (files.isNotEmpty && files.first.path != null) {
        final filePath = files.first.path!;
        final file = File(filePath);
        var content = await file.readAsString();

        if (content.trim().isEmpty) {
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFBA1A1A),
              behavior: SnackBarBehavior.floating,
              content: Text(
                AppStrings.isIndonesian
                    ? 'Berkas yang dipilih kosong.'
                    : 'The selected file is empty.',
              ),
            ),
          );
          return;
        }

        content = MirelloMarkdownParser.stripCodeFences(content);
        final pages = MirelloMarkdownParser.splitPages(content);
        await NotebookRepository.instance.updateMarkdown(
          widget.notebook.id,
          content,
          totalPages: pages.length,
        );

        widget.onImported?.call();
        nav.pop();

        messenger.showSnackBar(
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
                        ? 'Catatan berhasil disimpan!'
                        : 'Notes successfully saved!',
                    style: GoogleFonts.plusJakartaSans(
                      color: MirelloColors.paperSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
          content: Text(
            AppStrings.isIndonesian
                ? 'Gagal membaca berkas: $e'
                : 'Failed to read file: $e',
          ),
        ),
      );
    }
  }
}
