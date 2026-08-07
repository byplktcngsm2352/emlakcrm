import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/customer.dart';
import '../../models/customer_criteria.dart';
import '../../models/property.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crm_provider.dart';
import '../../theme/app_theme.dart';

class CustomerFormView extends StatefulWidget {
  final Customer? customer;

  const CustomerFormView({super.key, this.customer});

  @override
  State<CustomerFormView> createState() => _CustomerFormViewState();
}

class _CustomerFormViewState extends State<CustomerFormView> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _phone;
  late String _email;
  late CustomerType _type;
  late LeadStage _stage;
  late String _notes;

  // Criteria
  late double _minBudget;
  late double _maxBudget;
  late String _targetDistrictsInput;
  late double _minNetM2;
  late String _preferredRoomCount;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _name = c?.name ?? '';
    _phone = c?.phone ?? '';
    _email = c?.email ?? '';
    _type = c?.type ?? CustomerType.alici;
    _stage = c?.stage ?? LeadStage.yeniIletisim;
    _notes = c?.notes ?? '';

    _minBudget = c?.criteria.minBudget ?? 5000000;
    _maxBudget = c?.criteria.maxBudget ?? 35000000;
    _targetDistrictsInput = c?.criteria.targetDistricts.join(', ') ?? 'Beşiktaş, Sarıyer, Kadıköy';
    _minNetM2 = c?.criteria.minNetM2 ?? 120;
    _preferredRoomCount = c?.criteria.preferredRoomCount ?? '3+1';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Müşteriyi Düzenle' : 'Yeni Müşteri & Kriter Ekle', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Kişisel İletişim Bilgileri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.emeraldAccent)),
            const SizedBox(height: 12),

            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Müşteri Adı Soyadı *', hintText: 'Örn: Ahmet Yılmaz'),
              validator: (v) => v == null || v.isEmpty ? 'İsim girmelisiniz' : null,
              onSaved: (v) => _name = v!,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Telefon *', hintText: '+90532...'),
                    validator: (v) => v == null || v.isEmpty ? 'Telefon zorunludur' : null,
                    onSaved: (v) => _phone = v!,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-posta'),
                    onSaved: (v) => _email = v!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<CustomerType>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Müşteri Tipi'),
                    items: CustomerType.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(Customer(id: '', name: '', phone: '', type: t, createdAt: DateTime.now(), criteria: CustomerCriteria()).typeName),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _type = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<LeadStage>(
                    initialValue: _stage,
                    decoration: const InputDecoration(labelText: 'Süreç Aşaması'),
                    items: LeadStage.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(Customer(id: '', name: '', phone: '', type: CustomerType.alici, stage: s, createdAt: DateTime.now(), criteria: CustomerCriteria()).stageName),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _stage = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Müşteri Arama Kriterleri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.goldAccent)),
            const SizedBox(height: 12),

            // Budget Slider / Range
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _minBudget.toInt().toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min Bütçe (₺)'),
                    onSaved: (v) => _minBudget = double.tryParse(v!) ?? 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _maxBudget.toInt().toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max Bütçe (₺)'),
                    onSaved: (v) => _maxBudget = double.tryParse(v!) ?? 50000000,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: _targetDistrictsInput,
              decoration: const InputDecoration(labelText: 'Hedef İlçeler (Virgülle ayırın)', hintText: 'Beşiktaş, Sarıyer, Bodrum'),
              onSaved: (v) => _targetDistrictsInput = v!,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _minNetM2.toInt().toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min Net m²'),
                    onSaved: (v) => _minNetM2 = double.tryParse(v!) ?? 80,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _preferredRoomCount,
                    decoration: const InputDecoration(labelText: 'Tercih Oda (3+1)'),
                    onSaved: (v) => _preferredRoomCount = v!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: _notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Müşteri Notları / Özel Talepler'),
              onSaved: (v) => _notes = v!,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _saveForm(context),
              child: Text(
                isEditing ? 'Müşteriyi Güncelle' : 'Müşteriyi Kaydet',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _saveForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = Provider.of<CrmProvider>(context, listen: false);
      final districts = _targetDistrictsInput.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final criteria = CustomerCriteria(
        minBudget: _minBudget,
        maxBudget: _maxBudget,
        currency: '₺',
        targetDistricts: districts,
        preferredTypes: [PropertyType.daire, PropertyType.villa],
        listingType: ListingType.satilik,
        minNetM2: _minNetM2,
        preferredRoomCount: _preferredRoomCount,
      );

      final auth = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = auth.currentUser;

      final customer = Customer(
        id: widget.customer?.id ?? const Uuid().v4(),
        name: _name,
        phone: _phone,
        email: _email,
        type: _type,
        stage: _stage,
        notes: _notes,
        createdAt: widget.customer?.createdAt ?? DateTime.now(),
        criteria: criteria,
        agentId: widget.customer?.agentId ?? (currentUser?.id ?? 'admin-id'),
        agentName: widget.customer?.agentName ?? (currentUser?.fullName ?? 'Admin Yönetici'),
      );

      if (widget.customer != null) {
        provider.updateCustomer(customer);
        auth.logAction('Müşteri Kaydı Güncellendi', details: '${customer.name} (${customer.stageName})');
      } else {
        provider.addCustomer(customer);
        auth.logAction('Yeni Müşteri Kaydedildi', details: '${customer.name} (${customer.typeName})');
      }

      Navigator.pop(context);
    }
  }
}
