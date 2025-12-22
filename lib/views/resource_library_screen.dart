import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/availability_selector.dart';
import '../components/file_type_Selector.dart';
import '../viewmodels/resource_provider.dart';
import '../components/learning_card.dart';
import '../core/routes.dart';
import '../core/translation_helper.dart';
import '../models/lesson.dart';

class ResourceLibraryScreen extends ConsumerWidget {
  const ResourceLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(resourcesProvider);

    final String subject = ModalRoute.of(context)!.settings.arguments as String;

    ref.read(resourcesProvider.notifier).loadSubject(subject);

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
  final resourcesURLCtrl = TextEditingController();
  final String subject = ModalRoute.of(context)!.settings.arguments as String;
  bool _selectedAvailability = true;
  String _fileTypeSelector = "Web";
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Add Resources'),
      content: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16, right: 16, top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Subject title')),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 8),
            TextField(controller: resourcesURLCtrl, decoration: const InputDecoration(labelText: 'Resources URL')),
            const SizedBox(height: 8),
            AvailabilitySelector(
              initialValue: _selectedAvailability,
                onChanged: (value) {
                  _selectedAvailability = value;
                } // You can now use _selectedAvailability anywhere in this screen debugPrint("Selected availability: $value"); },
            ),
            const SizedBox(height: 8),
            FileTypeSelector(
                initialValue: _fileTypeSelector,
                onChanged: (value) {
                  _fileTypeSelector = value;
                } // You can now use _selectedAvailability anywhere in this screen debugPrint("Selected availability: $value"); },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(getLocalizedString(ref, 'cancel'))),
        FilledButton(
          onPressed: () async {
            final l = Lesson(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: titleCtrl.text,
              subject: subject,
              type: 'pdf',
              downloadUrl: resourcesURLCtrl.text,
              offlineAvailable: _selectedAvailability,
              createdAt: DateTime.now(),
            );
            ref.read(resourcesProvider.notifier).addResource(l);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(getLocalizedString(ref, 'save')),
        ),
      ],
    ),
  );
}
