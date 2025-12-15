import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planner_item.dart';
import '../viewmodels/auth_provider.dart';
import '../viewmodels/planner_provider.dart';
import '../components/planner_card.dart';
import '../core/routes.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planners = ref.watch(plannerProvider);

    // Separate pending and completed items for better UI
    final pendingItems = planners.where((p) => p.status == 'pending').toList();
    final completedItems = planners
        .where((p) => p.status == 'completed')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Study Planner')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          //Pending Tasks Section (Prominent)
          Text(
            'Pending Tasks (${pendingItems.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          pendingItems.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text('You have no pending tasks! Good job.'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingItems.length,
                  itemBuilder: (_, i) {
                    final p = pendingItems[i];
                    return PlannerCard(
                      item: p,
                      onTap: () => Navigator.pushNamed(
                        context,
                        Routes.plannerDetail,
                        arguments: p,
                      ),
                      onDelete: () => ref
                          .read(plannerProvider.notifier)
                          .deletePlanner(p.id),
                    );
                  },
                ),

          const Divider(height: 40),
          // Completed Tasks Section (Secondary)
          Text(
            'Completed (${completedItems.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          completedItems.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: Text('No completed tasks yet.')),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: completedItems.length,
                  itemBuilder: (_, i) {
                    final p = completedItems[i];
                    return Opacity(
                      opacity: 0.6,
                      child: PlannerCard(
                        item: p,
                        onTap: () => Navigator.pushNamed(
                          context,
                          Routes.plannerDetail,
                          arguments: p,
                        ),
                        onDelete: () => ref
                            .read(plannerProvider.notifier)
                            .deletePlanner(p.id),
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addDialog(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final task1Ctrl = TextEditingController();
    final task2Ctrl = TextEditingController();

    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Add New Study Plan'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Plan Title',
                      hintText: 'e.g., Math Revision',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'e.g., Chapters 3 & 4',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Target Date:'),
                      TextButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Text(
                          '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sub-Tasks (Optional)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextField(
                    controller: task1Ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Task 1',
                      hintText: 'e.g., Finish all exercises',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: task2Ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Task 2',
                      hintText: 'e.g., Create mind map',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final tasks = [
                    task1Ctrl.text.trim(),
                    task2Ctrl.text.trim(),
                  ].where((t) => t.isNotEmpty).toList();

                  if (titleCtrl.text.trim().isEmpty) {
                    return;
                  }

                  final p = PlannerItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId:
                        ref.read(authControllerProvider).currentUserEmail ??
                        'demo',
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    date: selectedDate,
                    status: 'pending', // New items are always pending
                    tasks: tasks,
                  );

                  ref.read(plannerProvider.notifier).addPlanner(p);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Add Plan'),
              ),
            ],
          );
        },
      ),
    );
  }
}
