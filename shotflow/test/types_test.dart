import 'package:flutter_test/flutter_test.dart';
import 'package:shotflow/src/connection/types.dart';

void main() {
  group('ShotlistEntry', () {
    test('fromJson creates a valid instance', () {
      final json = {
        'id': 1,
        'title': 'Test Title',
        'operator_id': 2,
        'operator_name': 'Operator Name',
        'duration': 120,
      };

      final entry = ShotlistEntry.fromJson(json);

      expect(entry.id, 1);
      expect(entry.title, 'Test Title');
      expect(entry.operatorId, 2);
      expect(entry.operatorName, 'Operator Name');
      expect(entry.duration, 120);
    });
  });

  group('ChatMessage', () {
    test('fromJson creates a valid instance', () {
      final json = {
        'sender': 'You',
        'message': 'Hello',
      };

      final message = ChatMessage.fromJson(json);

      expect(message.isOperator, true);
      expect(message.name, 'You');
      expect(message.text, 'Hello');
    });

    test('toJson returns a valid map', () {
      final message = ChatMessage(isOperator: true, text: 'Hello', name: 'You');

      final json = message.toJson();

      expect(json['sender'], 'You');
      expect(json['message'], 'Hello');
    });
  });
}
