import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'connection_service.dart';
import 'types.dart';

class ConnectionController with ChangeNotifier {
  ConnectionController({
    required this.connectionService,
    bool autoConnect = true,
  }) {
    _subscription = connectionService.stream.listen(
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
      onError: (dynamic error) {
        debugPrint('ConnectionService Error: $error');
      },
    );

    _status = connectionService.statusStream.listen(
      (event) {
        _isReconnecting = false;
        notifyListeners();
      },
      onDone: () {
        debugPrint('Service status stream closed');
      },
      onError: (dynamic error) {
        debugPrint('ConnectionService Error: $error');
      },
    );

    if (!autoConnect) {
      return;
    }

    connectionService.init().then((status) {
      switch (status) {
        case ConnectionResult.success:
          debugPrint('Connected');
          notifyListeners();
        case ConnectionResult.invalidToken:
          debugPrint('Invalid token');
          _isReconnecting = false;
          notifyListeners();
        case ConnectionResult.connectionError:
          debugPrint('Connection error');
          _isReconnecting = false;
          notifyListeners();
      }
    });
  }

  void _parseMessage(String message) {
    try {
      final jsonData = jsonDecode(message) as Map<String, dynamic>;
      switch (jsonData['type'] as String) {
        case 'shotlist_jump':
          _currentlyLive = jsonData['currently_live'] as int;
        case 'shotlist_update':
          final data = jsonData['data'] as List<dynamic>;
          _shotlist = data
              .map((e) => ShotlistEntry.fromJson(e as Map<String, dynamic>))
              .toList();
        case 'operator_assign':
          _operatorId = jsonData['operator_id'] as int;
        case 'message_history':
          final data = jsonData['messages'] as List<dynamic>;
          _chatMessages = data
              .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList();
        case 'chat_message':
          final message =
              ChatMessage.fromJson(jsonData['message'] as Map<String, dynamic>);
          _chatMessages.add(message);
          unreadMessages++;

        default:
          throw Exception('Unknown message type');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing JSON: $e');
    }
  }

  late final ConnectionService connectionService;
  late StreamSubscription<dynamic> _subscription;
  late StreamSubscription<dynamic> _status;

  bool get isConnected => connectionService.isConnected;

  bool _isReconnecting = true;
  bool get isReconnecting => _isReconnecting;

  int _currentlyLive = 0;
  int get currentlyLive => _currentlyLive;

  List<ShotlistEntry> _shotlist = [];
  List<ShotlistEntry> get shotlist => _shotlist;

  int _operatorId = 0;
  int get operatorId => _operatorId;

  List<ChatMessage> _chatMessages = [];
  List<ChatMessage> get chatMessages => _chatMessages;

  int unreadMessages = 0;

  Color getTallyColor() {
    if (_shotlist.isEmpty) {
      return Colors.transparent;
    } else if (_shotlist[_currentlyLive].operatorId == _operatorId) {
      return Colors.red;
    } else if (_shotlist[(_currentlyLive + 1).clamp(0, _shotlist.length - 1)]
            .operatorId ==
        _operatorId) {
      return Colors.green;
    } else {
      return Colors.transparent;
    }
  }

  (int, ShotlistEntry?) getNextEntry() {
    var timeUntil = 0;
    for (var i = _currentlyLive; i < _shotlist.length; i++) {
      if (_shotlist[i].operatorId == _operatorId) {
        return (timeUntil, _shotlist[i]);
      }
      timeUntil += _shotlist[i].duration;
    }
    return (-1, null);
  }

  Future<ConnectionResult> connect(String? url, String? token) async {
    if (url == null || token == null) {
      return ConnectionResult.invalidToken;
    }
    _isReconnecting = false;
    await connectionService.setCredentials(url, token);
    return connectionService.connect();
  }

  Future<void> reconnect() async {
    _isReconnecting = true;
    notifyListeners();
    final status = await connectionService.connect();
    if (status != ConnectionResult.success) {
      _isReconnecting = false;
      notifyListeners();
    }
  }

  void sendChatMessage(String text) {
    final message = ChatMessage(
      isOperator: true,
      text: text,
      name: 'You',
    );
    chatMessages.add(message);
    connectionService.sendMessage(
      '{"type": "chat_message", "message": ${jsonEncode(message)}}',
    );
  }

  void disconnect() {
    _isReconnecting = false;
    connectionService
      ..disconnect()
      ..clearCredentials();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _status.cancel();
    connectionService.dispose();
    super.dispose();
  }
}
