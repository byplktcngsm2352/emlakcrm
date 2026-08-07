import 'dart:convert';
import 'customer_criteria.dart';

enum CustomerType { alici, satici, kiraci, mulkSahibi }

enum LeadStage {
  yeniIletisim, // 1. New Lead
  kriterAlindi,  // 2. Requirements Gathered
  sunumYapildi,  // 3. Property Viewing / Presentation
  teklifAsamasi, // 4. Offer Made / Negotiation
  satisYapildi,  // 5. Deal Closed
  olumsuz        // 6. Lost / Archived
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final CustomerType type;
  final LeadStage stage;
  final String notes;
  final DateTime createdAt;
  final CustomerCriteria criteria;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    required this.type,
    this.stage = LeadStage.yeniIletisim,
    this.notes = '',
    required this.createdAt,
    required this.criteria,
  });

  String get typeName {
    switch (type) {
      case CustomerType.alici:
        return 'Alıcı Müşteri';
      case CustomerType.satici:
        return 'Satıcı Portföy Sahibi';
      case CustomerType.kiraci:
        return 'Kiracı Adayı';
      case CustomerType.mulkSahibi:
        return 'Mülk Sahibi (Kiralayan)';
    }
  }

  String get stageName {
    switch (stage) {
      case LeadStage.yeniIletisim:
        return 'Yeni İletişim';
      case LeadStage.kriterAlindi:
        return 'Kriter Alındı';
      case LeadStage.sunumYapildi:
        return 'Yer Gösterildi';
      case LeadStage.teklifAsamasi:
        return 'Teklif / Pazarlık';
      case LeadStage.satisYapildi:
        return 'Satış / Anlaşma';
      case LeadStage.olumsuz:
        return 'Olumsuz / Arşiv';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'type': type.index,
      'stage': stage.index,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'criteria': criteria.toMap(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'] ?? '',
      type: CustomerType.values[map['type'] ?? 0],
      stage: LeadStage.values[map['stage'] ?? 0],
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      criteria: CustomerCriteria.fromMap(map['criteria'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory Customer.fromJson(String source) => Customer.fromMap(json.decode(source));

  Customer copyWith({
    String? name,
    String? phone,
    String? email,
    CustomerType? type,
    LeadStage? stage,
    String? notes,
    CustomerCriteria? criteria,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      type: type ?? this.type,
      stage: stage ?? this.stage,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      criteria: criteria ?? this.criteria,
    );
  }
}
