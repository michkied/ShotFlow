import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rxdart/rxdart.dart';

class ConnectionService {
  ConnectionService(this.url, this.token);

  String url;
  String token;

  bool get isConnected => _isConnected;
  bool _isConnected = false;

  late WebSocketChannel _channel;
  late StreamSubscription _subscription;

  final _outStreamSubject = BehaviorSubject<dynamic>();
  Stream<dynamic> get stream => _outStreamSubject.stream;

  bool _isFirstRestart = false;
  bool _isFollowingRestart = false;
  bool _isManuallyClosed = false;
  bool _isVerified = false;

  void _handleLostConnection() {
    if (_isFirstRestart && !_isFollowingRestart) {
      Future.delayed(const Duration(seconds: 3), () {
        _isFollowingRestart = false;
        connect();
      });
      _isFollowingRestart = true;
    } else {
      _isFirstRestart = true;
      connect();
    }
  }

  void connect() async {
    _isVerified = false;
    _channel = WebSocketChannel.connect(
      Uri.parse(url),
    );
    try {
      await _channel.ready;
    } catch (e) {
      print('Error connecting: $e');
      _handleLostConnection();
      return;
    }

    _channel.sink.add(token);
    _isConnected = true;
    _isManuallyClosed = false;

    _subscription = _channel.stream.listen(
      (event) {
        if (!_isVerified) {
          if (event.toString() == 'ok') {
            _isVerified = true;
          } else {
            _isVerified = false;
          }
          return;
        }
        _isFirstRestart = false;
        _outStreamSubject.add(event);
      },
      onError: (error) {
        print('Connection Error: $error');
        _isConnected = false;
        _subscription.cancel();
        _handleLostConnection();
      },
      onDone: () {
        print('Connection closed');
        _isConnected = false;
        _subscription.cancel();
        if (!_isManuallyClosed) {
          _handleLostConnection();
        }
      },
    );
  }

  void sendMessage(String message) => _channel.sink.add(message);

  void disconnect() {
    _isManuallyClosed = true;
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
