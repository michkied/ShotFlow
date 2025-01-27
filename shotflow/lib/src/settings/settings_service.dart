import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'types.dart';

/// A service that stores and retrieves user settings using SharedPreferences.
class SettingsService {
  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKeyRed = 'accent_color_r';
  static const String _accentColorKeyGreen = 'accent_color_g';
  static const String _accentColorKeyBlue = 'accent_color_b';
  static const String _localeTypeKey = 'locale_type';

  Future<ThemeMode> themeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    return ThemeMode.values[themeIndex];
  }

  Future<Color> accentColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValueRed =
        prefs.getInt(_accentColorKeyRed) ?? (Colors.blue.r * 255).toInt();
    final colorValueGreen =
        prefs.getInt(_accentColorKeyGreen) ?? (Colors.blue.g * 255).toInt();
    final colorValueBlue =
        prefs.getInt(_accentColorKeyBlue) ?? (Colors.blue.b * 255).toInt();
    return Color.fromRGBO(colorValueRed, colorValueGreen, colorValueBlue, 100);
  }

  Future<SupportedLocales> localeType() async {
    final prefs = await SharedPreferences.getInstance();
    final localeIndex =
        prefs.getInt(_localeTypeKey) ?? SupportedLocales.def.index;
    return SupportedLocales.values[localeIndex];
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, theme.index);
  }

  Future<void> updateAccentColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKeyRed, (color.r * 255).toInt());
    await prefs.setInt(_accentColorKeyGreen, (color.g * 255).toInt());
    await prefs.setInt(_accentColorKeyBlue, (color.b * 255).toInt());
  }

  Future<void> updateLocaleType(SupportedLocales locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_localeTypeKey, locale.index);
  }
}
