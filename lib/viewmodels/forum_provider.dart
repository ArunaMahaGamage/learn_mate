import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String userId;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'content': content,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
  };

  static Question fromMap(Map<String, dynamic> json) => Question(
    id: json['id'],
    userId: json['userId'],
    title: json['title'],
    content: json['content'],
    tags: (json['tags'] as List).map((e) => e.toString()).toList(),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

final forumProvider = StateNotifierProvider<ForumNotifier, List<Question>>((
  ref,
) {
  return ForumNotifier();
});

class ForumNotifier extends StateNotifier<List<Question>> {
  ForumNotifier() : super([]) {
    load();
  }

  final _firestore = FirebaseFirestore.instance;

  Future<void> load() async {
    final snap = await _firestore
        .collection('forum')
        .orderBy('createdAt', descending: true)
        .get();
    state = snap.docs
        .map((d) => Question.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> addQuestion(Question q) async {
    state = [q, ...state];
    await _firestore.collection('forum').doc(q.id).set(q.toMap());
  }

  Future<void> addAnswer(String questionId, Map<String, dynamic> answer) async {
    await _firestore
        .collection('forum')
        .doc(questionId)
        .collection('answers')
        .add(answer);
  }
}
