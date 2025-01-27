import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shotflow/src/home/custom_animations.dart';
import 'package:shotflow/src/home/disconnected_overlay.dart';

import '../connection/connection_controller.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'shotlist/shotlist_view.dart';
import 'messages/messages_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late final AnimationController _shotlistController = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  );
  late final _shotlistAnimation =
      CustomAnimations.getShotlistAnimation(_shotlistController);

  late final AnimationController _settingsController = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  );
  late final _settingsAnimation =
      CustomAnimations.getSettingsAnimation(_settingsController);

  late final AnimationController _messagesController = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  );
  late final _messagesAnimation =
      CustomAnimations.getMessagesAnimation(_messagesController);

  int currentPageIndex = 1;

  Widget getMessagesDestination() {
    return NavigationDestination(
      icon: ScaleTransition(
          scale: _messagesAnimation,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: Consumer<ConnectionController>(
                builder: (context, connection, child) {
              if (connection.unreadMessages == 0) {
                return currentPageIndex == 0
                    ? Icon(Icons.message, key: ValueKey<int>(1))
                    : Icon(Icons.message_outlined, key: ValueKey<int>(0));
              }
              return Badge(
                label: Text(connection.unreadMessages.toString()),
                child: currentPageIndex == 0
                    ? Icon(Icons.message, key: ValueKey<int>(1))
                    : Icon(Icons.message_outlined, key: ValueKey<int>(0)),
              );
            }),
          )),
      label: AppLocalizations.of(context)!.messagesLabel,
    );
  }

  Widget getShotlistDestination() {
    return NavigationDestination(
      icon: RotationTransition(
          turns: _shotlistAnimation,
          alignment: Alignment.bottomCenter,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: currentPageIndex == 1
                ? Icon(Icons.videocam_rounded, key: ValueKey<int>(1))
                : Icon(Icons.videocam_outlined, key: ValueKey<int>(0)),
          )),
      label: AppLocalizations.of(context)!.shotlistLabel,
    );
  }

  Widget getSettingsDestination() {
    return NavigationDestination(
      icon: RotationTransition(
          turns: _settingsAnimation,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: currentPageIndex == 2
                ? Icon(Icons.settings, key: ValueKey<int>(1))
                : Icon(Icons.settings_outlined, key: ValueKey<int>(0)),
          )),
      label: AppLocalizations.of(context)!.settingsLabel,
    );
  }

  Widget getTallyOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Consumer<ConnectionController>(
          builder: (context, connection, child) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: connection.getTallyColor(), // Border color
                  width: 6, // Border width
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shotlistController.dispose();
    _settingsController.dispose();
    _messagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      switch (currentPageIndex) {
        case 0:
          _messagesController.repeat(count: 1);
          break;
        case 1:
          _shotlistController.repeat(count: 1);
          break;
        case 2:
          _settingsController.repeat(count: 1);
          break;
      }
    });

    return Stack(children: [
      Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: <Widget>[
            getMessagesDestination(),
            getShotlistDestination(),
            getSettingsDestination(),
          ],
        ),
        body: SafeArea(
          child: Stack(children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: <Widget>[
                MessagesView(),
                ShotlistView(),
                Consumer<SettingsController>(
                    builder: (context, settings, child) {
                  return SettingsView(controller: settings);
                }),
              ][currentPageIndex],
            ),
            getTallyOverlay()
          ]),
        ),
      ),
      Consumer<ConnectionController>(builder: (context, connection, child) {
        if (connection.isConnected) {
          return Container();
        }
        return DisconnectedOverlay(connection: connection);
      })
    ]);
  }
}
