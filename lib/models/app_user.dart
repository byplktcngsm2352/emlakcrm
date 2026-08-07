import 'dart:convert';

enum UserRole { admin, staff }

class AppUser {
  final String id;
  final String username;
  final String password;
  final String fullName;
  final String title; // e.g. "Şirket Yöneticisi / Broker", "Emlak Danışmanı"
  final UserRole role;
  final String phone;
  final String email;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.username,
    required this.password,
    required this.fullName,
    this.title = 'Emlak Danışmanı',
    this.role = UserRole.staff,
    this.phone = '',
    this.email = '',
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  String get roleName => role == UserRole.admin ? 'Yönetici (Admin)' : 'Saha Personeli / Danışman';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullName': fullName,
      'title': title,
      'role': role.index,
      'phone': phone,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      fullName: map['fullName'],
      title: map['title'] ?? 'Emlak Danışmanı',
      role: UserRole.values[map['role'] ?? 1],
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AppUser.fromJson(String source) => AppUser.fromMap(json.decode(source));
}
