import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'src/app.dart';
import 'src/connection/connection_service.dart';
import 'src/home/settings/settings_controller.dart';
import 'src/home/settings/settings_service.dart';
import 'src/connection/connection_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  final storage = FlutterSecureStorage();
  final connectionService = ConnectionService(storage);
  final connectionController =
      ConnectionController(connectionService: connectionService);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => settingsController),
      ChangeNotifierProvider(create: (context) => connectionController),
    ],
    child: ShotFlowApp(),
  ));
}
