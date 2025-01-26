import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'connection/connection_controller.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'shotlist/shotlist_view.dart';
import 'messages/messages_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
          selectedIndex: currentPageIndex,
          destinations: <Widget>[
            NavigationDestination(
              icon: Consumer<ConnectionController>(
                  builder: (context, connection, child) {
                if (connection.unreadMessages == 0) {
                  return Icon(Icons.message_outlined);
                }
                return Badge(
                  label: Text(connection.unreadMessages.toString()),
                  child: Icon(Icons.message_outlined),
                );
              }),
              selectedIcon: Icon(Icons.message),
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
        body: SafeArea(
          child: Stack(children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: <Widget>[
                // SequencesView(),
                MessagesView(),
                ShotlistView(),
                Consumer<SettingsController>(
                    builder: (context, settings, child) {
                  return SettingsView(controller: settings);
                }),
              ][currentPageIndex],
            ),
            Positioned.fill(
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
            ),
          ]),
        ),
      ),
      Consumer<ConnectionController>(builder: (context, connection, child) {
        if (connection.isConnected) {
          return Container();
        }
        return Positioned.fill(
          child: Container(
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  DefaultTextStyle(
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    child: Text('Connection lost.'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text('Go to login page'),
                  ),
                  SizedBox(height: 60),
                  if (connection.isReconnecting) ...[
                    DefaultTextStyle(
                      style: TextStyle(fontSize: 14),
                      child: Text('Attempting to reconnect...'),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 10,
                      child: CircularProgressIndicator(),
                    ),
                  ] else ...[
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      child: Text("Can't connect to the server."),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        connection.reconnect();
                      },
                      child: Text('Try again'),
                    ),
                  ]
                ],
              ),
            ),
          ),
        );
      })
    ]);
  }
}
