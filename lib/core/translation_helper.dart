import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'localization_helper.dart';
import '../viewmodels/settings_provider.dart';

String getLocalizedString(WidgetRef ref, String key) {
  final settings = ref.watch(settingsProvider);
  final strings = LocalizationHelper.getLocalizedStrings(
    settings.preferredLanguage,
  );
  return strings[key] ?? key;
}