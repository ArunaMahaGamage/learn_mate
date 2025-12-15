// lib/viewmodels/settings_provider.dart (UPDATED & SIMPLIFIED)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((
  ref,
) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(Settings()) {
    loadSettings();
  }

  // --- Persistence Simulation ---
  Future<void> loadSettings() async {
    // Simulation: Load initial settings or use default
    await Future.delayed(const Duration(milliseconds: 50));
    final Map<String, dynamic>? loadedData = null;

    if (loadedData != null) {
      state = Settings.fromMap(loadedData);
    } else {
      state = Settings();
    }
  }

  Future<void> _saveSettings() async {
    // Simulation: Save settings to local storage
    print('Settings saved to local storage: ${state.toMap()}');
  }

  // --- General Preference Logic ---

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _saveSettings();
  }

  void setPreferredLanguage(String language) {
    state = state.copyWith(preferredLanguage: language);
    _saveSettings();
  }
}
