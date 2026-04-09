import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/listing_provider.dart';
import '../../models/user.dart';
import '../../theme/theme.dart';
import '../watchlist/watchlist_screen.dart';
import '../recommendations_screen.dart';
import '../reports/reports_screen.dart';
import '../listings/listing_management_screen.dart';
import '../leads/leads_screen.dart';
import '../admin/admin_console_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        if (user == null) {
          return const Center(
            child:
                Text('Not logged in', style: TextStyle(color: AppColors.muted)),
          );
        }
        switch (user.role) {
          case UserRole.admin:
            return _AdminDashboard(user: user);
          case UserRole.agent:
            return _AgentDashboard(user: user);
          default:
            return _BuyerInvestorDashboard(user: user);
        }
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Buyer / Investor Dashboard
// ─────────────────────────────────────────────────────────────────────────────
class _BuyerInvestorDashboard extends StatelessWidget {
  final AppUser user;
  const _BuyerInvestorDashboard({required this.user});

  String _planLabel(SubscriptionPlan p) {
    switch (p) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.basic:
        return 'Basic';
      case SubscriptionPlan.professional:
        return 'Pro';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
    }
  }

  Color _planColor(SubscriptionPlan p) {
    switch (p) {
      case SubscriptionPlan.free:
        return AppColors.muted;
      case SubscriptionPlan.basic:
        return AppColors.accent2;
      case SubscriptionPlan.professional:
        return AppColors.accent;
      case SubscriptionPlan.enterprise:
        return AppColors.warn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistProvider>();
    final properties = context.watch<PropertyProvider>();
    final firstName = user.name.split(' ').first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back, $firstName! 👋',
                        style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text("Here's your investment overview",
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _planColor(user.plan).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: _planColor(user.plan).withOpacity(0.4)),
                ),
                child: Text(_planLabel(user.plan),
                    style: TextStyle(
                        color: _planColor(user.plan),
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick stats
          Row(
            children: [
              Expanded(
                  child: _statCard(
                'Saved',
                '${watchlist.watchedIds.length}',
                Icons.bookmark_outlined,
                AppColors.accent,
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: _statCard(
                'Alerts',
                '${watchlist.unreadCount}',
                Icons.notifications_outlined,
                AppColors.warn,
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: _statCard(
                'Listings',
                '${properties.allProperties.length}',
                Icons.home_outlined,
                AppColors.good,
              )),
            ],
          ),
          const SizedBox(height: 16),

          _sectionHeader(context, 'Quick Actions'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _quickAction(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Recommendations',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RecommendationsScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _quickAction(
                  icon: Icons.description_outlined,
                  label: 'Reports',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportsScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _quickAction(
                  icon: Icons.bookmark_outline,
                  label: 'Watchlist',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WatchlistScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Matching Properties
          _sectionHeader(context, 'Matching Your Criteria'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.filter_alt_outlined,
                      color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${properties.allProperties.length} properties',
                      style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    const Text('match your saved criteria',
                        style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Watchlist summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Watchlist',
                  style: Theme.of(context).textTheme.headlineSmall),
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const WatchlistScreen())),
                child: const Text('View All',
                    style: TextStyle(color: AppColors.accent, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (watchlist.watchedIds.isEmpty)
            _emptyState(
                Icons.bookmark_border_outlined, 'No saved properties yet')
          else
            ...watchlist.watchedIds.take(3).map((id) {
              try {
                final p =
                    properties.allProperties.firstWhere((p) => p.id == id);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bg1,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.home_outlined,
                            color: AppColors.accent, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title,
                                style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis),
                            Text(p.priceFormatted,
                                style: const TextStyle(
                                    color: AppColors.accent2, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: p.getSignalColor().withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(p.signal,
                            style: TextStyle(
                                color: p.getSignalColor(),
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              } catch (_) {
                return const SizedBox.shrink();
              }
            }),
          const SizedBox(height: 16),

          // Recent Alerts
          _sectionHeader(context, 'Recent Alerts'),
          const SizedBox(height: 10),
          if (watchlist.alerts.isEmpty)
            _emptyState(Icons.notifications_off_outlined, 'No alerts')
          else
            ...watchlist.alerts.take(3).map((alert) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bg1,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: alert.isRead
                            ? AppColors.line
                            : AppColors.accent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_outlined,
                          color:
                              alert.isRead ? AppColors.muted : AppColors.accent,
                          size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alert.propertyTitle,
                                style: TextStyle(
                                    color: alert.isRead
                                        ? AppColors.muted
                                        : AppColors.text,
                                    fontSize: 12,
                                    fontWeight: alert.isRead
                                        ? FontWeight.normal
                                        : FontWeight.w600)),
                            Text(alert.message,
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 16),

          // AI Recommendations CTA
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const RecommendationsScreen())),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.3),
                    AppColors.accent2.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: AppColors.accent, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Recommendations',
                            style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text('See properties tailored to your profile',
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: AppColors.accent, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Market Snapshot
          _sectionHeader(context, 'Market Snapshot'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('San Jose, CA',
                        style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    Text('Avg Price',
                        style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    Text('\$879K',
                        style: TextStyle(
                            color: AppColors.accent2,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.good.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.trending_up,
                              color: AppColors.good, size: 14),
                          SizedBox(width: 4),
                          Text('+4.2% YoY',
                              style: TextStyle(
                                  color: AppColors.good,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('14 days avg on market',
                        style: TextStyle(color: AppColors.muted, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Agent Dashboard
// ─────────────────────────────────────────────────────────────────────────────
class _AgentDashboard extends StatelessWidget {
  final AppUser user;
  const _AgentDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingProvider>().listings;
    final firstName = user.name.split(' ').first;

    final activeListings =
        listings.where((l) => l.status.name == 'active').length;
    final sold = listings.where((l) => l.status.name == 'sold').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, $firstName 👔',
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const Text('Agent Dashboard',
              style: TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                  child: _statCard('Active Listings', '$activeListings',
                      Icons.home_outlined, AppColors.good)),
              const SizedBox(width: 10),
              Expanded(
                  child: _statCard('Total Leads', '5', Icons.people_outline,
                      AppColors.accent)),
              const SizedBox(width: 10),
              Expanded(
                  child: _statCard('Closed/mo', '$sold',
                      Icons.check_circle_outline, AppColors.warn)),
            ],
          ),
          const SizedBox(height: 16),

          // Pipeline mini-view
          _sectionHeader(context, 'Lead Pipeline'),
          const SizedBox(height: 10),
          Row(
            children: [
              _pipelineCard('New', 1, AppColors.accent2),
              const SizedBox(width: 8),
              _pipelineCard('Contacted', 2, AppColors.warn),
              const SizedBox(width: 8),
              _pipelineCard('Qualified', 1, AppColors.good),
              const SizedBox(width: 8),
              _pipelineCard('Closed', 1, AppColors.muted),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _quickAction(
                  icon: Icons.home_work_outlined,
                  label: 'Manage Listings',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ListingManagementScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _quickAction(
                  icon: Icons.people_outline,
                  label: 'Lead Management',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LeadsScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Recent listings
          _sectionHeader(context, 'Recent Listings'),
          const SizedBox(height: 10),
          ...listings.take(3).map((l) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bg1,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.title,
                              style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text(
                              '\$${l.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                              style: const TextStyle(
                                  color: AppColors.accent2, fontSize: 12)),
                        ],
                      ),
                    ),
                    _statusBadge(l.status.name),
                  ],
                ),
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _pipelineCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 20)),
            Text(label,
                style: const TextStyle(color: AppColors.muted, fontSize: 9),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = AppColors.good;
        break;
      case 'underContract':
        color = AppColors.warn;
        break;
      case 'sold':
        color = AppColors.accent;
        break;
      default:
        color = AppColors.muted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Admin Dashboard
// ─────────────────────────────────────────────────────────────────────────────
class _AdminDashboard extends StatelessWidget {
  final AppUser user;
  const _AdminDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Admin Dashboard',
              style: TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const Text('System Overview',
              style: TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 16),

          // Stats
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _adminCard('Total Users', '1,284', AppColors.accent),
              _adminCard('Active Subs', '847', AppColors.good),
              _adminCard('Listings', '3,192', AppColors.accent2),
              _adminCard('API Calls', '42.8K', AppColors.warn),
            ],
          ),
          const SizedBox(height: 16),

          // User Growth Chart
          _sectionHeader(context, 'User Growth (6 months)'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: 300,
                  barGroups: [
                    _bar(0, 180),
                    _bar(1, 210),
                    _bar(2, 195),
                    _bar(3, 245),
                    _bar(4, 270),
                    _bar(5, 284),
                  ],
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.line.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (_) =>
                        const FlLine(color: Colors.transparent),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const m = ['Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb'];
                          final i = v.toInt();
                          return i < m.length
                              ? Text(m[i],
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 9))
                              : const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (v, _) => Text(
                          '${v.toInt()}',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 9),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminConsoleScreen()),
              ),
              icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
              label: const Text('Open Full Admin Console'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.accent),
                foregroundColor: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.accent,
          width: 22,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _adminCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 22)),
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────
Widget _statCard(String label, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      color: AppColors.bg1,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: const TextStyle(color: AppColors.muted, fontSize: 9),
            textAlign: TextAlign.center),
      ],
    ),
  );
}

Widget _sectionHeader(BuildContext context, String title) {
  return Text(title, style: Theme.of(context).textTheme.headlineSmall);
}

Widget _quickAction({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return SizedBox(
    height: 48,
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.line),
        foregroundColor: AppColors.text,
      ),
    ),
  );
}

Widget _emptyState(IconData icon, String text) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: AppColors.muted),
          const SizedBox(height: 6),
          Text(text,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    ),
  );
}
