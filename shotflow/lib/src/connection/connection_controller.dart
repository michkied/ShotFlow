import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'connection_service.dart';
import 'types.dart';

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

    _status = _connectionService.statusStream.listen(
      (event) {
        _isReconnecting = false;
        notifyListeners();
      },
      onDone: () {
        debugPrint('Service status stream closed');
      },
      onError: (error) {
        debugPrint('ConnectionService Error: $error');
      },
    );

    _connectionService.init().then((status) {
      switch (status) {
        case ConnectionResult.success:
          debugPrint('Connected');
          notifyListeners();
          break;
        case ConnectionResult.invalidToken:
          debugPrint('Invalid token');
          _isReconnecting = false;
          notifyListeners();
          break;
        case ConnectionResult.connectionError:
          debugPrint('Connection error');
          _isReconnecting = false;
          notifyListeners();
          break;
      }
    });
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
  late StreamSubscription _status;

  bool get isConnected => _connectionService.isConnected;

  bool _isReconnecting = true;
  bool get isReconnecting => _isReconnecting;

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

  Future<ConnectionResult> connect(String url, String token) async {
    _isReconnecting = false;
    await _connectionService.setCredentials(url, token);
    return _connectionService.connect();
  }

  Future<void> reconnect() async {
    _isReconnecting = true;
    notifyListeners();
    final status = await _connectionService.connect();
    if (status != ConnectionResult.success) {
      _isReconnecting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _connectionService.dispose();
    super.dispose();
  }
}
