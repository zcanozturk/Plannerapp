class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'] as String?;
    final tagsRaw = json['tags'];
    final legacyTag = json['tag'] as String?;
    final tags = tagsRaw is List
        ? tagsRaw.map((item) => item.toString()).toList()
        : (legacyTag == null || legacyTag.isEmpty ? <String>[] : [legacyTag]);
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      tags: tags,
      createdAt:
          created == null ? DateTime.now() : DateTime.parse(created),
    );
  }
}
