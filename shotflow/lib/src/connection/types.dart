class ShotlistEntry {
  ShotlistEntry(
    this.id,
    this.title,
    this.operatorId,
    this.operatorName,
    this.duration,
  );

  factory ShotlistEntry.fromJson(Map<String, dynamic> json) {
    return ShotlistEntry(
      json['id'] as int,
      json['title'] as String,
      json['operator_id'] as int,
      json['operator_name'] as String,
      json['duration'] as int,
    );
  }
  final int id;
  final String title;
  final int operatorId;
  final String operatorName;
  final int duration;
}

enum ConnectionResult {
  success,
  invalidToken,
  connectionError,
}

class ChatMessage {
  ChatMessage({
    required this.isOperator,
    required this.text,
    required this.name,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      isOperator: json['sender'] == 'You',
      text: json['message'].toString(),
      name: json['sender'].toString(),
    );
  }

  final bool isOperator;
  final String name;
  final String text;

  Map<String, dynamic> toJson() {
    return {
      'sender': isOperator ? 'You' : name,
      'message': text,
    };
  }
}
