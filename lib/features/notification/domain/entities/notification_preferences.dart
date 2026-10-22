/// The signed-in user's push-notification preferences, edited from
/// Settings → Notifications.
class NotificationPreferences {
  final bool orderUpdates;
  final bool promotions;
  final bool systemAlerts;

  /// Defaults match the backend column defaults.
  const NotificationPreferences({
    this.orderUpdates = true,
    this.promotions = false,
    this.systemAlerts = true,
  });

  NotificationPreferences copyWith({
    bool? orderUpdates,
    bool? promotions,
    bool? systemAlerts,
  }) {
    return NotificationPreferences(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      systemAlerts: systemAlerts ?? this.systemAlerts,
    );
  }
}
