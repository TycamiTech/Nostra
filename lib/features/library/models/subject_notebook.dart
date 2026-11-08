import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/doodle_illustrations.dart';
import '../data/default_subjects_seed.dart';

/// Represents an editorial UTBK subject notebook containing markdown notes and progress.
class SubjectNotebook {
  final String id;
  final String title;
  final String code;
  final String cardColorHex;
  final SubjectDoodleType doodleType;
  final String? markdownContent;
  final String? pdfFilePath;
  final String lastOpenedText;
  final int currentPage;
  final int totalPages;
  final bool isFavorite;
  final DateTime? updatedAt;
  final bool isArchived;
  final bool isDeleted;
  final DateTime? deletedAt;

  const SubjectNotebook({
    required this.id,
    required this.title,
    required this.code,
    required this.cardColorHex,
    required this.doodleType,
    this.markdownContent,
    this.pdfFilePath,
    this.lastOpenedText = 'Baru ditambahkan',
    this.currentPage = 1,
    this.totalPages = 4,
    this.isFavorite = false,
    this.updatedAt,
    this.isArchived = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  /// Convenience getter for Flutter Color from hex string
  Color get cardColor {
    final hex = cardColorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  /// Progress fraction (0.0 to 1.0)
  double get progressFraction =>
      totalPages > 0 ? (currentPage / totalPages).clamp(0.0, 1.0) : 0.0;

  /// Formatted relative date string (e.g., 'Hari ini, 22:50', 'Kemarin, 14:30', or '7 Nov 2026')
  String get formattedLastOpened => DateFormatter.formatRelative(updatedAt);

  SubjectNotebook copyWith({
    String? id,
    String? title,
    String? code,
    String? cardColorHex,
    SubjectDoodleType? doodleType,
    String? markdownContent,
    String? pdfFilePath,
    bool clearPdfFilePath = false,
    String? lastOpenedText,
    int? currentPage,
    int? totalPages,
    bool? isFavorite,
    DateTime? updatedAt,
    bool? isArchived,
    bool? isDeleted,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return SubjectNotebook(
      id: id ?? this.id,
      title: title ?? this.title,
      code: code ?? this.code,
      cardColorHex: cardColorHex ?? this.cardColorHex,
      doodleType: doodleType ?? this.doodleType,
      markdownContent: markdownContent ?? this.markdownContent,
      pdfFilePath:
          clearPdfFilePath ? null : (pdfFilePath ?? this.pdfFilePath),
      lastOpenedText: lastOpenedText ?? this.lastOpenedText,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isFavorite: isFavorite ?? this.isFavorite,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'code': code,
      'cardColorHex': cardColorHex,
      'doodleType': doodleType.name,
      'markdownContent': markdownContent,
      'pdfFilePath': pdfFilePath,
      'lastOpenedText': lastOpenedText,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'isFavorite': isFavorite,
      'updatedAt': updatedAt?.toIso8601String(),
      'isArchived': isArchived,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory SubjectNotebook.fromMap(Map<dynamic, dynamic> map) {
    return SubjectNotebook(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Catatan UTBK',
      code: map['code'] as String? ?? 'UTBK',
      cardColorHex: map['cardColorHex'] as String? ?? '#E8E1EB',
      doodleType: SubjectDoodleType.values.firstWhere(
        (e) => e.name == map['doodleType'],
        orElse: () => SubjectDoodleType.logic,
      ),
      markdownContent: map['markdownContent'] as String?,
      pdfFilePath: map['pdfFilePath'] as String?,
      lastOpenedText: map['lastOpenedText'] as String? ?? 'Baru saja',
      currentPage: (map['currentPage'] as num?)?.toInt() ?? 1,
      totalPages: (map['totalPages'] as num?)?.toInt() ?? 4,
      isFavorite: map['isFavorite'] as bool? ?? false,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
      isArchived: map['isArchived'] as bool? ?? false,
      isDeleted: map['isDeleted'] as bool? ?? false,
      deletedAt: map['deletedAt'] != null
          ? DateTime.tryParse(map['deletedAt'] as String)
          : null,
    );
  }

  /// The 4 default UTBK subjects styled in Mirello Soft Warm pastels
  static List<SubjectNotebook> get defaultSubjects =>
      DefaultSubjectsSeed.defaultSubjects;
}
