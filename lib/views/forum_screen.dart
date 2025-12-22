import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/forum_provider.dart';
import '../core/routes.dart';
import '../core/translation_helper.dart';

class ForumScreen extends ConsumerWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(forumProvider);

    return Scaffold(
      appBar: AppBar(title: Text(getLocalizedString(ref, 'forum'))),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (_, i) {
          final q = questions[i];
          return Card(
            child: ListTile(
              title: Text(q.title),
              subtitle: Text(q.content),
              onTap: () => Navigator.pushNamed(
                context,
                Routes.questionDetail,
                arguments: q,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addDialog(context,ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> _addDialog(BuildContext context, WidgetRef ref) async {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(getLocalizedString(ref, 'forum')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: titleCtrl, decoration: InputDecoration(labelText: getLocalizedString(ref, 'title'))),
          const SizedBox(height: 8),
          TextField(controller: descCtrl, decoration: InputDecoration(labelText: getLocalizedString(ref, 'description'))),
          const SizedBox(height: 8),
          TextField(controller: tagsCtrl, decoration: InputDecoration(labelText: getLocalizedString(ref, 'tags'))),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(getLocalizedString(ref, 'cancel'))),
        FilledButton(
          onPressed: () async {
            final q = Question(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: 'demo',
              title: titleCtrl.text,
              content: descCtrl.text,
              tags: [tagsCtrl.text,],
              createdAt: DateTime.now(),
            );
            ref.read(forumProvider.notifier).addQuestion(q);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(getLocalizedString(ref, 'save')),
        ),
      ],
    ),
  );
}
