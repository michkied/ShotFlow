import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shotflow/src/connection/connection_controller.dart';
import 'package:shotflow/src/connection/connection_service.dart';
import 'package:shotflow/src/connection/types.dart';

import 'connection_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
@GenerateMocks([ConnectionService])
void main() {
  group('ConnectionService', () {
    final mockStorage = MockFlutterSecureStorage();
    final connectionService = ConnectionService(mockStorage);

    test('init returns invalidToken when url or token is empty', () async {
      when(mockStorage.read(key: 'url')).thenAnswer((_) async => '');
      when(mockStorage.read(key: 'token')).thenAnswer((_) async => '');

      final result = await connectionService.init();

      expect(result, ConnectionResult.invalidToken);
    });

    test('init calls connect when url and token are not empty', () async {
      when(mockStorage.read(key: 'url')).thenAnswer((_) async => 'ws://test');
      when(mockStorage.read(key: 'token')).thenAnswer((_) async => 'token');

      final result = await connectionService.init();

      expect(result, isNot(ConnectionResult.invalidToken));
    });

    test('setCredentials stores url and token', () async {
      await connectionService.setCredentials('ws://test', 'token');

      verify(mockStorage.write(key: 'url', value: 'ws://test')).called(1);
      verify(mockStorage.write(key: 'token', value: 'token')).called(1);
    });

    test('connect returns connectionError on failure', () async {
      connectionService
        ..url = 'ws://test'
        ..token = 'token';

      final result = await connectionService.connect();

      expect(result, ConnectionResult.connectionError);
    });

    test('clearCredentials deletes url and token', () async {
      await connectionService.clearCredentials();

      verify(mockStorage.delete(key: 'url')).called(1);
      verify(mockStorage.delete(key: 'token')).called(1);
    });
  });

  late MockConnectionService mockConnectionService;
  late ConnectionController connectionController;

  setUp(() {
    mockConnectionService = MockConnectionService();
    when(mockConnectionService.stream).thenAnswer((_) => const Stream.empty());
    when(mockConnectionService.statusStream)
        .thenAnswer((_) => const Stream.empty());
    when(mockConnectionService.init())
        .thenAnswer((_) async => ConnectionResult.success);
    connectionController =
        ConnectionController(connectionService: mockConnectionService);
  });

  group('ConnectionController', () {
    test('Connect method sets credentials and connects', () async {
      when(mockConnectionService.setCredentials(any, any))
          .thenAnswer((_) async {});
      when(mockConnectionService.connect())
          .thenAnswer((_) async => ConnectionResult.success);

      final result = await connectionController.connect('url', 'token');

      expect(result, ConnectionResult.success);
      verify(mockConnectionService.setCredentials('url', 'token')).called(1);
      verify(mockConnectionService.connect()).called(1);
    });

    test('Reconnect method sets isReconnecting and connects', () async {
      when(mockConnectionService.connect())
          .thenAnswer((_) async => ConnectionResult.success);

      await connectionController.reconnect();

      expect(connectionController.isReconnecting, true);
      verify(mockConnectionService.connect()).called(1);
    });

    test('Send chat message adds message to chatMessages and sends message',
        () {
      connectionController.sendChatMessage('Hello');

      expect(connectionController.chatMessages.length, 1);
      expect(connectionController.chatMessages.first.text, 'Hello');
      verify(mockConnectionService.sendMessage(any)).called(1);
    });

    test('Disconnect method clears credentials and disconnects', () {
      connectionController.disconnect();

      verify(mockConnectionService.clearCredentials()).called(1);
      verify(mockConnectionService.disconnect()).called(1);
    });
  });
}
