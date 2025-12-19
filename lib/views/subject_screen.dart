import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/routes.dart';

// Subject model
class Subject {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  Subject({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

// Example provider (could be replaced with Firestore fetch)
final subjectsProvider = Provider<List<Subject>>((ref) {
  return [
    Subject(id: '1', name: 'Science', icon: Icons.science, color: Colors.green),
    Subject(id: '2', name: 'Mathematics', icon: Icons.calculate, color: Colors.blue),
    Subject(id: '3', name: 'History', icon: Icons.history_edu, color: Colors.brown),
    Subject(id: '4', name: 'English', icon: Icons.menu_book, color: Colors.purple),
    Subject(id: '5', name: 'IT', icon: Icons.computer, color: Colors.teal),
    Subject(id: '6', name: 'Geography', icon: Icons.public, color: Colors.orange),
  ];
});

// Subjects screen as ConsumerWidget
class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.resources, arguments: subject.name);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening ${subject.name} lessons...')),
              );
            },
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(subject.icon, color: Colors.black, size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subject.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
