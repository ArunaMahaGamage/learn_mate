import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/forum_provider.dart';

class QuestionDetailScreen extends ConsumerWidget {
  const QuestionDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Question q = ModalRoute.of(context)!.settings.arguments as Question;
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text(q.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.content),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Write an answer'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref.read(forumProvider.notifier).addAnswer(q.id, {
                  'userId': 'demo',
                  'content': controller.text,
                  'createdAt': DateTime.now().toIso8601String(),
                });
                controller.clear();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Answer posted')));
              },
              child: const Text('Post Answer'),
            ),
            const SizedBox(height: 12),
            const Text('Answers (live view omitted in scaffold)'),
          ],
        ),
      ),
    );
  }
}
