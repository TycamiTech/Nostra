import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/nostra_theme.dart';
import '../../annotations/models/toc_item.dart';
import '../../annotations/presentation/search_and_toc_sheet.dart';
import '../../annotations/presentation/sticky_note_overlay.dart';
import '../../library/data/notebook_repository.dart';
import '../../library/models/subject_notebook.dart';
import '../../library/presentation/dual_import_sheet.dart';
import '../data/reader_repository.dart';
import '../models/sticky_note.dart';
import '../services/nostra_markdown_parser.dart';

class ReaderScreen extends StatefulWidget {
  final SubjectNotebook notebook;

  const ReaderScreen({
    super.key,
    required this.notebook,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late SubjectNotebook _notebook;
  late int _currentPage;
  late int _totalPages;
  late List<String> _markdownPages;
  bool _isBookmarked = false;

  late PageController _pageController;
  Offset? _stickyNotePosition;

  final ReaderRepository _readerRepo = ReaderRepository.instance;
  final NotebookRepository _notebookRepo = NotebookRepository.instance;

  @override
  void initState() {
    super.initState();
    _notebook = widget.notebook;
    _loadMarkdownPages();

    // Resume directly from the notebook's last viewed page
    final maxPages = _markdownPages.isNotEmpty ? _markdownPages.length : 1;
    _currentPage = widget.notebook.currentPage.clamp(1, maxPages);
    final initialPageIndex = (_currentPage - 1).clamp(0, maxPages - 1);
    _pageController = PageController(initialPage: initialPageIndex);

    _isBookmarked = _readerRepo.isBookmarked(_notebook.id, _currentPage);
    _notebookRepo.updateCurrentPage(_notebook.id, _currentPage);
  }

  void _loadMarkdownPages() {
    final rawMarkdown = _notebook.markdownContent ?? '';
    _markdownPages = NostraMarkdownParser.splitPages(rawMarkdown);
    _totalPages = _markdownPages.length;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _reloadNotebook() {
    final all = _notebookRepo.getAll();
    final updated = all.firstWhere(
      (n) => n.id == _notebook.id,
      orElse: () => _notebook,
    );
    setState(() {
      _notebook = updated;
      _loadMarkdownPages();
      final maxPages = _markdownPages.isNotEmpty ? _markdownPages.length : 1;
      _currentPage = _currentPage.clamp(1, maxPages);
      _isBookmarked = _readerRepo.isBookmarked(_notebook.id, _currentPage);
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(_currentPage - 1);
    }
  }

  List<TocItem> _buildDynamicToc() {
    final items = <TocItem>[];
    for (int i = 0; i < _markdownPages.length; i++) {
      final title = NostraMarkdownParser.extractPageTitle(
        _markdownPages[i],
        pageIndex: i,
      );
      items.add(TocItem(
        title: title,
        pageNumber: i + 1,
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppSettingsService.instance.languageNotifier,
      builder: (context, language, _) {
        return Scaffold(
      backgroundColor: _notebook.cardColor,
      appBar: _buildTopBar(),
      body: Stack(
        children: [
          // 100% Native Editorial Markdown PageView (Horizontal 120fps Flat Paging)
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: _markdownPages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index + 1;
                  _isBookmarked =
                      _readerRepo.isBookmarked(_notebook.id, _currentPage);
                });
                _notebookRepo.updateCurrentPage(_notebook.id, _currentPage);
              },
              itemBuilder: (context, index) {
                return NostraEditorialPageView(
                  notebook: _notebook,
                  pageMarkdown: _markdownPages[index],
                  pageIndex: index,
                );
              },
            ),
          ),

          // Pinned Draggable Sticky Note Overlay (Can be moved anywhere on screen)
          if (_currentStickyNotes.isNotEmpty)
            Builder(
              builder: (context) {
                final screenSize = MediaQuery.of(context).size;
                final currentNote = _currentStickyNotes.first;
                final noteWidth = currentNote.width;
                final pos = _stickyNotePosition ??
                    Offset(
                      (screenSize.width - (noteWidth + 16.0))
                          .clamp(12.0, 1000.0),
                      20,
                    );

                return Positioned(
                  left: pos.dx.clamp(
                    12.0,
                    (screenSize.width - (noteWidth + 12.0))
                        .clamp(12.0, 1000.0),
                  ),
                  top: pos.dy.clamp(
                    12.0,
                    (screenSize.height - 240.0).clamp(12.0, 2000.0),
                  ),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        final current = _stickyNotePosition ??
                            Offset(
                              (screenSize.width - (noteWidth + 16.0))
                                  .clamp(12.0, 1000.0),
                              20,
                            );
                        final nextX = (current.dx + details.delta.dx).clamp(
                          12.0,
                          (screenSize.width - (noteWidth + 12.0))
                              .clamp(12.0, 1000.0),
                        );
                        final nextY = (current.dy + details.delta.dy).clamp(
                          12.0,
                          (screenSize.height - 240.0).clamp(12.0, 2000.0),
                        );
                        _stickyNotePosition = Offset(nextX, nextY);
                      });
                    },
                    child: StickyNoteWidget(
                      note: currentNote,
                      onEdit: () => _openStickyNoteEditor(
                        existing: currentNote,
                      ),
                      onDelete: () async {
                        await _readerRepo.deleteStickyNote(currentNote.id);
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),

          // Subtle Floating Page Indicator (above bottom floating pill)
          Positioned(
            right: 20,
            bottom: 96,
            child: _buildFloatingPageIndicator(),
          ),

          // Centered Bottom Floating Pill Toolbar (Nostra main menu background #F5F4F0)
          Positioned(
            left: 24,
            right: 24,
            bottom: 22,
            child: _buildBottomPillToolbar(),
          ),
        ],
      ),
    );
      },
    );
  }

  /// Flat Top Header matching the subject's pastel paper color
  PreferredSizeWidget _buildTopBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        decoration: BoxDecoration(
          color: _notebook.cardColor,
          border: const Border(
            bottom: BorderSide(
              color: NostraColors.borderCard,
              width: 1.0,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    LucideIcons.arrowLeft,
                    color: NostraColors.primaryInk,
                    size: 20,
                  ),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${_notebook.title} - ${_notebook.code}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: NostraColors.primaryInk,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    LucideIcons.list,
                    color: NostraColors.primaryInk,
                    size: 20,
                  ),
                  tooltip: AppStrings.isIndonesian
                      ? 'Daftar Isi & Bookmark'
                      : 'Table of Contents & Bookmarks',
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () =>
                      _openSearchAndToc(initialTab: SearchTocTab.toc),
                ),
                IconButton(
                  icon: const Icon(
                    LucideIcons.fileUp,
                    color: NostraColors.primaryInk,
                    size: 20,
                  ),
                  tooltip: AppStrings.isIndonesian
                      ? 'Impor / Tempel Catatan'
                      : 'Import / Paste Notes',
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    DualImportSheet.show(
                      context: context,
                      notebook: _notebook,
                      onImported: _reloadNotebook,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Floating Page Indicator in JetBrains Mono ("1 / 4", 13sp)
  Widget _buildFloatingPageIndicator() {
    return GestureDetector(
      onTap: _showJumpToPageDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: NostraColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: NostraColors.borderCard,
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isBookmarked) ...[
              const Icon(
                LucideIcons.bookMarked,
                size: 13,
                color: Color(0xFFBA1A1A),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              '$_currentPage / $_totalPages',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: NostraColors.primaryInk,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Centered Bottom Floating Pill Toolbar styled with main menu background #F5F4F0
  Widget _buildBottomPillToolbar() {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: NostraColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: NostraColors.borderCard,
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolbarButton(
            icon: LucideIcons.search,
            label: AppStrings.isIndonesian ? 'Cari & Bab' : 'Search & Chapters',
            onTap: () => _openSearchAndToc(initialTab: SearchTocTab.toc),
          ),
          _buildToolbarButton(
            icon: _isBookmarked
                ? LucideIcons.bookMarked
                : LucideIcons.bookmark,
            iconColor: _isBookmarked
                ? const Color(0xFFBA1A1A)
                : NostraColors.primaryInk,
            label: 'Bookmark',
            onTap: _toggleBookmark,
            onLongPress: () =>
                _openSearchAndToc(initialTab: SearchTocTab.bookmarks),
          ),
          _buildToolbarButton(
            icon: LucideIcons.stickyNote,
            iconColor: _currentStickyNotes.isNotEmpty
                ? const Color(0xFFD97706)
                : NostraColors.primaryInk,
            label: 'Sticky Notes',
            onTap: () => _openStickyNoteEditor(),
            onLongPress: _showStickyNotesSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    Color iconColor = NostraColors.primaryInk,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      onLongPress: onLongPress,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: NostraColors.primaryInk,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggles bookmark for current page
  Future<void> _toggleBookmark() async {
    final newState =
        await _readerRepo.toggleBookmark(_notebook.id, _currentPage);
    setState(() {
      _isBookmarked = newState;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: NostraColors.primaryInk,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        content: Text(
          newState
              ? (AppStrings.isIndonesian
                  ? 'Halaman $_currentPage ditandai ke Bookmark.'
                  : 'Page $_currentPage added to Bookmarks.')
              : (AppStrings.isIndonesian
                  ? 'Bookmark halaman $_currentPage dihapus.'
                  : 'Bookmark for page $_currentPage removed.'),
          style: GoogleFonts.plusJakartaSans(
            color: NostraColors.paperSurface,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  /// Sticky notes pinned to the currently viewed page
  List<StickyNote> get _currentStickyNotes =>
      _readerRepo.getNotesForPage(_notebook.id, _currentPage);

  /// Opens the Table of Contents & Search drawer sheet with dynamic titles
  void _openSearchAndToc({SearchTocTab initialTab = SearchTocTab.toc}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchAndTocSheet(
        subjectId: _notebook.id,
        totalPages: _totalPages,
        initialTab: initialTab,
        customTocItems: _buildDynamicToc(),
        onPageSelected: (targetPage) {
          _goToPage(targetPage);
        },
      ),
    );
  }

  /// Opens the minimalist flat square sticky note editor
  void _openStickyNoteEditor({StickyNote? existing}) {
    StickyNoteEditorModal.show(
      context: context,
      subjectId: _notebook.id,
      pageNumber: _currentPage,
      existingNote: existing ??
          (_currentStickyNotes.isNotEmpty ? _currentStickyNotes.first : null),
      onSaved: () {
        setState(() {});
      },
    );
  }

  /// Dialog to jump directly to a page or search page number
  void _showJumpToPageDialog() {
    final textController =
        TextEditingController(text: _currentPage.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: NostraColors.paperSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: NostraColors.borderSubtle, width: 1),
          ),
          title: Text(
            AppStrings.isIndonesian
                ? 'Lompat ke Halaman'
                : 'Jump to Page',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: NostraColors.primaryInk,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.isIndonesian
                    ? 'Masukkan nomor halaman (1 sampai $_totalPages):'
                    : 'Enter page number (1 to $_totalPages):',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: NostraColors.secondaryMuted,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: NostraColors.primaryInk,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFEFECE1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
                backgroundColor: NostraColors.primaryInk,
                foregroundColor: NostraColors.paperSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final targetPage = int.tryParse(textController.text.trim());
                if (targetPage != null &&
                    targetPage >= 1 &&
                    targetPage <= _totalPages) {
                  Navigator.pop(context);
                  _goToPage(targetPage);
                }
              },
              child: Text(
                AppStrings.isIndonesian ? 'Lompat' : 'Jump',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _goToPage(int pageNumber) {
    if (pageNumber >= 1 && pageNumber <= _totalPages) {
      _pageController.animateToPage(
        pageNumber - 1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Sticky Notes Management Modal Sheet
  void _showStickyNotesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final notes =
                _readerRepo.getNotesForPage(_notebook.id, _currentPage);

            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 22,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: NostraColors.paperSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sticky Notes (Hlm. $_currentPage)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: NostraColors.primaryInk,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.plusCircle,
                          size: 20,
                          color: NostraColors.primaryInk,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _openStickyNoteEditor();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (notes.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              LucideIcons.stickyNote,
                              size: 32,
                              color: NostraColors.secondaryMuted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada catatan pada halaman ini.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: NostraColors.secondaryMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: notes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Navigator.pop(context);
                                _openStickyNoteEditor(existing: note);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: note.color,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: note.headerColor.withValues(alpha: 0.6),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        note.content,
                                        style: GoogleFonts.caveat(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: NostraColors.primaryInk,
                                          height: 1.25,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await _readerRepo.deleteStickyNote(note.id);
                                        setModalState(() {});
                                        setState(() {});
                                      },
                                      child: const Icon(
                                        LucideIcons.trash2,
                                        size: 16,
                                        color: NostraColors.secondaryMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NostraColors.primaryInk,
                        foregroundColor: NostraColors.paperSurface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _openStickyNoteEditor();
                      },
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: Text(
                        'Tambah Catatan Baru',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
