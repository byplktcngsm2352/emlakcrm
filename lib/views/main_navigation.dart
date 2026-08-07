import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard/dashboard_view.dart';
import 'properties/property_list_view.dart';
import 'customers/customer_list_view.dart';
import 'matching/smart_matching_view.dart';
import 'ai_tools/ai_studio_view.dart';
import 'admin/admin_dashboard_view.dart';
import 'auth/login_view.dart';
import 'whatsapp/whatsapp_templates_view.dart';
import 'reminders/reminders_view.dart';
import 'portal_tracking/portal_tracking_view.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (!auth.isLoggedIn) {
          return const LoginView();
        }

        final pages = [
          const DashboardView(),
          const PropertyListView(),
          const CustomerListView(),
          const SmartMatchingView(),
          const AiStudioView(),
          if (auth.isAdmin) const AdminDashboardView(),
        ];

        return Scaffold(
          drawer: _buildAppDrawer(context, auth),
          body: IndexedStack(
            index: _currentIndex < pages.length ? _currentIndex : 0,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex < pages.length ? _currentIndex : 0,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.emeraldAccent,
            unselectedItemColor: AppTheme.textMutedDark,
            backgroundColor: AppTheme.darkSurface,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard, color: AppTheme.emeraldAccent),
                label: 'Özet',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_work_outlined),
                activeIcon: Icon(Icons.home_work, color: AppTheme.emeraldAccent),
                label: 'Portföy',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people, color: AppTheme.emeraldAccent),
                label: 'Müşteriler',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.hub_outlined),
                activeIcon: Icon(Icons.hub, color: AppTheme.emeraldAccent),
                label: 'Eşleştirme',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_outlined),
                activeIcon: Icon(Icons.auto_awesome, color: AppTheme.goldAccent),
                label: 'AI Stüdyo',
              ),
              if (auth.isAdmin)
                const BottomNavigationBarItem(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  activeIcon: Icon(Icons.admin_panel_settings, color: AppTheme.goldAccent),
                  label: 'Admin',
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppDrawer(BuildContext context, AuthProvider auth) {
    final user = auth.currentUser;

    return Drawer(
      backgroundColor: AppTheme.darkSurface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.darkBackground, Color(0xFF0D5C3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppTheme.emeraldPrimary,
              child: Text(
                user != null && user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'A',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            accountName: Text(user?.fullName ?? 'Aktif Kullanıcı', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            accountEmail: Text('${user?.roleName} • ${user?.title}', style: const TextStyle(color: AppTheme.goldAccent, fontSize: 12)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: AppTheme.emeraldAccent),
            title: const Text('Ana Sayfa & Portföy Özeti', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.home_work, color: AppTheme.emeraldAccent),
            title: const Text('Portföyüm & İlanlar', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: AppTheme.emeraldAccent),
            title: const Text('Müşteri Kayıtları & CRM', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.hub, color: AppTheme.emeraldAccent),
            title: const Text('Akıllı Eşleştirme Motoru', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: AppTheme.goldAccent),
            title: const Text('AI İlan & Öneri Stüdyosu', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 4);
            },
          ),
          if (auth.isAdmin) ...[
            const Divider(color: AppTheme.darkBorder),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: AppTheme.goldAccent),
              title: const Text('👑 Admin Paneli (Personel & Loglar)', style: TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 5);
              },
            ),
          ],
          const Divider(color: AppTheme.darkBorder),
          ListTile(
            leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
            title: const Text('WhatsApp Şablonları', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WhatsappTemplatesView()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active, color: AppTheme.warningOrange),
            title: const Text('Hatırlatmalar & Randevular', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RemindersView()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.travel_explore, color: AppTheme.infoBlue),
            title: const Text('Portal Link Takibi', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PortalTrackingView()));
            },
          ),
          const Divider(color: AppTheme.darkBorder),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorRed),
            title: const Text('Çıkış Yap', style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold)),
            onTap: () async {
              Navigator.pop(context);
              await auth.logout();
            },
          ),
        ],
      ),
    );
  }
}
