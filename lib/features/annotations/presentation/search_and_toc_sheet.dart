import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/nostra_theme.dart';
import '../../reader/data/reader_repository.dart';
import '../models/toc_item.dart';
import '../widgets/corner_doodles.dart';
import '../widgets/dotted_leader_line.dart';

enum SearchTocTab { toc, bookmarks }

class SearchAndTocSheet extends StatefulWidget {
  final String subjectId;
  final int totalPages;
  final SearchTocTab initialTab;
  final ValueChanged<int> onPageSelected;
  final List<TocItem>? customTocItems;

  const SearchAndTocSheet({
    super.key,
    required this.subjectId,
    required this.totalPages,
    this.initialTab = SearchTocTab.toc,
    required this.onPageSelected,
    this.customTocItems,
  });

  @override
  State<SearchAndTocSheet> createState() => _SearchAndTocSheetState();
}

class _SearchAndTocSheetState extends State<SearchAndTocSheet> {
  late SearchTocTab _activeTab;
  final TextEditingController _searchController = TextEditingController();
  final ReaderRepository _readerRepo = ReaderRepository.instance;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TocItem> _getBookmarks() {
    final list = <TocItem>[];
    for (int p = 1; p <= widget.totalPages; p++) {
      if (_readerRepo.isBookmarked(widget.subjectId, p)) {
        list.add(
          TocItem(
            title: AppStrings.isIndonesian
                ? 'Halaman Ditandai #$p'
                : 'Bookmarked Page #$p',
            pageNumber: p,
            isBookmark: true,
          ),
        );
      }
    }
    return list;
  }

  List<TocItem> _getItemsForDisplay() {
    final defaultToc = widget.customTocItems ??
        TocItem.getChaptersForSubject(widget.subjectId);
    final all = _activeTab == SearchTocTab.toc
        ? defaultToc
        : _getBookmarks();

    if (_searchQuery.isEmpty) return all;

    return all.where((item) {
      final matchTitle = item.title.toLowerCase().contains(_searchQuery);
      final matchPage = item.pageNumber.toString().contains(_searchQuery);
      return matchTitle || matchPage;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedItems = _getItemsForDisplay();

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: NostraColors.scaffoldBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Stack(
          children: [
            // Hand-drawn Corner Line-Art Doodles (Top corners)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 60,
              child: CustomPaint(
                painter: TopCornerDoodlesPainter(),
              ),
            ),

            // Main Content Layout
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Center Pull Handle
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
                  const SizedBox(height: 18),

                  // Top Search Bar with rounded pill input and lavender square button
                  _buildTopSearchBar(),
                  const SizedBox(height: 14),

                  // Segmented Tabs ("Daftar Isi" & "Bookmark")
                  _buildSegmentedTabSelector(),
                  const SizedBox(height: 16),

                  // Content List
                  Expanded(
                    child: displayedItems.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: displayedItems.length,
                            separatorBuilder: (context, index) =>
                                const Divider(
                              color: Color(0xFFEBE7DD),
                              height: 1,
                              thickness: 0.8,
                            ),
                            itemBuilder: (context, index) {
                              final item = displayedItems[index];
                              return DottedLeaderLineRow(
                                title: item.title,
                                pageNumber: item.pageNumber,
                                isBookmark: item.isBookmark,
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onPageSelected(item.pageNumber);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSearchBar() {
    return Row(
      children: [
        // Rounded pill input (#EAE8E1, borderRadius: 16)
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEAE8E1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: NostraColors.borderSubtle,
                width: 0.8,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: NostraColors.primaryInk,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.isIndonesian
                    ? 'Cari di dokumen...'
                    : 'Search document...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: NostraColors.secondaryMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          LucideIcons.x,
                          size: 16,
                          color: NostraColors.secondaryMuted,
                        ),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Soft lavender square search button (#D8CEE6) with LucideIcons.search
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFD8CEE6), // Soft lavender
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: NostraColors.borderCard,
              width: 0.8,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              LucideIcons.search,
              size: 20,
              color: NostraColors.primaryInk,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              FocusScope.of(context).unfocus();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE8E1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              tab: SearchTocTab.toc,
              label: AppStrings.isIndonesian ? 'Daftar Isi' : 'Table of Contents',
              icon: LucideIcons.listTree,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              tab: SearchTocTab.bookmarks,
              label: 'Bookmark',
              icon: LucideIcons.bookMarked,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required SearchTocTab tab,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _activeTab == tab;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? NostraColors.paperSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? NostraColors.primaryInk
                  : NostraColors.secondaryMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? NostraColors.primaryInk
                    : NostraColors.secondaryMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isBookmarkTab = _activeTab == SearchTocTab.bookmarks;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBookmarkTab ? LucideIcons.bookmark : LucideIcons.searchX,
              size: 28,
              color: NostraColors.secondaryMuted,
            ),
            const SizedBox(height: 12),
            Text(
              isBookmarkTab
                  ? (AppStrings.isIndonesian
                      ? 'Belum ada halaman yang ditandai'
                      : 'No bookmarked pages yet')
                  : (AppStrings.isIndonesian
                      ? 'Bab atau halaman tidak ditemukan'
                      : 'Chapter or page not found'),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NostraColors.primaryInk,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isBookmarkTab
                  ? (AppStrings.isIndonesian
                      ? 'Gunakan tombol Bookmark pada bilah bawah pembaca untuk menyimpan halaman favorit.'
                      : 'Use the Bookmark button on the bottom bar to save favorite pages.')
                  : (AppStrings.isIndonesian
                      ? 'Coba gunakan kata kunci bab atau nomor halaman lain.'
                      : 'Try using different chapter titles or page numbers.'),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: NostraColors.secondaryMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

