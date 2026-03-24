class PdfItem {
  const PdfItem({
    required this.id,
    required this.name,
    required this.path,
    required this.addedAt,
  });

  final String id;
  final String name;
  final String path;
  final DateTime addedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory PdfItem.fromJson(Map<String, dynamic> json) {
    final added = json['addedAt'] as String?;
    return PdfItem(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      addedAt: added == null ? DateTime.now() : DateTime.parse(added),
    );
  }
}
