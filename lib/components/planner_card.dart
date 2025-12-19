import 'package:flutter/material.dart';
import '../models/planner_item.dart';

class PlannerCard extends StatelessWidget {
  final PlannerItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PlannerCard({super.key, required this.item, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.title),
        subtitle: Text('${item.description}\n${item.date.toLocal()}'),
        trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
        onTap: onTap,
      ),
    );
  }
}
