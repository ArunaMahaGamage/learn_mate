class AppUser {
  final String userId;
  final String name;
  final String email;
  final String language;
  final String role;

  AppUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.language,
    required this.role,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'email': email,
    'language': language,
    'role': role,
  };

  static AppUser fromMap(Map<String, dynamic> json) => AppUser(
    userId: json['userId'],
    name: json['name'],
    email: json['email'],
    language: json['language'],
    role: json['role'],
  );
}
