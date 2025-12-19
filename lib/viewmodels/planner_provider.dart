import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/planner_item.dart';

final plannerProvider = StateNotifierProvider<PlannerNotifier, List<PlannerItem>>((ref) {
  return PlannerNotifier();
});

class PlannerNotifier extends StateNotifier<List<PlannerItem>> {
  PlannerNotifier() : super([]) {
    loadInitial();
  }

  final _firestore = FirebaseFirestore.instance;
  final _plannerBox = Hive.box('planner_box');

  Future<void> loadInitial() async {
    // Try offline cache first
    final cached = _plannerBox.get('items', defaultValue: []);
    if (cached is List) {
      state = cached.map((e) => PlannerItem.fromMap(Map<String, dynamic>.from(e))).toList();
    }

    // Fetch online and cache
    try {
      final snap = await _firestore.collection('study_planner').orderBy('date').get();
      final items = snap.docs.map((d) => PlannerItem.fromMap({'id': d.id, ...d.data()})).toList();
      state = items;
      _plannerBox.put('items', items.map((e) => e.toMap()).toList());
    } on FirebaseException catch (e) {
      // Catch Firebase-specific errors
      throw Exception(e);
    } catch (e) {
      // Catch any other errors
      throw Exception('Login failed. Please try again.');
    }
  }

  Future<void> addPlanner(PlannerItem item) async {
    try {
      state = [...state, item];
      await _firestore.collection('study_planner').doc(item.id).set(
          item.toMap());
      await _plannerBox.put('items', state.map((e) => e.toMap()).toList());
    } on FirebaseException catch (e) {
      // Catch Firebase-specific errors
      throw Exception(e);
    } catch (e) {
      // Catch any other errors
      throw Exception('Login failed. Please try again.');
    }
  }

  Future<void> updatePlanner(PlannerItem item) async {
    try {
      state = state.map((p) => p.id == item.id ? item : p).toList();
      await _firestore.collection('study_planner').doc(item.id).update(
          item.toMap());
      await _plannerBox.put('items', state.map((e) => e.toMap()).toList());
    } on FirebaseException catch (e) {
      // Catch Firebase-specific errors
      throw Exception(e);
    } catch (e) {
      // Catch any other errors
      throw Exception('Login failed. Please try again.');
    }
  }

  Future<void> deletePlanner(String id) async {
    try {
      state = state.where((p) => p.id != id).toList();
      await _firestore.collection('study_planner').doc(id).delete();
      await _plannerBox.put('items', state.map((e) => e.toMap()).toList());
    } on FirebaseException catch (e) {
      // Catch Firebase-specific errors
      throw Exception(e);
    } catch (e) {
      // Catch any other errors
      throw Exception('Login failed. Please try again.');
    }
  }
}
