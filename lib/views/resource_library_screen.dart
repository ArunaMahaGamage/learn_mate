import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/resource_provider.dart';
import '../components/learning_card.dart';
import '../core/routes.dart';
import '../models/lesson.dart';

class ResourceLibraryScreen extends ConsumerWidget {
  const ResourceLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(resourcesProvider);

    final String subject = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: Text('$subject')),
      body: ListView.builder(
        itemCount: resources.length,
        itemBuilder: (_, i) {
          final r = resources[i];
          return LearningCard(
            lesson: r,
            onTap: () => Navigator.pushNamed(context, Routes.resourceDetail, arguments: r),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addDialog(context, ref);
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
  final String subject = ModalRoute.of(context)!.settings.arguments as String;
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Add Resources'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Subject')),
          const SizedBox(height: 8),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 8),
          TextField(controller: tagsCtrl, decoration: const InputDecoration(labelText: 'Resources')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            final l = Lesson(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: subject,
              subject: descCtrl.text,
              type: 'pdf',
              downloadUrl: 'https://example.com/notes.pdf',
              offlineAvailable: true,
              createdAt: DateTime.now(),
            );
            ref.read(resourcesProvider.notifier).addResource(l);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
