enum AppThemeMode { light, dark, system }

class Settings {
  final AppThemeMode themeMode;
  final bool enableNotifications;
  final bool enableDataSync;
  final String preferredLanguage;

  Settings({
    this.themeMode = AppThemeMode.system,
    this.enableNotifications = true,
    this.enableDataSync = true,
    this.preferredLanguage = 'English',
  });

  Settings copyWith({
    AppThemeMode? themeMode,
    bool? enableNotifications,
    bool? enableDataSync,
    String? preferredLanguage,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableDataSync: enableDataSync ?? this.enableDataSync,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  // Helper for persistence (to store as a Map/JSON in SharedPreferences or Firestore)
  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'enableNotifications': enableNotifications,
      'enableDataSync': enableDataSync,
      'preferredLanguage': preferredLanguage,
    };
  }

  // Helper for loading from persistence
  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      themeMode: AppThemeMode
          .values[map['themeMode'] as int? ?? AppThemeMode.system.index],
      enableNotifications: map['enableNotifications'] as bool? ?? true,
      enableDataSync: map['enableDataSync'] as bool? ?? true,
      preferredLanguage: map['preferredLanguage'] as String? ?? 'English',
    );
  }
}
