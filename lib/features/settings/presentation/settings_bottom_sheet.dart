import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/nostra_theme.dart';
import '../../backup/presentation/vault_backup_sheet.dart';
import '../../library/presentation/prompt_guide_sheet.dart';
import 'app_mode_screen.dart';
import 'archive_screen.dart';
import 'trash_screen.dart';

/// Bottom sheet displaying Nostra Settings (Pengaturan):
/// - Mode Aplikasi (Normal / Ahli)
/// - Bahasa (Indonesia / English)
/// - Arsip
/// - Sampah (Trash)
/// - Panduan & Template Prompt AI
/// - Cadangan & Berkas Lokal (Vault)
class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => const SettingsBottomSheet(),
    );
  }

  void _showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: NostraColors.paperSurface,
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
                    color: NostraColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppStrings.chooseLanguageTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: NostraColors.primaryInk,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.chooseLanguageDesc,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: NostraColors.secondaryMuted,
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<AppLanguage>(
                valueListenable: AppSettingsService.instance.languageNotifier,
                builder: (context, currentLang, _) {
                  return Column(
                    children: [
                      _buildLanguageOption(
                        title: 'Bahasa Indonesia',
                        flagEmoji: '🇮🇩',
                        isSelected: currentLang == AppLanguage.id,
                        onTap: () async {
                          await AppSettingsService.instance
                              .setLanguage(AppLanguage.id);
                          if (modalCtx.mounted) Navigator.pop(modalCtx);
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildLanguageOption(
                        title: 'English',
                        flagEmoji: '🇬🇧',
                        isSelected: currentLang == AppLanguage.en,
                        onTap: () async {
                          await AppSettingsService.instance
                              .setLanguage(AppLanguage.en);
                          if (modalCtx.mounted) Navigator.pop(modalCtx);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String flagEmoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? NostraColors.tabPillBackground : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? NostraColors.primaryInk
                  : NostraColors.borderCard,
              width: isSelected ? 1.4 : 0.9,
            ),
          ),
          child: Row(
            children: [
              Text(
                flagEmoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: NostraColors.primaryInk,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  LucideIcons.check,
                  size: 18,
                  color: NostraColors.primaryInk,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppSettingsService.instance.languageNotifier,
      builder: (context, language, _) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(
            color: NostraColors.paperSurface,
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
                    color: NostraColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppStrings.settings,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: NostraColors.primaryInk,
                ),
              ),
              const SizedBox(height: 14),

              // Item 1: Mode Aplikasi (Normal vs Ahli)
              ValueListenableBuilder<AppMode>(
                valueListenable: AppSettingsService.instance.modeNotifier,
                builder: (context, currentMode, _) {
                  final isNormal = currentMode == AppMode.normal;
                  return _buildSettingsTile(
                    icon: isNormal ? LucideIcons.notebookPen : LucideIcons.code2,
                    titleRow: Row(
                      children: [
                        Text(
                          AppStrings.appMode,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: NostraColors.primaryInk,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isNormal
                                ? const Color(0xFFDCE6DF)
                                : const Color(0xFFE8E1EB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isNormal
                                ? AppStrings.normalModeBadge
                                : AppStrings.expertModeBadge,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isNormal
                                  ? const Color(0xFF2A5035)
                                  : const Color(0xFF4A2B55),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: isNormal
                        ? AppStrings.normalModeSubtitle
                        : AppStrings.expertModeSubtitle,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppModeScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 10),

              // Item 2: Bahasa (Language)
              _buildSettingsTile(
                icon: LucideIcons.languages,
                titleRow: Row(
                  children: [
                    Text(
                      AppStrings.language,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: NostraColors.primaryInk,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE2EA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppStrings.languageBadge,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E2E40),
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: AppStrings.languageSubtitle,
                onTap: () => _showLanguageModal(context),
              ),
              const SizedBox(height: 10),

              // Item 3: Arsip
              _buildSettingsTile(
                icon: LucideIcons.archive,
                title: AppStrings.archive,
                subtitle: AppStrings.archiveSubtitle,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArchiveScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Item 4: Sampah
              _buildSettingsTile(
                icon: LucideIcons.trash2,
                title: AppStrings.trash,
                subtitle: AppStrings.trashSubtitle,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrashScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Item 5: Panduan & Template Prompt AI
              _buildSettingsTile(
                icon: LucideIcons.bookOpen,
                title: AppStrings.promptGuide,
                subtitle: AppStrings.promptGuideSubtitle,
                onTap: () {
                  Navigator.pop(context);
                  PromptGuideSheet.show(context);
                },
              ),
              const SizedBox(height: 10),

              // Item 6: Cadangan & Berkas Lokal (Vault)
              _buildSettingsTile(
                icon: LucideIcons.hardDrive,
                title: AppStrings.localVault,
                subtitle: AppStrings.localVaultSubtitle,
                onTap: () {
                  Navigator.pop(context);
                  VaultBackupSheet.show(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    Widget? titleRow,
    String? title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: NostraColors.borderCard,
              width: 0.9,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: NostraColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: NostraColors.borderCard,
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: NostraColors.primaryInk,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (titleRow != null)
                      titleRow
                    else
                      Text(
                        title ?? '',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: NostraColors.primaryInk,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: NostraColors.secondaryMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: NostraColors.secondaryMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
