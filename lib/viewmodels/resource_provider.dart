import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/lesson.dart';

final resourcesProvider = StateNotifierProvider<ResourcesNotifier, List<Lesson>>((ref) {
  return ResourcesNotifier();
});

class ResourcesNotifier extends StateNotifier<List<Lesson>> {
  ResourcesNotifier() : super([]) {
    //loadInitial();
  }

  final _firestore = FirebaseFirestore.instance;
  final _box = Hive.box('resources_box');

  Future<void> loadInitial() async {
    // Offline first
    final cached = _box.get('list', defaultValue: []);
    if (cached is List) {
      state = cached.map((e) => Lesson.fromMap(Map<String, dynamic>.from(e))).toList();
    }

    // Online sync
    final snap = await _firestore.collection('resources').orderBy('createdAt', descending: true).get();
    final list = snap.docs.map((d) => Lesson.fromMap({'id': d.id, ...d.data()})).toList();
    state = list;
    _box.put('list', list.map((e) => e.toMap()).toList());
  }

  Future<void> loadSubject(String subject) async {

    try {
      // Offline first
      final cached = _box.get('list$subject', defaultValue: []);
      if (cached is List) {
        state = cached
            .map((e) => Lesson.fromMap(Map<String, dynamic>.from(e)))
            .where((lesson) => lesson.subject == subject)
            .toList();
      }
    } catch(e) {
      print(e);
    }

    try {
      // Online sync
      final snap = await _firestore
          .collection('resources')
          .where(
          'subject', isEqualTo: subject)
          //.orderBy('createdAt', descending: true)
          .get();
      final list = snap.docs.map((d) =>
          Lesson.fromMap({'id': d.id, ...d.data()})).toList();
      state = list;
      _box.put('list$subject', list.map((e) => e.toMap()).toList());
    } catch(e) {
      print(e);
    }
  }

  Future<void> addResource(Lesson lesson) async {
    state = [lesson, ...state];
    await _firestore.collection('resources').doc(lesson.id).set(lesson.toMap());
    _box.put('list', state.map((e) => e.toMap()).toList());
  }

  Future<void> deleteResource(String id) async {
    state = state.where((r) => r.id != id).toList();
    await _firestore.collection('resources').doc(id).delete();
    _box.put('list', state.map((e) => e.toMap()).toList());
  }
}
