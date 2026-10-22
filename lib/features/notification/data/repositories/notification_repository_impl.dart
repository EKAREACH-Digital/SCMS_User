import 'package:smart_canteen_user_frontend/features/notification/data/datasources/notification_datasource.dart';
import 'package:smart_canteen_user_frontend/features/notification/domain/entities/notification_item.dart';
import 'package:smart_canteen_user_frontend/features/notification/domain/entities/notification_preferences.dart';
import 'package:smart_canteen_user_frontend/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._datasource);

  final NotificationDatasource _datasource;

  @override
  Future<List<NotificationItem>> getNotifications() async =>
      (await _datasource.getNotifications()).map((n) => n.toEntity()).toList();

  @override
  Future<int> getUnreadCount() => _datasource.getUnreadCount();

  @override
  Future<void> markAllRead() => _datasource.markAllRead();

  @override
  Future<void> dismiss(String id) => _datasource.dismiss(id);

  @override
  Future<NotificationPreferences> getPreferences() async =>
      (await _datasource.getPreferences()).toEntity();

  @override
  Future<NotificationPreferences> updatePreferences({
    required String userId,
    bool? orderUpdates,
    bool? promotions,
    bool? systemAlerts,
  }) async {
    final dto = await _datasource.updatePreferences(
      userId: userId,
      orderUpdates: orderUpdates,
      promotions: promotions,
      systemAlerts: systemAlerts,
    );
    return dto.toEntity();
  }
}
