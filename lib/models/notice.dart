class Notice {
  final String id;
  final String userId;
  final String message;
  final String type; // reminder/update/system
  final DateTime createdAt;
  final bool read;

  Notice({
    required this.id,
    required this.userId,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.read,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'message': message,
    'type': type,
    'createdAt': createdAt.toIso8601String(),
    'read': read,
  };

  static Notice fromMap(Map<String, dynamic> json) => Notice(
    id: json['id'],
    userId: json['userId'],
    message: json['message'],
    type: json['type'],
    createdAt: DateTime.parse(json['createdAt']),
    read: json['read'] ?? false,
  );
}
