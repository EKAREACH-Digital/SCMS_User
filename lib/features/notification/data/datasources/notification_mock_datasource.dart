import 'package:smart_canteen_user_frontend/features/notification/data/datasources/notification_datasource.dart';
import 'package:smart_canteen_user_frontend/features/notification/data/models/notification_dto.dart';
import 'package:smart_canteen_user_frontend/features/notification/data/models/notification_preferences_dto.dart';
import 'package:smart_canteen_user_frontend/features/notification/domain/entities/notification_item.dart';

/// In-memory [NotificationDatasource] for tests and offline work.
class NotificationMockDatasource implements NotificationDatasource {
  // Dismissed ids so the mock feed reflects dismiss() within a session.
  final Set<String> _dismissed = {};
  bool _allRead = false;

  List<NotificationDto> _seed() {
    final now = DateTime.now();
    return [
      NotificationDto(
        id: 'n1',
        title: 'Low balance',
        body: 'Your wallet balance is below \$5. Top Up to keep ordering.',
        type: 'wallet',
        isRead: _allRead,
        createdAt: now.subtract(const Duration(minutes: 10)),
        source: NotificationSource.personal,
      ),
      NotificationDto(
        id: 'n2',
        title: 'Order ready for pickup',
        body: 'Your order is ready — head to the counter to pick it up.',
        type: 'order',
        isRead: _allRead,
        createdAt: now.subtract(const Duration(hours: 2)),
        source: NotificationSource.personal,
      ),
      NotificationDto(
        id: 'a1',
        title: 'Scholar Discount Active',
        body: '20% off all meals this week for CADT Scholars.',
        type: 'announcement',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 5)),
        source: NotificationSource.announcement,
      ),
      NotificationDto(
        id: 'n3',
        title: 'Top Up confirmed',
        body: '\$10.00 was added to your wallet.',
        type: 'wallet',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
        source: NotificationSource.personal,
      ),
    ];
  }

  @override
  Future<List<NotificationDto>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _seed().where((n) => !_dismissed.contains(n.id)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    if (_allRead) return 0;
    return _seed()
        .where(
          (n) =>
              !n.isRead &&
              n.source == NotificationSource.personal &&
              !_dismissed.contains(n.id),
        )
        .length;
  }

  @override
  Future<void> markAllRead() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _allRead = true;
  }

  @override
  Future<void> dismiss(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _dismissed.add(id);
  }

  // In-memory switches so mock toggles persist for the app session.
  NotificationPreferencesDto _prefs = const NotificationPreferencesDto(
    orderUpdates: true,
    promotions: false,
    systemAlerts: true,
  );

  @override
  Future<NotificationPreferencesDto> getPreferences() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _prefs;
  }

  @override
  Future<NotificationPreferencesDto> updatePreferences({
    required String userId,
    bool? orderUpdates,
    bool? promotions,
    bool? systemAlerts,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _prefs = NotificationPreferencesDto(
      orderUpdates: orderUpdates ?? _prefs.orderUpdates,
      promotions: promotions ?? _prefs.promotions,
      systemAlerts: systemAlerts ?? _prefs.systemAlerts,
    );
    return _prefs;
  }
}
