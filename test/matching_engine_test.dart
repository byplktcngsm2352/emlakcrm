import 'package:flutter_test/flutter_test.dart';
import 'package:emlak_crm/models/customer.dart';
import 'package:emlak_crm/models/customer_criteria.dart';
import 'package:emlak_crm/models/property.dart';
import 'package:emlak_crm/services/matching_engine.dart';
import 'package:emlak_crm/services/whatsapp_service.dart';

void main() {
  group('Smart Matching Engine Tests', () {
    test('Calculate perfect match score for matching criteria', () {
      final customer = Customer(
        id: 'c1',
        name: 'Ahmet Yılmaz',
        phone: '+905321112233',
        type: CustomerType.alici,
        createdAt: DateTime.now(),
        criteria: CustomerCriteria(
          minBudget: 10000000,
          maxBudget: 40000000,
          targetDistricts: ['Beşiktaş'],
          preferredTypes: [PropertyType.daire],
          listingType: ListingType.satilik,
          minNetM2: 150,
        ),
      );

      final property = Property(
        id: 'p1',
        title: 'Beşiktaş Bebek Daire',
        type: PropertyType.daire,
        listingType: ListingType.satilik,
        price: 30000000,
        netM2: 200,
        grossM2: 230,
        roomCount: '4+1',
        province: 'İstanbul',
        district: 'Beşiktaş',
        neighborhood: 'Bebek',
        description: 'Lüks daire',
        imageUrls: [],
        createdAt: DateTime.now(),
      );

      final match = MatchingEngine.calculateMatch(customer, property);
      expect(match.score, equals(100.0));
      expect(match.matchedCriteria.isNotEmpty, true);
      expect(match.unmatchedCriteria.isEmpty, true);
    });

    test('Calculate lower score when budget exceeds max budget', () {
      final customer = Customer(
        id: 'c2',
        name: 'Mehmet Demir',
        phone: '+905427778899',
        type: CustomerType.alici,
        createdAt: DateTime.now(),
        criteria: CustomerCriteria(
          minBudget: 5000000,
          maxBudget: 10000000,
          targetDistricts: ['Kadıköy'],
          preferredTypes: [PropertyType.daire],
          listingType: ListingType.satilik,
          minNetM2: 100,
        ),
      );

      final property = Property(
        id: 'p2',
        title: 'Pahalı Kadıköy Villa',
        type: PropertyType.villa,
        listingType: ListingType.satilik,
        price: 50000000, // Exceeds budget significantly
        netM2: 300,
        grossM2: 350,
        roomCount: '5+1',
        province: 'İstanbul',
        district: 'Kadıköy',
        neighborhood: 'Suadiye',
        description: 'Lüks villa',
        imageUrls: [],
        createdAt: DateTime.now(),
      );

      final match = MatchingEngine.calculateMatch(customer, property);
      expect(match.score, lessThan(80.0));
      expect(match.unmatchedCriteria.any((u) => u.contains('Fiyat Bütçeyi Aşıyor')), true);
    });
  });

  group('WhatsApp Template Engine Tests', () {
    test('Parses placeholders correctly', () {
      const template = 'Merhaba {Müşteri_Adı}, {Portföy_Başlık} ilanımızın fiyatı {Fiyat}.';
      final customer = Customer(
        id: 'c1',
        name: 'Zeynep Kaya',
        phone: '+905051112233',
        type: CustomerType.alici,
        createdAt: DateTime.now(),
        criteria: CustomerCriteria(),
      );

      final property = Property(
        id: 'p1',
        title: 'Bodrum Villa',
        type: PropertyType.villa,
        listingType: ListingType.satilik,
        price: 25000000,
        currency: '₺',
        netM2: 250,
        grossM2: 300,
        roomCount: '4+1',
        province: 'Muğla',
        district: 'Bodrum',
        neighborhood: 'Yalıkavak',
        description: 'Harika villa',
        imageUrls: [],
        createdAt: DateTime.now(),
      );

      final result = WhatsappService.parseTemplate(
        content: template,
        customer: customer,
        property: property,
      );

      expect(result, contains('Zeynep Kaya'));
      expect(result, contains('Bodrum Villa'));
      expect(result, contains('₺25000000'));
    });
  });
}
