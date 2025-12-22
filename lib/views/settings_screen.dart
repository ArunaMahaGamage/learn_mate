import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';
import '../viewmodels/settings_provider.dart';
import '../core/translation_helper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);  
    

    return Scaffold(
      appBar: AppBar(title: Text(getLocalizedString(ref, 'settings'))),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              getLocalizedString(ref, 'general_preferences'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          ListTile(
            title: Text(getLocalizedString(ref, 'app_theme')),
            subtitle: Text(
              settings.themeMode.toString().split('.').last.toUpperCase(),
            ),
            trailing: const Icon(Icons.style),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(getLocalizedString(ref, 'select_theme')),
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
          ),
          
          ListTile(
            title: Text(getLocalizedString(ref, 'language')),
            subtitle: Text(settings.preferredLanguage),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () async {
              final selected = await _showLanguagePicker(
                context,
                settings.preferredLanguage,
                ref
              );
              if (selected != null && context.mounted) {
                notifier.setPreferredLanguage(selected);
              }
            },
          ),

          const Divider(height: 30),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              getLocalizedString(ref, 'about'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ListTile(
            title: Text(getLocalizedString(ref, 'version')),
            trailing: Text(
              '1.0.0',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> _showLanguagePicker(
  BuildContext context,
  String current,
  WidgetRef ref,
) async {
  const languages = ['English', 'தமிழ்', 'සිංහල'];
  return await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(getLocalizedString(ref, 'select_language')),
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

// ---------------- LOGOUT DIALOG ----------------

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            debugPrint('User logged out');
          },
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
