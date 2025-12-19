class Lesson {
  final String id;
  final String title;
  final String subject;
  final String type; // pdf/video/article
  final String downloadUrl;
  final bool offlineAvailable;
  final DateTime createdAt;

  Lesson({
    required this.id,
    required this.title,
    required this.subject,
    required this.type,
    required this.downloadUrl,
    required this.offlineAvailable,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subject': subject,
    'type': type,
    'downloadUrl': downloadUrl,
    'offlineAvailable': offlineAvailable,
    'createdAt': createdAt.toIso8601String(),
  };

  static Lesson fromMap(Map<String, dynamic> json) => Lesson(
    id: json['id'],
    title: json['title'],
    subject: json['subject'],
    type: json['type'],
    downloadUrl: json['downloadUrl'],
    offlineAvailable: json['offlineAvailable'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
  );
}
