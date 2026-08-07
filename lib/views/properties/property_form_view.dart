import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/property.dart';
import '../../providers/crm_provider.dart';
import '../../theme/app_theme.dart';

class PropertyFormView extends StatefulWidget {
  final Property? property;

  const PropertyFormView({super.key, this.property});

  @override
  State<PropertyFormView> createState() => _PropertyFormViewState();
}

class _PropertyFormViewState extends State<PropertyFormView> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late PropertyType _type;
  late ListingType _listingType;
  late double _price;
  late String _currency;
  late double _netM2;
  late double _grossM2;
  late String _roomCount;
  late int _floor;
  late int _totalFloors;
  late String _heating;
  late String _deedStatus;
  late String _zoningStatus;
  late String _province;
  late String _district;
  late String _neighborhood;
  late String _adaParsel;
  late String _description;
  late List<String> _features;
  late String _imageUrl;
  late String _sahibindenUrl;

  final List<String> _availableFeatures = [
    'Deniz Manzarası',
    'Akıllı Ev',
    'Balkon/Teras',
    'Özel Havuz',
    'Ortak Havuz',
    'Kapalı Otopark',
    'Müstakil Bahçe',
    'Asansör',
    '24/7 Güvenlik',
    'Şömine',
    'Kış Bahçesi',
    'Cadde Üzeri',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _title = p?.title ?? '';
    _type = p?.type ?? PropertyType.daire;
    _listingType = p?.listingType ?? ListingType.satilik;
    _price = p?.price ?? 15000000;
    _currency = p?.currency ?? '₺';
    _netM2 = p?.netM2 ?? 140;
    _grossM2 = p?.grossM2 ?? 165;
    _roomCount = p?.roomCount ?? '3+1';
    _floor = p?.floor ?? 2;
    _totalFloors = p?.totalFloors ?? 6;
    _heating = p?.heating ?? 'Kombi (Doğalgaz)';
    _deedStatus = p?.deedStatus ?? 'Kat Mülkiyeti';
    _zoningStatus = p?.zoningStatus ?? 'Konut İmarlı';
    _province = p?.province ?? 'İstanbul';
    _district = p?.district ?? 'Kadıköy';
    _neighborhood = p?.neighborhood ?? 'Caddebostan Mah.';
    _adaParsel = p?.adaParsel ?? '';
    _description = p?.description ?? '';
    _features = p?.features.toList() ?? ['Balkon/Teras', 'Kapalı Otopark', 'Asansör'];
    _imageUrl = p?.imageUrls.isNotEmpty == true ? p!.imageUrls.first : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800';
    _sahibindenUrl = p?.portalLinks['Sahibinden'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.property != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Portföyü Düzenle' : 'Yeni Portföy Ekle', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: 'İlan Başlığı *', hintText: 'Örn: Beşiktaş Bebek Seaview Lüks Penthouse'),
              validator: (v) => v == null || v.isEmpty ? 'Başlık zorunludur' : null,
              onSaved: (v) => _title = v!,
            ),
            const SizedBox(height: 16),

            // Property Type & Listing Type Dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<PropertyType>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Gayrimenkul Tipi'),
                    items: PropertyType.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(Property(
                          id: '',
                          title: '',
                          type: t,
                          listingType: ListingType.satilik,
                          price: 0,
                          netM2: 0,
                          grossM2: 0,
                          roomCount: '',
                          province: '',
                          district: '',
                          neighborhood: '',
                          description: '',
                          imageUrls: [],
                          createdAt: DateTime.now(),
                        ).typeName),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _type = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<ListingType>(
                    initialValue: _listingType,
                    decoration: const InputDecoration(labelText: 'İlan Tipi'),
                    items: ListingType.values.map((l) {
                      return DropdownMenuItem(
                        value: l,
                        child: Text(l == ListingType.satilik ? 'Satılık' : 'Kiralık'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _listingType = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price & Currency
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: _price.toInt().toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Fiyat *', hintText: '15000000'),
                    validator: (v) => v == null || v.isEmpty ? 'Fiyat giriniz' : null,
                    onSaved: (v) => _price = double.tryParse(v!) ?? 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: const InputDecoration(labelText: 'Birim'),
                    items: const [
                      DropdownMenuItem(value: '₺', child: Text('₺ (TL)')),
                      DropdownMenuItem(value: '\$', child: Text('\$ (USD)')),
                      DropdownMenuItem(value: '€', child: Text('€ (EUR)')),
                    ],
                    onChanged: (val) => setState(() => _currency = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Net / Gross m2 & Rooms
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _netM2.toInt().toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Net m²'),
                    onSaved: (v) => _netM2 = double.tryParse(v!) ?? 100,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _grossM2.toInt().toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Brüt m²'),
                    onSaved: (v) => _grossM2 = double.tryParse(v!) ?? 120,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _roomCount,
                    decoration: const InputDecoration(labelText: 'Oda (3+1)'),
                    onSaved: (v) => _roomCount = v!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location: Province & District & Neighborhood
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _province,
                    decoration: const InputDecoration(labelText: 'İl *'),
                    validator: (v) => v == null || v.isEmpty ? 'İl zorunludur' : null,
                    onSaved: (v) => _province = v!,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _district,
                    decoration: const InputDecoration(labelText: 'İlçe *'),
                    validator: (v) => v == null || v.isEmpty ? 'İlçe zorunludur' : null,
                    onSaved: (v) => _district = v!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _neighborhood,
              decoration: const InputDecoration(labelText: 'Mahalle / Semt'),
              onSaved: (v) => _neighborhood = v!,
            ),
            const SizedBox(height: 16),

            // Ada/Parsel & Deed status
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _deedStatus,
                    decoration: const InputDecoration(labelText: 'Tapu Durumu'),
                    onSaved: (v) => _deedStatus = v!,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _adaParsel,
                    decoration: const InputDecoration(labelText: 'Ada / Parsel'),
                    onSaved: (v) => _adaParsel = v!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Image URL & Sahibinden portal URL
            TextFormField(
              initialValue: _imageUrl,
              decoration: const InputDecoration(labelText: 'Görsel Bağlantısı (URL)', hintText: 'https://...'),
              onSaved: (v) => _imageUrl = v!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _sahibindenUrl,
              decoration: const InputDecoration(labelText: 'Sahibinden / Portal İlan Bağlantısı', hintText: 'https://sahibinden.com/ilan/...'),
              onSaved: (v) => _sahibindenUrl = v!,
            ),
            const SizedBox(height: 16),

            // Features Checklist Chips
            const Text('Portföy Özellikleri & Donanımlar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableFeatures.map((feat) {
                final isSelected = _features.contains(feat);
                return FilterChip(
                  label: Text(feat),
                  selected: isSelected,
                  selectedColor: AppTheme.emeraldPrimary,
                  backgroundColor: AppTheme.darkCard,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _features.add(feat);
                      } else {
                        _features.remove(feat);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              initialValue: _description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Detaylı Açıklama / Notlar', hintText: 'Mülk hakkında ek bilgiler...'),
              onSaved: (v) => _description = v!,
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _saveForm(context),
              child: Text(
                isEditing ? 'Portföyü Güncelle' : 'Portföyü Kaydet',
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
      final portalLinks = <String, String>{};
      if (_sahibindenUrl.isNotEmpty) {
        portalLinks['Sahibinden'] = _sahibindenUrl;
      }

      final property = Property(
        id: widget.property?.id ?? const Uuid().v4(),
        title: _title,
        type: _type,
        listingType: _listingType,
        price: _price,
        currency: _currency,
        netM2: _netM2,
        grossM2: _grossM2,
        roomCount: _roomCount,
        floor: _floor,
        totalFloors: _totalFloors,
        heating: _heating,
        deedStatus: _deedStatus,
        zoningStatus: _zoningStatus,
        province: _province,
        district: _district,
        neighborhood: _neighborhood,
        adaParsel: _adaParsel,
        description: _description,
        status: widget.property?.status ?? PropertyStatus.aktif,
        imageUrls: [_imageUrl.isNotEmpty ? _imageUrl : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800'],
        portalLinks: portalLinks,
        createdAt: widget.property?.createdAt ?? DateTime.now(),
        features: _features,
      );

      if (widget.property != null) {
        provider.updateProperty(property);
      } else {
        provider.addProperty(property);
      }

      Navigator.pop(context);
    }
  }
}
