import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rxdart/rxdart.dart';

import 'types.dart';

class ConnectionService {
  ConnectionService();

  late String url;
  late String token;

  bool get isConnected => _isConnected;
  bool _isConnected = false;

  late WebSocketChannel _channel;
  late StreamSubscription _subscription;

  final _outStreamSubject = BehaviorSubject<dynamic>();
  Stream<dynamic> get stream => _outStreamSubject.stream;

  bool _isVerified = false;

  void setCredentials(String url, String token) {
    this.url = url;
    this.token = token;
  }

  Future<ConnectionStatus> connect() async {
    _isVerified = false;
    _channel = WebSocketChannel.connect(
      Uri.parse(url),
    );
    try {
      await _channel.ready;
    } catch (e) {
      debugPrint('Error connecting: $e');
      return ConnectionStatus.connectionError;
    }

    _channel.sink.add(token);
    _isConnected = true;

    final completer = Completer<ConnectionStatus>();

    _subscription = _channel.stream.listen(
      (event) {
        if (!_isVerified) {
          if (event.toString() == 'ok') {
            _isVerified = true;
            completer.complete(ConnectionStatus.success);
          } else {
            completer.complete(ConnectionStatus.invalidToken);
          }
          return;
        }
        _outStreamSubject.add(event);
      },
      onError: (error) {
        debugPrint('Connection Error: $error');
        _isConnected = false;
        _subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete(ConnectionStatus.connectionError);
        }
      },
      onDone: () {
        debugPrint('Connection closed');
        _isConnected = false;
        _subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete(ConnectionStatus.connectionError);
        }
      },
    );

    return completer.future;
  }

  void sendMessage(String message) => _channel.sink.add(message);

  void disconnect() {
    _subscription.cancel();
    _channel.sink.close();
  }

  void restart() {
    disconnect();
    connect();
  }

  void dispose() {
    _subscription.cancel();
    _channel.sink.close();
    _outStreamSubject.close();
  }
}
