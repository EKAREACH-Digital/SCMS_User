import 'package:flutter_test/flutter_test.dart';

import 'package:smart_canteen_user_frontend/features/notification/data/models/notification_preferences_dto.dart';

void main() {
  test('reads the notify_* switches off the user JSON', () {
    final prefs = NotificationPreferencesDto.fromUserJson({
      'id': 'user-1',
      'notify_order_updates': false,
      'notify_promotions': true,
      'notify_system_alerts': false,
    }).toEntity();

    expect(prefs.orderUpdates, isFalse);
    expect(prefs.promotions, isTrue);
    expect(prefs.systemAlerts, isFalse);
  });

  test('falls back to the backend column defaults', () {
    final prefs = NotificationPreferencesDto.fromUserJson({
      'id': 'user-1',
    }).toEntity();

    expect(prefs.orderUpdates, isTrue);
    expect(prefs.promotions, isFalse);
    expect(prefs.systemAlerts, isTrue);
  });
}
