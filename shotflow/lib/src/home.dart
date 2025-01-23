import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'connection/connection_controller.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'shotlist/shotlist_view.dart';
import 'messages/messages_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
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
            Consumer<SettingsController>(builder: (context, settings, child) {
              return SettingsView(controller: settings);
            }),
          ][currentPageIndex],
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: Consumer<ConnectionController>(
            builder: (context, connection, child) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: connection.tallyColor, // Border color
                    width: 4, // Border width
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ]);
  }
}
