import '../models/customer.dart';
import '../models/customer_criteria.dart';
import '../models/matching_result.dart';
import '../models/property.dart';

class MatchingEngine {
  /// Computes matching score between a Customer and a Property
  static MatchResult calculateMatch(Customer customer, Property property) {
    final CustomerCriteria criteria = customer.criteria;
    double totalWeight = 0;
    double earnedWeight = 0;

    final List<String> matched = [];
    final List<String> unmatched = [];

    // 1. Listing Type Match (Satılık / Kiralık) - Weight 20%
    totalWeight += 20;
    if (property.listingType == criteria.listingType) {
      earnedWeight += 20;
      matched.add('İlan Türü Uyuşuyor (${property.listingTypeName})');
    } else {
      unmatched.add('İlan Türü Farklı (Müşteri: ${criteria.listingType == ListingType.satilik ? "Satılık" : "Kiralık"}, Mülk: ${property.listingTypeName})');
    }

    // 2. Budget Range Match - Weight 30%
    totalWeight += 30;
    final double price = property.price;
    if (price >= criteria.minBudget && price <= criteria.maxBudget) {
      earnedWeight += 30;
      matched.add('Bütçe Kriterine Uygun (${property.currency}${_formatNum(price)})');
    } else if (price <= criteria.maxBudget * 1.15) {
      // 15% budget stretch room
      earnedWeight += 18;
      matched.add('Bütçeye Yakın (%15 Pazarlık Alanı)');
    } else if (price < criteria.minBudget) {
      earnedWeight += 25;
      matched.add('Müşteri Bütçesinin Altında (Cazip Fiyat)');
    } else {
      unmatched.add('Fiyat Bütçeyi Aşıyor (${property.currency}${_formatNum(price)} > Max: ${criteria.currency}${_formatNum(criteria.maxBudget)})');
    }

    // 3. Property Type Match - Weight 20%
    totalWeight += 20;
    if (criteria.preferredTypes.isEmpty || criteria.preferredTypes.contains(property.type)) {
      earnedWeight += 20;
      matched.add('Mülk Tipi Tercihiyle Eşleşiyor (${property.typeName})');
    } else {
      unmatched.add('Farklı Mülk Tipi (${property.typeName})');
    }

    // 4. District / Location Overlap - Weight 15%
    totalWeight += 15;
    if (criteria.targetDistricts.isEmpty) {
      earnedWeight += 15;
      matched.add('Lokasyon Esnek');
    } else {
      final bool districtMatch = criteria.targetDistricts.any(
        (d) => d.toLowerCase().contains(property.district.toLowerCase()) || property.district.toLowerCase().contains(d.toLowerCase()),
      );
      if (districtMatch) {
        earnedWeight += 15;
        matched.add('Aranan İlçe (${property.district})');
      } else {
        unmatched.add('Farklı Bölgede (${property.district})');
      }
    }

    // 5. Min Net m2 Match - Weight 10%
    totalWeight += 10;
    if (property.netM2 >= criteria.minNetM2) {
      earnedWeight += 10;
      matched.add('Metrekare Yeterli (${property.netM2.toInt()} m² >= Min: ${criteria.minNetM2.toInt()} m²)');
    } else {
      final double diff = criteria.minNetM2 - property.netM2;
      unmatched.add('Beklenenden ${diff.toInt()} m² daha küçük (${property.netM2.toInt()} m²)');
    }

    // 6. Features Overlap - Weight 5%
    if (criteria.preferredFeatures.isNotEmpty) {
      totalWeight += 5;
      int matchedCount = 0;
      for (final f in criteria.preferredFeatures) {
        if (property.features.contains(f)) {
          matchedCount++;
        }
      }
      if (matchedCount > 0) {
        final double featureEarned = (matchedCount / criteria.preferredFeatures.length) * 5;
        earnedWeight += featureEarned;
        matched.add('$matchedCount Özellik Eşleşti (${criteria.preferredFeatures.where((f) => property.features.contains(f)).join(", ")})');
      }
    }

    final double score = (earnedWeight / totalWeight) * 100;

    return MatchResult(
      customer: customer,
      property: property,
      score: score.clamp(0, 100),
      matchedCriteria: matched,
      unmatchedCriteria: unmatched,
    );
  }

  static String _formatNum(double num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(0)}K';
    }
    return num.toStringAsFixed(0);
  }
}
