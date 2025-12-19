// lib/views/settings_screen.dart (UPDATED & SIMPLIFIED)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';
import '../viewmodels/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // --- 1. General Preferences ---
          _SettingsSectionTitle(title: 'General Preferences'),

          // Theme Mode Selector
          _ThemeModeSettingTile(settings: settings, notifier: notifier),

          // Language Selector (uses updated _showLanguagePicker below)
          ListTile(
            title: const Text('Language'),
            subtitle: Text(settings.preferredLanguage),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () async {
              final selected = await _showLanguagePicker(
                context,
                settings.preferredLanguage,
              );
              if (selected != null && context.mounted) {
                notifier.setPreferredLanguage(selected);
              }
            },
          ),

          const Divider(height: 30),

          // --- 2. About ---
          _SettingsSectionTitle(title: 'About'),
          ListTile(
            title: const Text('Version'),
            trailing: Text(
              '1.0.0',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.link),
            onTap: () {
              /* Navigate to Terms screen */
            },
          ),
        ],
      ),
    );
  }
}

// --- Helper Widgets ---

class _SettingsSectionTitle extends StatelessWidget {
  final String title;
  const _SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _ThemeModeSettingTile extends StatelessWidget {
  final Settings settings;
  final SettingsNotifier notifier;

  const _ThemeModeSettingTile({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('App Theme'),
      subtitle: Text(
        settings.themeMode.toString().split('.').last.toUpperCase(),
      ),
      trailing: const Icon(Icons.style),
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Select Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppThemeMode.values.map((mode) {
                return RadioListTile<AppThemeMode>(
                  title: Text(mode.toString().split('.').last),
                  value: mode,
                  groupValue: settings.themeMode,
                  onChanged: (AppThemeMode? newMode) {
                    if (newMode != null) {
                      notifier.setThemeMode(newMode);
                      Navigator.pop(ctx);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

// CRITICAL UPDATE: Language list restricted to English, Tamil, and Sinhala.
Future<String?> _showLanguagePicker(
  BuildContext context,
  String current,
) async {
  // Only the three requested languages are included here
  const languages = ['English', 'Tamil', 'Sinhala'];
  return await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Select Language'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: current,
              onChanged: (String? newLang) {
                if (newLang != null) {
                  Navigator.pop(ctx, newLang);
                }
              },
            );
          }).toList(),
        ),
      ),
    ),
  );
}
