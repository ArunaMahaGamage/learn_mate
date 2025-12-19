import 'package:flutter/material.dart';
import '../models/lesson.dart';

/*class LearningCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback? onTap;

  const LearningCard({super.key, required this.lesson, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(lesson.title),
        subtitle: Text('${lesson.subject} • ${lesson.type}'),
        trailing: Icon(lesson.offlineAvailable ? Icons.offline_pin : Icons.cloud_download),
        onTap: onTap,
      ),
    );
  }
}*/

class LearningCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback? onTap;

  const LearningCard({super.key, required this.lesson, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                lesson.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Subject + Type row
              Row(
                children: [
                  Icon(Icons.school, color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    lesson.subject,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.insert_drive_file, color: Colors.green, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    lesson.type.toUpperCase(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Offline availability
              Row(
                children: [
                  Icon(
                    lesson.offlineAvailable ? Icons.offline_pin : Icons.cloud_download,
                    color: lesson.offlineAvailable ? Colors.teal : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    lesson.offlineAvailable ? "Available Offline" : "Available Online",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Created date
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.orange, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    "Added on ${lesson.createdAt.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Example: open downloadUrl
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("Open"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

