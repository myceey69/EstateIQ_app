import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../providers/property_provider.dart';
import '../../theme/theme.dart';
import '../../models/alert.dart';
import '../../widgets/property_card.dart';
import '../detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({Key? key}) : super(key: key);

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistProvider>(
      builder: (context, watchlist, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Watchlist'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (_tabCtrl.index == 1 && watchlist.alerts.isNotEmpty)
                TextButton(
                  onPressed: () {
                    watchlist.markAllRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('All alerts marked as read'),
                          backgroundColor: AppColors.good),
                    );
                  },
                  child: const Text('Mark all read',
                      style: TextStyle(color: AppColors.accent, fontSize: 13)),
                ),
            ],
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: AppColors.accent,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.muted,
              onTap: (_) => setState(() {}),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Saved'),
                      if (watchlist.watchedIds.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _badge(
                            '${watchlist.watchedIds.length}', AppColors.accent),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Alerts'),
                      if (watchlist.unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        _badge('${watchlist.unreadCount}', AppColors.bad),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              _SavedPropertiesTab(watchlist: watchlist),
              _AlertsTab(watchlist: watchlist),
            ],
          ),
        );
      },
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _SavedPropertiesTab extends StatelessWidget {
  final WatchlistProvider watchlist;
  const _SavedPropertiesTab({required this.watchlist});

  @override
  Widget build(BuildContext context) {
    final properties = context.watch<PropertyProvider>();
    final saved = watchlist.watchedIds
        .map((id) {
          try {
            return properties.allProperties.firstWhere((p) => p.id == id);
          } catch (_) {
            return null;
          }
        })
        .whereType<dynamic>()
        .toList();

    if (saved.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border_outlined,
                size: 64, color: AppColors.muted),
            const SizedBox(height: 16),
            const Text('No saved properties yet',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('Browse properties and tap Save to add them here.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: saved.length,
      itemBuilder: (ctx, i) {
        final prop = saved[i];
        return Dismissible(
          key: Key(prop.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            watchlist.removeFromWatchlist(prop.id);
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text('${prop.title} removed from watchlist'),
                backgroundColor: AppColors.warn,
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: Colors.white,
                  onPressed: () => watchlist.addToWatchlist(prop.id),
                ),
              ),
            );
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.bad.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_outline, color: AppColors.bad),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PropertyCard(
              property: prop,
              onTap: () {
                context.read<PropertyProvider>().setSelectedProperty(prop);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DetailScreen()));
              },
            ),
          ),
        );
      },
    );
  }
}

class _AlertsTab extends StatelessWidget {
  final WatchlistProvider watchlist;
  const _AlertsTab({required this.watchlist});

  @override
  Widget build(BuildContext context) {
    if (watchlist.alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 64, color: AppColors.muted),
            const SizedBox(height: 16),
            const Text('No alerts',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text(
                'You\'ll receive alerts for price changes and new matches.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: watchlist.alerts.length,
      separatorBuilder: (_, __) =>
          const Divider(color: AppColors.line, height: 1),
      itemBuilder: (ctx, i) {
        final alert = watchlist.alerts[i];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: alert.isRead
                ? AppColors.panel
                : AppColors.accent.withOpacity(0.15),
            child: Icon(
              _alertIcon(alert.type),
              color: alert.isRead ? AppColors.muted : AppColors.accent,
              size: 18,
            ),
          ),
          title: Text(
            alert.propertyTitle,
            style: TextStyle(
              color: alert.isRead ? AppColors.muted : AppColors.text,
              fontSize: 14,
              fontWeight: alert.isRead ? FontWeight.normal : FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.message,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _timeAgo(alert.createdAt),
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ],
          ),
          trailing: !alert.isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () => watchlist.markAlertRead(alert.id),
        );
      },
    );
  }

  IconData _alertIcon(AlertType type) {
    switch (type) {
      case AlertType.priceChange:
        return Icons.price_change_outlined;
      case AlertType.newMatch:
        return Icons.search_outlined;
      case AlertType.marketShift:
        return Icons.trending_up;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
