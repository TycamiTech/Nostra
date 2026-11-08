import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/mirello_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../backup/services/local_vault_service.dart';
import '../data/free_notes_repository.dart';
import '../models/free_note.dart';
import 'live_markdown_controller.dart';
import 'rich_text_controller.dart';
import 'widgets/note_color_picker_sheet.dart';

class FreeNoteEditorScreen extends StatefulWidget {
  final FreeNote? existingNote;
  final String? noteId;

  const FreeNoteEditorScreen({super.key, this.existingNote, this.noteId});

  @override
  State<FreeNoteEditorScreen> createState() => _FreeNoteEditorScreenState();
}

class _FreeNoteEditorScreenState extends State<FreeNoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  GoogleKeepRichTextController? _richController;
  LiveMarkdownEditingController? _rawController;
  late final FocusNode _titleFocusNode;
  late final FocusNode _contentFocusNode;

  late String _id;
  late DateTime _createdAt;
  late DateTime _updatedAt;
  late String _colorHex;
  late bool _isPinned;
  late bool _isFavorite;
  late List<String> _imagePaths;
  late bool _isArchived;
  bool _isNew = false;
  bool _isDeleted = false;
  bool _isPreviewMode = false;
  Offset? _lastPointerDownOffset;

  bool get _isNormalMode => AppSettingsService.instance.isNormal;

  @override
  void initState() {
    super.initState();
    FreeNote? note = widget.existingNote;
    if (note == null && widget.noteId != null) {
      note = FreeNotesRepository.instance.getById(widget.noteId!);
    }
    final initialContent = note?.content ?? '';

    if (_isNormalMode) {
      _richController = GoogleKeepRichTextController.fromMarkdown(initialContent);
      _contentController = _richController!;
    } else {
      _rawController = LiveMarkdownEditingController(text: initialContent);
      _contentController = _rawController!;
    }

    _contentController.addListener(_onContentChanged);

    if (note != null) {
      _id = note.id;
      _titleController = TextEditingController(text: note.title);
      _createdAt = note.createdAt;
      _updatedAt = note.updatedAt;
      _colorHex = note.colorHex;
      _isPinned = note.isPinned;
      _isFavorite = note.isFavorite;
      _imagePaths = List<String>.from(note.imagePaths);
      _isArchived = note.isArchived;
      _isNew = false;
    } else {
      _id = DateTime.now().millisecondsSinceEpoch.toString();
      _titleController = TextEditingController();
      _createdAt = DateTime.now();
      _updatedAt = DateTime.now();
      _colorHex = FreeNote.presetColors[0];
      _isPinned = false;
      _isFavorite = false;
      _imagePaths = [];
      _isArchived = false;
      _isNew = true;
    }

    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();

    if (_isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocusNode.requestFocus();
      });
    }
  }

  void _onContentChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _saveNote();
    _contentController.removeListener(_onContentChanged);
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) => NoteColorPickerSheet.parseHex(hex);

  String _getContentMarkdown() {
    if (_isNormalMode && _richController != null) {
      return _richController!.toMarkdown().trim();
    }
    return _contentController.text.trim();
  }

  void _saveNote() {
    if (_isDeleted) return;

    final title = _titleController.text.trim();
    final content = _getContentMarkdown();

    if (title.isEmpty && content.isEmpty && _imagePaths.isEmpty) {
      if (!_isNew) {
        FreeNotesRepository.instance.delete(_id);
      }
      return;
    }

    final note = FreeNote(
      id: _id,
      title: title,
      content: content,
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
      colorHex: _colorHex,
      isPinned: _isPinned,
      isFavorite: _isFavorite,
      imagePaths: List<String>.from(_imagePaths),
      isArchived: _isArchived,
    );

    FreeNotesRepository.instance.save(note);
    _isNew = false;
  }

  String _formatDate(DateTime dt) => DateFormatter.formatFull(dt);

  int get _wordCount {
    final text = '${_titleController.text} ${_contentController.text}'.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
  }

  // --- Formatting Helpers ---

  void _wrapSelection(String prefix, [String? suffix]) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final endSuff = suffix ?? prefix;

    if (!selection.isValid) return;

    if (selection.isCollapsed) {
      final cursor = selection.baseOffset;
      // If cursor is right between markers e.g. **|**
      if (cursor >= prefix.length &&
          cursor + endSuff.length <= text.length &&
          text.substring(cursor - prefix.length, cursor) == prefix &&
          text.substring(cursor, cursor + endSuff.length) == endSuff) {
        final newText = text.replaceRange(cursor - prefix.length, cursor + endSuff.length, '');
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: cursor - prefix.length),
        );
        _saveNote();
        return;
      }

      final newText = text.replaceRange(cursor, cursor, '$prefix$endSuff');
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursor + prefix.length),
      );
    } else {
      final start = selection.start;
      final end = selection.end;
      final selectedText = text.substring(start, end);

      // Check if already wrapped inside selection: e.g. **bold**
      if (selectedText.startsWith(prefix) &&
          selectedText.endsWith(endSuff) &&
          selectedText.length >= prefix.length + endSuff.length) {
        final inner = selectedText.substring(
          prefix.length,
          selectedText.length - endSuff.length,
        );
        final newText = text.replaceRange(start, end, inner);
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection(
            baseOffset: start,
            extentOffset: start + inner.length,
          ),
        );
        _saveNote();
        return;
      }

      // Check if markers surround the selection: **|selected|**
      if (start >= prefix.length &&
          end + endSuff.length <= text.length &&
          text.substring(start - prefix.length, start) == prefix &&
          text.substring(end, end + endSuff.length) == endSuff) {
        final textWithoutEnd = text.replaceRange(end, end + endSuff.length, '');
        final cleanedText = textWithoutEnd.replaceRange(start - prefix.length, start, '');
        _contentController.value = TextEditingValue(
          text: cleanedText,
          selection: TextSelection(
            baseOffset: start - prefix.length,
            extentOffset: end - prefix.length,
          ),
        );
        _saveNote();
        return;
      }

      // Normal wrap
      final newText =
          text.replaceRange(start, end, '$prefix$selectedText$endSuff');
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: start + prefix.length,
          extentOffset: start + prefix.length + selectedText.length,
        ),
      );
    }
    _saveNote();
  }

  void _prefixLine(String prefix) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final cursor = selection.isValid ? selection.baseOffset : text.length;

    // Find current line bounds
    int lineStart = 0;
    if (cursor > 0 && cursor <= text.length) {
      final lastNewline = text.lastIndexOf('\n', cursor - 1);
      if (lastNewline != -1) {
        lineStart = lastNewline + 1;
      }
    }

    int lineEnd = text.indexOf('\n', cursor);
    if (lineEnd == -1) {
      lineEnd = text.length;
    }

    final currentLine = text.substring(lineStart, lineEnd);

    // If current line already starts with this exact prefix, toggle it off!
    if (currentLine.startsWith(prefix)) {
      final newLine = currentLine.substring(prefix.length);
      final newText = text.replaceRange(lineStart, lineEnd, newLine);
      final newCursor = (cursor - prefix.length).clamp(lineStart, lineStart + newLine.length);
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor),
      );
      _saveNote();
      return;
    }

    // If it's a heading prefix, check if another heading is already there and replace it
    if (prefix.startsWith('#')) {
      final headingMatch = RegExp(r'^#{1,3}\s+').firstMatch(currentLine);
      if (headingMatch != null) {
        final oldPrefix = headingMatch.group(0)!;
        final newLine = prefix + currentLine.substring(oldPrefix.length);
        final newText = text.replaceRange(lineStart, lineEnd, newLine);
        final diff = prefix.length - oldPrefix.length;
        final newCursor = (cursor + diff).clamp(lineStart, lineStart + newLine.length);
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newCursor),
        );
        _saveNote();
        return;
      }
    }

    // Add prefix
    final newLine = prefix + currentLine;
    final newText = text.replaceRange(lineStart, lineEnd, newLine);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor + prefix.length),
    );
    _saveNote();
  }

  void _onH1Tap() {
    if (_isNormalMode && _richController != null) {
      _richController!.toggleH1();
    } else {
      _prefixLine('# ');
    }
    setState(() {});
    _saveNote();
  }

  void _onH2Tap() {
    if (_isNormalMode && _richController != null) {
      _richController!.toggleH2();
    } else {
      _prefixLine('## ');
    }
    setState(() {});
    _saveNote();
  }

  void _onBoldTap() {
    if (_isNormalMode && _richController != null) {
      _richController!.toggleBold();
    } else {
      _wrapSelection('**', '**');
    }
    setState(() {});
    _saveNote();
  }

  void _onItalicTap() {
    if (_isNormalMode && _richController != null) {
      _richController!.toggleItalic();
    } else {
      _wrapSelection('*', '*');
    }
    setState(() {});
    _saveNote();
  }

  void _onUnderlineTap() {
    if (_isNormalMode && _richController != null) {
      _richController!.toggleUnderline();
    } else {
      _wrapSelection('<u>', '</u>');
    }
    setState(() {});
    _saveNote();
  }

  void _onStrikeTap() {
    if (_isNormalMode && _richController != null) {
      _richController!.toggleStrikethrough();
    } else {
      _wrapSelection('~~', '~~');
    }
    setState(() {});
    _saveNote();
  }

  void _onHighlightTap() {
    if (_isNormalMode && _richController != null) {
      _richController!.toggleHighlight();
    } else {
      _wrapSelection('==', '==');
    }
    setState(() {});
    _saveNote();
  }

  Future<void> _pickAndInsertImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );

      if (result.isNotEmpty && result.first.path != null) {
        final originalPath = result.first.path!;
        final originalFile = File(originalPath);

        // Copy image to persistent application storage
        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory('${appDir.path}/nostra_images');
        if (!imagesDir.existsSync()) {
          imagesDir.createSync(recursive: true);
        }

        final ext = originalPath.split('.').last;
        final newFileName = 'img_${DateTime.now().millisecondsSinceEpoch}.$ext';
        final savedFile = await originalFile.copy('${imagesDir.path}/$newFileName');

        setState(() {
          _imagePaths.add(savedFile.path);
        });

        _saveNote();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
    _saveNote();
  }

  void _showFullScreenImage(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.x, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text(
                    'Gambar tidak dapat dimuat',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showColorPicker() async {
    final hex = await NoteColorPickerSheet.show(
      context,
      currentColorHex: _colorHex,
    );
    if (hex != null && mounted) {
      setState(() {
        _colorHex = hex;
      });
      _saveNote();
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: MirelloColors.paperSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppStrings.isIndonesian ? 'Pindahkan ke Sampah?' : 'Move to Trash?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: MirelloColors.primaryInk,
          ),
        ),
        content: Text(
          AppStrings.isIndonesian
              ? 'Catatan ini akan disimpan di Sampah selama 7 hari sebelum dihapus permanen.'
              : 'This note will be kept in Trash for 7 days before being permanently deleted.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: MirelloColors.secondaryMuted,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              AppStrings.cancel,
              style: GoogleFonts.plusJakartaSans(
                color: MirelloColors.secondaryMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              _isDeleted = true;
              FreeNotesRepository.instance.delete(_id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.noteMovedToTrash),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              AppStrings.isIndonesian ? 'Pindahkan' : 'Move',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _copyAllText() {
    final title = _titleController.text.trim();
    final content = _getContentMarkdown();
    final combined = title.isEmpty ? content : '$title\n\n$content';
    if (combined.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: combined));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.isIndonesian
                ? 'Teks catatan berhasil disalin ke clipboard!'
                : 'Note text copied to clipboard!',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _exportNote({required bool asTxt}) {
    final note = FreeNote(
      id: _id,
      title: _titleController.text.trim(),
      content: _getContentMarkdown(),
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
      colorHex: _colorHex,
      isPinned: _isPinned,
      isFavorite: _isFavorite,
      imagePaths: List<String>.from(_imagePaths),
    );
    LocalVaultService.instance.exportSingleNote(note, asTxt: asTxt);
  }

  @override
  Widget build(BuildContext context) {
    final pageBgColor = _parseColor(_colorHex);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _saveNote();
        }
      },
      child: Scaffold(
        backgroundColor: pageBgColor,
        appBar: AppBar(
          backgroundColor: pageBgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              LucideIcons.chevronLeft,
              color: MirelloColors.primaryInk,
              size: 22,
            ),
            tooltip: AppStrings.isIndonesian ? 'Kembali & Simpan' : 'Back & Save',
            onPressed: () {
              _saveNote();
              Navigator.pop(context);
            },
          ),
          actions: [
            // Normal Mode: Quick Image Insert Button
            if (AppSettingsService.instance.isNormal)
              IconButton(
                icon: const Icon(
                  LucideIcons.imagePlus,
                  color: MirelloColors.primaryInk,
                  size: 20,
                ),
                tooltip: AppStrings.isIndonesian ? 'Sisipkan Gambar' : 'Insert Image',
                onPressed: _pickAndInsertImage,
              ),

            // Expert Mode: Preview / Edit Toggle
            if (AppSettingsService.instance.isExpert)
              IconButton(
                icon: Icon(
                  _isPreviewMode ? LucideIcons.edit3 : LucideIcons.eye,
                  color: MirelloColors.primaryInk,
                  size: 20,
                ),
                tooltip: _isPreviewMode
                    ? (AppStrings.isIndonesian ? 'Edit Catatan' : 'Edit Note')
                    : (AppStrings.isIndonesian ? 'Pratinjau Catatan' : 'Preview Note'),
                onPressed: () {
                  setState(() {
                    _isPreviewMode = !_isPreviewMode;
                  });
                },
              ),
            // Color picker
            IconButton(
              icon: const Icon(
                LucideIcons.palette,
                color: MirelloColors.primaryInk,
                size: 20,
              ),
              tooltip: AppStrings.isIndonesian ? 'Ubah Warna Catatan' : 'Change Note Color',
              onPressed: _showColorPicker,
            ),
            // Pin toggle
            IconButton(
              icon: Icon(
                _isPinned ? LucideIcons.pinOff : LucideIcons.pin,
                color: _isPinned
                    ? const Color(0xFFBA1A1A)
                    : MirelloColors.primaryInk,
                size: 20,
              ),
              tooltip: _isPinned ? AppStrings.unpin : AppStrings.pinToTop,
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                });
                _saveNote();
              },
            ),
            // Favorite toggle
            IconButton(
              icon: Icon(
                _isFavorite ? LucideIcons.heartHandshake : LucideIcons.heart,
                color: _isFavorite
                    ? const Color(0xFFBA1A1A)
                    : MirelloColors.primaryInk,
                size: 20,
              ),
              tooltip: _isFavorite
                  ? AppStrings.removeFromFavorites
                  : AppStrings.addToFavorites,
              onPressed: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
                _saveNote();
              },
            ),
            // More menu
            PopupMenuButton<String>(
              icon: const Icon(
                LucideIcons.moreVertical,
                color: MirelloColors.primaryInk,
                size: 20,
              ),
              color: MirelloColors.paperSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onSelected: (value) {
                if (value == 'delete') {
                  _confirmDelete();
                } else if (value == 'archive') {
                  setState(() {
                    _isArchived = !_isArchived;
                  });
                  _saveNote();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isArchived
                            ? AppStrings.noteArchived
                            : AppStrings.noteUnarchived,
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (value == 'copy') {
                  _copyAllText();
                } else if (value == 'export_md') {
                  _exportNote(asTxt: false);
                } else if (value == 'export_txt') {
                  _exportNote(asTxt: true);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(
                        _isArchived
                            ? LucideIcons.archiveRestore
                            : LucideIcons.archive,
                        size: 16,
                        color: MirelloColors.primaryInk,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isArchived
                            ? AppStrings.unarchiveNote
                            : AppStrings.archiveNote,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: MirelloColors.primaryInk,
                        ),
                      ),
                    ],
                  ),
                ),
                if (AppSettingsService.instance.isExpert)
                  PopupMenuItem(
                    value: 'export_md',
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.fileCode,
                          size: 16,
                          color: MirelloColors.primaryInk,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppStrings.isIndonesian
                              ? 'Ekspor Berkas .md (Obsidian)'
                              : 'Export .md File (Obsidian)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: MirelloColors.primaryInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'export_txt',
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.fileText,
                        size: 16,
                        color: MirelloColors.primaryInk,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppSettingsService.instance.isExpert
                            ? (AppStrings.isIndonesian
                                ? 'Ekspor Berkas .txt (Notepad)'
                                : 'Export .txt File (Notepad)')
                            : (AppStrings.isIndonesian
                                ? 'Bagikan / Ekspor Teks (.txt)'
                                : 'Share / Export Text (.txt)'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: MirelloColors.primaryInk,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'copy',
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.copy,
                        size: 16,
                        color: MirelloColors.primaryInk,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.isIndonesian
                            ? 'Salin Semua Teks'
                            : 'Copy All Text',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: MirelloColors.primaryInk,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.trash2,
                        size: 16,
                        color: Color(0xFFBA1A1A),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.moveToTrash,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFBA1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: _isPreviewMode ? _buildPreviewBody() : _buildEditorBody(),
                ),
              ),

              // Formatting Toolbar above keyboard (Only in Edit mode)
              if (!_isPreviewMode)
                _buildFormattingToolbar(pageBgColor),
            ],
          ),
        ),
      ),
    );
  }

  /// Edit Mode Body with text fields and image strip
  Widget _buildEditorBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Field
        TextField(
          controller: _titleController,
          focusNode: _titleFocusNode,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: MirelloColors.primaryInk,
          ),
          decoration: InputDecoration(
            hintText: AppStrings.isIndonesian ? 'Judul Catatan' : 'Note Title',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: MirelloColors.secondaryMuted.withValues(alpha: 0.6),
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            _contentFocusNode.requestFocus();
          },
        ),

        // Info & Date subtitle
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _contentController,
            builder: (context, val, _) {
              return Row(
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 12,
                    color: MirelloColors.secondaryMuted.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _formatDate(_updatedAt),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: MirelloColors.secondaryMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: MirelloColors.secondaryMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.wordsCount(_wordCount),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: MirelloColors.secondaryMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_imagePaths.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: MirelloColors.secondaryMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_imagePaths.length} ${AppStrings.isIndonesian ? "gambar" : "images"}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: MirelloColors.secondaryMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),

        // Attached Images Strip (if any)
        if (_imagePaths.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _imagePaths.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final path = _imagePaths[index];
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _showFullScreenImage(path),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(path),
                          width: 120,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 120,
                            height: 100,
                            color: Colors.black12,
                            child: const Icon(LucideIcons.imageOff, size: 20),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.x,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 10),
        const Divider(
          color: MirelloColors.borderSubtle,
          thickness: 0.8,
          height: 1,
        ),
        const SizedBox(height: 12),

        // Content Field
        Expanded(
          child: Listener(
            onPointerDown: (e) {
              _lastPointerDownOffset = e.localPosition;
            },
            child: TextField(
              controller: _contentController,
              focusNode: _contentFocusNode,
              onTap: _handleEditorContentTap,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                height: 1.6,
                color: MirelloColors.primaryInk,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: AppSettingsService.instance.isExpert
                    ? (AppStrings.isIndonesian
                        ? 'Mulai mengetik catatan di sini...\nGunakan bilah alat di bawah untuk memformat teks (Markdown).'
                        : 'Start typing your notes here...\nUse the toolbar below to format text (Markdown).')
                    : (AppStrings.isIndonesian
                        ? 'Mulai mengetik catatan di sini sesuka hati...'
                        : 'Start typing your notes freely here...'),
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  height: 1.6,
                  color: MirelloColors.secondaryMuted.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
        ),
      ],
    );
  }

  void _handleEditorContentTap() {
    final pointer = _lastPointerDownOffset;
    final cursor = _contentController.selection.baseOffset;
    if (cursor < 0) return;

    if (_isNormalMode && _richController != null) {
      final bounds = _richController!.currentLineBounds;
      final lineStart = bounds.$1;
      final offsetInLine = cursor - lineStart;

      final isNearLeftEdge = pointer != null && pointer.dx <= 48;
      final isNearPrefix = offsetInLine <= 2;

      if (isNearLeftEdge || isNearPrefix) {
        final toggled = _richController!.toggleCheckboxAtOffset(cursor);
        if (toggled) {
          HapticFeedback.lightImpact();
          setState(() {});
          _saveNote();
        }
      }
    } else if (!_isNormalMode) {
      final rawText = _contentController.text;
      final lines = rawText.split('\n');
      int currentOffset = 0;

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final lineStart = currentOffset;
        final lineEnd = lineStart + line.length;

        if (cursor >= lineStart && cursor <= lineEnd + 1) {
          final trimmed = line.trimLeft();
          final indent = line.length - trimmed.length;
          final offsetInLine = cursor - lineStart;
          final isNearLeftEdge = pointer != null && pointer.dx <= 48;
          final isNearPrefix = offsetInLine <= (indent + 6);

          if (isNearLeftEdge || isNearPrefix) {
            if (trimmed.startsWith('- [ ] ') || trimmed.startsWith('[ ] ')) {
              final prefixLen = trimmed.startsWith('- [ ] ') ? 6 : 4;
              final target = trimmed.startsWith('- [ ] ') ? '- [x] ' : '[x] ';
              final newText = rawText.replaceRange(
                lineStart + indent,
                lineStart + indent + prefixLen,
                target,
              );
              _contentController.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(
                  offset: cursor.clamp(0, newText.length),
                ),
              );
              HapticFeedback.lightImpact();
              setState(() {});
              _saveNote();
              break;
            } else if (trimmed.startsWith('- [x] ') || trimmed.startsWith('[x] ')) {
              final prefixLen = trimmed.startsWith('- [x] ') ? 6 : 4;
              final target = trimmed.startsWith('- [x] ') ? '- [ ] ' : '[ ] ';
              final newText = rawText.replaceRange(
                lineStart + indent,
                lineStart + indent + prefixLen,
                target,
              );
              _contentController.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(
                  offset: cursor.clamp(0, newText.length),
                ),
              );
              HapticFeedback.lightImpact();
              setState(() {});
              _saveNote();
              break;
            }
          }
        }
        currentOffset += line.length + 1;
      }
    }
  }

  /// Preview / Read Mode Body with formatted typography and embedded images
  Widget _buildPreviewBody() {
    final title = _titleController.text.trim();
    final content = _getContentMarkdown();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title.isNotEmpty ? title : AppStrings.untitledNote,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: MirelloColors.primaryInk,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatDate(_updatedAt),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: MirelloColors.secondaryMuted,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: MirelloColors.borderSubtle, thickness: 1),
          const SizedBox(height: 12),

          // Attached Images Gallery (Full Width in Preview)
          if (_imagePaths.isNotEmpty) ...[
            for (final path in _imagePaths) ...[
              GestureDetector(
                onTap: () => _showFullScreenImage(path),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: MirelloColors.borderCard, width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(path),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ],
          ],

          // Formatted Content Lines
          _buildRenderedContent(content),
        ],
      ),
    );
  }

  /// Renders Markdown / Rich Content in Preview Mode
  Widget _buildRenderedContent(String rawContent) {
    if (rawContent.trim().isEmpty) {
      return Text(
        AppStrings.isIndonesian
            ? '(Belum ada isi catatan)'
            : '(No note content yet)',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: MirelloColors.secondaryMuted,
        ),
      );
    }

    final lines = rawContent.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lines.length; i++) ...[
          _buildRenderedLine(lines[i], i),
          const SizedBox(height: 5),
        ],
      ],
    );
  }

  Widget _buildRenderedLine(String line, int lineIndex) {
    final trimmed = line.trim();

    // 1. Heading 1: # ...
    if (trimmed.startsWith('# ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 4),
        child: Text(
          trimmed.substring(2),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: MirelloColors.primaryInk,
          ),
        ),
      );
    }

    // 2. Heading 2: ## ...
    if (trimmed.startsWith('## ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 3),
        child: Text(
          trimmed.substring(3),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: MirelloColors.primaryInk,
          ),
        ),
      );
    }

    // 3. Heading 3: ### ...
    if (trimmed.startsWith('### ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 2),
        child: Text(
          trimmed.substring(4),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: MirelloColors.primaryInk,
          ),
        ),
      );
    }

    // 4. Checklist: - [ ] or - [x]
    final isUnchecked = trimmed.startsWith('- [ ] ') || trimmed.startsWith('[ ] ');
    final isChecked = trimmed.startsWith('- [x] ') || trimmed.startsWith('[x] ');
    if (isUnchecked || isChecked) {
      final textStart = isUnchecked
          ? (trimmed.startsWith('- [ ] ') ? 6 : 4)
          : (trimmed.startsWith('- [x] ') ? 6 : 4);
      final itemText = trimmed.substring(textStart);

      return GestureDetector(
        onTap: () {
          // Toggle checkbox state in content
          if (_isNormalMode && _richController != null) {
            final allLines = _richController!.text.split('\n');
            if (lineIndex < allLines.length) {
              final oldLine = allLines[lineIndex];
              if (oldLine.startsWith('☐ ')) {
                allLines[lineIndex] = oldLine.replaceFirst('☐ ', '☑ ');
              } else if (oldLine.startsWith('☑ ')) {
                allLines[lineIndex] = oldLine.replaceFirst('☑ ', '☐ ');
              }
              setState(() {
                _richController!.text = allLines.join('\n');
              });
              _saveNote();
            }
          } else {
            final allLines = _contentController.text.split('\n');
            if (lineIndex < allLines.length) {
              final oldLine = allLines[lineIndex];
              if (isUnchecked) {
                allLines[lineIndex] = oldLine.replaceFirst('[ ]', '[x]');
              } else {
                allLines[lineIndex] = oldLine.replaceFirst('[x]', '[ ]');
              }
              setState(() {
                _contentController.text = allLines.join('\n');
              });
              _saveNote();
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.5),
                child: Icon(
                  isChecked ? LucideIcons.checkSquare2 : LucideIcons.square,
                  size: 16.5,
                  color: isChecked ? MirelloColors.secondaryMuted : MirelloColors.primaryInk,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  itemText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    height: 1.45,
                    color: isChecked
                        ? MirelloColors.secondaryMuted
                        : MirelloColors.primaryInk,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 5. Bullet List: - ... or * ...
    if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, right: 8),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: MirelloColors.primaryInk,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: _buildInlineRichText(trimmed.substring(2)),
            ),
          ],
        ),
      );
    }

    // 6. Blockquote: > ...
    if (trimmed.startsWith('> ')) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          border: const Border(
            left: BorderSide(color: MirelloColors.primaryInk, width: 3),
          ),
        ),
        child: _buildInlineRichText(trimmed.substring(2)),
      );
    }

    // 7. Normal Paragraph with inline format
    if (trimmed.isEmpty) {
      return const SizedBox(height: 8);
    }

    return _buildInlineRichText(trimmed);
  }

  /// Builds rich text spans for bold, italic, strike, highlight, and underline
  Widget _buildInlineRichText(String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(
      r'(==[^=\n]+==|'
      r'\*\*[^\*\n]+\*\*|'
      r'~~[^~\n]+~~|'
      r'<u>[^<]+</u>|'
      r'\*[^\*\n]+\*)',
    );

    int lastEnd = 0;
    final defaultStyle = GoogleFonts.plusJakartaSans(
      fontSize: 15.5,
      height: 1.55,
      color: MirelloColors.primaryInk,
    );

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: defaultStyle,
        ));
      }

      final matched = match.group(0)!;

      // Highlight ==...==
      if (matched.startsWith('==') && matched.endsWith('==')) {
        final inner = matched.substring(2, matched.length - 2);
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFF6E08E),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              inner,
              style: defaultStyle.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1E1E),
              ),
            ),
          ),
        ));
      }
      // Bold **...**
      else if (matched.startsWith('**') && matched.endsWith('**')) {
        spans.add(TextSpan(
          text: matched.substring(2, matched.length - 2),
          style: defaultStyle.copyWith(fontWeight: FontWeight.w700),
        ));
      }
      // Strike ~~...~~
      else if (matched.startsWith('~~') && matched.endsWith('~~')) {
        spans.add(TextSpan(
          text: matched.substring(2, matched.length - 2),
          style: defaultStyle.copyWith(decoration: TextDecoration.lineThrough),
        ));
      }
      // Underline <u>...</u>
      else if (matched.startsWith('<u>') && matched.endsWith('</u>')) {
        spans.add(TextSpan(
          text: matched.substring(3, matched.length - 4),
          style: defaultStyle.copyWith(decoration: TextDecoration.underline),
        ));
      }
      // Italic *...*
      else if (matched.startsWith('*') && matched.endsWith('*')) {
        spans.add(TextSpan(
          text: matched.substring(1, matched.length - 1),
          style: defaultStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: defaultStyle,
      ));
    }

    return Text.rich(TextSpan(children: spans));
  }

  /// Floating Formatting Toolbar right above the keyboard
  Widget _buildFormattingToolbar(Color pageBgColor) {
    final isH1Active = _isNormalMode ? (_richController?.isH1Active ?? false) : false;
    final isH2Active = _isNormalMode ? (_richController?.isH2Active ?? false) : false;
    final isBoldActive = _isNormalMode ? (_richController?.isBoldActive ?? false) : false;
    final isItalicActive = _isNormalMode ? (_richController?.isItalicActive ?? false) : false;
    final isUnderlineActive = _isNormalMode ? (_richController?.isUnderlineActive ?? false) : false;
    final isStrikeActive = _isNormalMode ? (_richController?.isStrikethroughActive ?? false) : false;
    final isHighlightActive = _isNormalMode ? (_richController?.isHighlightActive ?? false) : false;

    return Container(
      decoration: BoxDecoration(
        color: pageBgColor,
        border: const Border(
          top: BorderSide(
            color: MirelloColors.borderSubtle,
            width: 0.8,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Dark minimalist bar
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // H1 Button
              _buildToolbarButton(
                child: Text(
                  'H1',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                tooltip: AppStrings.isIndonesian ? 'Judul Utama (H1)' : 'Main Heading (H1)',
                isActive: isH1Active,
                onTap: _onH1Tap,
              ),

              // H2 Button
              _buildToolbarButton(
                child: Text(
                  'H2',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                tooltip: AppStrings.isIndonesian ? 'Sub-Judul (H2)' : 'Subheading (H2)',
                isActive: isH2Active,
                onTap: _onH2Tap,
              ),

              _buildToolbarDivider(),

              // Bold (B) Button
              _buildToolbarButton(
                child: const Text(
                  'B',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                tooltip: AppStrings.isIndonesian ? 'Tebal (Bold)' : 'Bold',
                isActive: isBoldActive,
                onTap: _onBoldTap,
              ),

              // Italic (I) Button
              _buildToolbarButton(
                child: const Text(
                  'I',
                  style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                tooltip: AppStrings.isIndonesian ? 'Miring (Italic)' : 'Italic',
                isActive: isItalicActive,
                onTap: _onItalicTap,
              ),

              // Underline (U) Button
              _buildToolbarButton(
                child: const Text(
                  'U',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                tooltip: AppStrings.isIndonesian ? 'Garis Bawah (Underline)' : 'Underline',
                isActive: isUnderlineActive,
                onTap: _onUnderlineTap,
              ),

              // Strike (S) Button
              _buildToolbarButton(
                child: const Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                tooltip: AppStrings.isIndonesian ? 'Coret (Strikethrough)' : 'Strikethrough',
                isActive: isStrikeActive,
                onTap: _onStrikeTap,
              ),

              // Highlight / Stabilo Button
              _buildToolbarButton(
                child: const Icon(
                  LucideIcons.highlighter,
                  color: Color(0xFFF6E08E),
                  size: 16,
                ),
                tooltip: AppStrings.isIndonesian ? 'Stabilo Kuning' : 'Yellow Highlight',
                isActive: isHighlightActive,
                onTap: _onHighlightTap,
              ),

              _buildToolbarDivider(),

              // Image Insertion (JPG / PNG)
              _buildToolbarButton(
                child: const Icon(
                  LucideIcons.image,
                  color: Colors.white,
                  size: 16,
                ),
                tooltip: AppStrings.isIndonesian ? 'Sisipkan Foto / Gambar (JPG/PNG)' : 'Insert Photo / Image (JPG/PNG)',
                onTap: _pickAndInsertImage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required Widget child,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withValues(alpha: 0.22) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 18,
      width: 1,
      color: Colors.white24,
    );
  }
}
