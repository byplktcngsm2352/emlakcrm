import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/app_user.dart';
import '../models/activity_log.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _currentUser;
  List<AppUser> _users = [];
  List<ActivityLog> _activityLogs = [];
  bool _isLoading = true;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  List<AppUser> get users => _users;
  List<AppUser> get staffUsers => _users.where((u) => u.role == UserRole.staff).toList();
  List<ActivityLog> get activityLogs => _activityLogs;
  bool get isLoading => _isLoading;

  AuthProvider() {
    loadAuthData();
  }

  // --- Login / Logout ---
  Future<bool> login(String username, String password) async {
    final cleanUsername = username.trim().toLowerCase();
    final cleanPassword = password.trim();

    // Check default admin fallback explicitly
    if (cleanUsername == 'admin' && cleanPassword == 'admin123') {
      _currentUser = _getAdminUser();
      await _saveSession();
      logAction('Yönetici Girişi Yapıldı', details: 'Admin paneline giriş yapıldı');
      notifyListeners();
      return true;
    }

    // Check in registered users list
    try {
      final user = _users.firstWhere(
        (u) => u.username.toLowerCase() == cleanUsername && u.password == cleanPassword,
      );
      _currentUser = user;
      await _saveSession();
      logAction('Kullanıcı Girişi Yapıldı', details: '${user.fullName} sisteme giriş yaptı');
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    if (_currentUser != null) {
      logAction('Çıkış Yapıldı', details: '${_currentUser!.fullName} sistemden çıkış yaptı');
    }
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_current_user_id');
    notifyListeners();
  }

  // --- Staff Management (Admin Only) ---
  Future<void> addStaff(AppUser staff) async {
    _users.insert(0, staff);
    logAction('Yeni Personel Eklendi', details: '${staff.fullName} (${staff.username}) sisteme tanımlandı.');
    notifyListeners();
    await _saveUsers();
  }

  Future<void> updateStaff(AppUser staff) async {
    final index = _users.indexWhere((u) => u.id == staff.id);
    if (index != -1) {
      _users[index] = staff;
      logAction('Personel Bilgisi Güncellendi', details: '${staff.fullName} bilgileri güncellendi.');
      notifyListeners();
      await _saveUsers();
    }
  }

  Future<void> deleteStaff(String id) async {
    final user = _users.firstWhere((u) => u.id == id, orElse: () => _getAdminUser());
    _users.removeWhere((u) => u.id == id);
    logAction('Personel Silindi', details: '${user.fullName} sistemden kaldırıldı.');
    notifyListeners();
    await _saveUsers();
  }

  // --- Audit Trail Activity Log ---
  void logAction(String action, {String details = ''}) {
    final log = ActivityLog(
      id: const Uuid().v4(),
      userId: _currentUser?.id ?? 'sys',
      userName: _currentUser?.fullName ?? 'Sistem',
      userTitle: _currentUser?.title ?? 'Admin',
      action: action,
      details: details,
      timestamp: DateTime.now(),
    );
    _activityLogs.insert(0, log);
    notifyListeners();
    _saveLogs();
  }

  // --- Persistence & Seeds ---
  Future<void> loadAuthData() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString('auth_users');
    final String? logsJson = prefs.getString('auth_logs');
    final String? activeUserId = prefs.getString('auth_current_user_id');

    if (usersJson != null && usersJson.isNotEmpty) {
      final List<dynamic> list = List<dynamic>.from(
        Uri.decodeComponent(usersJson).split(';;;').where((e) => e.isNotEmpty).map((e) => AppUser.fromJson(e)).toList(),
      );
      _users = list.cast<AppUser>();
    } else {
      _seedDefaultUsers();
    }

    if (logsJson != null && logsJson.isNotEmpty) {
      final List<dynamic> list = List<dynamic>.from(
        Uri.decodeComponent(logsJson).split(';;;').where((e) => e.isNotEmpty).map((e) => ActivityLog.fromJson(e)).toList(),
      );
      _activityLogs = list.cast<ActivityLog>();
    } else {
      _seedDefaultLogs();
    }

    if (activeUserId != null) {
      try {
        _currentUser = _users.firstWhere((u) => u.id == activeUserId);
      } catch (_) {
        _currentUser = null;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setString('auth_current_user_id', _currentUser!.id);
    }
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final str = _users.map((u) => u.toJson()).join(';;;');
    await prefs.setString('auth_users', Uri.encodeComponent(str));
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final str = _activityLogs.map((l) => l.toJson()).join(';;;');
    await prefs.setString('auth_logs', Uri.encodeComponent(str));
  }

  AppUser _getAdminUser() {
    return AppUser(
      id: 'admin-id',
      username: 'admin',
      password: 'admin123',
      fullName: 'Admin Yönetici',
      title: 'Şirket Sahibi / Broker',
      role: UserRole.admin,
      phone: '+905320000000',
      email: 'admin@emlakcrm.com',
      createdAt: DateTime.now(),
    );
  }

  void _seedDefaultUsers() {
    _users = [
      _getAdminUser(),
      AppUser(
        id: 'staff-1',
        username: 'danisman1',
        password: '123456',
        fullName: 'Canan Demir',
        title: 'Kıdemli Emlak Danışmanı',
        role: UserRole.staff,
        phone: '+905051112233',
        email: 'canan.demir@emlakcrm.com',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      AppUser(
        id: 'staff-2',
        username: 'danisman2',
        password: '123456',
        fullName: 'Mert Aksoy',
        title: 'Arsa & Ticari Uzmanı',
        role: UserRole.staff,
        phone: '+905423334455',
        email: 'mert.aksoy@emlakcrm.com',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  void _seedDefaultLogs() {
    _activityLogs = [
      ActivityLog(
        id: 'log-1',
        userId: 'admin-id',
        userName: 'Admin Yönetici',
        userTitle: 'Broker',
        action: 'Sistem Başlatıldı & Admin Hesabı Yapılandırıldı',
        details: 'Giriş Kullanıcı Adı: admin',
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
      ),
      ActivityLog(
        id: 'log-2',
        userId: 'staff-1',
        userName: 'Canan Demir',
        userTitle: 'Kıdemli Danışman',
        action: 'Yeni Portföy Eklendi: Bebek Seaview Penthouse',
        details: '34.500.000 TL • Satılık Daire',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      ActivityLog(
        id: 'log-3',
        userId: 'staff-2',
        userName: 'Mert Aksoy',
        userTitle: 'Ticari Uzmanı',
        action: 'Müşteri Aşama Güncellendi: Mehmet Demir ➔ Teklif',
        details: 'Bağdat Caddesi Mağaza Kiralama teklifi',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
}
