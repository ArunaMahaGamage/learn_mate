import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz.dart';
import '../viewmodels/quiz_provider.dart';
import '../core/routes.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          quiz.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${quiz.questions.length} Questions | By: ${quiz.createdBy}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleMenuAction(context, value, quizListNotifier),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit Quiz')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
        onTap: () => quizTakingNotifier.startQuiz(quiz),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String value,
    dynamic notifier,
  ) async {
    if (value == 'edit') {
      Navigator.pushNamed(context, Routes.quizCreation, arguments: quiz);
    } else if (value == 'delete') {
      final confirmed = await _showDeleteDialog(context);
      if (confirmed == true) {
        notifier.deleteQuiz(quiz.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz deleted successfully')),
        );
      }
    }
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Quiz?'),
        content: Text('Are you sure you want to delete "${quiz.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
