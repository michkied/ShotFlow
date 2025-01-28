import 'package:flutter/material.dart';
import 'package:shotflow/src/home/settings/types.dart';

import 'settings_service.dart';

/// A controller that manages the user's settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  late ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Color _accentColor = Colors.blue;
  Color get accentColor => _accentColor;

  SupportedLocales _localeType = SupportedLocales.def;
  SupportedLocales get localeType => _localeType;
  Locale? get locale {
    switch (_localeType) {
      case SupportedLocales.en:
        return const Locale('en');
      case SupportedLocales.pl:
        return const Locale('pl');
      case SupportedLocales.def:
        return null;
    }
  }

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _accentColor = await _settingsService.accentColor();
    _localeType = await _settingsService.localeType();

    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) {
      return;
    }
    if (newThemeMode == _themeMode) {
      return;
    }
    _themeMode = newThemeMode;

    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateAccentColor(Color? newcolor) async {
    if (newcolor == null) {
      return;
    }
    if (newcolor == accentColor) {
      return;
    }
    _accentColor = newcolor;

    notifyListeners();
    await _settingsService.updateAccentColor(newcolor);
  }

  Future<void> updateLocale(SupportedLocales? newLocale) async {
    if (newLocale == null) {
      return;
    }
    if (newLocale == _localeType) {
      return;
    }
    _localeType = newLocale;

    notifyListeners();
    await _settingsService.updateLocaleType(newLocale);
  }
}
