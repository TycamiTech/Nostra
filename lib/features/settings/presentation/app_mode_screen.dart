import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/nostra_theme.dart';

class AppModeScreen extends StatefulWidget {
  const AppModeScreen({super.key});

  @override
  State<AppModeScreen> createState() => _AppModeScreenState();
}

class _AppModeScreenState extends State<AppModeScreen> {
  final AppSettingsService _settings = AppSettingsService.instance;

  Future<void> _selectMode(AppMode mode) async {
    if (_settings.currentMode == mode) return;

    await _settings.setAppMode(mode);
    setState(() {});

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mode == AppMode.normal
              ? AppStrings.normalModeActivatedSnackBar
              : AppStrings.expertModeActivatedSnackBar,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: NostraColors.primaryInk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: _settings.languageNotifier,
      builder: (context, language, _) {
        return Scaffold(
      backgroundColor: NostraColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: NostraColors.scaffoldBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.arrowLeft,
            color: NostraColors.primaryInk,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.appModeTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: NostraColors.primaryInk,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
          physics: const BouncingScrollPhysics(),
          children: [
            // Header Intro
            Text(
              AppStrings.customizeNoteStyle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: NostraColors.primaryInk,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.customizeNoteStyleDesc,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: NostraColors.secondaryMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),

            // Card 1: Mode Normal (Standar / Pemula)
            _buildModeCard(
              mode: AppMode.normal,
              badgeText: AppStrings.normalCardBadge,
              badgeColor: const Color(0xFFDCE6DF),
              badgeTextColor: const Color(0xFF2A5035),
              icon: LucideIcons.notebookPen,
              iconBgColor: const Color(0xFFE8EFEA),
              title: AppStrings.normalCardTitle,
              tagline: AppStrings.normalCardTagline,
              description: AppStrings.normalCardDesc,
              features: AppStrings.normalCardFeatures,
            ),

            const SizedBox(height: 18),

            // Card 2: Mode Ahli (Expert / Markdown)
            _buildModeCard(
              mode: AppMode.expert,
              badgeText: AppStrings.expertCardBadge,
              badgeColor: const Color(0xFFE8E1EB),
              badgeTextColor: const Color(0xFF4A2B55),
              icon: LucideIcons.code2,
              iconBgColor: const Color(0xFFF3ECF6),
              title: AppStrings.expertCardTitle,
              tagline: AppStrings.expertCardTagline,
              description: AppStrings.expertCardDesc,
              features: AppStrings.expertCardFeatures,
            ),

            const SizedBox(height: 24),

            // Info Card at Bottom
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: NostraColors.borderCard,
                  width: 0.9,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6E08E).withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.info,
                      size: 16,
                      color: NostraColors.primaryInk,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.modeSafetyNotice,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: NostraColors.secondaryMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildModeCard({
    required AppMode mode,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String tagline,
    required String description,
    required List<String> features,
  }) {
    final isSelected = _settings.currentMode == mode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectMode(mode),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? NostraColors.primaryInk
                  : NostraColors.borderCard,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? NostraColors.primaryInk.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Badge & Radio Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? NostraColors.primaryInk
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? NostraColors.primaryInk
                            : NostraColors.borderSubtle,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Icon & Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: NostraColors.primaryInk,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: NostraColors.primaryInk,
                          ),
                        ),
                        Text(
                          tagline,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: NostraColors.secondaryMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  height: 1.45,
                  color: NostraColors.primaryInk.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 14),

              // Divider
              Divider(
                color: NostraColors.borderCard.withValues(alpha: 0.7),
                height: 1,
              ),
              const SizedBox(height: 12),

              // Feature bullets
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.5),
                        child: Icon(
                          isSelected
                              ? LucideIcons.check
                              : LucideIcons.circleDot,
                          size: 13,
                          color: isSelected
                              ? const Color(0xFF2A5035)
                              : NostraColors.secondaryMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: NostraColors.primaryInk,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

