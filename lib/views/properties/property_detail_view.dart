import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/property.dart';
import '../../providers/crm_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../services/ai_service.dart';
import '../../services/whatsapp_service.dart';
import 'property_form_view.dart';
import '../ai_tools/ai_studio_view.dart';

class PropertyDetailView extends StatelessWidget {
  final Property property;

  const PropertyDetailView({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Banner Sliver
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.darkSurface,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PropertyFormView(property: property)),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    property.imageUrls.isNotEmpty ? property.imageUrls.first : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.darkSurface,
                      child: const Icon(Icons.home, color: AppTheme.textMutedDark, size: 60),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldPrimary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                property.typeName.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.goldAccent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                property.listingTypeName.toUpperCase(),
                                style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          property.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppTheme.emeraldAccent, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              property.locationString,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.emeraldAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Portföy Fiyatı', style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.formatCurrency(property.price, property.currency),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.emeraldPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            property.statusName,
                            style: const TextStyle(color: AppTheme.emeraldAccent, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Action Buttons (AI Generator & WhatsApp Share)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.emeraldPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.auto_awesome, color: AppTheme.goldLight),
                          label: const Text('AI İlan Üret', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AiStudioView(initialProperty: property),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('WhatsApp Paylaş', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            _showWhatsappShareModal(context, property);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Specs Grid
                  const Text('Teknik Detaylar & Özellikler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  _buildSpecsGrid(property),

                  const SizedBox(height: 24),

                  // Features Tags
                  if (property.features.isNotEmpty) ...[
                    const Text('Nitelikler & Donanım', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: property.features.map((f) {
                        return Chip(
                          label: Text(f, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          avatar: const Icon(Icons.check_circle_outline, color: AppTheme.emeraldAccent, size: 16),
                          backgroundColor: AppTheme.darkCard,
                          side: const BorderSide(color: AppTheme.darkBorder),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  const Text('İlan Açıklaması', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                      property.description.isNotEmpty ? property.description : 'Henüz açıklama girilmemiş.',
                      style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // External Portal Links Tracker
                  if (property.portalLinks.isNotEmpty) ...[
                    const Text('Portal Bağlantıları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Column(
                      children: property.portalLinks.entries.map((entry) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.darkBorder),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.link, color: AppTheme.emeraldAccent),
                            title: Text(entry.key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text(entry.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                            trailing: const Icon(Icons.open_in_new, color: AppTheme.textSecondaryDark, size: 18),
                            onTap: () async {
                              final uri = Uri.parse(entry.value);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsGrid(Property p) {
    final items = [
      {'label': 'Mülk Tipi', 'val': p.typeName, 'icon': Icons.home_work_outlined},
      {'label': 'Net / Brüt', 'val': '${p.netM2.toInt()} / ${p.grossM2.toInt()} m²', 'icon': Icons.square_foot},
      {'label': 'Oda Sayısı', 'val': p.roomCount, 'icon': Icons.king_bed_outlined},
      {'label': 'Bulunduğu Kat', 'val': '${p.floor}. Kat (${p.totalFloors} Katlı)', 'icon': Icons.stairs},
      {'label': 'Isınma', 'val': p.heating, 'icon': Icons.local_fire_department_outlined},
      {'label': 'Tapu Durumu', 'val': p.deedStatus, 'icon': Icons.article_outlined},
      if (p.adaParsel.isNotEmpty) {'label': 'Ada / Parsel', 'val': p.adaParsel, 'icon': Icons.map_outlined},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Row(
            children: [
              Icon(item['icon'] as IconData, color: AppTheme.emeraldAccent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item['label'] as String, style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      item['val'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWhatsappShareModal(BuildContext context, Property property) {
    final provider = Provider.of<CrmProvider>(context, listen: false);
    final customers = provider.customers;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('WhatsApp İle Paylaş', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              const Text('İlan sunumunu hangi müşterinize göndermek istersiniz?', style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final cust = customers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.emeraldPrimary.withOpacity(0.2),
                        child: Text(cust.name[0], style: const TextStyle(color: AppTheme.emeraldAccent, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(cust.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(cust.phone, style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                      trailing: const Icon(Icons.send, color: Color(0xFF25D366)),
                      onTap: () {
                        Navigator.pop(context);
                        final pitchMsg = AiService.generateClientRecommendationPitch(cust, property);
                        WhatsappService.sendWhatsapp(phone: cust.phone, message: pitchMsg);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
