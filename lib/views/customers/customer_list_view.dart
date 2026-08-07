import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/customer.dart';
import '../../providers/crm_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/whatsapp_service.dart';
import 'customer_detail_view.dart';
import 'customer_form_view.dart';
import 'customer_pipeline_view.dart';

class CustomerListView extends StatefulWidget {
  const CustomerListView({super.key});

  @override
  State<CustomerListView> createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<CustomerListView> {
  String _searchQuery = '';
  CustomerType? _selectedTypeFilter;

  @override
  Widget build(BuildContext context) {
    return Consumer<CrmProvider>(
      builder: (context, provider, child) {
        final customers = provider.customers.where((c) {
          final matchesSearch = _searchQuery.isEmpty ||
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.phone.contains(_searchQuery) ||
              c.criteria.targetDistricts.any((d) => d.toLowerCase().contains(_searchQuery.toLowerCase()));
          final matchesType = _selectedTypeFilter == null || c.type == _selectedTypeFilter;
          return matchesSearch && matchesType;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Müşteri Yönetimi & CRM', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.view_kanban, color: AppTheme.emeraldAccent),
                tooltip: 'Süreç Aşamaları (Pipeline)',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerPipelineView()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_add_alt_1, color: AppTheme.emeraldAccent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerFormView()),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Müşteri adı, telefon veya aranan bölge...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondaryDark),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Tümü', _selectedTypeFilter == null, () => setState(() => _selectedTypeFilter = null)),
                          _buildFilterChip('Alıcılar', _selectedTypeFilter == CustomerType.alici, () => setState(() => _selectedTypeFilter = CustomerType.alici)),
                          _buildFilterChip('Kiracılar', _selectedTypeFilter == CustomerType.kiraci, () => setState(() => _selectedTypeFilter = CustomerType.kiraci)),
                          _buildFilterChip('Mülk Sahipleri', _selectedTypeFilter == CustomerType.satici, () => setState(() => _selectedTypeFilter = CustomerType.satici)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Customer List
              Expanded(
                child: customers.isEmpty
                    ? const Center(
                        child: Text('Kayıtlı müşteri bulunamadı.', style: TextStyle(color: AppTheme.textSecondaryDark)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final cust = customers[index];
                          return _buildCustomerCard(context, provider, cust);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.emeraldPrimary,
        backgroundColor: AppTheme.darkCard,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textSecondaryDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, CrmProvider provider, Customer customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CustomerDetailView(customer: customer)),
          );
        },
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.emeraldPrimary.withOpacity(0.2),
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'M',
            style: const TextStyle(color: AppTheme.emeraldAccent, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                customer.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _getStageColor(customer.stage).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStageColor(customer.stage).withOpacity(0.5)),
              ),
              child: Text(
                customer.stageName,
                style: TextStyle(color: _getStageColor(customer.stage), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${customer.typeName} • ${customer.phone}',
              style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
            ),
            if (customer.criteria.targetDistricts.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.pin_drop_outlined, size: 12, color: AppTheme.emeraldAccent),
                  const SizedBox(width: 4),
                  Text(
                    'Aranan: ${customer.criteria.targetDistricts.join(", ")}',
                    style: const TextStyle(color: AppTheme.emeraldAccent, fontSize: 11),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.phone, color: AppTheme.infoBlue, size: 20),
              onPressed: () async {
                final uri = Uri.parse('tel:${customer.phone}');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
            IconButton(
              icon: const Icon(Icons.chat, color: Color(0xFF25D366), size: 20),
              onPressed: () {
                WhatsappService.sendWhatsapp(
                  phone: customer.phone,
                  message: 'Merhaba ${customer.name}, emlak talebiniz ile ilgili ulaşmaktayım.',
                );
              },
            ),
          ],
        ),
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
}
