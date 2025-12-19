class PlannerItem {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime date;
  final String status; // pending/completed
  final List<String> tasks;

  PlannerItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    required this.tasks,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
    'status': status,
    'tasks': tasks,
  };

  static PlannerItem fromMap(Map<String, dynamic> json) => PlannerItem(
    id: json['id'],
    userId: json['userId'],
    title: json['title'],
    description: json['description'],
    date: DateTime.parse(json['date']),
    status: json['status'],
    tasks: (json['tasks'] as List).map((e) => e.toString()).toList(),
  );
}
