import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shotflow/src/connection/types.dart';
import 'dart:convert';

import 'connection_service.dart';

class ConnectionController with ChangeNotifier {
  ConnectionController() {
    _connectionService = ConnectionService();
    _subscription = _connectionService.stream.listen(
      (event) {
        debugPrint(event.toString());
        try {
          _parseMessage(event.toString());
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
  }

  void _parseMessage(String message) {
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
      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing JSON: $e');
    }
  }

  late final ConnectionService _connectionService;
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

  Future<ConnectionStatus> connect(String url, String token) {
    _connectionService.setCredentials(url, token);
    return _connectionService.connect();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _connectionService.dispose();
    super.dispose();
  }
}
