import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/customer.dart';
import '../../models/property.dart';
import '../../providers/crm_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/ai_service.dart';
import '../../services/whatsapp_service.dart';

class AiStudioView extends StatefulWidget {
  final Property? initialProperty;
  final Customer? initialCustomer;

  const AiStudioView({super.key, this.initialProperty, this.initialCustomer});

  @override
  State<AiStudioView> createState() => _AiStudioViewState();
}

class _AiStudioViewState extends State<AiStudioView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1: AI Listing State
  Property? _selectedListingProperty;
  AiTone _selectedTone = AiTone.luksPrestij;
  String _generatedListingText = '';

  // Tab 2: AI Recommendation Pitch State
  Customer? _selectedPitchCustomer;
  Property? _selectedPitchProperty;
  String _generatedPitchText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedListingProperty = widget.initialProperty;
    _selectedPitchCustomer = widget.initialCustomer;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CrmProvider>(
      builder: (context, provider, child) {
        final properties = provider.allProperties;
        final customers = provider.customers;

        if (_selectedListingProperty == null && properties.isNotEmpty) {
          _selectedListingProperty = properties.first;
        }
        if (_selectedPitchProperty == null && properties.isNotEmpty) {
          _selectedPitchProperty = properties.first;
        }
        if (_selectedPitchCustomer == null && customers.isNotEmpty) {
          _selectedPitchCustomer = customers.first;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.auto_awesome, color: AppTheme.goldAccent),
                SizedBox(width: 8),
                Text('Yapay Zeka (AI) Asistan Stüdyosu', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.emeraldAccent,
              labelColor: AppTheme.emeraldAccent,
              unselectedLabelColor: AppTheme.textSecondaryDark,
              tabs: const [
                Tab(text: 'AI İlan Metni Generator'),
                Tab(text: 'AI Müşteri Sunum Önerisi'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: AI Listing Description Generator
              _buildListingGeneratorTab(context, properties),

              // TAB 2: AI Customer Recommendation Pitch Assistant
              _buildPitchAssistantTab(context, customers, properties),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListingGeneratorTab(BuildContext context, List<Property> properties) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('1. Portföy Seçin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        DropdownButtonFormField<Property>(
          initialValue: _selectedListingProperty,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.home_work, color: AppTheme.emeraldAccent)),
          dropdownColor: AppTheme.darkCard,
          items: properties.map((p) {
            return DropdownMenuItem(
              value: p,
              child: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedListingProperty = val),
        ),
        const SizedBox(height: 16),

        const Text('2. İlan Metni Üslubu (Tonu)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildToneChip('✨ Lüks & Prestijli', AiTone.luksPrestij),
            _buildToneChip('🏡 Samimi & Detaylı', AiTone.samimiDetay),
            _buildToneChip('🚀 Yatırım Odaklı', AiTone.yatirimOdakli),
          ],
        ),
        const SizedBox(height: 20),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.emeraldPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.auto_awesome, color: AppTheme.goldLight),
          label: const Text('AI İlan Metnini Üret', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          onPressed: () {
            if (_selectedListingProperty != null) {
              final text = AiService.generateListingDescription(_selectedListingProperty!, _selectedTone);
              setState(() {
                _generatedListingText = text;
              });
            }
          },
        ),
        const SizedBox(height: 24),

        if (_generatedListingText.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Üretilen AI İlan Metni', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.goldAccent, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.copy, color: AppTheme.emeraldAccent),
                tooltip: 'Metni Kopyala',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _generatedListingText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('İlan metni panoya kopyalandı!'), backgroundColor: AppTheme.emeraldPrimary),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.emeraldAccent.withOpacity(0.4)),
            ),
            child: SelectableText(
              _generatedListingText,
              style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildToneChip(String label, AiTone tone) {
    final isSelected = _selectedTone == tone;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedTone = tone),
      selectedColor: AppTheme.emeraldPrimary,
      backgroundColor: AppTheme.darkCard,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textSecondaryDark, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
    );
  }

  Widget _buildPitchAssistantTab(BuildContext context, List<Customer> customers, List<Property> properties) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('1. Müşteri Seçin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        DropdownButtonFormField<Customer>(
          initialValue: _selectedPitchCustomer,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.person, color: AppTheme.emeraldAccent)),
          dropdownColor: AppTheme.darkCard,
          items: customers.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(c.name),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedPitchCustomer = val),
        ),
        const SizedBox(height: 16),

        const Text('2. Önerilecek Portföyü Seçin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        DropdownButtonFormField<Property>(
          initialValue: _selectedPitchProperty,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.home_work, color: AppTheme.goldAccent)),
          dropdownColor: AppTheme.darkCard,
          items: properties.map((p) {
            return DropdownMenuItem(
              value: p,
              child: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedPitchProperty = val),
        ),
        const SizedBox(height: 20),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.emeraldPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.psychology, color: AppTheme.goldLight),
          label: const Text('AI İkna Sunum Metni Oluştur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          onPressed: () {
            if (_selectedPitchCustomer != null && _selectedPitchProperty != null) {
              final text = AiService.generateClientRecommendationPitch(_selectedPitchCustomer!, _selectedPitchProperty!);
              setState(() {
                _generatedPitchText = text;
              });
            }
          },
        ),
        const SizedBox(height: 24),

        if (_generatedPitchText.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Üretilen Müşteri Sunum Metni', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.goldAccent, fontSize: 16)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, color: AppTheme.emeraldAccent),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _generatedPitchText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sunum metni kopyalandı!'), backgroundColor: AppTheme.emeraldPrimary),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF25D366)),
                    onPressed: () {
                      if (_selectedPitchCustomer != null) {
                        WhatsappService.sendWhatsapp(phone: _selectedPitchCustomer!.phone, message: _generatedPitchText);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.goldAccent.withOpacity(0.4)),
            ),
            child: SelectableText(
              _generatedPitchText,
              style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }
}
