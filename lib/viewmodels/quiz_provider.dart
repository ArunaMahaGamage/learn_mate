import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/quiz.dart';

class QuizTakingState {
  final Quiz? activeQuiz;
  final Map<String, int> userAnswers;
  final QuizResult? result;

  QuizTakingState({this.activeQuiz, required this.userAnswers, this.result});

  QuizTakingState copyWith({
    Quiz? activeQuiz,
    Map<String, int>? userAnswers,
    QuizResult? result,
  }) {
    return QuizTakingState(
      activeQuiz: activeQuiz ?? this.activeQuiz,
      userAnswers: userAnswers ?? this.userAnswers,
      result: result,
    );
  }
}

final quizListProvider = StateNotifierProvider<QuizListNotifier, List<Quiz>>(
  (ref) => QuizListNotifier(),
);

final quizTakingProvider =
    StateNotifierProvider<QuizTakingNotifier, QuizTakingState>(
      (ref) => QuizTakingNotifier(),
    );

class QuizListNotifier extends StateNotifier<List<Quiz>> {
  QuizListNotifier() : super([]) {
    loadQuizzes();
  }

  final _firestore = FirebaseFirestore.instance.collection('quizzes');
  final _quizBox = Hive.box('quiz_box');

  Future<void> loadQuizzes() async {
    // 1. Immediately load from Hive for instant UI
    final cachedData = _quizBox.get('cached_quizzes');
    if (cachedData != null && cachedData is Map) {
      try {
        final List<Quiz> cachedQuizzes = [];
        cachedData.forEach((key, value) {
          // FIX: Use .cast<String, dynamic>() to handle Hive's Map<dynamic, dynamic>
          final Map<String, dynamic> typedMap = Map<dynamic, dynamic>.from(
            value,
          ).cast<String, dynamic>();
          cachedQuizzes.add(Quiz.fromMap({...typedMap, 'id': key.toString()}));
        });
        state = cachedQuizzes;
      } catch (e) {
        print("Error parsing Hive cache: $e");
      }
    }

    try {
      // 2. Try to fetch from Firestore to update the cache
      final snap = await _firestore.orderBy('title').get();
      final quizzes = snap.docs
          .map((d) => Quiz.fromMap({'id': d.id, ...d.data()}))
          .toList();

      state = quizzes;
      _updateLocalCache();
    } catch (e) {
      print("Offline mode or Network error: Using existing Hive data");
    }
  }

  Future<void> addQuiz(Quiz quiz) async {
    state = [quiz, ...state];
    _updateLocalCache();

    try {
      _firestore.doc(quiz.id).set(quiz.toMap());
    } catch (e) {
      print("Firestore background sync queued: $e");
    }
  }

  Future<void> updateQuiz(Quiz updatedQuiz) async {
    state = state.map((q) => q.id == updatedQuiz.id ? updatedQuiz : q).toList();
    _updateLocalCache();

    try {
      _firestore.doc(updatedQuiz.id).update(updatedQuiz.toMap());
    } catch (e) {
      print("Update queued: $e");
    }
  }

  Future<void> deleteQuiz(String id) async {
    state = state.where((q) => q.id != id).toList();
    _updateLocalCache();

    try {
      _firestore.doc(id).delete();
    } catch (e) {
      print("Delete queued: $e");
    }
  }

  void _updateLocalCache() {
    final Map<String, dynamic> quizCache = {};
    for (var quiz in state) {
      quizCache[quiz.id] = quiz.toMap();
    }
    _quizBox.put('cached_quizzes', quizCache);
  }
}

class QuizTakingNotifier extends StateNotifier<QuizTakingState> {
  QuizTakingNotifier() : super(QuizTakingState(userAnswers: {}));

  void startQuiz(Quiz quiz) {
    state = QuizTakingState(activeQuiz: quiz, userAnswers: {});
  }

  void selectAnswer(String questionId, int selectedIndex) {
    final updatedAnswers = Map<String, int>.from(state.userAnswers)
      ..[questionId] = selectedIndex;

    state = state.copyWith(userAnswers: updatedAnswers, result: null);
  }

  void submitQuiz() {
    final quiz = state.activeQuiz;
    if (quiz == null) return;

    int correctCount = 0;
    for (final question in quiz.questions) {
      final userAnswer = state.userAnswers[question.id];
      if (userAnswer != null && userAnswer == question.correctAnswerIndex) {
        correctCount++;
      }
    }

    final totalQuestions = quiz.questions.length;
    final scorePercentage = (totalQuestions > 0)
        ? (correctCount / totalQuestions * 100).round()
        : 0;

    final result = QuizResult(
      totalQuestions: totalQuestions,
      correctAnswers: correctCount,
      scorePercentage: scorePercentage,
      userAnswers: state.userAnswers,
    );

    state = state.copyWith(result: result);
  }

  void endQuiz() {
    state = QuizTakingState(userAnswers: {});
  }
}
