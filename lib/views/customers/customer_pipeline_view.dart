import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer.dart';
import '../../providers/crm_provider.dart';
import '../../theme/app_theme.dart';
import 'customer_detail_view.dart';

class CustomerPipelineView extends StatelessWidget {
  const CustomerPipelineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CrmProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Müşteri Süreç Aşamaları (Pipeline)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: PageView(
            physics: const BouncingScrollPhysics(),
            children: LeadStage.values.map((stage) {
              final stageCustomers = provider.customers.where((c) => c.stage == stage).toList();
              return _buildStageColumn(context, provider, stage, stageCustomers);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStageColumn(BuildContext context, CrmProvider provider, LeadStage stage, List<Customer> customers) {
    final Color stageColor = _getStageColor(stage);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stageColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stage Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: stageColor.withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(color: stageColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _getStageName(stage),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: stageColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${customers.length} Kişi',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Kaydırarak aşamalar arası geçiş yapabilirsiniz ➔', style: TextStyle(color: AppTheme.textMutedDark, fontSize: 11)),
          ),

          // Customers List in Stage
          Expanded(
            child: customers.isEmpty
                ? const Center(
                    child: Text('Bu aşamada henüz müşteri yok.', style: TextStyle(color: AppTheme.textSecondaryDark)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final cust = customers[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.darkBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    cust.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward, color: AppTheme.emeraldAccent, size: 18),
                                  tooltip: 'Sonraki Aşamaya Taşı',
                                  onPressed: () => _advanceStage(context, provider, cust),
                                ),
                              ],
                            ),
                            Text(
                              '${cust.typeName} • ${cust.phone}',
                              style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                            ),
                            if (cust.criteria.targetDistricts.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Bölge: ${cust.criteria.targetDistricts.join(", ")}',
                                style: const TextStyle(color: AppTheme.emeraldAccent, fontSize: 11),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                                child: const Text('Profil & Detaylar ➔', style: TextStyle(fontSize: 12, color: AppTheme.infoBlue)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CustomerDetailView(customer: cust)),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _advanceStage(BuildContext context, CrmProvider provider, Customer customer) {
    final int nextIndex = (customer.stage.index + 1) % LeadStage.values.length;
    final LeadStage newStage = LeadStage.values[nextIndex];

    provider.updateCustomerStage(customer.id, newStage);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${customer.name} "${_getStageName(newStage)}" aşamasına taşındı.'),
        backgroundColor: AppTheme.emeraldPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getStageColor(LeadStage stage) {
    switch (stage) {
      case LeadStage.yeniIletisim:
        return AppTheme.infoBlue;
      case LeadStage.kriterAlindi:
        return Colors.purpleAccent;
      case LeadStage.sunumYapildi:
        return AppTheme.warningOrange;
      case LeadStage.teklifAsamasi:
        return AppTheme.goldAccent;
      case LeadStage.satisYapildi:
        return AppTheme.successGreen;
      case LeadStage.olumsuz:
        return AppTheme.errorRed;
    }
  }

  String _getStageName(LeadStage stage) {
    switch (stage) {
      case LeadStage.yeniIletisim:
        return '1. Yeni İletişim';
      case LeadStage.kriterAlindi:
        return '2. Kriter Alındı';
      case LeadStage.sunumYapildi:
        return '3. Yer Gösterildi';
      case LeadStage.teklifAsamasi:
        return '4. Teklif / Pazarlık';
      case LeadStage.satisYapildi:
        return '5. Anlaşma / Satış';
      case LeadStage.olumsuz:
        return '6. Olumsuz / Arşiv';
    }
  }
}
