import 'dart:convert';

class WhatsappTemplate {
  final String id;
  final String title;
  final String category; // Portföy Sunumu, Tanışma, İlan Linki, Randevu Hatırlatma
  final String content;

  WhatsappTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'content': content,
    };
  }

  factory WhatsappTemplate.fromMap(Map<String, dynamic> map) {
    return WhatsappTemplate(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      content: map['content'],
    );
  }

  String toJson() => json.encode(toMap());

  factory WhatsappTemplate.fromJson(String source) => WhatsappTemplate.fromMap(json.decode(source));
}
