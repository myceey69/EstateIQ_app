import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/watchlist_provider.dart';
import '../theme/theme.dart';
import 'home_screen.dart';
import 'profile/profile_screen.dart';
import 'market/market_trends_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'watchlist/watchlist_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MarketTrendsScreen(),
    DashboardScreen(),
    ProfileScreen(),
  ];

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'EstateIQ';
      case 1:
        return 'Market';
      case 2:
        return 'Dashboard';
      case 3:
        return 'Profile';
      default:
        return 'EstateIQ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistProvider>(
      builder: (context, watchlist, _) {
        return Scaffold(
          appBar: AppBar(
            title: Consumer<AuthProvider>(
              builder: (_, auth, __) {
                if (_currentIndex == 0 && auth.isLoggedIn) {
                  final first = auth.currentUser!.name.split(' ').first;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'EstateIQ',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hi, $first 👋',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }
                return Text(_getTitle(_currentIndex));
              },
            ),
            actions: [
              // Bell icon with unread badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.muted),
                    tooltip: 'Notifications',
                    onPressed: () => _showAlertsSheet(context, watchlist),
                  ),
                  if (watchlist.unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.bad,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            watchlist.unreadCount > 9
                                ? '9+'
                                : '${watchlist.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Watchlist icon
              IconButton(
                icon:
                    const Icon(Icons.bookmark_outline, color: AppColors.muted),
                tooltip: 'Open watchlist',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WatchlistScreen()),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            backgroundColor: AppColors.bg1,
            indicatorColor: AppColors.accent.withOpacity(0.2),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) =>
                setState(() => _currentIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.accent),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.trending_up_outlined),
                selectedIcon: Icon(Icons.trending_up, color: AppColors.accent),
                label: 'Market',
              ),
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon:
                    Icon(Icons.dashboard_rounded, color: AppColors.accent),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon:
                    Icon(Icons.person_rounded, color: AppColors.accent),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAlertsSheet(BuildContext context, WatchlistProvider watchlist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Alerts',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      watchlist.markAllRead();
                      Navigator.pop(context);
                    },
                    child: const Text('Mark all read',
                        style:
                            TextStyle(color: AppColors.accent, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.line, height: 1),
            if (watchlist.alerts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child:
                    Text('No alerts', style: TextStyle(color: AppColors.muted)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: watchlist.alerts.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: AppColors.line, height: 1),
                itemBuilder: (_, i) {
                  final alert = watchlist.alerts[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: alert.isRead
                          ? AppColors.panel
                          : AppColors.accent.withOpacity(0.15),
                      child: Icon(
                        _alertIcon(alert.type.name),
                        color:
                            alert.isRead ? AppColors.muted : AppColors.accent,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      alert.propertyTitle,
                      style: TextStyle(
                        color: alert.isRead ? AppColors.muted : AppColors.text,
                        fontSize: 14,
                        fontWeight:
                            alert.isRead ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      alert.message,
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => watchlist.markAlertRead(alert.id),
                  );
                },
              ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  IconData _alertIcon(String typeName) {
    switch (typeName) {
      case 'priceChange':
        return Icons.price_change_outlined;
      case 'newMatch':
        return Icons.search_outlined;
      case 'marketShift':
        return Icons.trending_up;
      default:
        return Icons.notifications_outlined;
    }
  }
}
