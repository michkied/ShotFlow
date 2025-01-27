import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connection/connection_controller.dart';
import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ListTile(
                title: const Text('Light'),
                leading: Radio<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: controller.themeMode,
                  onChanged: controller.updateThemeMode,
                ),
              ),
              ListTile(
                title: const Text('Dark'),
                leading: Radio<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: controller.themeMode,
                  onChanged: controller.updateThemeMode,
                ),
              ),
              ListTile(
                title: const Text('System'),
                leading: Radio<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: controller.themeMode,
                  onChanged: controller.updateThemeMode,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Accent Color',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 20),
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: controller.accentColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  children: Colors.primaries.map((color) {
                    return ChoiceChip(
                      label: Text(''),
                      labelPadding: EdgeInsets.all(0),
                      selected: controller.accentColor == color,
                      selectedColor: color,
                      onSelected: (bool selected) {
                        controller.updateAccentColor(selected ? color : null);
                      },
                      backgroundColor: color,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      showCheckmark: false,
                      selectedShadowColor: Colors.white,
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 50),
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
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Logout',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
