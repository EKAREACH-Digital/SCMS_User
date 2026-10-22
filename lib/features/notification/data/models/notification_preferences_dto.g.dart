// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPreferencesDto _$NotificationPreferencesDtoFromJson(
  Map<String, dynamic> json,
) => NotificationPreferencesDto(
  orderUpdates: json['notify_order_updates'] as bool? ?? true,
  promotions: json['notify_promotions'] as bool? ?? false,
  systemAlerts: json['notify_system_alerts'] as bool? ?? true,
);
