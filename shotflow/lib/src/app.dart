import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'home/home_view.dart';
import 'home/settings/settings_controller.dart';
import 'login/login_view.dart';
import 'login/qr_scan_view.dart';

class ShotFlowApp extends StatelessWidget {
  const ShotFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settings, child) {
        return MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: settings.accentColor,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: settings.accentColor,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: settings.themeMode,
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('pl'),
          ],
          locale: settings.locale,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          onGenerateRoute: (routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (context) {
                switch (routeSettings.name) {
                  case '/home':
                    return const HomeView();
                  case '/login':
                    return const LoginView();
                  case '/qr_scan':
                    return const QRViewScreen();
                  default:
                    return const LoginView();
                }
              },
            );
          },
        );
      },
    );
  }
}
