import 'package:url_launcher/url_launcher.dart';
import '../models/customer.dart';
import '../models/property.dart';

class WhatsappService {
  /// Replaces placeholder variables in WhatsApp template
  static String parseTemplate({
    required String content,
    Customer? customer,
    Property? property,
    String? customLink,
  }) {
    String parsed = content;

    if (customer != null) {
      parsed = parsed.replaceAll('{Müşteri_Adı}', customer.name);
      parsed = parsed.replaceAll('{Telefon}', customer.phone);
    } else {
      parsed = parsed.replaceAll('{Müşteri_Adı}', 'Değerli Müşterimiz');
    }

    if (property != null) {
      parsed = parsed.replaceAll('{Portföy_Başlık}', property.title);
      parsed = parsed.replaceAll('{Fiyat}', '${property.currency}${property.price.toInt()}');
      parsed = parsed.replaceAll('{Oda_Sayısı}', property.roomCount);
      parsed = parsed.replaceAll('{Konum}', property.locationString);
      parsed = parsed.replaceAll('{m2}', '${property.netM2.toInt()} m²');
      
      final String link = customLink ?? (property.portalLinks.values.isNotEmpty ? property.portalLinks.values.first : '');
      parsed = parsed.replaceAll('{İlan_Linki}', link);
    }

    return parsed;
  }

  /// Sends a WhatsApp message directly to a phone number
  static Future<bool> sendWhatsapp({
    required String phone,
    required String message,
  }) async {
    // Sanitize phone number (keep digits only)
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanPhone.startsWith('+') && !cleanPhone.startsWith('90')) {
      if (cleanPhone.startsWith('0')) {
        cleanPhone = '90${cleanPhone.substring(1)}';
      } else {
        cleanPhone = '90$cleanPhone';
      }
    }
    cleanPhone = cleanPhone.replaceAll('+', '');

    final String encodedMsg = Uri.encodeComponent(message);
    final Uri whatsappAppUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedMsg');
    final Uri whatsappWebUri = Uri.parse('https://api.whatsapp.com/send?phone=$cleanPhone&text=$encodedMsg');

    try {
      if (await canLaunchUrl(whatsappAppUri)) {
        return await launchUrl(whatsappAppUri);
      } else if (await canLaunchUrl(whatsappWebUri)) {
        return await launchUrl(whatsappWebUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('WhatsApp launch error: $e');
    }
    return false;
  }
}
