class ShotlistEntry {
  final int id;
  final String title;
  final int operatorId;
  final String operatorName;
  final int duration;

  ShotlistEntry(
      this.id, this.title, this.operatorId, this.operatorName, this.duration);

  factory ShotlistEntry.fromJson(Map<String, dynamic> json) {
    return ShotlistEntry(
      json['id'] as int,
      json['title'] as String,
      json['operator_id'] as int,
      json['operator_name'] as String,
      json['duration'] as int,
    );
  }
}

enum ConnectionResult {
  success,
  invalidToken,
  connectionError,
}

class ChatMessage {
  ChatMessage(
      {required this.isOperator, required this.text, required this.name});

  final bool isOperator;
  final String name;
  final String text;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
        isOperator: json['sender'] == "You",
        text: json['message'],
        name: json['sender']);
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': isOperator ? 'You' : name,
      'message': text,
    };
  }
}
