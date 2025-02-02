import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../connection/connection_controller.dart';
import 'settings_controller.dart';
import 'types.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language
              Text(
                AppLocalizations.of(context)!.language,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ListTile(
                title: const Text('English'),
                leading: Radio<SupportedLocales>(
                  value: SupportedLocales.en,
                  groupValue: controller.localeType,
                  onChanged: controller.updateLocale,
                ),
              ),
              ListTile(
                title: const Text('Polski'),
                leading: Radio<SupportedLocales>(
                  value: SupportedLocales.pl,
                  groupValue: controller.localeType,
                  onChanged: controller.updateLocale,
                ),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.systemTheme),
                leading: Radio<SupportedLocales>(
                  value: SupportedLocales.def,
                  groupValue: controller.localeType,
                  onChanged: controller.updateLocale,
                ),
              ),
              const SizedBox(height: 20),

              // Theme
              Text(
                AppLocalizations.of(context)!.theme,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.lightTheme),
                leading: Radio<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: controller.themeMode,
                  onChanged: controller.updateThemeMode,
                ),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.darkTheme),
                leading: Radio<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: controller.themeMode,
                  onChanged: controller.updateThemeMode,
                ),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.systemTheme),
                leading: Radio<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: controller.themeMode,
                  onChanged: controller.updateThemeMode,
                ),
              ),
              const SizedBox(height: 20),

              // Accent color
              Text(
                AppLocalizations.of(context)!.accentColor,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: controller.accentColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: Colors.primaries.map((color) {
                    return ChoiceChip(
                      label: const Text(''),
                      labelPadding: EdgeInsets.zero,
                      selected: controller.accentColor == color,
                      selectedColor: color,
                      onSelected: (selected) {
                        controller.updateAccentColor(selected ? color : null);
                      },
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      showCheckmark: false,
                      selectedShadowColor: Colors.white,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 50),

              // Logout
              Consumer<ConnectionController>(
                builder: (context, connection, child) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        connection.disconnect();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          AppLocalizations.of(context)!.logout,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
