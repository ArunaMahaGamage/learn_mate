import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/quiz_provider.dart';
import '../models/quiz.dart';
import '../core/routes.dart';

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

//QUIZ LIST VIEW
class QuizListView extends ConsumerWidget {
  const QuizListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the list of quizzes
    final quizzes = ref.watch(quizListProvider);
    final listNotifier = ref.read(quizListProvider.notifier);

    if (quizzes.isEmpty) {
      listNotifier.loadQuizzes();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Available Quizzes')),
      body: RefreshIndicator(
        onRefresh: listNotifier.loadQuizzes,
        child: quizzes.isEmpty
            ? const Center(
                child: Text(
                  'No quizzes available. Pull down to refresh or create one!',
                ),
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

class QuizListTile extends ConsumerWidget {
  final Quiz quiz;
  const QuizListTile({super.key, required this.quiz});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizTakingNotifier = ref.read(quizTakingProvider.notifier);
    final quizListNotifier = ref.read(quizListProvider.notifier);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(quiz.title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          '${quiz.questions.length} Questions | Created by: ${quiz.createdBy}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              // U - Update (Edit)
              Navigator.pushNamed(
                context,
                Routes.quizCreation,
                arguments: quiz,
              );
            } else if (value == 'delete') {
              // D - Delete
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: Text(
                    'Are you sure you want to delete "${quiz.title}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (!context.mounted) return;

              if (confirmed == true) {
                quizListNotifier.deleteQuiz(quiz.id);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Quiz deleted!')));
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit Quiz (U)')),
            const PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete Quiz (D)',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        onTap: () {
          // R - Read (Start Quiz Taking)
          quizTakingNotifier.startQuiz(quiz);
        },
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
          tooltip: 'Exit Quiz',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Progress: $answeredCount/$totalQuestions answered',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),

          for (var i = 0; i < totalQuestions; i++)
            _QuestionCard(
              index: i,
              question: quiz.questions[i],
              selectedAnswerIndex:
                  quizTakingState.userAnswers[quiz.questions[i].id],
              onAnswerSelected: quizTakingNotifier.selectAnswer,
            ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isComplete ? quizTakingNotifier.submitQuiz : null,
              child: Text(isComplete ? 'Submit Quiz' : 'Answer all questions'),
            ),
          ),
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
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${question.question}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            ...List.generate(question.options.length, (i) {
              final isSelected = i == selectedAnswerIndex;
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                title: Text(question.options[i]),
                onTap: () => onAnswerSelected(question.id, i),
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
    final pass = result.scorePercentage >= 70;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onEnd,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: pass ? Colors.green.shade50 : Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    pass ? 'Congratulations!' : 'Keep Practicing!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${result.scorePercentage}%',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: pass ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${result.correctAnswers} out of ${result.totalQuestions} correct.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Quiz Review:', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),

          for (var i = 0; i < quiz.questions.length; i++)
            _ResultQuestionReview(
              index: i,
              question: quiz.questions[i],
              userAnswerIndex: result.userAnswers[quiz.questions[i].id],
            ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              onPressed: onTryAgain,
              label: const Text('Review Again'),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.exit_to_app),
              onPressed: onEnd,
              label: const Text('Back to Quizzes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultQuestionReview extends StatelessWidget {
  final int index;
  final QuizQuestion question;
  final int? userAnswerIndex;

  const _ResultQuestionReview({
    required this.index,
    required this.question,
    required this.userAnswerIndex,
  });
  @override
  Widget build(BuildContext context) {
    final isCorrect = userAnswerIndex == question.correctAnswerIndex;
    final statusColor = isCorrect ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${index + 1}. ${question.question}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...List.generate(question.options.length, (i) {
              final isUserAnswer = i == userAnswerIndex;
              final isCorrectAnswer = i == question.correctAnswerIndex;

              Widget? trailingIcon;
              Color tileColor = Colors.transparent;

              if (isCorrectAnswer) {
                trailingIcon = const Icon(Icons.check, color: Colors.green);
                tileColor = Colors.green.shade100;
              } else if (isUserAnswer) {
                trailingIcon = const Icon(Icons.close, color: Colors.red);
                tileColor = Colors.red.shade100;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(4),
                    border: isUserAnswer && !isCorrect
                        ? Border.all(color: Colors.red, width: 2)
                        : null,
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: isUserAnswer
                        ? Icon(Icons.person, color: statusColor, size: 18)
                        : null,
                    title: Text(
                      question.options[i],
                      style: TextStyle(
                        fontWeight: isCorrectAnswer
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: trailingIcon,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
