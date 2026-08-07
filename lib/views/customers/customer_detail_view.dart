import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/customer.dart';
import '../../providers/crm_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../services/matching_engine.dart';
import '../../services/whatsapp_service.dart';
import 'customer_form_view.dart';
import '../properties/property_detail_view.dart';

class CustomerDetailView extends StatelessWidget {
  final Customer customer;

  const CustomerDetailView({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Consumer<CrmProvider>(
      builder: (context, provider, child) {
        // Compute real-time matched properties for this customer
        final matches = provider.properties
            .map((p) => MatchingEngine.calculateMatch(customer, p))
            .where((m) => m.score >= 50)
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));

        return Scaffold(
          appBar: AppBar(
            title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CustomerFormView(customer: customer)),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Customer Profile Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.emeraldPrimary.withOpacity(0.2),
                          child: Text(
                            customer.name[0].toUpperCase(),
                            style: const TextStyle(color: AppTheme.emeraldAccent, fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(customer.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(customer.typeName, style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.emeraldPrimary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Aşama: ${customer.stageName}', style: const TextStyle(color: AppTheme.emeraldAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.darkBorder),
                    const SizedBox(height: 8),

                    // Quick Contact Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildContactButton(
                          icon: Icons.phone,
                          label: 'Hemen Ara',
                          color: AppTheme.infoBlue,
                          onTap: () async {
                            final uri = Uri.parse('tel:${customer.phone}');
                            if (await canLaunchUrl(uri)) await launchUrl(uri);
                          },
                        ),
                        _buildContactButton(
                          icon: Icons.chat,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          onTap: () {
                            WhatsappService.sendWhatsapp(phone: customer.phone, message: 'Merhaba ${customer.name}, size özel yeni portföylerimiz hazır.');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Search Criteria Summary Card
              const Text('Arama Kriterleri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Column(
                  children: [
                    _buildCriteriaRow('Bütçe Aralığı', '${customer.criteria.currency}${Formatters.formatCompactCurrency(customer.criteria.minBudget)} - ${Formatters.formatCompactCurrency(customer.criteria.maxBudget)}'),
                    const SizedBox(height: 8),
                    _buildCriteriaRow('Hedef Bölgeler', customer.criteria.targetDistricts.isNotEmpty ? customer.criteria.targetDistricts.join(', ') : 'Tüm Bölgeler'),
                    const SizedBox(height: 8),
                    _buildCriteriaRow('Minimum Net m²', '${customer.criteria.minNetM2.toInt()} m²'),
                    const SizedBox(height: 8),
                    _buildCriteriaRow('Tercih Edilen Oda', customer.criteria.preferredRoomCount),
                    const SizedBox(height: 8),
                    _buildCriteriaRow('İlan Türü', customer.criteria.listingType.name.toUpperCase()),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Auto-Matched Portfolios Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Otomatik Eşleşen Portföyler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.emeraldPrimary, borderRadius: BorderRadius.circular(10)),
                    child: Text('${matches.length} Uyumlu', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              matches.isEmpty
                  ? const Center(child: Text('Müşteri kriterleriyle yüksek uyumlu mülk henüz yok.', style: TextStyle(color: AppTheme.textSecondaryDark)))
                  : Column(
                      children: matches.map((match) {
                        final prop = match.property;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.darkBorder),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PropertyDetailView(property: prop)),
                              );
                            },
                            title: Text(prop.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text('${prop.locationString} • ${Formatters.formatCurrency(prop.price, prop.currency)}', style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.emeraldAccent),
                              ),
                              child: Text(
                                '%${match.score.toInt()} Uyum',
                                style: const TextStyle(color: AppTheme.emeraldAccent, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 24),

              // Notes
              const Text('Müşteri Notları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Text(
                  customer.notes.isNotEmpty ? customer.notes : 'Not eklenmemiş.',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaRow(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13)),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
