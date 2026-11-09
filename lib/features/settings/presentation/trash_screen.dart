import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/nostra_theme.dart';
import '../../../core/widgets/doodle_illustrations.dart';
import '../../library/data/notebook_repository.dart';
import '../../library/models/subject_notebook.dart';
import '../../notes/data/free_notes_repository.dart';
import '../../notes/models/free_note.dart';
import '../../notes/presentation/rich_text_controller.dart';

/// Trash Screen: Soft-deleted notes and subject notebooks with 7-day auto-purge
class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Purge expired items (> 7 days) upon entering Trash screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FreeNotesRepository.instance.purgeOldTrash();
      NotebookRepository.instance.purgeOldTrash();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _calculateDaysRemaining(DateTime? deletedAt) {
    if (deletedAt == null) return 7;
    final diff = DateTime.now().difference(deletedAt).inDays;
    final remaining = 7 - diff;
    return remaining.clamp(1, 7);
  }

  void _confirmEmptyTrash() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NostraColors.paperSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppStrings.emptyTrashPrompt,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: NostraColors.primaryInk,
          ),
        ),
        content: Text(
          AppStrings.emptyTrashPromptDesc,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: NostraColors.secondaryMuted,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.cancel,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: NostraColors.secondaryMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NostraColors.deleteRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await FreeNotesRepository.instance.emptyTrash();
              await NotebookRepository.instance.emptyTrash();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.trashEmptied),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              AppStrings.empty,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPermanentDelete({
    required String title,
    required Future<void> Function() onConfirmed,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NostraColors.paperSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppStrings.deletePermanentPrompt,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: NostraColors.primaryInk,
          ),
        ),
        content: Text(
          AppStrings.deletePermanentDesc(title),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: NostraColors.secondaryMuted,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.cancel,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: NostraColors.secondaryMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NostraColors.deleteRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await onConfirmed();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.deletePermanentSuccess(title)),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              AppStrings.deletePermanently,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        FreeNotesRepository.instance.listenable,
        NotebookRepository.instance.listenable,
        AppSettingsService.instance.languageNotifier,
      ]),
      builder: (context, _) {
        final trashNotes = FreeNotesRepository.instance.getTrash();
        final trashSubjects = NotebookRepository.instance.getTrash();
        final hasAnyTrash = trashNotes.isNotEmpty || trashSubjects.isNotEmpty;

        return Scaffold(
          backgroundColor: NostraColors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: NostraColors.scaffoldBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                LucideIcons.arrowLeft,
                color: NostraColors.primaryInk,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.trashHeaderTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: NostraColors.primaryInk,
                  ),
                ),
                Text(
                  AppStrings.trashHeaderSubtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: NostraColors.secondaryMuted,
                  ),
                ),
              ],
            ),
            actions: [
              if (hasAnyTrash)
                TextButton.icon(
                  onPressed: _confirmEmptyTrash,
                  icon: const Icon(
                    LucideIcons.trash2,
                    size: 15,
                    color: NostraColors.deleteRed,
                  ),
                  label: Text(
                    AppStrings.empty,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: NostraColors.deleteRed,
                    ),
                  ),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: NostraColors.tabPillBackground,
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
                  labelColor: NostraColors.primaryInk,
                  unselectedLabelColor: NostraColors.secondaryMuted,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(text: '${AppStrings.filterNotes} (${trashNotes.length})'),
                    Tab(text: '${AppStrings.filterUtbkModules} (${trashSubjects.length})'),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              // 7-day auto-purge reminder notice
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3E8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: NostraColors.borderSubtle,
                    width: 0.9,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.info,
                      size: 16,
                      color: NostraColors.secondaryMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppStrings.trashEmptyDesc,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: NostraColors.secondaryMuted,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTrashNotesTab(trashNotes),
                    _buildTrashSubjectsTab(trashSubjects),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 1: TRASH FREE NOTES
  // ==========================================
  Widget _buildTrashNotesTab(List<FreeNote> notes) {
    if (notes.isEmpty) {
      return _buildEmptyState(
        title: AppStrings.trashEmptyTitle,
        subtitle: AppStrings.isIndonesian
            ? 'Tidak ada catatan yang sedang berada di sampah.'
            : 'There are no notes currently in trash.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final note = notes[index];
        final daysLeft = _calculateDaysRemaining(note.deletedAt);
        final cardColor = Color(
          int.parse('FF${note.colorHex.replaceAll('#', '')}', radix: 16),
        );

        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: NostraColors.borderCard,
              width: 0.9,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title.isNotEmpty
                                ? note.title
                                : AppStrings.untitledNote,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: NostraColors.primaryInk,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Days remaining pill badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE8E8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.clock,
                                  size: 11,
                                  color: NostraColors.deleteRed,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AppStrings.daysRemaining(daysLeft),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: NostraColors.deleteRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Actions: Restore & Delete Permanently
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            LucideIcons.rotateCcw,
                            size: 18,
                            color: NostraColors.primaryInk,
                          ),
                          tooltip: AppStrings.restore,
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await FreeNotesRepository.instance
                                .restoreFromTrash(note.id);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.noteRestored),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            LucideIcons.trash2,
                            size: 18,
                            color: NostraColors.deleteRed,
                          ),
                          tooltip: AppStrings.deletePermanently,
                          onPressed: () {
                            _confirmPermanentDelete(
                              title: note.title.isNotEmpty
                                  ? note.title
                                  : AppStrings.untitledNote,
                              onConfirmed: () => FreeNotesRepository.instance
                                  .permanentlyDelete(note.id),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                if (note.content.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: GoogleKeepRichTextController.buildRichPreviewSpan(
                      note.content.length > 200
                          ? '${note.content.substring(0, 200)}...'
                          : note.content,
                      baseStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: NostraColors.secondaryMuted,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 2: TRASH SUBJECT NOTEBOOKS
  // ==========================================
  Widget _buildTrashSubjectsTab(List<SubjectNotebook> subjects) {
    if (subjects.isEmpty) {
      return _buildEmptyState(
        title: AppStrings.trashEmptyTitle,
        subtitle: AppStrings.isIndonesian
            ? 'Tidak ada mata pelajaran yang sedang berada di sampah.'
            : 'There are no subjects currently in trash.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      itemCount: subjects.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notebook = subjects[index];
        final daysLeft = _calculateDaysRemaining(notebook.deletedAt);

        return Container(
          height: 140,
          decoration: BoxDecoration(
            color: notebook.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: NostraColors.borderCard,
              width: 0.9,
            ),
          ),
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
                                      color: NostraColors.primaryInk,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDE8E8),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    AppStrings.daysRemaining(daysLeft),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: NostraColors.deleteRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              notebook.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: NostraColors.primaryInk,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Restore & Permanent Delete buttons
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: NostraColors.primaryInk,
                                    side: const BorderSide(
                                      color: NostraColors.borderCard,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(LucideIcons.rotateCcw, size: 13),
                                  label: Text(
                                    AppStrings.restore,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  onPressed: () async {
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    await NotebookRepository.instance
                                        .restoreFromTrash(notebook.id);
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppStrings.restoreSubjectSuccess(notebook.title),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: NostraColors.deleteRed,
                                    side: BorderSide(
                                      color: NostraColors.deleteRed.withValues(alpha: 0.2),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(LucideIcons.trash2, size: 13),
                                  label: Text(
                                    AppStrings.delete,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  onPressed: () {
                                    _confirmPermanentDelete(
                                      title: notebook.title,
                                      onConfirmed: () => NotebookRepository
                                          .instance
                                          .permanentlyDelete(notebook.id),
                                    );
                                  },
                                ),
                              ],
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
        );
      },
    );
  }

  Widget _buildEmptyState({
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
                  color: NostraColors.borderCard,
                  width: 0.9,
                ),
              ),
              child: const Icon(
                LucideIcons.trash2,
                size: 36,
                color: NostraColors.secondaryMuted,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: NostraColors.primaryInk,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: NostraColors.secondaryMuted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
