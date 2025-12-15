import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planner_item.dart';
import '../viewmodels/planner_provider.dart';

class PlannerDetailScreen extends ConsumerWidget {
  const PlannerDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlannerItem item =
        ModalRoute.of(context)!.settings.arguments as PlannerItem;

    final currentItem = ref
        .watch(plannerProvider)
        .firstWhere((p) => p.id == item.id, orElse: () => item);

    final isCompleted = currentItem.status == 'completed';

    return Scaffold(
      appBar: AppBar(title: Text(currentItem.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              avatar: Icon(
                isCompleted ? Icons.check_circle : Icons.pending,
                color: isCompleted ? Colors.green : Colors.orange,
              ),
              label: Text(isCompleted ? 'Completed' : 'Pending'),
              backgroundColor: isCompleted
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
            ),
            const SizedBox(height: 16),
            Text(
              'Description:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              currentItem.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Target Date:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${currentItem.date.toLocal().year}-${currentItem.date.toLocal().month}-${currentItem.date.toLocal().day}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Tasks List
            Text('Sub-Tasks:', style: Theme.of(context).textTheme.titleMedium),
            if (currentItem.tasks.isEmpty)
              const Text('No sub-tasks defined for this plan.'),
            ...currentItem.tasks
                .map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isCompleted ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            task,
                            style: TextStyle(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),

            const SizedBox(height: 40),

            // Update Button (Mark Completed/Pending)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(isCompleted ? Icons.undo : Icons.done_all),
                label: Text(
                  isCompleted ? 'Mark as PENDING' : 'Mark as COMPLETED',
                ),
                onPressed: () {
                  final newStatus = isCompleted ? 'pending' : 'completed';
                  final updated = PlannerItem(
                    id: currentItem.id,
                    userId: currentItem.userId,
                    title: currentItem.title,
                    description: currentItem.description,
                    date: currentItem.date,
                    status: newStatus,
                    tasks: currentItem.tasks,
                  );

                  // Send the update to the Notifier
                  ref.read(plannerProvider.notifier).updatePlanner(updated);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Plan marked as $newStatus')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
