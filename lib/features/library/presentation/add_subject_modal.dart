import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/mirello_theme.dart';
import '../../../core/widgets/doodle_illustrations.dart';
import '../data/notebook_repository.dart';
import '../models/subject_notebook.dart';

/// Modal bottom sheet to create a new custom Mata Pelajaran (UTBK Subject)
class AddSubjectModal extends StatefulWidget {
  const AddSubjectModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddSubjectModal(),
    );
  }

  @override
  State<AddSubjectModal> createState() => _AddSubjectModalState();
}

class _AddSubjectModalState extends State<AddSubjectModal> {
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();

  int _selectedColorIndex = 0;
  int _selectedDoodleIndex = 0;

  List<(String, String, Color)> get _colorOptions => [
    ('#E8E1EB', 'Lavender', MirelloColors.pastelLavender),
    ('#DCE2EA', AppStrings.isIndonesian ? 'Biru Muda' : 'Soft Blue', MirelloColors.pastelSoftBlue),
    ('#EFE5CD', 'Ochre', MirelloColors.pastelWarmOchre),
    ('#DCE6DF', 'Sage Green', MirelloColors.pastelSageGreen),
  ];

  List<(SubjectDoodleType, String)> get _doodleOptions => [
    (SubjectDoodleType.logic, AppStrings.isIndonesian ? 'Logika' : 'Logic'),
    (SubjectDoodleType.math, AppStrings.isIndonesian ? 'Kuantitatif' : 'Math'),
    (SubjectDoodleType.reading, AppStrings.isIndonesian ? 'Literasi' : 'Literacy'),
    (SubjectDoodleType.calculus, AppStrings.isIndonesian ? 'Kalkulus' : 'Calculus'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _saveSubject() async {
    final title = _titleController.text.trim();
    final code = _codeController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: MirelloColors.deleteRed,
          behavior: SnackBarBehavior.floating,
          content: Text(
            AppStrings.subjectNameEmptyError,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
      );
      return;
    }

    final uniqueId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final finalCode = code.isNotEmpty
        ? code
        : 'C-${(DateTime.now().millisecondsSinceEpoch % 100).toString().padLeft(2, '0')}';
    final selectedColor = _colorOptions[_selectedColorIndex].$1;
    final selectedDoodle = _doodleOptions[_selectedDoodleIndex].$1;

    final newNotebook = SubjectNotebook(
      id: uniqueId,
      title: title,
      code: finalCode,
      cardColorHex: selectedColor,
      doodleType: selectedDoodle,
      lastOpenedText: AppStrings.isIndonesian ? 'Baru ditambahkan' : 'Recently added',
      currentPage: 1,
      totalPages: 4,
      updatedAt: DateTime.now(),
    );

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await NotebookRepository.instance.save(newNotebook);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: MirelloColors.primaryInk,
        behavior: SnackBarBehavior.floating,
        content: Text(
          AppStrings.subjectAddedSuccess(title),
          style: GoogleFonts.plusJakartaSans(
            color: MirelloColors.paperSurface,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        decoration: const BoxDecoration(
          color: MirelloColors.paperSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
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
              Text(
                AppStrings.addNewSubjectTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: MirelloColors.primaryInk,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.addNewSubjectSubtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: MirelloColors.secondaryMuted,
                ),
              ),
              const SizedBox(height: 20),

              // Title field
              Text(
                AppStrings.subjectNameLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MirelloColors.primaryInk,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: MirelloColors.primaryInk,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.subjectNameHint,
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: MirelloColors.secondaryMuted,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFEAE8E1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Code field
              Text(
                AppStrings.shortCodeLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MirelloColors.primaryInk,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _codeController,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: MirelloColors.primaryInk,
                ),
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: AppStrings.shortCodeHint,
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: MirelloColors.secondaryMuted,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFEAE8E1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Color Picker
              Text(
                AppStrings.cardColorLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MirelloColors.primaryInk,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(_colorOptions.length, (index) {
                  final (_, label, color) = _colorOptions[index];
                  final isSelected = _selectedColorIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          right: index < _colorOptions.length - 1 ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? MirelloColors.primaryInk
                                : MirelloColors.borderCard,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: MirelloColors.primaryInk,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Doodle Picker
              Text(
                AppStrings.cardIllustrationLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MirelloColors.primaryInk,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(_doodleOptions.length, (index) {
                  final (type, label) = _doodleOptions[index];
                  final isSelected = _selectedDoodleIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDoodleIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          right: index < _doodleOptions.length - 1 ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _colorOptions[_selectedColorIndex].$3
                              : MirelloColors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? MirelloColors.primaryInk
                                : MirelloColors.borderCard,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            SubjectDoodle(
                              type: type,
                              width: 36,
                              height: 36,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: MirelloColors.primaryInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
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
                  onPressed: _saveSubject,
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: Text(
                    AppStrings.addSubjectBtn,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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

