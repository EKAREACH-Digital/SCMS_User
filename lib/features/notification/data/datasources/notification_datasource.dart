import 'package:smart_canteen_user_frontend/features/notification/data/models/notification_dto.dart';
import 'package:smart_canteen_user_frontend/features/notification/data/models/notification_preferences_dto.dart';

abstract class NotificationDatasource {
  /// Personal notifications and published announcements, merged newest first.
  Future<List<NotificationDto>> getNotifications();

  Future<int> getUnreadCount();

  Future<void> markAllRead();

  Future<void> dismiss(String id);

  Future<NotificationPreferencesDto> getPreferences();

  Future<NotificationPreferencesDto> updatePreferences({
    required String userId,
    bool? orderUpdates,
    bool? promotions,
    bool? systemAlerts,
  });
}
