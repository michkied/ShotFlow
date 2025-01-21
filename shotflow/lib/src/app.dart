import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'shotlist/shotlist_view.dart';
import 'messages/messages_view.dart';
import 'sequences/sequences_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: settingsController,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            theme: ThemeData(),
            darkTheme: ThemeData.dark(),
            themeMode: settingsController.themeMode,

            restorationScopeId: 'app',

            // Provide the generated AppLocalizations to the MaterialApp. This
            // allows descendant Widgets to display the correct translations
            // depending on the user's locale.
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English, no country code
            ],

            // Use AppLocalizations to configure the correct application title
            // depending on the user's locale.
            //
            // The appTitle is defined in .arb files found in the localization
            // directory.
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,

            home: NavigationExample(settingsController: settingsController),

            // Define a function to handle named routes in order to support
            // Flutter web url navigation and deep linking.
            // onGenerateRoute: (RouteSettings routeSettings) {
            //   return MaterialPageRoute<void>(
            //     settings: routeSettings,
            //     builder: (BuildContext context) {
            //       switch (routeSettings.name) {
            //         case SettingsView.routeName:
            //           return SettingsView(controller: settingsController);
            //         case SampleItemDetailsView.routeName:
            //           return const SampleItemDetailsView();
            //         case SampleItemListView.routeName:
            //         default:
            //           return NavigationExample(
            //               settingsController: settingsController);
            //       }
            //     },
            //   );
            // },
          );
        });
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key, required this.settingsController});
  final SettingsController settingsController;

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.blueAccent,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Badge(
              // label: Text('2'),
              child: Icon(Icons.message),
            ),
            icon: Badge(
              label: Text('2'),
              child: Icon(Icons.message_outlined),
            ),
            label: 'Messages',
          ),
          NavigationDestination(
            selectedIcon: Badge(
                isLabelVisible: false, child: Icon(Icons.videocam_rounded)),
            icon: Badge(
                isLabelVisible: false, child: Icon(Icons.videocam_outlined)),
            label: 'Shotlist',
          ),
          // NavigationDestination(
          //   icon: Icon(Icons.playlist_play),
          //   label: 'Sequences',
          // ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: <Widget>[
          // SequencesView(),
          MessagesView(),
          ShotlistView(),
          SettingsView(controller: widget.settingsController),
        ][currentPageIndex],
      ),
    );
  }
}


  // @override
  // Widget build(BuildContext context) {
  //   // Glue the SettingsController to the MaterialApp.
  //   //
  //   // The ListenableBuilder Widget listens to the SettingsController for changes.
  //   // Whenever the user updates their settings, the MaterialApp is rebuilt.
  //   return ListenableBuilder(
  //     listenable: settingsController,
  //     builder: (BuildContext context, Widget? child) {
  //       return MaterialApp(
  //         // Providing a restorationScopeId allows the Navigator built by the
  //         // MaterialApp to restore the navigation stack when a user leaves and
  //         // returns to the app after it has been killed while running in the
  //         // background.
  //         restorationScopeId: 'app',

  //         // Provide the generated AppLocalizations to the MaterialApp. This
  //         // allows descendant Widgets to display the correct translations
  //         // depending on the user's locale.
  //         localizationsDelegates: const [
  //           AppLocalizations.delegate,
  //           GlobalMaterialLocalizations.delegate,
  //           GlobalWidgetsLocalizations.delegate,
  //           GlobalCupertinoLocalizations.delegate,
  //         ],
  //         supportedLocales: const [
  //           Locale('en', ''), // English, no country code
  //         ],

  //         // Use AppLocalizations to configure the correct application title
  //         // depending on the user's locale.
  //         //
  //         // The appTitle is defined in .arb files found in the localization
  //         // directory.
  //         onGenerateTitle: (BuildContext context) =>
  //             AppLocalizations.of(context)!.appTitle,

  //         // Define a light and dark color theme. Then, read the user's
  //         // preferred ThemeMode (light, dark, or system default) from the
  //         // SettingsController to display the correct theme.
  //         theme: ThemeData(),
  //         darkTheme: ThemeData.dark(),
  //         themeMode: settingsController.themeMode,

  //         // Define a function to handle named routes in order to support
  //         // Flutter web url navigation and deep linking.
  //         onGenerateRoute: (RouteSettings routeSettings) {
  //           return MaterialPageRoute<void>(
  //             settings: routeSettings,
  //             builder: (BuildContext context) {
  //               switch (routeSettings.name) {
  //                 case SettingsView.routeName:
  //                   return SettingsView(controller: settingsController);
  //                 case SampleItemDetailsView.routeName:
  //                   return const SampleItemDetailsView();
  //                 case SampleItemListView.routeName:
  //                 default:
  //                   return const SampleItemListView();
  //               }
  //             },
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
// }
