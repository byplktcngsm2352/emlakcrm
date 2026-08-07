import 'dart:convert';

enum ReminderType { yerGosterme, geriArama, tapuRandevusu, genel }

class Reminder {
  final String id;
  final String title;
  final String note;
  final DateTime dateTime;
  final ReminderType type;
  final String? customerId;
  final String? propertyId;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.title,
    this.note = '',
    required this.dateTime,
    this.type = ReminderType.genel,
    this.customerId,
    this.propertyId,
    this.isCompleted = false,
  });

  String get typeName {
    switch (type) {
      case ReminderType.yerGosterme:
        return 'Yer Gösterme Randevusu';
      case ReminderType.geriArama:
        return 'Müşteri Geri Arama';
      case ReminderType.tapuRandevusu:
        return 'Tapu Randevusu';
      case ReminderType.genel:
        return 'Genel Görev';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'dateTime': dateTime.toIso8601String(),
      'type': type.index,
      'customerId': customerId,
      'propertyId': propertyId,
      'isCompleted': isCompleted,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      note: map['note'] ?? '',
      dateTime: DateTime.parse(map['dateTime']),
      type: ReminderType.values[map['type'] ?? 0],
      customerId: map['customerId'],
      propertyId: map['propertyId'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Reminder.fromJson(String source) => Reminder.fromMap(json.decode(source));

  Reminder copyWith({
    String? title,
    String? note,
    DateTime? dateTime,
    ReminderType? type,
    bool? isCompleted,
  }) {
    return Reminder(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      customerId: customerId,
      propertyId: propertyId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
