import 'package:smart_canteen_user_frontend/features/notification/domain/entities/notification_preferences.dart';

/// The signed-in user's push-notification preferences. Stored on the backend
/// `User` record (`notify_*` columns) and edited from Settings → Notifications.
class NotificationPreferencesDto {
  final bool orderUpdates;
  final bool promotions;
  final bool systemAlerts;

  const NotificationPreferencesDto({
    required this.orderUpdates,
    required this.promotions,
    required this.systemAlerts,
  });

  /// Reads the flat `notify_*` fields off a backend `User` JSON, defaulting to
  /// the backend column defaults when any are absent.
  factory NotificationPreferencesDto.fromUserJson(Map<String, dynamic> json) =>
      NotificationPreferencesDto(
        orderUpdates: json['notify_order_updates'] as bool? ?? true,
        promotions: json['notify_promotions'] as bool? ?? false,
        systemAlerts: json['notify_system_alerts'] as bool? ?? true,
      );

  NotificationPreferences toEntity() => NotificationPreferences(
    orderUpdates: orderUpdates,
    promotions: promotions,
    systemAlerts: systemAlerts,
  );
}
