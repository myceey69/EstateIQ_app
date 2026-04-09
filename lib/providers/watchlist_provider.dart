import 'package:flutter/foundation.dart';
import '../models/alert.dart';

class WatchlistProvider extends ChangeNotifier {
  final List<String> _watchedIds = [];
  final List<Alert> _alerts = [];

  WatchlistProvider() {
    _seedDemoAlerts();
  }

  List<String> get watchedIds => List.unmodifiable(_watchedIds);
  List<Alert> get alerts => List.unmodifiable(_alerts);

  int get unreadCount => _alerts.where((a) => !a.isRead).length;

  bool isWatched(String id) => _watchedIds.contains(id);

  void addToWatchlist(String id) {
    if (!_watchedIds.contains(id)) {
      _watchedIds.add(id);
      notifyListeners();
    }
  }

  void removeFromWatchlist(String id) {
    _watchedIds.remove(id);
    notifyListeners();
  }

  void addAlert(Alert alert) {
    _alerts.insert(0, alert);
    notifyListeners();
  }

  void markAlertRead(String id) {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllRead() {
    for (var i = 0; i < _alerts.length; i++) {
      if (!_alerts[i].isRead) {
        _alerts[i] = _alerts[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  void _seedDemoAlerts() {
    _alerts.addAll([
      Alert(
        id: 'alert-1',
        propertyId: 'SJ2',
        propertyTitle: 'Downtown Modern Condo',
        type: AlertType.priceChange,
        message: 'Price dropped by \$15,000 — now listed at \$720,000.',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Alert(
        id: 'alert-2',
        propertyId: 'SJ5',
        propertyTitle: 'Tech Hub Apartment',
        type: AlertType.newMatch,
        message: 'New listing matches your saved search "tech hub apartments".',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ]);
  }
}
