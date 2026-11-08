import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/mirello_theme.dart';
import '../../reader/data/reader_repository.dart';
import '../../reader/models/sticky_note.dart';

/// Preset pastel palette for Sticky Notes
const List<Map<String, String>> kStickyNoteColors = [
  {'label': 'Peach', 'hex': '#F5C6AA'},
  {'label': 'Kuning', 'hex': '#F6E08E'},
  {'label': 'Lavender', 'hex': '#E8E1EB'},
  {'label': 'Biru', 'hex': '#DCE2EA'},
  {'label': 'Sage', 'hex': '#DCE6DF'},
  {'label': 'Ochre', 'hex': '#EFE5CD'},
];

/// Clipper for the dog-ear folded corner shape
class FoldedCornerClipper extends CustomClipper<Path> {
  final double cornerSize;
  const FoldedCornerClipper({this.cornerSize = 22.0});

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(12, 0)
      ..lineTo(size.width - cornerSize, 0)
      ..lineTo(size.width, cornerSize)
      ..lineTo(size.width, size.height - 12)
      ..arcToPoint(
        Offset(size.width - 12, size.height),
        radius: const Radius.circular(12),
      )
      ..lineTo(12, size.height)
      ..arcToPoint(
        Offset(0, size.height - 12),
        radius: const Radius.circular(12),
      )
      ..lineTo(0, 12)
      ..arcToPoint(const Offset(12, 0), radius: const Radius.circular(12))
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Painter for the folded paper corner flap
class FoldedCornerPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;

  const FoldedCornerPainter({
    required this.color,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(shadowPath, shadowPaint);

    final foldPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    final foldPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(foldPath, foldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Customizable Sticky Note Widget supporting multiple sizes, shapes, and pastel colors.
class StickyNoteWidget extends StatelessWidget {
  final StickyNote note;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isInteractive;

  const StickyNoteWidget({
    super.key,
    required this.note,
    this.onEdit,
    this.onDelete,
    this.isInteractive = true,
  });

  int get _maxLines {
    switch (note.size) {
      case StickyNoteSize.small:
        return 4;
      case StickyNoteSize.medium:
        return 5;
      case StickyNoteSize.large:
        return 7;
    }
  }

  Widget _buildContentText() {
    return Text(
      note.content.isEmpty ? 'Tuliskan catatan kilat...' : note.content,
      maxLines: _maxLines,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.caveat(
        fontSize: note.fontSize,
        fontWeight: FontWeight.w600,
        color: MirelloColors.primaryInk,
        height: 1.25,
      ),
    );
  }

  Widget _buildSquare() {
    return Container(
      width: note.width,
      decoration: BoxDecoration(
        color: note.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(2, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Darker header strip
            Container(
              height: 26,
              color: note.headerColor,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.gripHorizontal,
                        size: 12,
                        color: MirelloColors.primaryInk.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'HLM. ${note.pageNumber}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: MirelloColors.primaryInk.withValues(alpha: 0.75),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  if (isInteractive && onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        LucideIcons.x,
                        size: 13,
                        color: MirelloColors.primaryInk.withValues(alpha: 0.75),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: _buildContentText(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRounded() {
    return Container(
      width: note.width,
      decoration: BoxDecoration(
        color: note.color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: note.headerColor.withValues(alpha: 0.7),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 14,
            offset: Offset(2, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: note.headerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.gripHorizontal,
                        size: 10,
                        color: MirelloColors.primaryInk.withValues(alpha: 0.65),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'HLM. ${note.pageNumber}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: MirelloColors.primaryInk.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isInteractive && onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      LucideIcons.x,
                      size: 14,
                      color: MirelloColors.primaryInk.withValues(alpha: 0.65),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildContentText(),
          ],
        ),
      ),
    );
  }

  Widget _buildFolded() {
    const foldSize = 22.0;
    return Container(
      width: note.width,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 12,
            offset: Offset(2, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipPath(
            clipper: const FoldedCornerClipper(cornerSize: foldSize),
            child: Container(
              width: note.width,
              decoration: BoxDecoration(
                color: note.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HLM. ${note.pageNumber}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: MirelloColors.primaryInk.withValues(alpha: 0.65),
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (isInteractive && onDelete != null)
                        Padding(
                          padding: const EdgeInsets.only(right: foldSize + 2),
                          child: GestureDetector(
                            onTap: onDelete,
                            child: Icon(
                              LucideIcons.x,
                              size: 13,
                              color: MirelloColors.primaryInk.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildContentText(),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(foldSize, foldSize),
              painter: FoldedCornerPainter(
                color: note.headerColor,
                shadowColor: const Color(0x28000000),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTape() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: note.width,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: note.color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 10,
                offset: Offset(2, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HLM. ${note.pageNumber}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: MirelloColors.primaryInk.withValues(alpha: 0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (isInteractive && onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        LucideIcons.x,
                        size: 13,
                        color: MirelloColors.primaryInk.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              _buildContentText(),
            ],
          ),
        ),
        // Translucent Washi Tape Strip
        Positioned(
          top: 0,
          left: (note.width / 2) - 28,
          child: Container(
            width: 56,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (note.shape) {
      case StickyNoteShape.square:
        child = _buildSquare();
        break;
      case StickyNoteShape.rounded:
        child = _buildRounded();
        break;
      case StickyNoteShape.folded:
        child = _buildFolded();
        break;
      case StickyNoteShape.tape:
        child = _buildTape();
        break;
    }

    return Transform.rotate(
      angle: -0.035, // Subtle organic paper tilt
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isInteractive ? onEdit : null,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: child,
        ),
      ),
    );
  }
}

/// Modal dialog to create or edit a Sticky Note with live preview and customization of color, size, and shape.
class StickyNoteEditorModal extends StatefulWidget {
  final String subjectId;
  final int pageNumber;
  final StickyNote? existingNote;
  final VoidCallback onSaved;

  const StickyNoteEditorModal({
    super.key,
    required this.subjectId,
    required this.pageNumber,
    this.existingNote,
    required this.onSaved,
  });

  static Future<void> show({
    required BuildContext context,
    required String subjectId,
    required int pageNumber,
    StickyNote? existingNote,
    required VoidCallback onSaved,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StickyNoteEditorModal(
        subjectId: subjectId,
        pageNumber: pageNumber,
        existingNote: existingNote,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<StickyNoteEditorModal> createState() => _StickyNoteEditorModalState();
}

class _StickyNoteEditorModalState extends State<StickyNoteEditorModal> {
  late TextEditingController _textController;
  late String _selectedColorHex;
  late StickyNoteSize _selectedSize;
  late StickyNoteShape _selectedShape;

  final ReaderRepository _readerRepo = ReaderRepository.instance;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.existingNote?.content ?? '',
    );
    _selectedColorHex = widget.existingNote?.colorHex ?? '#F5C6AA';
    _selectedSize = widget.existingNote?.size ?? StickyNoteSize.medium;
    _selectedShape = widget.existingNote?.shape ?? StickyNoteShape.square;

    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final note = StickyNote(
      id: widget.existingNote?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      subjectId: widget.subjectId,
      pageNumber: widget.pageNumber,
      content: text,
      colorHex: _selectedColorHex,
      size: _selectedSize,
      shape: _selectedShape,
      createdAt: widget.existingNote?.createdAt ?? DateTime.now(),
    );

    await _readerRepo.addStickyNote(note);
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final previewNote = StickyNote(
      id: 'preview',
      subjectId: widget.subjectId,
      pageNumber: widget.pageNumber,
      content: _textController.text.trim().isEmpty
          ? 'Tuliskan catatan kilat, rumus, atau pengingat di sini...'
          : _textController.text.trim(),
      colorHex: _selectedColorHex,
      size: _selectedSize,
      shape: _selectedShape,
      createdAt: DateTime.now(),
    );

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Title & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.stickyNote,
                        size: 18,
                        color: MirelloColors.primaryInk,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.existingNote != null
                            ? 'Edit Sticky Note'
                            : 'Sticky Note Baru',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: MirelloColors.primaryInk,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      LucideIcons.x,
                      size: 18,
                      color: MirelloColors.secondaryMuted,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Live Preview Stage
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: MirelloColors.paperSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: MirelloColors.borderCard,
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: StickyNoteWidget(
                    note: previewNote,
                    isInteractive: false,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Text Field Editor
              Container(
                decoration: BoxDecoration(
                  color: previewNote.color.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: previewNote.headerColor.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  autofocus: widget.existingNote == null,
                  style: GoogleFonts.caveat(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: MirelloColors.primaryInk,
                    height: 1.25,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.isIndonesian
                        ? 'Tuliskan rumus cepat atau catatan materi...'
                        : 'Write quick formulas or study notes...',
                    hintStyle: GoogleFonts.caveat(
                      fontSize: 18,
                      color: MirelloColors.secondaryMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Color Customization
              Text(
                AppStrings.isIndonesian ? 'WARNA CATATAN' : 'NOTE COLOR',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: MirelloColors.secondaryMuted,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: kStickyNoteColors.map((item) {
                  final hex = item['hex']!;
                  final isSelected = _selectedColorHex == hex;
                  final colorVal = Color(
                    int.parse('FF${hex.replaceAll('#', '')}', radix: 16),
                  );

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorHex = hex;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorVal,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? MirelloColors.primaryInk
                              : MirelloColors.borderCard,
                          width: isSelected ? 2.4 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: colorVal.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(
                                LucideIcons.check,
                                size: 16,
                                color: MirelloColors.primaryInk,
                              ),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Shape Customization
              Text(
                AppStrings.isIndonesian ? 'BENTUK' : 'SHAPE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: MirelloColors.secondaryMuted,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildShapeOption(
                    shape: StickyNoteShape.square,
                    label: AppStrings.isIndonesian ? 'Kotak' : 'Square',
                    icon: LucideIcons.square,
                  ),
                  const SizedBox(width: 8),
                  _buildShapeOption(
                    shape: StickyNoteShape.rounded,
                    label: AppStrings.isIndonesian ? 'Membulat' : 'Rounded',
                    icon: LucideIcons.circleDot,
                  ),
                  const SizedBox(width: 8),
                  _buildShapeOption(
                    shape: StickyNoteShape.folded,
                    label: AppStrings.isIndonesian ? 'Lipat' : 'Folded',
                    icon: LucideIcons.fileText,
                  ),
                  const SizedBox(width: 8),
                  _buildShapeOption(
                    shape: StickyNoteShape.tape,
                    label: AppStrings.isIndonesian ? 'Pita' : 'Tape',
                    icon: LucideIcons.bookmark,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Size Customization
              Text(
                AppStrings.isIndonesian ? 'UKURAN' : 'SIZE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: MirelloColors.secondaryMuted,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildSizeOption(
                    size: StickyNoteSize.small,
                    label: AppStrings.isIndonesian ? 'Kecil' : 'Small',
                  ),
                  const SizedBox(width: 8),
                  _buildSizeOption(
                    size: StickyNoteSize.medium,
                    label: AppStrings.isIndonesian ? 'Sedang' : 'Medium',
                  ),
                  const SizedBox(width: 8),
                  _buildSizeOption(
                    size: StickyNoteSize.large,
                    label: AppStrings.isIndonesian ? 'Besar' : 'Large',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bottom Actions
              Row(
                children: [
                  if (widget.existingNote != null)
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFBA1A1A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await _readerRepo.deleteStickyNote(
                          widget.existingNote!.id,
                        );
                        widget.onSaved();
                        navigator.pop();
                      },
                      child: Text(
                        AppStrings.delete,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: MirelloColors.secondaryMuted,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppStrings.cancel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MirelloColors.primaryInk,
                      foregroundColor: MirelloColors.paperSurface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onPressed: _handleSave,
                    child: Text(
                      widget.existingNote != null
                          ? AppStrings.save
                          : (AppStrings.isIndonesian ? 'Tempel' : 'Attach'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
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

  Widget _buildShapeOption({
    required StickyNoteShape shape,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedShape == shape;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedShape = shape;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? MirelloColors.primaryInk
                : MirelloColors.paperSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? MirelloColors.primaryInk
                  : MirelloColors.borderCard,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : MirelloColors.primaryInk,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : MirelloColors.primaryInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeOption({
    required StickyNoteSize size,
    required String label,
  }) {
    final isSelected = _selectedSize == size;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSize = size;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? MirelloColors.primaryInk
                : MirelloColors.paperSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? MirelloColors.primaryInk
                  : MirelloColors.borderCard,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : MirelloColors.primaryInk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
