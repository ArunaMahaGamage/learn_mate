import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes.dart';
import '../core/translation_helper.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiles = [
      _HomeTile(getLocalizedString(ref, 'planner'), Icons.event_note, Routes.planner),
      _HomeTile(getLocalizedString(ref, 'resources'), Icons.menu_book, Routes.subject),
      _HomeTile(getLocalizedString(ref, 'forum'), Icons.forum, Routes.forum),
      _HomeTile(getLocalizedString(ref, 'flashcards'), Icons.style, Routes.flashcards),
      _HomeTile(getLocalizedString(ref, 'quiz'), Icons.quiz, Routes.quiz),
      _HomeTile(getLocalizedString(ref, 'ai_assistant'), Icons.psychology, Routes.aiAssistant),
      _HomeTile(getLocalizedString(ref, 'profile'), Icons.person, Routes.profile),
      _HomeTile(getLocalizedString(ref, 'settings'), Icons.settings, Routes.settings),
      _HomeTile(getLocalizedString(ref, 'stopwatch'), Icons.timer, Routes.stopwatch), 
    ];

    return Scaffold(
      appBar: AppBar(title: Text(getLocalizedString(ref, 'home'))),
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
