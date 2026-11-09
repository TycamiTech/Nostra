import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/services/app_settings_service.dart';
import '../../../core/theme/nostra_theme.dart';
import '../../library/data/notebook_repository.dart';
import '../../notes/data/free_notes_repository.dart';
import '../services/local_vault_service.dart';

class VaultBackupSheet extends StatefulWidget {
  const VaultBackupSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VaultBackupSheet(),
    );
  }

  @override
  State<VaultBackupSheet> createState() => _VaultBackupSheetState();
}

class _VaultBackupSheetState extends State<VaultBackupSheet> {
  String _vaultPath = AppStrings.loadingFolderLocation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVaultPath();
  }

  Future<void> _loadVaultPath() async {
    try {
      final dir = await LocalVaultService.instance.getVaultDirectory();
      setState(() {
        _vaultPath = dir.path;
      });
    } catch (_) {
      setState(() {
        _vaultPath = 'Documents/Nostra';
      });
    }
  }

  Future<void> _handleBackupAll() async {
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final notebooks = NotebookRepository.instance.getAll();
      final freeNotes = FreeNotesRepository.instance.getAll();

      final count = await LocalVaultService.instance.backupAll(
        notebooks: notebooks,
        freeNotes: freeNotes,
      );

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: NostraColors.primaryInk,
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(
                  LucideIcons.checkCircle2,
                  color: Color(0xFFF6E08E),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.backupSuccess(count),
                    style: GoogleFonts.plusJakartaSans(
                      color: NostraColors.paperSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFBA1A1A),
            behavior: SnackBarBehavior.floating,
            content: Text(
              AppStrings.isIndonesian
                  ? 'Gagal mencadangkan: $e'
                  : 'Failed to backup: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleShareAll() async {
    setState(() => _isLoading = true);
    try {
      final notebooks = NotebookRepository.instance.getAll();
      final freeNotes = FreeNotesRepository.instance.getAll();

      await LocalVaultService.instance.shareAllNotes(
        notebooks: notebooks,
        freeNotes: freeNotes,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFBA1A1A),
            behavior: SnackBarBehavior.floating,
            content: Text(
              AppStrings.isIndonesian
                  ? 'Gagal membagikan berkas: $e'
                  : 'Failed to share files: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRestore() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md', 'txt', 'markdown'],
      );

      if (files.isNotEmpty) {
        final validPaths = files
            .map((f) => f.path)
            .whereType<String>()
            .toList();
        final count = await LocalVaultService.instance.restoreFromFiles(validPaths);

        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: NostraColors.primaryInk,
              behavior: SnackBarBehavior.floating,
              content: Row(
                children: [
                  const Icon(
                    LucideIcons.checkCircle2,
                    color: Color(0xFFF6E08E),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppStrings.restoreSuccess(count),
                      style: GoogleFonts.plusJakartaSans(
                        color: NostraColors.paperSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFBA1A1A),
            behavior: SnackBarBehavior.floating,
            content: Text(
              AppStrings.isIndonesian
                  ? 'Gagal memulihkan berkas: $e'
                  : 'Failed to restore files: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppSettingsService.instance.languageNotifier,
      builder: (context, language, _) {
        return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
      decoration: const BoxDecoration(
        color: NostraColors.paperSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: NostraColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: NostraColors.borderCard,
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  LucideIcons.hardDrive,
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
                      AppStrings.vaultTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: NostraColors.primaryInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.vaultSubtitleShort,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: NostraColors.secondaryMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  LucideIcons.x,
                  size: 20,
                  color: NostraColors.secondaryMuted,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: NostraColors.borderSubtle, thickness: 1),
          const SizedBox(height: 14),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vault Location Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCE6DF).withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFB5C9BB),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.folderCheck,
                              size: 16,
                              color: NostraColors.primaryInk,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.autoMirroringActive,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: NostraColors.primaryInk,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.autoMirroringDesc,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: NostraColors.primaryInk,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: NostraColors.borderCard,
                              width: 0.8,
                            ),
                          ),
                          child: SelectableText(
                            _vaultPath,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: NostraColors.primaryInk,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.vaultSafetyTip,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: NostraColors.primaryInk.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    AppStrings.fileOperations,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: NostraColors.primaryInk,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Option 1: Backup All Now
                  _buildActionTile(
                    icon: LucideIcons.hardDriveDownload,
                    title: AppStrings.syncAllTitle,
                    subtitle: AppStrings.syncAllSubtitle,
                    colorHex: '#DCE2EA',
                    onTap: _isLoading ? null : _handleBackupAll,
                  ),
                  const SizedBox(height: 10),

                  // Option 2: Share / Send All Files (Google Drive, WA, etc)
                  _buildActionTile(
                    icon: LucideIcons.share2,
                    title: AppStrings.shareAllTitle,
                    subtitle: AppStrings.shareAllSubtitle,
                    colorHex: '#E8E1EB',
                    onTap: _isLoading ? null : _handleShareAll,
                  ),
                  const SizedBox(height: 10),

                  // Option 3: Restore Notes from Files
                  _buildActionTile(
                    icon: LucideIcons.uploadCloud,
                    title: AppStrings.restoreTitle,
                    subtitle: AppStrings.restoreSubtitle,
                    colorHex: '#F6E08E',
                    onTap: _isLoading ? null : _handleRestore,
                  ),

                  const SizedBox(height: 16),

                  // Obsidian Info Pill
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFE5CD).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: NostraColors.borderCard,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          LucideIcons.info,
                          size: 15,
                          color: NostraColors.primaryInk,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.vaultCompatibilityFooter,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: NostraColors.primaryInk,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String colorHex,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(13),
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
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: NostraColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: NostraColors.borderCard,
                    width: 0.8,
                  ),
                ),
                child: Icon(icon, size: 18, color: NostraColors.primaryInk),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: NostraColors.primaryInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: NostraColors.secondaryMuted,
                        height: 1.35,
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
