import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../viewmodels/forum_provider.dart';
import '../core/routes.dart';

class ForumScreen extends ConsumerWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(forumProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Q&A'),
        centerTitle: true,
      ),
      body: questions.isEmpty
          ? const Center(
        child: Text(
          "No questions yet. Tap + to add one!",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: questions.length,
        itemBuilder: (_, i) {
          final q = questions[i];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(q.userId[0].toUpperCase()),
              ),
              title: Text(
                q.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: q.tags
                        .map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat.yMMMd().add_jm().format(q.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              onTap: () => Navigator.pushNamed(
                context,
                Routes.questionDetail,
                arguments: q,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text("Ask"),
      ),
    );
  }
}

Future<void> _addDialog(BuildContext context, WidgetRef ref) async {
  final _formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Ask a Question'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Title required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Description required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: tagsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'comma separated',
                  prefixIcon: Icon(Icons.tag),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'At least one tag required'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            final q = Question(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: 'demo',
              title: titleCtrl.text.trim(),
              content: descCtrl.text.trim(),
              tags: tagsCtrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
              createdAt: DateTime.now(),
            );

            ref.read(forumProvider.notifier).addQuestion(q);
            if (context.mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.send),
          label: const Text('Post'),
        ),
      ],
    ),
  );
}
