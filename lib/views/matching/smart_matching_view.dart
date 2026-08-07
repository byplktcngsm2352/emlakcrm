import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer.dart';
import '../../models/matching_result.dart';
import '../../models/property.dart';
import '../../providers/crm_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../services/matching_engine.dart';
import '../../services/ai_service.dart';
import '../../services/whatsapp_service.dart';
import '../properties/property_detail_view.dart';

class SmartMatchingView extends StatefulWidget {
  const SmartMatchingView({super.key});

  @override
  State<SmartMatchingView> createState() => _SmartMatchingViewState();
}

class _SmartMatchingViewState extends State<SmartMatchingView> {
  Customer? _selectedCustomer;

  @override
  Widget build(BuildContext context) {
    return Consumer<CrmProvider>(
      builder: (context, provider, child) {
        final customers = provider.customers;
        final properties = provider.allProperties;

        if (_selectedCustomer == null && customers.isNotEmpty) {
          _selectedCustomer = customers.first;
        }

        List<MatchResult> matchResults = [];
        if (_selectedCustomer != null) {
          matchResults = properties
              .map((p) => MatchingEngine.calculateMatch(_selectedCustomer!, p))
              .toList()
            ..sort((a, b) => b.score.compareTo(a.score));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Akıllı Portföy Eşleştirme', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: Column(
            children: [
              // Customer Selection Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.darkSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Eşleştirme Yapılacak Müşteri', style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.emeraldAccent.withOpacity(0.4)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Customer>(
                          isExpanded: true,
                          value: _selectedCustomer,
                          dropdownColor: AppTheme.darkCard,
                          items: customers.map((c) {
                            return DropdownMenuItem<Customer>(
                              value: c,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppTheme.emeraldPrimary,
                                    child: Text(c.name[0], style: const TextStyle(color: Colors.white, fontSize: 11)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${c.name} (${c.criteria.targetDistricts.isNotEmpty ? c.criteria.targetDistricts.first : "Tüm Bölgeler"})',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCustomer = val;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Match Results List Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCustomer != null ? '${_selectedCustomer!.name} için Sonuçlar' : 'Eşleşen Portföyler',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      '${matchResults.length} Portföy Tarandı',
                      style: const TextStyle(color: AppTheme.emeraldAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Match Results List
              Expanded(
                child: matchResults.isEmpty
                    ? const Center(child: Text('Portföy bulunamadı.', style: TextStyle(color: AppTheme.textSecondaryDark)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: matchResults.length,
                        itemBuilder: (context, index) {
                          final match = matchResults[index];
                          return _buildMatchResultCard(context, match);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchResultCard(BuildContext context, MatchResult match) {
    final Property prop = match.property;
    final Color scoreColor = match.score >= 80
        ? AppTheme.emeraldAccent
        : (match.score >= 60 ? AppTheme.goldAccent : AppTheme.warningOrange);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scoreColor.withOpacity(0.4), width: 1.5),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(12),
        childrenPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            prop.imageUrls.isNotEmpty ? prop.imageUrls.first : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 70,
              height: 70,
              color: AppTheme.darkSurface,
              child: const Icon(Icons.home, color: AppTheme.textMutedDark),
            ),
          ),
        ),
        title: Text(
          prop.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${prop.locationString} • ${Formatters.formatCurrency(prop.price, prop.currency)}',
              style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                match.matchCategory,
                style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ],
        ),
        children: [
          const Divider(color: AppTheme.darkBorder),
          const SizedBox(height: 8),

          // Matched criteria bullet points
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Uyumlu Kriterler:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen, fontSize: 13)),
          ),
          const SizedBox(height: 4),
          ...match.matchedCriteria.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 12))),
                  ],
                ),
              )),

          if (match.unmatchedCriteria.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Eksik / Farklı Kriterler:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.warningOrange, fontSize: 13)),
            ),
            const SizedBox(height: 4),
            ...match.unmatchedCriteria.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.warningOrange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item, style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12))),
                    ],
                  ),
                )),
          ],

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppTheme.darkBorder),
                  ),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Portföyü İncele', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PropertyDetailView(property: prop)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('WhatsApp Gönder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    final pitchMsg = AiService.generateClientRecommendationPitch(match.customer, prop);
                    WhatsappService.sendWhatsapp(phone: match.customer.phone, message: pitchMsg);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
