import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/nostra_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../data/free_notes_repository.dart';
import '../models/free_note.dart';
import 'free_note_editor_screen.dart';
import 'rich_text_controller.dart';

class FreeNotesTab extends StatefulWidget {
  final bool onlyFavorites;

  const FreeNotesTab({super.key, this.onlyFavorites = false});

  @override
  State<FreeNotesTab> createState() => _FreeNotesTabState();
}

class _FreeNotesTabState extends State<FreeNotesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return NostraColors.paperSurface;
    }
  }

  String _formatDateShort(DateTime dt) => DateFormatter.formatRelative(dt);

  void _openEditor([FreeNote? note]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FreeNoteEditorScreen(existingNote: note),
      ),
    );
  }

  void _showNoteActions(FreeNote note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: NostraColors.paperSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: NostraColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              note.title.isNotEmpty ? note.title : AppStrings.untitledNote,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: NostraColors.primaryInk,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                note.isPinned ? LucideIcons.pinOff : LucideIcons.pin,
                color: NostraColors.primaryInk,
              ),
              title: Text(
                note.isPinned ? AppStrings.unpin : AppStrings.pinToTop,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: NostraColors.primaryInk,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                FreeNotesRepository.instance.togglePin(note.id);
              },
            ),
            ListTile(
              leading: Icon(
                note.isFavorite ? LucideIcons.heartHandshake : LucideIcons.heart,
                color: note.isFavorite ? const Color(0xFFBA1A1A) : NostraColors.primaryInk,
              ),
              title: Text(
                note.isFavorite ? AppStrings.removeFromFavorites : AppStrings.addToFavorites,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: NostraColors.primaryInk,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                FreeNotesRepository.instance.toggleFavorite(note.id);
              },
            ),
            ListTile(
              leading: const Icon(
                LucideIcons.archive,
                color: NostraColors.primaryInk,
              ),
              title: Text(
                note.isArchived ? AppStrings.unarchiveNote : AppStrings.archiveNote,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: NostraColors.primaryInk,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                FreeNotesRepository.instance.toggleArchive(note.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      note.isArchived
                          ? AppStrings.noteUnarchived
                          : AppStrings.noteArchived,
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                LucideIcons.trash2,
                color: Color(0xFFBA1A1A),
              ),
              title: Text(
                AppStrings.moveToTrash,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFBA1A1A),
                ),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                FreeNotesRepository.instance.delete(note.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.noteMovedToTrash),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppSettingsService.instance.languageNotifier,
      builder: (context, language, _) {
        return Scaffold(
      backgroundColor: NostraColors.scaffoldBackground,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: NostraColors.primaryInk,
        foregroundColor: NostraColors.paperSurface,
        elevation: 2,
        onPressed: () => _openEditor(),
        icon: const Icon(LucideIcons.plus, size: 20),
        label: Text(
          AppStrings.newNote,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Greetings / Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.onlyFavorites
                      ? AppStrings.favoriteNotesTitle
                      : AppStrings.dailyNotes,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: NostraColors.primaryInk,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                ValueListenableBuilder<AppMode>(
                  valueListenable: AppSettingsService.instance.modeNotifier,
                  builder: (context, mode, _) {
                    final isNormal = mode == AppMode.normal;
                    return Text(
                      widget.onlyFavorites
                          ? AppStrings.favoriteNotesSubtitle
                          : (isNormal
                              ? AppStrings.dailyNotesSubtitleNormal
                              : AppStrings.dailyNotesSubtitleExpert),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: NostraColors.secondaryMuted,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: NostraColors.borderCard,
                  width: 1.0,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: NostraColors.primaryInk,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.searchNotes,
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: NostraColors.secondaryMuted.withValues(alpha: 0.7),
                  ),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    size: 18,
                    color: NostraColors.secondaryMuted,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            size: 16,
                            color: NostraColors.secondaryMuted,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Reactive Notes Grid/List
          Expanded(
            child: ValueListenableBuilder<Box>(
              valueListenable: FreeNotesRepository.instance.listenable,
              builder: (context, box, _) {
                final notes = FreeNotesRepository.instance.getAll(
                  searchQuery: _searchQuery,
                  onlyFavorites: widget.onlyFavorites,
                );

                if (notes.isEmpty) {
                  return _buildEmptyState();
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 90),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return _buildNoteCard(note);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildNoteCard(FreeNote note) {
    final bgColor = _parseColor(note.colorHex);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openEditor(note),
        onLongPress: () => _showNoteActions(note),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: NostraColors.borderCard.withValues(alpha: 0.9),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Thumbnail if available
              if (note.imagePaths.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Image.file(
                        File(note.imagePaths.first),
                        height: 64,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                      if (note.imagePaths.length > 1)
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.image,
                                  size: 10,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '+${note.imagePaths.length - 1}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Top Row: Title & Icons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title.isNotEmpty ? note.title : AppStrings.untitledNote,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: NostraColors.primaryInk,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.pin,
                      size: 14,
                      color: Color(0xFFBA1A1A),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),

              // Content snippet (rendered rich visual format, concealing raw markdown tags)
              Expanded(
                child: note.content.isNotEmpty
                    ? Text.rich(
                        GoogleKeepRichTextController.buildRichPreviewSpan(
                          note.content,
                          baseStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            height: 1.45,
                            color: NostraColors.primaryInk.withValues(alpha: 0.8),
                          ),
                        ),
                        maxLines: note.imagePaths.isNotEmpty ? 2 : 5,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        note.imagePaths.isNotEmpty
                            ? AppStrings.imageAttached
                            : AppStrings.noAdditionalText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          height: 1.45,
                          color: NostraColors.primaryInk.withValues(alpha: 0.8),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: note.imagePaths.isNotEmpty ? 2 : 5,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),

              const SizedBox(height: 8),

              // Bottom Row: Date & Favorite Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDateShort(note.updatedAt),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: NostraColors.secondaryMuted,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        FreeNotesRepository.instance.toggleFavorite(note.id),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        note.isFavorite
                            ? LucideIcons.heartHandshake
                            : LucideIcons.heart,
                        size: 14,
                        color: note.isFavorite
                            ? const Color(0xFFBA1A1A)
                            : NostraColors.secondaryMuted.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: NostraColors.borderCard,
                  width: 1.0,
                ),
              ),
              child: const Icon(
                LucideIcons.notebookPen,
                size: 32,
                color: NostraColors.secondaryMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? AppStrings.noNotesFound
                  : (widget.onlyFavorites
                      ? AppStrings.noFavoriteNotesYet
                      : AppStrings.noNotesYet),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: NostraColors.primaryInk,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? AppStrings.tryAnotherKeyword
                  : (widget.onlyFavorites
                      ? AppStrings.noFavoriteNotesDesc
                      : AppStrings.dailyNotesEmptyDesc),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: NostraColors.secondaryMuted,
                height: 1.4,
              ),
            ),
            if (_searchQuery.isEmpty && !widget.onlyFavorites) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: NostraColors.primaryInk,
                  foregroundColor: NostraColors.paperSurface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                ),
                onPressed: () => _openEditor(),
                icon: const Icon(LucideIcons.plus, size: 16),
                label: Text(
                  AppStrings.createFirstNote,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

