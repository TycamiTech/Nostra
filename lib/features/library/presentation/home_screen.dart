import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/mirello_theme.dart';
import '../../../core/widgets/doodle_illustrations.dart';
import '../../notes/presentation/free_notes_tab.dart';
import '../../reader/presentation/reader_screen.dart';
import '../../settings/presentation/settings_bottom_sheet.dart';
import '../data/notebook_repository.dart';
import '../models/subject_notebook.dart';
import 'add_subject_modal.dart';
import 'dual_import_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  int _favoriteSection = 0; // 0: Modul UTBK, 1: Catatan Bebas
  final NotebookRepository _repository = NotebookRepository.instance;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppSettingsService.instance.languageNotifier,
      builder: (context, language, _) {
        return Scaffold(
          backgroundColor: MirelloColors.scaffoldBackground,
          appBar: _buildEditorialAppBar(),
          body: SafeArea(
            child: _buildCurrentTabBody(language),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  Widget _buildCurrentTabBody(AppLanguage language) {
    switch (_currentTabIndex) {
      case 0:
        return _buildLibraryTab();
      case 1:
        return FreeNotesTab(
          key: ValueKey('freenotes_${language.name}'),
        );
      case 2:
        return _buildFavoritesTab(language);
      default:
        return _buildLibraryTab();
    }
  }

  Widget _buildLibraryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.readyToStudy,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: MirelloColors.primaryInk,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.readyToStudySubtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: MirelloColors.secondaryMuted,
                ),
              ),
            ],
          ),
        ),

        // Subject Card List (Reactive with Hive)
        Expanded(
          child: ValueListenableBuilder<Box>(
            valueListenable: _repository.listenable,
            builder: (context, box, _) {
              final displayedNotebooks = _repository.getAll();

              if (displayedNotebooks.isEmpty) {
                return _buildEmptyState(
                  isFavoritesFilter: false,
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
                physics: const BouncingScrollPhysics(),
                itemCount: displayedNotebooks.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final notebook = displayedNotebooks[index];
                  return _buildSubjectCard(notebook);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab(AppLanguage language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.favoritesCollection,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                  color: MirelloColors.primaryInk,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.favoritesCollectionSubtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: MirelloColors.secondaryMuted,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildFavoriteFilterPill(
                    index: 0,
                    title: AppStrings.filterUtbkModules,
                    icon: LucideIcons.bookOpen,
                  ),
                  const SizedBox(width: 10),
                  _buildFavoriteFilterPill(
                    index: 1,
                    title: AppStrings.filterNotes,
                    icon: LucideIcons.notebookPen,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _favoriteSection == 0
              ? ValueListenableBuilder<Box>(
                  valueListenable: _repository.listenable,
                  builder: (context, box, _) {
                    final favorites = _repository
                        .getAll()
                        .where((item) => item.isFavorite)
                        .toList();

                    if (favorites.isEmpty) {
                      return _buildEmptyState(isFavoritesFilter: true);
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: favorites.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final notebook = favorites[index];
                        return _buildSubjectCard(notebook);
                      },
                    );
                  },
                )
              : FreeNotesTab(
                  onlyFavorites: true,
                  key: ValueKey('fav_freenotes_${language.name}'),
                ),
        ),
      ],
    );
  }

  Widget _buildFavoriteFilterPill({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _favoriteSection == index;
    return InkWell(
      onTap: () {
        setState(() {
          _favoriteSection = index;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? MirelloColors.primaryInk
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? MirelloColors.primaryInk
                : MirelloColors.borderCard,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : MirelloColors.secondaryMuted,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : MirelloColors.secondaryMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Editorial Top Bar with centered Pacifico script
  PreferredSizeWidget _buildEditorialAppBar() {
    return AppBar(
      backgroundColor: MirelloColors.scaffoldBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          LucideIcons.menu,
          color: MirelloColors.primaryInk,
          size: 22,
        ),
        tooltip: AppStrings.menuNostra,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: () => _showMainMenuModal(context),
      ),
      title: Text(
        'Nostra',
        style: GoogleFonts.pacifico(
          fontSize: 26,
          color: MirelloColors.primaryInk,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: [
        if (_currentTabIndex == 0) ...[
          IconButton(
            icon: const Icon(
              LucideIcons.folderPlus,
              color: MirelloColors.primaryInk,
              size: 22,
            ),
            tooltip: AppStrings.addSubject,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () => _showAddSubjectModal(context),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  void _showMainMenuModal(BuildContext context) {
    SettingsBottomSheet.show(context);
  }

  /// Horizontal Subject Card (height: 145, borderRadius: 24, padding: 22)
  Widget _buildSubjectCard(SubjectNotebook notebook) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openReader(notebook),
        onLongPress: () => _showCardActionSheet(notebook),
        child: Ink(
          height: 145,
          decoration: BoxDecoration(
            color: notebook.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: MirelloColors.borderCard,
              width: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Row(
                  children: [
                    // Left side (70% width): Titles, subtitles, metadata
                    Expanded(
                      flex: 7,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Subject Code Pill
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: MirelloColors.scaffoldBackground
                                        .withAlpha(200),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    notebook.code,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: MirelloColors.primaryInk,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Subject Title (Plus Jakarta Sans, 18sp, Bold)
                            Text(
                              notebook.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                                color: MirelloColors.primaryInk,
                                height: 1.15,
                                letterSpacing: -0.3,
                              ),
                            ),

                            // Subtitle with ample space
                            Text(
                              '${notebook.formattedLastOpened} | ${AppStrings.pagePrefix} ${notebook.currentPage}/${notebook.totalPages}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: MirelloColors.secondaryMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right side (30% width): Hand-drawn vector line-art positioned safely below the heart
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(
                          right: 12,
                          top: 26,
                          bottom: 4,
                        ),
                        child: SubjectDoodle(
                          type: notebook.doodleType,
                          width: 88,
                          height: 88,
                        ),
                      ),
                    ),
                  ],
                ),

                // Subtle heart button in top-right
                Positioned(
                  top: 14,
                  right: 14,
                  child: GestureDetector(
                    onTap: () => _repository.toggleFavorite(notebook.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: MirelloColors.scaffoldBackground.withAlpha(160),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notebook.isFavorite
                            ? LucideIcons.heartHandshake
                            : LucideIcons.heart,
                        size: 14,
                        color: notebook.isFavorite
                            ? const Color(0xFFBA1A1A)
                            : MirelloColors.secondaryMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Flat Bottom Navigation Bar with 1px top border
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: MirelloColors.scaffoldBackground,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E0D8),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: LucideIcons.bookOpen,
                label: 'Library',
              ),
              _buildNavItem(
                index: 1,
                icon: LucideIcons.notebookPen,
                label: AppStrings.isIndonesian ? 'Catatan' : 'Notes',
              ),
              _buildNavItem(
                index: 2,
                icon: LucideIcons.heart,
                label: AppStrings.tabFavorites,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentTabIndex == index;
    final color =
        isSelected ? MirelloColors.primaryInk : MirelloColors.secondaryMuted;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          _currentTabIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({bool isFavoritesFilter = false}) {
    if (isFavoritesFilter) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: MirelloColors.paperSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.heartCrack,
                  size: 28,
                  color: MirelloColors.secondaryMuted,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.noFavoriteNotesYet,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MirelloColors.primaryInk,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.noFavoriteNotesDesc,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: MirelloColors.secondaryMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: MirelloColors.paperSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.folderPlus,
                size: 28,
                color: MirelloColors.secondaryMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.noSubjectsYet,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MirelloColors.primaryInk,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.noSubjectsDesc,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: MirelloColors.secondaryMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates directly to the ReaderScreen with a soft editorial fade & slide transition
  void _openReader(SubjectNotebook notebook) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) =>
            ReaderScreen(notebook: notebook),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.04, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  /// Tapping card opens preview / preparation sheet
  void _handleCardTap(SubjectNotebook notebook) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: notebook.cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: MirelloColors.borderCard,
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    notebook.code,
                    style: MirelloTextStyles.monoNumber(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notebook.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: MirelloColors.primaryInk,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.isIndonesian
                    ? '${notebook.totalPages} Halaman Catatan Editorial'
                    : '${notebook.totalPages} Pages of Editorial Notes',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: MirelloColors.secondaryMuted,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MirelloColors.primaryInk,
                        side: const BorderSide(
                          color: MirelloColors.borderSubtle,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        DualImportSheet.show(
                          context: context,
                          notebook: notebook,
                        );
                      },
                      icon: const Icon(LucideIcons.fileUp, size: 16),
                      label: Text(
                        AppStrings.isIndonesian ? 'Impor Catatan' : 'Import Notes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
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
                        Navigator.pop(context);
                        _openReader(notebook);
                      },
                      icon: const Icon(LucideIcons.bookOpen, size: 16),
                      label: Text(
                        AppStrings.isIndonesian ? 'Buka Catatan' : 'Open Notes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Action sheet triggered by long-pressing a subject card
  void _showCardActionSheet(SubjectNotebook notebook) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
              Text(
                AppStrings.isIndonesian
                    ? 'Kelola Catatan: ${notebook.title}'
                    : 'Manage Notes: ${notebook.title}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: MirelloColors.primaryInk,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  LucideIcons.info,
                  color: MirelloColors.primaryInk,
                  size: 20,
                ),
                title: Text(
                  AppStrings.isIndonesian
                      ? 'Lihat Detail & Status Modul'
                      : 'View Module Details & Status',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleCardTap(notebook);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  LucideIcons.fileText,
                  color: MirelloColors.primaryInk,
                  size: 20,
                ),
                title: Text(
                  AppStrings.isIndonesian
                      ? 'Impor / Tempel Catatan Markdown'
                      : 'Import / Paste Markdown Notes',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  DualImportSheet.show(
                    context: context,
                    notebook: notebook,
                  );
                },
              ),
              if (notebook.pdfFilePath != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    LucideIcons.trash2,
                    color: Color(0xFFBA1A1A),
                    size: 20,
                  ),
                  title: Text(
                    AppStrings.isIndonesian
                        ? 'Lepas File PDF (Kembali ke Sample)'
                        : 'Detach PDF File (Reset to Sample)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFBA1A1A),
                    ),
                  ),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    await _repository.updatePdfPath(notebook.id, null);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          AppStrings.isIndonesian
                              ? 'File PDF berhasil dilepas.'
                              : 'PDF file successfully detached.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  notebook.isFavorite ? LucideIcons.heartOff : LucideIcons.heart,
                  color: MirelloColors.primaryInk,
                  size: 20,
                ),
                title: Text(
                  notebook.isFavorite
                      ? AppStrings.removeFromFavorites
                      : AppStrings.addToFavorites,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _repository.toggleFavorite(notebook.id);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  LucideIcons.archive,
                  color: MirelloColors.primaryInk,
                  size: 20,
                ),
                title: Text(
                  notebook.isArchived
                      ? AppStrings.unarchiveNote
                      : AppStrings.archiveNote,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  await _repository.toggleArchive(notebook.id);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        notebook.isArchived
                            ? (AppStrings.isIndonesian
                                ? '"${notebook.title}" dikembalikan dari arsip.'
                                : '"${notebook.title}" restored from archive.')
                            : (AppStrings.isIndonesian
                                ? '"${notebook.title}" berhasil diarsipkan.'
                                : '"${notebook.title}" successfully archived.'),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  LucideIcons.trash2,
                  color: Color(0xFFBA1A1A),
                  size: 20,
                ),
                title: Text(
                  AppStrings.moveToTrash,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFBA1A1A),
                  ),
                ),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: MirelloColors.paperSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      title: Text(
                        AppStrings.isIndonesian
                            ? 'Pindahkan ke Sampah?'
                            : 'Move to Trash?',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: MirelloColors.primaryInk,
                        ),
                      ),
                      content: Text(
                        AppStrings.isIndonesian
                            ? 'Mata pelajaran "${notebook.title}" akan dipindahkan ke Sampah dan disimpan selama 7 hari sebelum dihapus permanen.'
                            : 'Subject "${notebook.title}" will be moved to Trash and stored for 7 days before permanent deletion.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: MirelloColors.secondaryMuted,
                          height: 1.4,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(
                            AppStrings.cancel,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              color: MirelloColors.secondaryMuted,
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
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            AppStrings.isIndonesian ? 'Pindahkan' : 'Move',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && mounted) {
                    await _repository.delete(notebook.id);
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: MirelloColors.primaryInk,
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          AppStrings.isIndonesian
                              ? '"${notebook.title}" dipindahkan ke Sampah.'
                              : '"${notebook.title}" moved to Trash.',
                          style: GoogleFonts.plusJakartaSans(
                            color: MirelloColors.paperSurface,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Modal to add a new custom subject (Mata Pelajaran)
  void _showAddSubjectModal(BuildContext context) {
    AddSubjectModal.show(context);
  }
}
