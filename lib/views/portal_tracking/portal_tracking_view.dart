import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/crm_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class PortalTrackingView extends StatelessWidget {
  const PortalTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CrmProvider>(
      builder: (context, provider, child) {
        final trackedProps = provider.allProperties.where((p) => p.portalLinks.isNotEmpty).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Portal İlan Takibi', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.travel_explore, color: AppTheme.emeraldAccent, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Harici Portal İlanları', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('${trackedProps.length} Portföy Portal Bağlantılı', style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (trackedProps.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('Henüz harici portal linki eklenmiş ilan bulunmuyor.', style: TextStyle(color: AppTheme.textSecondaryDark)),
                  ),
                )
              else
                ...trackedProps.map((prop) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(prop.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            '${prop.locationString} • ${Formatters.formatCurrency(prop.price, prop.currency)}',
                            style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppTheme.darkBorder),
                          const SizedBox(height: 8),

                          Column(
                            children: prop.portalLinks.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.goldAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(entry.key, style: const TextStyle(color: AppTheme.goldAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(entry.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.open_in_new, color: AppTheme.emeraldAccent, size: 18),
                                      onPressed: () async {
                                        final uri = Uri.parse(entry.value);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
