import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shotflow/src/settings/settings_controller.dart';
import 'package:shotflow/src/settings/settings_service.dart';
import 'package:shotflow/src/settings/types.dart';
import 'settings_test.mocks.dart';

@GenerateMocks([SettingsService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService', () {
    late SettingsService settingsService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      settingsService = SettingsService();
    });

    test('should return default theme mode if not set', () async {
      final themeMode = await settingsService.themeMode();
      expect(themeMode, ThemeMode.system);
    });

    test('should update and return theme mode', () async {
      await settingsService.updateThemeMode(ThemeMode.light);
      final themeMode = await settingsService.themeMode();
      final storedThemeMode = prefs.getInt('theme_mode');

      expect(themeMode, ThemeMode.light);
      expect(storedThemeMode, ThemeMode.light.index);
    });

    test('should return default accent color if not set', () async {
      final color = await settingsService.accentColor();
      expect(
          color,
          Color.from(
              alpha: Colors.blue.a,
              red: Colors.blue.r,
              green: Colors.blue.g,
              blue: Colors.blue.b));
    });

    test('should update and return accent color', () async {
      final newColor = Color.fromRGBO(255, 0, 0, 1);
      await settingsService.updateAccentColor(newColor);
      final color = await settingsService.accentColor();

      final storedRed = prefs.getInt('accent_color_r');
      final storedGreen = prefs.getInt('accent_color_g');
      final storedBlue = prefs.getInt('accent_color_b');

      expect(color, newColor);
      expect(storedRed, 255);
      expect(storedGreen, 0);
      expect(storedBlue, 0);
    });

    test('should return default locale type if not set', () async {
      final localeType = await settingsService.localeType();
      expect(localeType, SupportedLocales.def);
    });

    test('should update and return locale type', () async {
      await settingsService.updateLocaleType(SupportedLocales.en);
      final localeType = await settingsService.localeType();
      final storedLocaleType = prefs.getInt('locale_type');

      expect(localeType, SupportedLocales.en);
      expect(storedLocaleType, SupportedLocales.en.index);
    });
  });

  group('SettingsController', () {
    MockSettingsService mockSettingsService = MockSettingsService();
    SettingsController settingsController =
        SettingsController(mockSettingsService);

    test('loadSettings should load settings from the service', () async {
      when(mockSettingsService.themeMode())
          .thenAnswer((_) async => ThemeMode.dark);
      when(mockSettingsService.accentColor())
          .thenAnswer((_) async => Colors.red);
      when(mockSettingsService.localeType())
          .thenAnswer((_) async => SupportedLocales.en);

      await settingsController.loadSettings();

      expect(settingsController.themeMode, ThemeMode.dark);
      expect(settingsController.accentColor, Colors.red);
      expect(settingsController.localeType, SupportedLocales.en);
    });

    test('updateThemeMode should update the theme mode', () async {
      when(mockSettingsService.updateThemeMode(any)).thenAnswer((_) async {});

      await settingsController.updateThemeMode(ThemeMode.light);

      expect(settingsController.themeMode, ThemeMode.light);
      verify(mockSettingsService.updateThemeMode(ThemeMode.light)).called(1);
    });

    test('updateAccentColor should update the accent color', () async {
      when(mockSettingsService.updateAccentColor(any)).thenAnswer((_) async {});

      await settingsController.updateAccentColor(Colors.green);

      expect(settingsController.accentColor, Colors.green);
      verify(mockSettingsService.updateAccentColor(Colors.green)).called(1);
    });

    test('updateLocale should update the locale', () async {
      when(mockSettingsService.updateLocaleType(any)).thenAnswer((_) async {});

      await settingsController.updateLocale(SupportedLocales.pl);

      expect(settingsController.localeType, SupportedLocales.pl);
      expect(settingsController.locale, Locale('pl'));
      verify(mockSettingsService.updateLocaleType(SupportedLocales.pl))
          .called(1);
    });
  });
}
