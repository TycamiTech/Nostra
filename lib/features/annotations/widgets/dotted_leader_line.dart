import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/mirello_theme.dart';

/// Renders an editorial Table of Contents row with a dynamic dotted leader line.
/// Format: "BAB 01: Persamaan Linear .......... Hlm. 12"
class DottedLeaderLineRow extends StatelessWidget {
  final String title;
  final int pageNumber;
  final bool isBookmark;
  final VoidCallback onTap;

  const DottedLeaderLineRow({
    super.key,
    required this.title,
    required this.pageNumber,
    this.isBookmark = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // Chapter / Bookmark Title
            Flexible(
              flex: 0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: MirelloColors.primaryInk,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Dynamic Dotted Leader Line filling middle space
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const dotSpacing = 8.0;
                  final count = (constraints.maxWidth / dotSpacing).floor();
                  if (count <= 0) return const SizedBox.shrink();

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      count,
                      (index) => Container(
                        width: 2.2,
                        height: 2.2,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC8C4B8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            // Page Number Indicator (Hlm. 12)
            Text(
              'Hlm. $pageNumber',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: MirelloColors.primaryInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

