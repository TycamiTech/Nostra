import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/mirello_theme.dart';
import '../../models/free_note.dart';

/// Bottom sheet modal to select the background accent color for a FreeNote.
class NoteColorPickerSheet extends StatelessWidget {
  final String selectedColorHex;
  final ValueChanged<String> onColorSelected;

  const NoteColorPickerSheet({
    super.key,
    required this.selectedColorHex,
    required this.onColorSelected,
  });

  /// Displays the modal sheet and returns the selected color hex (or null if dismissed).
  static Future<String?> show(
    BuildContext context, {
    required String currentColorHex,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteColorPickerSheet(
        selectedColorHex: currentColorHex,
        onColorSelected: (hex) => Navigator.of(context).pop(hex),
      ),
    );
  }

  /// Parses a hex string (#RRGGBB or #AARRGGBB) into a [Color].
  static Color parseHex(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return MirelloColors.paperSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: MirelloColors.paperSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          const SizedBox(height: 14),
          Text(
            'Pilih Warna Catatan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: MirelloColors.primaryInk,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: FreeNote.presetColors.map((colorHex) {
                final color = parseHex(colorHex);
                final isSelected =
                    selectedColorHex.toUpperCase() == colorHex.toUpperCase();
                return GestureDetector(
                  onTap: () => onColorSelected(colorHex),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? MirelloColors.primaryInk
                            : MirelloColors.borderCard,
                        width: isSelected ? 2.5 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(
                            LucideIcons.check,
                            size: 20,
                            color: MirelloColors.primaryInk,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

