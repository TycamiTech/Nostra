import 'package:flutter/material.dart';

enum StickyNoteSize {
  small,
  medium,
  large,
}

enum StickyNoteShape {
  square, // Classic square with header strip
  rounded, // Organic pill rounded shape
  folded, // Dog-ear folded corner
  tape, // Washi tape header
}

class StickyNote {
  final String id;
  final String subjectId;
  final int pageNumber;
  final String content;
  final String colorHex;
  final StickyNoteSize size;
  final StickyNoteShape shape;
  final DateTime createdAt;

  const StickyNote({
    required this.id,
    required this.subjectId,
    required this.pageNumber,
    required this.content,
    this.colorHex = '#F5C6AA', // Default Warm Peach
    this.size = StickyNoteSize.medium,
    this.shape = StickyNoteShape.square,
    required this.createdAt,
  });

  Color get color {
    final hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  /// Darker tint for header strips or folded dog-ear corner
  Color get headerColor {
    final c = color;
    return Color.fromARGB(
      (c.a * 255.0).round().clamp(0, 255),
      (c.r * 255.0 * 0.88).round().clamp(0, 255),
      (c.g * 255.0 * 0.88).round().clamp(0, 255),
      (c.b * 255.0 * 0.88).round().clamp(0, 255),
    );
  }

  double get width {
    switch (size) {
      case StickyNoteSize.small:
        return 150.0;
      case StickyNoteSize.medium:
        return 185.0;
      case StickyNoteSize.large:
        return 230.0;
    }
  }

  double get fontSize {
    switch (size) {
      case StickyNoteSize.small:
        return 15.5;
      case StickyNoteSize.medium:
        return 17.5;
      case StickyNoteSize.large:
        return 19.5;
    }
  }

  StickyNote copyWith({
    String? id,
    String? subjectId,
    int? pageNumber,
    String? content,
    String? colorHex,
    StickyNoteSize? size,
    StickyNoteShape? shape,
    DateTime? createdAt,
  }) {
    return StickyNote(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      pageNumber: pageNumber ?? this.pageNumber,
      content: content ?? this.content,
      colorHex: colorHex ?? this.colorHex,
      size: size ?? this.size,
      shape: shape ?? this.shape,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'pageNumber': pageNumber,
        'content': content,
        'colorHex': colorHex,
        'size': size.name,
        'shape': shape.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory StickyNote.fromMap(Map<dynamic, dynamic> map) => StickyNote(
        id: map['id'] as String,
        subjectId: map['subjectId'] as String,
        pageNumber: (map['pageNumber'] as num).toInt(),
        content: map['content'] as String,
        colorHex: map['colorHex'] as String? ?? '#F5C6AA',
        size: StickyNoteSize.values.firstWhere(
          (e) => e.name == map['size'],
          orElse: () => StickyNoteSize.medium,
        ),
        shape: StickyNoteShape.values.firstWhere(
          (e) => e.name == map['shape'],
          orElse: () => StickyNoteShape.square,
        ),
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
