import 'package:smart_canteen_user_frontend/features/notification/domain/entities/notification_item.dart';
import 'package:smart_canteen_user_frontend/features/notification/domain/entities/notification_preferences.dart';

abstract class NotificationRepository {
  /// The merged Alerts feed: the user's own event notifications plus published
  /// announcements, newest first.
  Future<List<NotificationItem>> getNotifications();

  /// Number of unread personal notifications (for the bell badge).
  Future<int> getUnreadCount();

  /// Marks all of the user's personal notifications as read on the server.
  Future<void> markAllRead();

  /// Dismisses (deletes) a single personal notification on the server. Only
  /// personal notifications can be dismissed — announcements are broadcast.
  Future<void> dismiss(String id);

  /// The signed-in user's notification switches.
  Future<NotificationPreferences> getPreferences();

  /// Saves the switches for [userId] and returns the fresh set. Only non-null
  /// flags are sent, so callers can patch a subset.
  Future<NotificationPreferences> updatePreferences({
    required String userId,
    bool? orderUpdates,
    bool? promotions,
    bool? systemAlerts,
  });
}
