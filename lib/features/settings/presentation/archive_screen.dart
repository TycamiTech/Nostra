import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/mirello_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/doodle_illustrations.dart';
import '../../library/data/notebook_repository.dart';
import '../../library/models/subject_notebook.dart';
import '../../notes/data/free_notes_repository.dart';
import '../../notes/models/free_note.dart';
import '../../notes/presentation/free_note_editor_screen.dart';
import '../../notes/presentation/rich_text_controller.dart';
import '../../reader/presentation/reader_screen.dart';

/// Archive Screen for Nostra Notes & Subject Notebooks
class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppSettingsService.instance.languageNotifier,
      builder: (context, language, _) {
        return Scaffold(
      backgroundColor: MirelloColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: MirelloColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrowLeft,
            color: MirelloColors.primaryInk,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.archiveHeaderTitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: MirelloColors.primaryInk,
              ),
            ),
            Text(
              AppStrings.archiveHeaderSubtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: MirelloColors.secondaryMuted,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: MirelloColors.tabPillBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: MirelloColors.primaryInk,
              unselectedLabelColor: MirelloColors.secondaryMuted,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: AppStrings.filterNotes),
                Tab(text: AppStrings.filterUtbkModules),
              ],
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          FreeNotesRepository.instance.listenable,
          NotebookRepository.instance.listenable,
        ]),
        builder: (context, _) {
          final archivedNotes = FreeNotesRepository.instance.getArchived();
          final archivedSubjects = NotebookRepository.instance.getArchived();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildArchivedNotesTab(archivedNotes),
              _buildArchivedSubjectsTab(archivedSubjects),
            ],
          );
        },
      ),
    );
      },
    );
  }

  // ==========================================
  // TAB 1: ARCHIVED FREE NOTES
  // ==========================================
  Widget _buildArchivedNotesTab(List<FreeNote> notes) {
    if (notes.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.archive,
        title: AppStrings.isIndonesian
            ? 'Tidak Ada Catatan Diarsipkan'
            : 'No Archived Notes',
        subtitle: AppStrings.isIndonesian
            ? 'Catatan harian yang kamu arsipkan akan tersimpan di sini.'
            : 'Daily notes you archive will be stored here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final note = notes[index];
        final cardColor = Color(
          int.parse('FF${note.colorHex.replaceAll('#', '')}', radix: 16),
        );

        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MirelloColors.borderCard,
              width: 0.9,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FreeNoteEditorScreen(noteId: note.id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.title.isNotEmpty
                                ? note.title
                                : AppStrings.untitledNote,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: MirelloColors.primaryInk,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Unarchive button
                        IconButton(
                          icon: const Icon(
                            LucideIcons.archiveRestore,
                            size: 18,
                            color: MirelloColors.primaryInk,
                          ),
                          tooltip: AppStrings.unarchiveNote,
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await FreeNotesRepository.instance.unarchive(note.id);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.noteUnarchived),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        // Move to trash button
                        IconButton(
                          icon: const Icon(
                            LucideIcons.trash2,
                            size: 18,
                            color: MirelloColors.deleteRed,
                          ),
                          tooltip: AppStrings.moveToTrash,
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await FreeNotesRepository.instance.moveToTrash(note.id);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.noteMovedToTrash),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    if (note.content.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: GoogleKeepRichTextController.buildRichPreviewSpan(
                          note.content.length > 200
                              ? '${note.content.substring(0, 200)}...'
                              : note.content,
                          baseStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: MirelloColors.secondaryMuted,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.clock,
                          size: 12,
                          color: MirelloColors.secondaryMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(note.updatedAt),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: MirelloColors.secondaryMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 2: ARCHIVED SUBJECT NOTEBOOKS
  // ==========================================
  Widget _buildArchivedSubjectsTab(List<SubjectNotebook> subjects) {
    if (subjects.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.archive,
        title: AppStrings.isIndonesian
            ? 'Tidak Ada Mata Pelajaran Diarsipkan'
            : 'No Archived Subjects',
        subtitle: AppStrings.isIndonesian
            ? 'Mata pelajaran yang kamu arsipkan akan tersimpan di sini.'
            : 'Subject notebooks you archive will be stored here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: subjects.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notebook = subjects[index];

        return Container(
          height: 140,
          decoration: BoxDecoration(
            color: notebook.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: MirelloColors.borderCard,
              width: 0.9,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReaderScreen(notebook: notebook),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        // Left Info
                        Expanded(
                          flex: 7,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        notebook.code,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: MirelloColors.primaryInk,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        LucideIcons.archiveRestore,
                                        size: 18,
                                        color: MirelloColors.primaryInk,
                                      ),
                                      tooltip: AppStrings.unarchiveNote,
                                      onPressed: () async {
                                        final messenger =
                                            ScaffoldMessenger.of(context);
                                        await NotebookRepository.instance
                                            .unarchive(notebook.id);
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppStrings.isIndonesian
                                                  ? '"${notebook.title}" dikembalikan dari arsip.'
                                                  : '"${notebook.title}" restored from archive.',
                                            ),
                                            behavior:
                                                SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        LucideIcons.trash2,
                                        size: 18,
                                        color: MirelloColors.deleteRed,
                                      ),
                                      tooltip: AppStrings.moveToTrash,
                                      onPressed: () async {
                                        final messenger =
                                            ScaffoldMessenger.of(context);
                                        await NotebookRepository.instance
                                            .moveToTrash(notebook.id);
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppStrings.isIndonesian
                                                  ? '"${notebook.title}" dipindahkan ke Sampah.'
                                                  : '"${notebook.title}" moved to Trash.',
                                            ),
                                            behavior:
                                                SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  notebook.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: MirelloColors.primaryInk,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${AppStrings.pagePrefix} ${notebook.currentPage}/${notebook.totalPages}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: MirelloColors.secondaryMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right Doodle
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Center(
                              child: SubjectDoodle(
                                type: notebook.doodleType,
                                width: 68,
                                height: 68,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: MirelloColors.borderCard,
                  width: 0.9,
                ),
              ),
              child: Icon(
                icon,
                size: 36,
                color: MirelloColors.secondaryMuted,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: MirelloColors.primaryInk,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: MirelloColors.secondaryMuted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) => DateFormatter.formatRelative(dt);
}
