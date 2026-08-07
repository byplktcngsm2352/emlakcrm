import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/crm_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../models/property.dart';
import '../properties/property_detail_view.dart';
import '../properties/property_form_view.dart';
import '../customers/customer_form_view.dart';
import '../reminders/reminders_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CrmProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.emeraldAccent));
        }

        return Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // iOS Large Title style Header Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.darkSurface,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.emeraldAccent.withOpacity(0.4)),
                        ),
                        child: const Icon(Icons.real_estate_agent, color: AppTheme.emeraldAccent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Emlak CRM Premium',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RemindersView()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Agent Welcome & Quick Actions Card
                      _buildWelcomeBanner(context),
                      const SizedBox(height: 20),

                      // Key Metrics Stat Grid
                      const Text(
                        'Portföy & Finansal Özet',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      _buildMetricsGrid(context, provider),

                      const SizedBox(height: 24),

                      // Property Category Distribution Chart
                      const Text(
                        'Portföy Dağılımı',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      _buildPortfolioDistributionChart(context, provider),

                      const SizedBox(height: 24),

                      // Pending Reminders Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Yaklaşan Randevu & Görevler',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RemindersView()),
                              );
                            },
                            child: const Text('Tümünü Gör', style: TextStyle(color: AppTheme.emeraldAccent)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildRemindersSummary(context, provider),

                      const SizedBox(height: 24),

                      // Recent Portfolios Carousel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Son Eklenen Portföyler',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondaryDark),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildRecentPropertiesList(context, provider),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D5C3A), Color(0xFF0F4C81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Hoş Geldiniz, Danışman',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Lüks Portföy Yönetimi',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.goldAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.goldAccent),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: AppTheme.goldAccent, size: 14),
                    SizedBox(width: 4),
                    Text('VIP CRM', style: TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.darkBackground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_home_work, color: AppTheme.emeraldPrimary),
                  label: const Text('Yeni Portföy', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PropertyFormView()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white30),
                    ),
                  ),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Yeni Müşteri', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomerFormView()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, CrmProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Toplam Portföy Değeri',
                value: Formatters.formatCompactCurrency(provider.totalPortfolioValue),
                subtitle: '${provider.activePropertiesCount} Aktif İlan',
                icon: Icons.account_balance_wallet,
                color: AppTheme.goldAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Aktif İlanlar',
                value: '${provider.activePropertiesCount}',
                subtitle: 'Portföyüm',
                icon: Icons.holiday_village,
                color: AppTheme.emeraldAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Kayıtlı Müşteri',
                value: '${provider.totalCustomersCount}',
                subtitle: 'CRM Veritabanı',
                icon: Icons.people_alt,
                color: AppTheme.infoBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Başarılı Satışlar',
                value: '${provider.closedDealsCount}',
                subtitle: 'Tamamlanan',
                icon: Icons.verified,
                color: AppTheme.successGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryDark)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  Widget _buildPortfolioDistributionChart(BuildContext context, CrmProvider provider) {
    final properties = provider.allProperties;
    int daireCount = properties.where((p) => p.type == PropertyType.daire).length;
    int villaCount = properties.where((p) => p.type == PropertyType.villa).length;
    int arsaCount = properties.where((p) => p.type == PropertyType.arsa).length;
    int ticariCount = properties.where((p) => p.type == PropertyType.ticari).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 30,
                sections: [
                  PieChartSectionData(color: AppTheme.emeraldAccent, value: daireCount.toDouble(), radius: 25, showTitle: false),
                  PieChartSectionData(color: AppTheme.goldAccent, value: villaCount.toDouble(), radius: 25, showTitle: false),
                  PieChartSectionData(color: AppTheme.infoBlue, value: arsaCount.toDouble(), radius: 25, showTitle: false),
                  PieChartSectionData(color: AppTheme.warningOrange, value: ticariCount.toDouble(), radius: 25, showTitle: false),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendRow('Daire', daireCount, AppTheme.emeraldAccent),
                const SizedBox(height: 6),
                _buildLegendRow('Villa', villaCount, AppTheme.goldAccent),
                const SizedBox(height: 6),
                _buildLegendRow('Arsa / Arazi', arsaCount, AppTheme.infoBlue),
                const SizedBox(height: 6),
                _buildLegendRow('İşyeri / Ticari', ticariCount, AppTheme.warningOrange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String title, int count, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
        const Spacer(),
        Text('$count Adet', style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRemindersSummary(BuildContext context, CrmProvider provider) {
    final pendingReminders = provider.reminders.where((r) => !r.isCompleted).take(3).toList();

    if (pendingReminders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: const Text('🎉 Bekleyen randevu veya hatırlatmanız bulunmuyor.', style: TextStyle(color: AppTheme.textSecondaryDark)),
      );
    }

    return Column(
      children: pendingReminders.map((reminder) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: ListTile(
            leading: IconButton(
              icon: Icon(
                reminder.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: reminder.isCompleted ? AppTheme.successGreen : AppTheme.emeraldAccent,
              ),
              onPressed: () => provider.toggleReminder(reminder.id),
            ),
            title: Text(
              reminder.title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              '${Formatters.formatDateTime(reminder.dateTime)} • ${reminder.typeName}',
              style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 11),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentPropertiesList(BuildContext context, CrmProvider provider) {
    final recent = provider.properties.take(4).toList();

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recent.length,
        itemBuilder: (context, index) {
          final prop = recent[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PropertyDetailView(property: prop)),
              );
            },
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      prop.imageUrls.isNotEmpty ? prop.imageUrls.first : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        color: AppTheme.darkSurface,
                        child: const Icon(Icons.home, color: AppTheme.textMutedDark),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prop.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prop.locationString,
                          style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Formatters.formatCurrency(prop.price, prop.currency),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.emeraldAccent, fontSize: 13),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldPrimary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                prop.roomCount,
                                style: const TextStyle(color: AppTheme.emeraldAccent, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
