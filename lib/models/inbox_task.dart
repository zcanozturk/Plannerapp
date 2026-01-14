class InboxTask {
  const InboxTask({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
    };
  }

  factory InboxTask.fromJson(Map<String, dynamic> json) {
    return InboxTask(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
    );
  }
}
