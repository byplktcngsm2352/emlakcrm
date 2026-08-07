import 'dart:convert';

class ActivityLog {
  final String id;
  final String userId;
  final String userName;
  final String userTitle;
  final String action; // e.g. "Yeni Portföy Eklendi: Bebek Penthouse"
  final String details;
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.userName,
    this.userTitle = 'Danışman',
    required this.action,
    this.details = '',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userTitle': userTitle,
      'action': action,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      userTitle: map['userTitle'] ?? 'Danışman',
      action: map['action'],
      details: map['details'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ActivityLog.fromJson(String source) => ActivityLog.fromMap(json.decode(source));
}
