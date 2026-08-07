import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/whatsapp_template.dart';
import '../../providers/crm_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/whatsapp_service.dart';

class WhatsappTemplatesView extends StatelessWidget {
  const WhatsappTemplatesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CrmProvider>(
      builder: (context, provider, child) {
        final templates = provider.templates;

        return Scaffold(
          appBar: AppBar(
            title: const Text('WhatsApp Şablonları', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Info banner on dynamic variables
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.emeraldAccent.withOpacity(0.4)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.emeraldAccent, size: 18),
                        SizedBox(width: 8),
                        Text('Dinamik Şablon Değişkenleri', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Şablonlarınızda {Müşteri_Adı}, {Portföy_Başlık}, {Fiyat}, {Oda_Sayısı}, {Konum}, {İlan_Linki} etiketlerini kullanabilirsiniz. Mesaj gönderilirken otomatik doldurulur.',
                      style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('Kayıtlı Mesaj Şablonları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),

              ...templates.map((tpl) => _buildTemplateCard(context, provider, tpl)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemplateCard(BuildContext context, CrmProvider provider, WhatsappTemplate tpl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tpl.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(tpl.category, style: const TextStyle(color: AppTheme.goldAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(tpl.content, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.darkBorder)),
                  icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                  label: const Text('Kopyala', style: TextStyle(color: Colors.white, fontSize: 12)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: tpl.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Şablon kopyalandı!'), backgroundColor: AppTheme.emeraldPrimary),
                    );
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Test Gönder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (provider.customers.isNotEmpty) {
                      final cust = provider.customers.first;
                      final prop = provider.allProperties.isNotEmpty ? provider.allProperties.first : null;
                      final parsed = WhatsappService.parseTemplate(content: tpl.content, customer: cust, property: prop);
                      WhatsappService.sendWhatsapp(phone: cust.phone, message: parsed);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
