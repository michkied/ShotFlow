import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rxdart/rxdart.dart';

import 'types.dart';

class ConnectionService {
  ConnectionService(FlutterSecureStorage storage) : _storage = storage;

  Future<ConnectionResult> init() async {
    url = await _storage.read(key: 'url') ?? '';
    token = await _storage.read(key: 'token') ?? '';
    if (url.isEmpty || token.isEmpty) {
      return ConnectionResult.invalidToken;
    }
    return await connect();
  }

  FlutterSecureStorage _storage;

  String url = '';
  String token = '';

  bool get isConnected => _isConnected;
  bool _isConnected = false;

  late WebSocketChannel _channel;
  late StreamSubscription _subscription;
  bool _initialized = false;

  final _outStreamSubject = BehaviorSubject<dynamic>();
  Stream<dynamic> get stream => _outStreamSubject.stream;

  final _statusStreamSubject = BehaviorSubject<dynamic>();
  Stream<dynamic> get statusStream => _statusStreamSubject.stream;

  bool _isVerified = false;

  Future<void> setCredentials(String url, String token) async {
    this.url = url;
    this.token = token;
    await _storage.write(key: 'url', value: url);
    await _storage.write(key: 'token', value: token);
  }

  Future<ConnectionResult> connect() async {
    if (_isConnected) {
      disconnect();
    }
    _isVerified = false;
    _channel = WebSocketChannel.connect(
      Uri.parse(url),
    );
    try {
      await _channel.ready.timeout(Duration(seconds: 5));
    } catch (e) {
      debugPrint('Error connecting: $e');
      return ConnectionResult.connectionError;
    }

    _channel.sink.add(token);
    _isConnected = true;

    final completer = Completer<ConnectionResult>();

    _subscription = _channel.stream.listen(
      (event) {
        if (!_isVerified) {
          if (event.toString() == 'ok') {
            _isVerified = true;
            completer.complete(ConnectionResult.success);
          } else {
            completer.complete(ConnectionResult.invalidToken);
          }
          return;
        }
        _outStreamSubject.add(event);
      },
      onError: (error) {
        debugPrint('Connection Error: $error');
        _isConnected = false;
        _subscription.cancel();
        _statusStreamSubject.add('disconnected'); // Notify listeners
        if (!completer.isCompleted) {
          completer.complete(ConnectionResult.connectionError);
        }
      },
      onDone: () {
        debugPrint('Connection closed');
        _isConnected = false;
        _subscription.cancel();
        _statusStreamSubject.add('disconnected'); // Notify listeners
        if (!completer.isCompleted) {
          completer.complete(ConnectionResult.connectionError);
        }
      },
    );

    _initialized = true;

    return completer.future;
  }

  void sendMessage(String message) => _channel.sink.add(message);

  void disconnect() {
    _subscription.cancel();
    _channel.sink.close();
    _statusStreamSubject.add('disconnected'); // Notify listeners
  }

  void reconnect() {
    if (_initialized) {
      disconnect();
    }
    connect();
  }

  void dispose() {
    _subscription.cancel();
    _channel.sink.close();
    _outStreamSubject.close();
    _statusStreamSubject.close();
  }
}
