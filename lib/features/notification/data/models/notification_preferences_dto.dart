import 'package:json_annotation/json_annotation.dart';

import 'package:smart_canteen_user_frontend/features/notification/domain/entities/notification_preferences.dart';

part 'notification_preferences_dto.g.dart';

/// The signed-in user's push-notification preferences. Stored on the backend
/// `User` record (`notify_*` columns) and edited from Settings → Notifications.
/// Missing fields fall back to the backend column defaults.
@JsonSerializable()
class NotificationPreferencesDto {
  @JsonKey(name: 'notify_order_updates', defaultValue: true)
  final bool orderUpdates;
  @JsonKey(name: 'notify_promotions', defaultValue: false)
  final bool promotions;
  @JsonKey(name: 'notify_system_alerts', defaultValue: true)
  final bool systemAlerts;

  const NotificationPreferencesDto({
    required this.orderUpdates,
    required this.promotions,
    required this.systemAlerts,
  });

  /// Reads the flat `notify_*` fields off a backend `User` JSON.
  factory NotificationPreferencesDto.fromUserJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesDtoFromJson(json);

  NotificationPreferences toEntity() => NotificationPreferences(
    orderUpdates: orderUpdates,
    promotions: promotions,
    systemAlerts: systemAlerts,
  );
}
