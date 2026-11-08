class FreeNote {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String colorHex;
  final bool isPinned;
  final bool isFavorite;
  final List<String> imagePaths;
  final bool isArchived;
  final bool isDeleted;
  final DateTime? deletedAt;

  const FreeNote({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.colorHex = '#FFFDF8',
    this.isPinned = false,
    this.isFavorite = false,
    this.imagePaths = const [],
    this.isArchived = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  FreeNote copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? colorHex,
    bool? isPinned,
    bool? isFavorite,
    List<String>? imagePaths,
    bool? isArchived,
    bool? isDeleted,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return FreeNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      colorHex: colorHex ?? this.colorHex,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      imagePaths: imagePaths ?? this.imagePaths,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'colorHex': colorHex,
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'imagePaths': imagePaths,
      'isArchived': isArchived,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory FreeNote.fromMap(Map<dynamic, dynamic> map) {
    List<String> images = const [];
    if (map['imagePaths'] is List) {
      images = (map['imagePaths'] as List).map((e) => e.toString()).toList();
    }

    return FreeNote(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      colorHex: map['colorHex']?.toString() ?? '#FFFDF8',
      isPinned: map['isPinned'] == true,
      isFavorite: map['isFavorite'] == true,
      imagePaths: images,
      isArchived: map['isArchived'] == true,
      isDeleted: map['isDeleted'] == true,
      deletedAt: map['deletedAt'] != null
          ? DateTime.tryParse(map['deletedAt'].toString())
          : null,
    );
  }

  /// Preset pastel colors matching Nostra editorial theme
  static const List<String> presetColors = [
    '#FFFDF8', // Paper Surface (Clean Cream)
    '#F6E08E', // Mustard / Highlighter Yellow
    '#F5C6AA', // Soft Peach / Warm Coral
    '#DCE6DF', // Sage Green / Mint
    '#DCE2EA', // Soft Glacier Blue
    '#E8E1EB', // Lavender Purple
    '#EFE5CD', // Warm Ochre / Vintage Linen
  ];
}
