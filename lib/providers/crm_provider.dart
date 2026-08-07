import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../models/customer_criteria.dart';
import '../models/property.dart';
import '../models/reminder.dart';
import '../models/whatsapp_template.dart';

class CrmProvider extends ChangeNotifier {
  List<Property> _properties = [];
  List<Customer> _customers = [];
  List<Reminder> _reminders = [];
  List<WhatsappTemplate> _templates = [];

  bool _isLoading = true;
  String _propertySearchQuery = '';
  PropertyType? _selectedPropertyTypeFilter;
  PropertyStatus? _selectedStatusFilter;

  List<Property> get properties {
    return _properties.where((p) {
      final matchesSearch = _propertySearchQuery.isEmpty ||
          p.title.toLowerCase().contains(_propertySearchQuery.toLowerCase()) ||
          p.district.toLowerCase().contains(_propertySearchQuery.toLowerCase()) ||
          p.province.toLowerCase().contains(_propertySearchQuery.toLowerCase());
      final matchesType = _selectedPropertyTypeFilter == null || p.type == _selectedPropertyTypeFilter;
      final matchesStatus = _selectedStatusFilter == null || p.status == _selectedStatusFilter;
      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }

  List<Property> get allProperties => _properties;
  List<Customer> get customers => _customers;
  List<Reminder> get reminders => _reminders;
  List<WhatsappTemplate> get templates => _templates;
  bool get isLoading => _isLoading;

  String get propertySearchQuery => _propertySearchQuery;
  PropertyType? get selectedPropertyTypeFilter => _selectedPropertyTypeFilter;
  PropertyStatus? get selectedStatusFilter => _selectedStatusFilter;

  // Stats
  double get totalPortfolioValue {
    return _properties
        .where((p) => p.status == PropertyStatus.aktif)
        .fold(0, (sum, p) => sum + p.price);
  }

  int get activePropertiesCount => _properties.where((p) => p.status == PropertyStatus.aktif).length;
  int get totalCustomersCount => _customers.length;
  int get pendingRemindersCount => _reminders.where((r) => !r.isCompleted).length;
  int get closedDealsCount => _customers.where((c) => c.stage == LeadStage.satisYapildi).length;

  CrmProvider() {
    loadData();
  }

  void setSearchQuery(String query) {
    _propertySearchQuery = query;
    notifyListeners();
  }

  void setTypeFilter(PropertyType? type) {
    _selectedPropertyTypeFilter = type;
    notifyListeners();
  }

  void setStatusFilter(PropertyStatus? status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  // --- CRUD Property ---
  Future<void> addProperty(Property property) async {
    _properties.insert(0, property);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> updateProperty(Property property) async {
    final index = _properties.indexWhere((p) => p.id == property.id);
    if (index != -1) {
      _properties[index] = property;
      notifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> deleteProperty(String id) async {
    _properties.removeWhere((p) => p.id == id);
    notifyListeners();
    await _saveToStorage();
  }

  // --- CRUD Customer ---
  Future<void> addCustomer(Customer customer) async {
    _customers.insert(0, customer);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> updateCustomer(Customer customer) async {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
      notifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> updateCustomerStage(String customerId, LeadStage newStage) async {
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      _customers[index] = _customers[index].copyWith(stage: newStage);
      notifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> deleteCustomer(String id) async {
    _customers.removeWhere((c) => c.id == id);
    notifyListeners();
    await _saveToStorage();
  }

  // --- CRUD Reminders ---
  Future<void> addReminder(Reminder reminder) async {
    _reminders.insert(0, reminder);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> toggleReminder(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(isCompleted: !_reminders[index].isCompleted);
      notifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
    await _saveToStorage();
  }

  // --- Data Loading & Mock Seed ---
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String? propertiesJson = prefs.getString('crm_properties');
    final String? customersJson = prefs.getString('crm_customers');
    final String? remindersJson = prefs.getString('crm_reminders');

    if (propertiesJson != null && propertiesJson.isNotEmpty) {
      final List<dynamic> list = List<dynamic>.from(Uri.decodeComponent(propertiesJson).split(';;;').where((e) => e.isNotEmpty).map((e) => Property.fromJson(e)).toList());
      _properties = list.cast<Property>();
    } else {
      _seedMockProperties();
    }

    if (customersJson != null && customersJson.isNotEmpty) {
      final List<dynamic> list = List<dynamic>.from(Uri.decodeComponent(customersJson).split(';;;').where((e) => e.isNotEmpty).map((e) => Customer.fromJson(e)).toList());
      _customers = list.cast<Customer>();
    } else {
      _seedMockCustomers();
    }

    if (remindersJson != null && remindersJson.isNotEmpty) {
      final List<dynamic> list = List<dynamic>.from(Uri.decodeComponent(remindersJson).split(';;;').where((e) => e.isNotEmpty).map((e) => Reminder.fromJson(e)).toList());
      _reminders = list.cast<Reminder>();
    } else {
      _seedMockReminders();
    }

    _seedMockTemplates();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final propStr = _properties.map((p) => p.toJson()).join(';;;');
    final custStr = _customers.map((c) => c.toJson()).join(';;;');
    final remStr = _reminders.map((r) => r.toJson()).join(';;;');

    await prefs.setString('crm_properties', Uri.encodeComponent(propStr));
    await prefs.setString('crm_customers', Uri.encodeComponent(custStr));
    await prefs.setString('crm_reminders', Uri.encodeComponent(remStr));
  }

  void _seedMockProperties() {
    _properties = [
      Property(
        id: 'prop-1',
        title: 'Beşiktaş Bebek Seaview Lüks Penthouse Daire',
        type: PropertyType.daire,
        listingType: ListingType.satilik,
        price: 34500000,
        currency: '₺',
        netM2: 220,
        grossM2: 260,
        roomCount: '4+1',
        floor: 5,
        totalFloors: 5,
        heating: 'Yerden Isıtma & VRF',
        deedStatus: 'Kat Mülkiyeti',
        province: 'İstanbul',
        district: 'Beşiktaş',
        neighborhood: 'Bebek Mah.',
        description: 'Bebek sahilinde panoramik Boğaz manzaralı, akıllı ev sistemli, özel kapalı otoparklı ultra lüks teraslı penthouse.',
        imageUrls: [
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
        ],
        portalLinks: {
          'Sahibinden': 'https://sahibinden.com/ilan/1049281',
          'Hepsiemlak': 'https://hepsiemlak.com/ilan/99281',
        },
        features: ['Deniz Manzarası', 'Akıllı Ev', 'Balkon/Teras', 'Kapalı Otopark', 'Asansör', 'Güvenlik'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Property(
        id: 'prop-2',
        title: 'Bodrum Yalıkavak Marinaya Yakın Özel Havuzlu Villa',
        type: PropertyType.villa,
        listingType: ListingType.satilik,
        price: 48000000,
        currency: '₺',
        netM2: 380,
        grossM2: 450,
        roomCount: '5+2',
        floor: 1,
        totalFloors: 2,
        heating: 'VRF Klima & Şömine',
        deedStatus: 'Kat Mülkiyeti',
        province: 'Muğla',
        district: 'Bodrum',
        neighborhood: 'Yalıkavak Mah.',
        description: 'Yalıkavak Marina manzaralı, müstakil sonsuzluk havuzlu, geniş peyzajlı bahçeli taş mimari villa.',
        imageUrls: [
          'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=800',
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
        ],
        portalLinks: {'Sahibinden': 'https://sahibinden.com/ilan/1098273'},
        features: ['Özel Havuz', 'Deniz Manzarası', 'Geniş Bahçe', 'Müstakil', 'Otopark', 'Güvenlik'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Property(
        id: 'prop-3',
        title: 'Sarıyer Zekeriyaköy Bahçeli Müstakil Villa',
        type: PropertyType.villa,
        listingType: ListingType.satilik,
        price: 27500000,
        currency: '₺',
        netM2: 290,
        grossM2: 330,
        roomCount: '4+2',
        floor: 1,
        totalFloors: 3,
        heating: 'Kombi (Doğalgaz)',
        deedStatus: 'Kat Mülkiyeti',
        province: 'İstanbul',
        district: 'Sarıyer',
        neighborhood: 'Zekeriyaköy Mah.',
        description: 'Doğa ile iç içe, prestijli sitede 24 saat güvenlikli, şömineli, kış bahçeli müstakil villa.',
        imageUrls: [
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
        ],
        portalLinks: {'Hepsiemlak': 'https://hepsiemlak.com/ilan/88210'},
        features: ['Güvenlikli Site', 'Ortak Havuz', 'Kış Bahçesi', 'Şömine', 'Otopark'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Property(
        id: 'prop-4',
        title: 'İzmir Çeşme Alaçatı Konut İmarlı Villa Arsası',
        type: PropertyType.arsa,
        listingType: ListingType.satilik,
        price: 18500000,
        currency: '₺',
        netM2: 650,
        grossM2: 650,
        roomCount: 'Arsa',
        zoningStatus: '%20/40 Konut İmarlı',
        deedStatus: 'Müstakil Tapu',
        province: 'İzmir',
        district: 'Çeşme',
        neighborhood: 'Alaçatı Mah.',
        adaParsel: 'Ada: 104 / Parsel: 12',
        description: 'Alaçatı merkezine ve plajlara yakın konumda, 2 kat villa yapımına uygun ruhsatı hazır arsa.',
        imageUrls: [
          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800',
        ],
        portalLinks: {},
        features: ['Konut İmarlı', 'Müstakil Tapu', 'Yol-Su-Elektrik Altyapısı Var'],
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      Property(
        id: 'prop-5',
        title: 'Kadıköy Bağdat Caddesi Üzeri Kiralık Mağaza/Ofis',
        type: PropertyType.ticari,
        listingType: ListingType.kiralik,
        price: 140000,
        currency: '₺',
        netM2: 180,
        grossM2: 210,
        roomCount: 'Açık Alan + 2 Ofis',
        floor: 1,
        totalFloors: 6,
        heating: 'VRF Merkezi',
        deedStatus: 'Kat Mülkiyeti',
        province: 'İstanbul',
        district: 'Kadıköy',
        neighborhood: 'Suadiye Mah.',
        description: 'Bağdat Caddesi üzerinde yüksek vitrin görünürlüklü, kurumsal kiracıya uygun dükkan/mağaza.',
        imageUrls: [
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
        ],
        portalLinks: {'Emlakjet': 'https://emlakjet.com/ilan/77129'},
        features: ['Cadde Üzeri', 'Yüksek Vitrin', 'Otopark', 'Asansör'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  void _seedMockCustomers() {
    _customers = [
      Customer(
        id: 'cust-1',
        name: 'Ahmet Yılmaz',
        phone: '+905321112233',
        email: 'ahmet.yilmaz@gmail.com',
        type: CustomerType.alici,
        stage: LeadStage.sunumYapildi,
        notes: 'Beşiktaş veya Sarıyer civarında Boğaz manzaralı lüks daire arıyor. Bütçesi esnek.',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        criteria: CustomerCriteria(
          minBudget: 20000000,
          maxBudget: 40000000,
          currency: '₺',
          targetDistricts: ['Beşiktaş', 'Sarıyer'],
          preferredTypes: [PropertyType.daire, PropertyType.villa],
          listingType: ListingType.satilik,
          minNetM2: 180,
          preferredRoomCount: '4+1',
          preferredFeatures: ['Deniz Manzarası', 'Akıllı Ev', 'Kapalı Otopark'],
        ),
      ),
      Customer(
        id: 'cust-2',
        name: 'Zeynep Kaya',
        phone: '+905054445566',
        email: 'zeynep.kaya@outlook.com',
        type: CustomerType.alici,
        stage: LeadStage.teklifAsamasi,
        notes: 'Bodrum Yalıkavak veya Çeşme tarafında tatil villası veya arsa arıyor.',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        criteria: CustomerCriteria(
          minBudget: 15000000,
          maxBudget: 50000000,
          currency: '₺',
          targetDistricts: ['Bodrum', 'Çeşme'],
          preferredTypes: [PropertyType.villa, PropertyType.arsa],
          listingType: ListingType.satilik,
          minNetM2: 300,
          preferredRoomCount: '5+2',
          preferredFeatures: ['Özel Havuz', 'Deniz Manzarası', 'Müstakil'],
        ),
      ),
      Customer(
        id: 'cust-3',
        name: 'Mehmet Demir',
        phone: '+905427778899',
        email: 'm.demir@holding.com',
        type: CustomerType.kiraci,
        stage: LeadStage.kriterAlindi,
        notes: 'Kadıköy Bağdat caddesinde kurumsal showroom alanı arıyor.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        criteria: CustomerCriteria(
          minBudget: 50000,
          maxBudget: 160000,
          currency: '₺',
          targetDistricts: ['Kadıköy'],
          preferredTypes: [PropertyType.ticari],
          listingType: ListingType.kiralik,
          minNetM2: 150,
          preferredRoomCount: 'Açık Alan',
          preferredFeatures: ['Cadde Üzeri', 'Yüksek Vitrin'],
        ),
      ),
    ];
  }

  void _seedMockReminders() {
    _reminders = [
      Reminder(
        id: 'rem-1',
        title: 'Bebek Penthouse Yer Gösterme Randevusu',
        note: 'Ahmet Bey ile saat 14:00\'te Bebek mülkünün kapısında buluşulacak.',
        dateTime: DateTime.now().add(const Duration(hours: 4)),
        type: ReminderType.yerGosterme,
        customerId: 'cust-1',
        propertyId: 'prop-1',
      ),
      Reminder(
        id: 'rem-2',
        title: 'Zeynep Hanım Geri Arama (Yalıkavak Villa Teklifi)',
        note: 'Fiyat pazarlığı son durumu görüşülecek.',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        type: ReminderType.geriArama,
        customerId: 'cust-2',
        propertyId: 'prop-2',
      ),
      Reminder(
        id: 'rem-3',
        title: 'Tapu Dairesi Evrak Teslimi (Kadıköy Tapu)',
        note: 'Harç ödemeleri ve web tapu başvurusu kontrol edilecek.',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        type: ReminderType.tapuRandevusu,
      ),
    ];
  }

  void _seedMockTemplates() {
    _templates = [
      WhatsappTemplate(
        id: 'tpl-1',
        title: 'Özel Portföy Sunumu (Eşleşen İlan)',
        category: 'Portföy Sunumu',
        content: '''Sayın {Müşteri_Adı},

Aradığınız kriterlere son derece uygun olan yeni portföyümüzü bilgilerinize sunuyorum:

🏠 {Portföy_Başlık}
📍 Konum: {Konum}
💵 Fiyat: {Fiyat}
📐 Özellikler: {m2} | {Oda_Sayısı}

Detayları ve fotoğrafları incelemek için ilan bağlantısı:
{İlan_Linki}

İlgilenirseniz sunum randevusu planlayabiliriz. Saygılarımla.''',
      ),
      WhatsappTemplate(
        id: 'tpl-2',
        title: 'Yer Gösterme Randevu Hatırlatma',
        category: 'Randevu Hatırlatma',
        content: '''Sayın {Müşteri_Adı},

Bugün planladığımız gayrimenkul yer gösterme randevumuzu hatırlatmak istedim.

📍 Mülk: {Portföy_Başlık}
📍 Konum: {Konum}

Konumda buluşmak üzere, iyi günler dilerim.''',
      ),
      WhatsappTemplate(
        id: 'tpl-3',
        title: 'Yeni Müşteri Karşılama & Kriter Teyidi',
        category: 'Tanışma',
        content: '''Merhaba {Müşteri_Adı},

Emlak talebiniz tarafımıza ulaşmıştır. Size en doğru portföyleri sunabilmemiz için bütçe, tercih ettiğiniz ilçeler ve mülk tipi detaylarınızı teyit etmek isteriz.

Size yardımcı olmaktan memnuniyet duyarız. İyi çalışmalar!''',
      ),
    ];
  }
}
