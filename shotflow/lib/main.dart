import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/connection/connection_controller.dart';
import 'src/connection/connection_service.dart';

void main() async {
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  final connectionController =
      ConnectionController(ConnectionService('ws://localhost:5000/', 'abc'));

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => settingsController),
      ChangeNotifierProvider(create: (context) => connectionController),
    ],
    child: MyApp(),
  ));
}
