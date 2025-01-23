import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shotflow/src/connection/types.dart';
import 'dart:convert';

import 'connection_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class ConnectionController with ChangeNotifier {
  ConnectionController(this._connectionService) {
    _subscription = _connectionService.stream.listen(
      (event) {
        debugPrint(event.toString());
        try {
          parseMessage(event.toString());
          notifyListeners(); // Notify listeners of the change
        } catch (e) {
          debugPrint('Error parsing JSON: $e');
        }
      },
      onDone: () {
        debugPrint('Service stream closed');
      },
      onError: (error) {
        debugPrint('ConnectionService Error: $error');
      },
    );

    _connectionService.connect();
  }

  void parseMessage(String message) {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(message);
      switch (jsonData['type'] as String) {
        case 'shotlist_jump':
          _currentlyLive = jsonData['currently_live'] as int;
          break;
        case 'shotlist_update':
          final List<dynamic> data = jsonData['data'] as List<dynamic>;
          _shotlist = data.map((e) => ShotlistEntry.fromJson(e)).toList();
          break;
        case 'operator_assign':
          _operatorId = jsonData['operator_id'] as int;
          break;
        default:
          throw Exception('Unknown message type');
      }
      notifyListeners(); // Notify listeners of the change
    } catch (e) {
      debugPrint('Error parsing JSON: $e');
    }
  }

  final ConnectionService _connectionService;
  late StreamSubscription _subscription;

  int _currentlyLive = 0;
  int get currentlyLive => _currentlyLive;

  List<ShotlistEntry> _shotlist = [];
  List<ShotlistEntry> get shotlist => _shotlist;

  int _operatorId = 0;
  int get operatorId => _operatorId;

  Color get tallyColor => _shotlist.isEmpty
      ? Colors.transparent
      : _shotlist[_currentlyLive].operatorId == _operatorId
          ? Colors.red
          : _shotlist[(_currentlyLive + 1).clamp(0, _shotlist.length - 1)]
                      .operatorId ==
                  _operatorId
              ? Colors.green
              : Colors.transparent;

  @override
  void dispose() {
    _subscription.cancel();
    _connectionService.dispose();
    super.dispose();
  }
}
