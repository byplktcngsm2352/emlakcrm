import 'dart:convert';
import 'property.dart';

class CustomerCriteria {
  final double minBudget;
  final double maxBudget;
  final String currency;
  final List<String> targetDistricts;
  final List<PropertyType> preferredTypes;
  final ListingType listingType;
  final double minNetM2;
  final String preferredRoomCount; // e.g. "3+1" or "Hepsi"
  final List<String> preferredFeatures; // Balcony, Pool, Parking, Elevator, Sea View, etc.

  CustomerCriteria({
    this.minBudget = 0,
    this.maxBudget = 50000000,
    this.currency = '₺',
    this.targetDistricts = const [],
    this.preferredTypes = const [PropertyType.daire, PropertyType.villa],
    this.listingType = ListingType.satilik,
    this.minNetM2 = 80,
    this.preferredRoomCount = '3+1',
    this.preferredFeatures = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'currency': currency,
      'targetDistricts': targetDistricts,
      'preferredTypes': preferredTypes.map((e) => e.index).toList(),
      'listingType': listingType.index,
      'minNetM2': minNetM2,
      'preferredRoomCount': preferredRoomCount,
      'preferredFeatures': preferredFeatures,
    };
  }

  factory CustomerCriteria.fromMap(Map<String, dynamic> map) {
    return CustomerCriteria(
      minBudget: (map['minBudget'] as num?)?.toDouble() ?? 0,
      maxBudget: (map['maxBudget'] as num?)?.toDouble() ?? 50000000,
      currency: map['currency'] ?? '₺',
      targetDistricts: List<String>.from(map['targetDistricts'] ?? []),
      preferredTypes: (map['preferredTypes'] as List<dynamic>?)
              ?.map((e) => PropertyType.values[e])
              .toList() ??
          [PropertyType.daire, PropertyType.villa],
      listingType: ListingType.values[map['listingType'] ?? 0],
      minNetM2: (map['minNetM2'] as num?)?.toDouble() ?? 80,
      preferredRoomCount: map['preferredRoomCount'] ?? '3+1',
      preferredFeatures: List<String>.from(map['preferredFeatures'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomerCriteria.fromJson(String source) => CustomerCriteria.fromMap(json.decode(source));
}
