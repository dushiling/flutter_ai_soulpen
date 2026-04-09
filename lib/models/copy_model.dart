class CopyModel {
  CopyModel({
    required this.id,
    required this.content,
    required this.scene,
    required this.styles,
    required this.createdAt,
    this.isFavorite = false,
    this.isPinned = false,
  });

  final String id;
  String content;
  String scene;
  List<String> styles;
  DateTime createdAt;
  bool isFavorite;
  bool isPinned;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'scene': scene,
      'styles': styles,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
      'isPinned': isPinned,
    };
  }

  factory CopyModel.fromJson(Map map) {
    return CopyModel(
      id: map['id'] as String,
      content: map['content'] as String? ?? '',
      scene: map['scene'] as String? ?? '朋友圈',
      styles: (map['styles'] as List?)?.cast<String>() ?? <String>[],
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      isFavorite: map['isFavorite'] as bool? ?? false,
      isPinned: map['isPinned'] as bool? ?? false,
    );
  }
}
