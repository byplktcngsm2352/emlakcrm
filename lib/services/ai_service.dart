import '../models/customer.dart';
import '../models/property.dart';
import '../models/matching_result.dart';
import '../services/matching_engine.dart';

enum AiTone { luksPrestij, samimiDetay, yatirimOdakli }

class AiService {
  /// AI Listing Description Generator
  static String generateListingDescription(Property property, AiTone tone) {
    final String location = '${property.neighborhood}, ${property.district} / ${property.province}';
    final String priceStr = '${property.currency}${property.price.toInt()}';
    final String featuresStr = property.features.isNotEmpty ? property.features.join(', ') : 'Otopark, Güvenlik, Balkon';

    switch (tone) {
      case AiTone.luksPrestij:
        return '''
✨ PRESTİJLİ YAŞAMIN YENİ ADRESİ: ${property.title.toUpperCase()} ✨

$location bölgesinin en seçkin konumunda yer alan bu özel ${property.typeName.toLowerCase()}, mimari zarafeti ve konforu bir arada sunuyor. 

💎 ÖNE ÇIKAN AYRICALIKLAR:
• Mülk Tipi: ${property.typeName} (${property.listingTypeName})
• Kullanım Alanı: Net ${property.netM2.toInt()} m² / Brüt ${property.grossM2.toInt()} m²
• Oda Düzeni: ${property.roomCount} ferah ve aydınlık yaşam alanları
• Kat Bilgisi: ${property.floor}. Kat / Toplam ${property.totalFloors} Kat
• Isınma & Altyapı: ${property.heating}
• Tapu Durumu: ${property.deedStatus}
• Donanım & Nitelikler: $featuresStr

🏛️ YAŞAM KALİTENİZİ YÜKSELTİN:
Yüksek tavan tasarımı, birinci sınıf malzeme kalitesi ve eşsiz atmosferi ile ayrıcalıklı bir yaşam sizleri bekliyor. Ulaşım akslarına, seçkin restoranlara ve alışveriş merkezlerine birkaç dakika mesafede.

Fiyat: $priceStr
Detaylı bilgi ve özel sunum randevusu için lütfen bizimle iletişime geçiniz.
''';

      case AiTone.samimiDetay:
        return '''
🏡 HAYALİNİZDEKİ EV SİZİ BEKLİYOR: ${property.title}

$location mahallesinde, huzurlu ve aile odaklı bir sitede yer alan ${property.roomCount} geniş ${property.typeName.toLowerCase()} portföyümüz satışa sunulmuştur!

📌 MÜLK BİLGİLERİ VE DETAYLAR:
- Net Kullanım: ${property.netM2.toInt()} m² net kullanım alanı
- Oda Sayısı: ${property.roomCount} (Kullanışlı oda dağılımı ve aydınlık salon)
- Kat: ${property.floor}. kat (Toplam ${property.totalFloors} katlı bina)
- Isınma: ${property.heating} ile ekonomik konfor
- Ek Özellikler: $featuresStr

🌱 LOKASYON AVANTAJLARI:
Okullara, semt pazarına, toplu taşıma duraklarına ve parklara yürüme mesafesinde. Ailenizle keyifle vakit geçirebileceğiniz ferah bir yaşam alanı.

💰 Satış Bedeli: $priceStr
Kaçırılmayacak bu fırsatı yerinde görmek için hemen arayın!
''';

      case AiTone.yatirimOdakli:
        return '''
🚀 YÜKSEK AMORTİSMAN & YATIRIM FIRSATI: ${property.title}

$location lokasyonunda, prim potansiyeli yüksek ve yüksek kira getirisi vaat eden stratejik ${property.typeName.toLowerCase()} fırsatı!

📊 YATIRIM VE TEKNİK ANALİZ:
• İşlem Tipi: ${property.listingTypeName}
• Metrekare: Net ${property.netM2.toInt()} m² / Brüt ${property.grossM2.toInt()} m²
• Oda/Bölüm: ${property.roomCount}
• Bölge Değer Artış Trendi: Yıllık ortalama yüksek prim ve talep gören bölge
• Tapu Status: ${property.deedStatus} (Krediye Uygun)
• Donanımlar: $featuresStr

🎯 NEDEN BU PORTFÖY?
Gelişen ulaşım hatlarına ve kurumsal merkezlere yakınlığı sayesinde boş kalmayacak, değerini her geçen gün katlayacak nitelikte bir gayrimenkul yatırımı.

Fiyat: $priceStr
Portföy analizi ve ekspertiz detayları için hemen ulaşın.
''';
    }
  }

  /// AI Customer Portfolio Pitch Recommendation Assistant
  static String generateClientRecommendationPitch(Customer customer, Property property) {
    final MatchResult match = MatchingEngine.calculateMatch(customer, property);

    final String matchedPointsText = match.matchedCriteria.map((m) => '✅ $m').join('\n');
    final String unmatchedPointsText = match.unmatchedCriteria.isNotEmpty
        ? match.unmatchedCriteria.map((u) => '💡 $u').join('\n')
        : '🌟 Tüm arama kriterlerinizle eksiksiz eşleşmektedir.';

    return '''
Sayın ${customer.name},

Size özel olarak analiz ettiğimiz ve aradığınız kriterlere %${match.score.toInt()} oranında uyum sağlayan portföyümüzü bilgilerinize sunarım:

🏠 PORTFÖY: ${property.title}
📍 Konum: ${property.locationString}
💵 Fiyat: ${property.currency}${property.price.toInt()}
📐 Özellikler: ${property.roomCount} | ${property.netM2.toInt()} m² Net | Kat: ${property.floor}

🎯 NEDEN SİZİN İÇİN EN İYİ SEÇENEK?
$matchedPointsText

${match.unmatchedCriteria.isNotEmpty ? "📌 DİKKAT EDİLEBİLECEK NOKTALAR:\n$unmatchedPointsText" : ""}

Yapay zeka portföy eşleştirme analizimize göre bu mülk, hem yaşam konforu hem de bütçe dengesi açısından aradığınız profile en yakın seçenektir.

Mülkü yerinde incelemek ve detaylı sunum randevusu oluşturmak için ne zaman uygunsunuz?

Saygılarımla,
Emlak Danışmanınız
''';
  }
}
