import 'package:flutter/material.dart';
import 'package:shotflow/src/settings/types.dart';

import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => _themeMode;

  Color _accentColor = Colors.blue;
  Color get accentColor => _accentColor;

  SupportedLocales _localeType = SupportedLocales.def;
  SupportedLocales get localeType => _localeType;
  Locale? get locale {
    switch (_localeType) {
      case SupportedLocales.en:
        return Locale('en');
      case SupportedLocales.pl:
        return Locale('pl');
      case SupportedLocales.def:
        return null;
    }
  }

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;

    // Otherwise, store the new ThemeMode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateAccentColor(Color? newcolor) async {
    if (newcolor == null) return;
    if (newcolor == accentColor) return;
    _accentColor = newcolor;

    notifyListeners();
  }

  Future<void> updateLocale(SupportedLocales? newLocale) async {
    if (newLocale == null) return;
    if (newLocale == _localeType) return;
    _localeType = newLocale;

    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    // await _settingsService.updateLocale(newLocale);
  }
}
