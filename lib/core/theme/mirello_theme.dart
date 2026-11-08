import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mirello Soft Warm Color Palette
/// Designed for distraction-free, editorial-grade reading and study organization.
class MirelloColors {
  MirelloColors._();

  // Core surfaces & ink
  static const Color scaffoldBackground = Color(0xFFF5F4F0); // Soft Warm Off-White
  static const Color paperSurface = Color(0xFFF7F3E8); // Warm Cream Paper
  static const Color primaryInk = Color(0xFF1E1E1E); // Deep Charcoal
  static const Color secondaryMuted = Color(0xFF6E6D6A); // Warm Gray

  // Subject Card Pastels
  static const Color pastelLavender = Color(0xFFE8E1EB); // Card Pastel 1 (TPS)
  static const Color pastelSoftBlue = Color(0xFFDCE2EA); // Card Pastel 2 (Literasi B. Inggris / PK)
  static const Color pastelWarmOchre = Color(0xFFEFE5CD); // Card Pastel 3 (Pengetahuan Kuantitatif)
  static const Color pastelSageGreen = Color(0xFFDCE6DF); // Card Pastel 4 (Literasi B. Indonesia)

  // Accents & Highlights
  static const Color highlighterYellow = Color(0xFFF6E08E); // Highlighter Yellow
  static const Color deleteRed = Color(0xFFBA1A1A); // Crimson Delete Red
  static const Color tabPillBackground = Color(0xFFEDEAE2); // Segmented tab pill track
  static const Color borderSubtle = Color(0xFFE3DFD5); // Thin editorial divider
  static const Color borderCard = Color(0x1F1E1E1E); // 12% deep charcoal border
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color surfaceTranslucent = Color(0xCCF7F3E8);
}

/// Editorial Typography System for Mirello UTBK
/// Combines cursive brand flourishes, modern sans-serif UI, classical serifs,
/// and monospace page/progress counters.
class MirelloTextStyles {
  MirelloTextStyles._();

  // Brand Cursive Headers (Satisfy & Pacifico)
  static TextStyle brandHeader({
    double fontSize = 30,
    Color color = MirelloColors.primaryInk,
  }) =>
      GoogleFonts.satisfy(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: 0.5,
      );

  static TextStyle brandHeaderPacifico({
    double fontSize = 26,
    Color color = MirelloColors.primaryInk,
  }) =>
      GoogleFonts.pacifico(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color,
      );

  // Modern UI & Card Titles (Plus Jakarta Sans)
  static TextStyle uiHeadline({
    Color color = MirelloColors.primaryInk,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle uiTitleLarge({
    Color color = MirelloColors.primaryInk,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.3,
      );

  static TextStyle uiTitleMedium({
    Color color = MirelloColors.primaryInk,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: -0.2,
      );

  static TextStyle uiBody({
    Color color = MirelloColors.primaryInk,
    double height = 1.45,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: color,
        height: height,
      );

  static TextStyle uiCaption({
    Color color = MirelloColors.secondaryMuted,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.1,
      );

  static TextStyle uiBadge({
    Color color = MirelloColors.primaryInk,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.4,
      );

  // Classic Editorial & Reading Serif (Newsreader & Lora)
  static TextStyle readingTitle({
    Color color = MirelloColors.primaryInk,
  }) =>
      GoogleFonts.newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: -0.2,
      );

  static TextStyle readingSubtitleSerif({
    Color color = MirelloColors.secondaryMuted,
  }) =>
      GoogleFonts.newsreader(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        color: color,
      );

  static TextStyle readingBodySerif({
    Color color = MirelloColors.primaryInk,
    double height = 1.6,
  }) =>
      GoogleFonts.lora(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color,
        height: height,
      );

  // Page Numbers, Timers & Numerical Metrics (JetBrains Mono)
  static TextStyle monoNumber({
    Color color = MirelloColors.primaryInk,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: 0.3,
      );
}

/// Global Mirello Light Theme configuration
class MirelloTheme {
  MirelloTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: MirelloColors.scaffoldBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: MirelloColors.primaryInk,
        onPrimary: MirelloColors.paperSurface,
        secondary: MirelloColors.secondaryMuted,
        onSecondary: MirelloColors.pureWhite,
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        surface: MirelloColors.paperSurface,
        onSurface: MirelloColors.primaryInk,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: MirelloColors.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: MirelloTextStyles.uiTitleLarge(),
        iconTheme: const IconThemeData(
          color: MirelloColors.primaryInk,
          size: 20,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: MirelloColors.borderCard,
            width: 1.0,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: MirelloColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
