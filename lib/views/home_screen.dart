import 'package:flutter/material.dart';
import '../core/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _HomeTile('Planner', Icons.event_note, Routes.planner),
      _HomeTile('Resources', Icons.menu_book, Routes.subject),
      _HomeTile('Forum', Icons.forum, Routes.forum),
      _HomeTile('Flashcards', Icons.style, Routes.flashcards),
      _HomeTile('Quiz', Icons.quiz, Routes.quiz),
      _HomeTile('AI Assistant', Icons.psychology, Routes.aiAssistant),
      _HomeTile('Profile', Icons.person, Routes.profile),
      _HomeTile('Settings', Icons.settings, Routes.settings),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: tiles.map((t) => _Tile(t: t)).toList(),
      ),
    );
  }
}

class _HomeTile {
  final String title;
  final IconData icon;
  final String route;
  _HomeTile(this.title, this.icon, this.route);
}

class _Tile extends StatelessWidget {
  final _HomeTile t;
  const _Tile({required this.t});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, t.route),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(t.icon, size: 36),
              const SizedBox(height: 8),
              Text(t.title),
            ],
          ),
        ),
      ),
    );
  }
}
