import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: AppTheme.goldAccent),
                SizedBox(width: 8),
                Text('Admin Yönetim Paneli', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: AppTheme.errorRed),
                tooltip: 'Çıkış Yap',
                onPressed: () async {
                  await auth.logout();
                },
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.emeraldAccent,
              labelColor: AppTheme.emeraldAccent,
              unselectedLabelColor: AppTheme.textSecondaryDark,
              tabs: const [
                Tab(text: 'Personel Yönetimi'),
                Tab(text: 'Firma İşlem Logları'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: Personel Yönetimi
              _buildStaffManagementTab(context, auth),

              // TAB 2: Firma İşlem Logları
              _buildActivityLogsTab(context, auth),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStaffManagementTab(BuildContext context, AuthProvider auth) {
    final staff = auth.staffUsers;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Add Staff Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Çalışan Personel Sayısı', style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${staff.length} Aktif Personel', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldPrimary),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Personel Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _showAddStaffModal(context, auth),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text('Kayıtlı Çalışanlar & Giriş Bilgileri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),

        if (staff.isEmpty)
          const Center(child: Text('Henüz personel eklenmemiş.', style: TextStyle(color: AppTheme.textSecondaryDark)))
        else
          ...staff.map((user) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.emeraldPrimary.withValues(alpha: 0.2),
                    child: Text(user.fullName[0].toUpperCase(), style: const TextStyle(color: AppTheme.emeraldAccent, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(user.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('${user.title} • K.Adı: ${user.username} | Şifre: ${user.password}', style: const TextStyle(color: AppTheme.emeraldAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                      if (user.phone.isNotEmpty) Text('Tel: ${user.phone}', style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 11)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed, size: 20),
                    onPressed: () => auth.deleteStaff(user.id),
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildActivityLogsTab(BuildContext context, AuthProvider auth) {
    final logs = auth.activityLogs;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Tüm Personel & Admin İşlem Geçmişi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),

        if (logs.isEmpty)
          const Center(child: Text('İşlem kaydı bulunmuyor.', style: TextStyle(color: AppTheme.textSecondaryDark)))
        else
          ...logs.map((log) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.goldAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.history, color: AppTheme.goldAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log.action, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('${log.userName} (${log.userTitle})', style: const TextStyle(color: AppTheme.emeraldAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                          if (log.details.isNotEmpty) Text(log.details, style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(Formatters.formatDateTime(log.timestamp), style: const TextStyle(color: AppTheme.textMutedDark, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  void _showAddStaffModal(BuildContext context, AuthProvider auth) {
    final nameCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final titleCtrl = TextEditingController(text: 'Emlak Danışmanı');
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Yeni Çalışan / Personel Ekle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Ad Soyad *', hintText: 'Mehmet Yılmaz'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: usernameCtrl,
                      decoration: const InputDecoration(labelText: 'Kullanıcı Adı *', hintText: 'mehmet.yilmaz'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: passwordCtrl,
                      decoration: const InputDecoration(labelText: 'Şifre *', hintText: '123456'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Unvan / Görev', hintText: 'Kıdemli Danışman'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Telefon', hintText: '+90532...'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldPrimary),
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && usernameCtrl.text.isNotEmpty && passwordCtrl.text.isNotEmpty) {
                      auth.addStaff(
                        AppUser(
                          id: const Uuid().v4(),
                          username: usernameCtrl.text.trim(),
                          password: passwordCtrl.text.trim(),
                          fullName: nameCtrl.text.trim(),
                          title: titleCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          role: UserRole.staff,
                          createdAt: DateTime.now(),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Personeli Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
