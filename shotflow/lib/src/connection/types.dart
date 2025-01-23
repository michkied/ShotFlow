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

enum ConnectionStatus {
  success,
  invalidToken,
  connectionError,
}
