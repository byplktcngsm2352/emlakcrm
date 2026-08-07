import 'dart:convert';

enum PropertyType { daire, villa, mustakil, arsa, ticari }

enum ListingType { satilik, kiralik }

enum PropertyStatus { aktif, opsiyonlu, satildi, pasif }

class Property {
  final String id;
  final String title;
  final PropertyType type;
  final ListingType listingType;
  final double price;
  final String currency; // ₺, $, €
  final double netM2;
  final double grossM2;
  final String roomCount; // e.g. "3+1", "4+2", "Arsa"
  final int floor;
  final int totalFloors;
  final String heating; // Doğalgaz, Yerden Isıtma, Klima, VRF, Yok
  final String deedStatus; // Kat Mülkiyeti, Kat İrtifakı, Hisseli Tapu, Müstakil Tapu
  final String zoningStatus; // Konut İmarı, Ticari, Tarım, Sanayi, Yok
  final String province; // İl
  final String district; // İlçe
  final String neighborhood; // Mahalle
  final String adaParsel;
  final String description;
  final PropertyStatus status;
  final List<String> imageUrls;
  final Map<String, String> portalLinks; // {"Sahibinden": "url", "Hepsiemlak": "url"}
  final DateTime createdAt;
  final List<String> features; // Balcony, Pool, Elevator, Parking, Sea View, etc.

  Property({
    required this.id,
    required this.title,
    required this.type,
    required this.listingType,
    required this.price,
    this.currency = '₺',
    required this.netM2,
    required this.grossM2,
    required this.roomCount,
    this.floor = 1,
    this.totalFloors = 5,
    this.heating = 'Kombi (Doğalgaz)',
    this.deedStatus = 'Kat Mülkiyeti',
    this.zoningStatus = 'Konut İmarlı',
    required this.province,
    required this.district,
    required this.neighborhood,
    this.adaParsel = '',
    required this.description,
    this.status = PropertyStatus.aktif,
    required this.imageUrls,
    this.portalLinks = const {},
    required this.createdAt,
    this.features = const [],
  });

  String get typeName {
    switch (type) {
      case PropertyType.daire:
        return 'Daire';
      case PropertyType.villa:
        return 'Villa';
      case PropertyType.mustakil:
        return 'Müstakil Ev';
      case PropertyType.arsa:
        return 'Arsa / Arazi';
      case PropertyType.ticari:
        return 'İşyeri / Ticari';
    }
  }

  String get listingTypeName => listingType == ListingType.satilik ? 'Satılık' : 'Kiralık';

  String get statusName {
    switch (status) {
      case PropertyStatus.aktif:
        return 'Aktif İlan';
      case PropertyStatus.opsiyonlu:
        return 'Opsiyonlu';
      case PropertyStatus.satildi:
        return 'Satıldı / Kiralandı';
      case PropertyStatus.pasif:
        return 'Pasif / Arşiv';
    }
  }

  String get locationString => '$district, $province ($neighborhood)';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.index,
      'listingType': listingType.index,
      'price': price,
      'currency': currency,
      'netM2': netM2,
      'grossM2': grossM2,
      'roomCount': roomCount,
      'floor': floor,
      'totalFloors': totalFloors,
      'heating': heating,
      'deedStatus': deedStatus,
      'zoningStatus': zoningStatus,
      'province': province,
      'district': district,
      'neighborhood': neighborhood,
      'adaParsel': adaParsel,
      'description': description,
      'status': status.index,
      'imageUrls': imageUrls,
      'portalLinks': portalLinks,
      'createdAt': createdAt.toIso8601String(),
      'features': features,
    };
  }

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'],
      title: map['title'],
      type: PropertyType.values[map['type'] ?? 0],
      listingType: ListingType.values[map['listingType'] ?? 0],
      price: (map['price'] as num).toDouble(),
      currency: map['currency'] ?? '₺',
      netM2: (map['netM2'] as num).toDouble(),
      grossM2: (map['grossM2'] as num).toDouble(),
      roomCount: map['roomCount'] ?? '3+1',
      floor: map['floor'] ?? 1,
      totalFloors: map['totalFloors'] ?? 5,
      heating: map['heating'] ?? 'Kombi (Doğalgaz)',
      deedStatus: map['deedStatus'] ?? 'Kat Mülkiyeti',
      zoningStatus: map['zoningStatus'] ?? 'Konut İmarlı',
      province: map['province'] ?? '',
      district: map['district'] ?? '',
      neighborhood: map['neighborhood'] ?? '',
      adaParsel: map['adaParsel'] ?? '',
      description: map['description'] ?? '',
      status: PropertyStatus.values[map['status'] ?? 0],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      portalLinks: Map<String, String>.from(map['portalLinks'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']),
      features: List<String>.from(map['features'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Property.fromJson(String source) => Property.fromMap(json.decode(source));
}
