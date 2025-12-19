import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/flashcard.dart';

final flashcardProvider =
    StateNotifierProvider<FlashcardNotifier, List<Flashcard>>((ref) {
      return FlashcardNotifier();
    });

class FlashcardNotifier extends StateNotifier<List<Flashcard>> {
  FlashcardNotifier() : super([]) {
    loadFlashcards();
  }

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Get current user ID or fallback to a guest ID
  String get _userId => _auth.currentUser?.uid ?? 'guest_user';

  // LOAD from Firestore
  Future<void> loadFlashcards() async {
    try {
      final snap = await _db
          .collection('users')
          .doc(_userId)
          .collection('flashcards')
          .get();

      state = snap.docs.map((doc) {
        final data = doc.data();
        return Flashcard(
          id: doc.id,
          front: data['front'] ?? '',
          back: data['back'] ?? '',
          isMastered: data['isMastered'] ?? false,
        );
      }).toList();
    } catch (e) {
      print("Error loading flashcards: $e");
    }
  }

  // ADD to Firestore
  Future<void> addCard(String front, String back) async {
    try {
      await _db.collection('users').doc(_userId).set({
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final docRef = _db
          .collection('users')
          .doc(_userId)
          .collection('flashcards')
          .doc(); // Auto-generate ID

      final newCard = Flashcard(id: docRef.id, front: front, back: back);

      await docRef.set(newCard.toMap());
      state = [...state, newCard];
    } catch (e) {
      print("Error adding flashcard: $e");
    }
  }

  // DELETE from Firestore
  Future<void> deleteCard(String id) async {
    try {
      await _db
          .collection('users')
          .doc(_userId)
          .collection('flashcards')
          .doc(id)
          .delete();

      state = state.where((card) => card.id != id).toList();
    } catch (e) {
      print("Error deleting flashcard: $e");
    }
  }
}
