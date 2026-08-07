import 'customer.dart';
import 'property.dart';

class MatchResult {
  final Customer customer;
  final Property property;
  final double score; // 0.0 - 100.0 %
  final List<String> matchedCriteria; // Bullet points of matched features/criteria
  final List<String> unmatchedCriteria; // Bullet points of missing or mismatched criteria

  MatchResult({
    required this.customer,
    required this.property,
    required this.score,
    required this.matchedCriteria,
    required this.unmatchedCriteria,
  });

  String get matchCategory {
    if (score >= 85) return 'Mükemmel Uyum (%${score.toInt()})';
    if (score >= 65) return 'Yüksek Uyum (%${score.toInt()})';
    if (score >= 45) return 'Orta Uyum (%${score.toInt()})';
    return 'Düşük Uyum (%${score.toInt()})';
  }
}
