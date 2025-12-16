import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> loadQuizzes() async {
    final snap = await _firestore.orderBy('title').get();
    state = snap.docs
        .map((d) => Quiz.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> addQuiz(Quiz quiz) async {
    final docRef = _firestore.doc(quiz.id);
    await docRef.set(quiz.toMap());
    state = [quiz, ...state]; // Add locally for immediate update
  }

  Future<void> updateQuiz(Quiz updatedQuiz) async {
    await _firestore.doc(updatedQuiz.id).update(updatedQuiz.toMap());
    // Update local state by replacing the old quiz object
    state = state.map((q) => q.id == updatedQuiz.id ? updatedQuiz : q).toList();
  }

  Future<void> deleteQuiz(String id) async {
    await _firestore.doc(id).delete();
    // Remove from local state
    state = state.where((q) => q.id != id).toList();
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
    state = QuizTakingState(userAnswers: {}); // Reset to initial state
  }
}
