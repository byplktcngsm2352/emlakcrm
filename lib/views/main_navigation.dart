import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard/dashboard_view.dart';
import 'properties/property_list_view.dart';
import 'customers/customer_list_view.dart';
import 'matching/smart_matching_view.dart';
import 'ai_tools/ai_studio_view.dart';
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

  final List<Widget> _pages = const [
    DashboardView(),
    PropertyListView(),
    CustomerListView(),
    SmartMatchingView(),
    AiStudioView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildAppDrawer(context),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.emeraldAccent,
        unselectedItemColor: AppTheme.textMutedDark,
        backgroundColor: AppTheme.darkSurface,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard, color: AppTheme.emeraldAccent),
            label: 'Özet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work_outlined),
            activeIcon: Icon(Icons.home_work, color: AppTheme.emeraldAccent),
            label: 'Portföy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people, color: AppTheme.emeraldAccent),
            label: 'Müşteriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hub_outlined),
            activeIcon: Icon(Icons.hub, color: AppTheme.emeraldAccent),
            label: 'Eşleştirme',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome, color: AppTheme.goldAccent),
            label: 'AI Stüdyo',
          ),
        ],
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.darkSurface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.darkBackground, Color(0xFF0D5C3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldPrimary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.emeraldAccent),
                  ),
                  child: const Icon(Icons.real_estate_agent, color: AppTheme.goldAccent, size: 28),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Emlak CRM Premium',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'iOS 15+ Profesyonel Sürüm',
                  style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                ),
              ],
            ),
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
        ],
      ),
    );
  }
}
