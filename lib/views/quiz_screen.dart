import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/quiz_provider.dart';
import '../models/quiz.dart';
import '../core/routes.dart';
import '../components/quiz_list_tile.dart'; //custom component

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizTakingState = ref.watch(quizTakingProvider);

    if (quizTakingState.activeQuiz != null) {
      return QuizTakingView(
        quizTakingState: quizTakingState,
        quizTakingNotifier: ref.read(quizTakingProvider.notifier),
      );
    }
    return const QuizListView();
  }
}

class QuizListView extends ConsumerWidget {
  const QuizListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzes = ref.watch(quizListProvider);
    final listNotifier = ref.read(quizListProvider.notifier);

    // Initial load if list is empty
    if (quizzes.isEmpty) {
      listNotifier.loadQuizzes();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Available Quizzes')),
      body: RefreshIndicator(
        onRefresh: listNotifier.loadQuizzes,
        child: quizzes.isEmpty
            ? const Center(
                child: Text('No quizzes available. Pull down to refresh!'),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: quizzes.length,
                itemBuilder: (_, i) {
                  return QuizListTile(quiz: quizzes[i]);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, Routes.quizCreation, arguments: null);
        },
        icon: const Icon(Icons.add_box),
        label: const Text('Create Quiz'),
      ),
    );
  }
}

class QuizTakingView extends StatelessWidget {
  final QuizTakingState quizTakingState;
  final QuizTakingNotifier quizTakingNotifier;

  const QuizTakingView({
    super.key,
    required this.quizTakingState,
    required this.quizTakingNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final quiz = quizTakingState.activeQuiz!;

    // Show results if the quiz is finished
    if (quizTakingState.result != null) {
      return _QuizResultView(
        result: quizTakingState.result!,
        quiz: quiz,
        onTryAgain: () => quizTakingNotifier.startQuiz(quiz),
        onEnd: quizTakingNotifier.endQuiz,
      );
    }

    final totalQuestions = quiz.questions.length;
    final answeredCount = quizTakingState.userAnswers.length;
    final isComplete = answeredCount == totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => quizTakingNotifier.endQuiz(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LinearProgressIndicator(
            value: totalQuestions > 0 ? answeredCount / totalQuestions : 0,
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 12),
          Text(
            'Progress: $answeredCount/$totalQuestions answered',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Question List
          for (var i = 0; i < totalQuestions; i++)
            _QuestionCard(
              index: i,
              question: quiz.questions[i],
              selectedAnswerIndex:
                  quizTakingState.userAnswers[quiz.questions[i].id],
              onAnswerSelected: quizTakingNotifier.selectAnswer,
            ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: isComplete ? quizTakingNotifier.submitQuiz : null,
              child: Text(
                isComplete ? 'Submit Quiz' : 'Please answer all questions',
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final QuizQuestion question;
  final int? selectedAnswerIndex;
  final void Function(String questionId, int selectedIndex) onAnswerSelected;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selectedAnswerIndex,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${index + 1}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question.question,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...List.generate(question.options.length, (i) {
              final isSelected = i == selectedAnswerIndex;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.05)
                      : null,
                ),
                child: RadioListTile<int>(
                  value: i,
                  groupValue: selectedAnswerIndex,
                  title: Text(question.options[i]),
                  onChanged: (_) => onAnswerSelected(question.id, i),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  final QuizResult result;
  final Quiz quiz;
  final VoidCallback onTryAgain;
  final VoidCallback onEnd;

  const _QuizResultView({
    required this.result,
    required this.quiz,
    required this.onTryAgain,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final isPassed = result.scorePercentage >= 70;

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isPassed ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  isPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  size: 64,
                  color: isPassed ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Score: ${result.scorePercentage}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPassed
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
                Text(
                  '${result.correctAnswers} / ${result.totalQuestions} Correct',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEnd,
                  child: const Text('Exit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onTryAgain,
                  child: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
