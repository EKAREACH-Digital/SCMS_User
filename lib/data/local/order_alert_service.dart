import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Fires a "your food is ready" alert a short time after checkout.
///
/// Mock behaviour standing in for the real kitchen signal: the backend has no
/// order-ready event yet, so the delay is simulated on the device. One alert
/// per item ordered, each with sound and vibration.
///
/// Alerts are scheduled with the OS rather than a [Timer], so they still fire
/// when the app is backgrounded or closed — a `Timer` dies with the isolate.
class OrderAlertService {
  OrderAlertService._();

  static final OrderAlertService instance = OrderAlertService._();

  /// How long after checkout the food is "ready". Mock value.
  static const Duration readyAfter = Duration(minutes: 1);

  static const String _channelId = 'order_ready';
  static const String _channelName = 'Order updates';
  static const String _channelDescription =
      'Tells you when the food you ordered is ready to collect.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  /// Notified when an alert comes due while the app is alive, so the Alerts
  /// tab can show the same message the OS just delivered.
  final _fired = StreamController<OrderAlert>.broadcast();
  Stream<OrderAlert> get onAlert => _fired.stream;

  /// In-flight timers, so leaving the app doesn't leak them.
  final List<Timer> _timers = [];

  /// Safe to call more than once. Never throws — a device that refuses
  /// notification permission should not stop the app from starting.
  Future<void> init() async {
    if (_ready) return;
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(await _localTimeZone()));

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      );
      await _plugin.initialize(settings: settings);

      // Android needs the channel to exist before anything targets it, and
      // its importance is what earns heads-up display plus sound.
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: _channelDescription,
              importance: Importance.high,
            ),
          );

      // Android 13+ gates notifications behind a runtime permission.
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _ready = true;
    } catch (e) {
      debugPrint('[OrderAlertService] init failed: $e');
    }
  }

  /// Schedules one alert per item in the order.
  ///
  /// [items] is one entry per line on the receipt — put the quantity in the
  /// label ("Fried rice ×2") rather than repeating the same dish, so a
  /// three-of-one order buzzes once, not three times.
  Future<void> scheduleForOrder({
    required String orderId,
    required List<OrderAlertItem> items,
  }) async {
    if (!_ready) await init();
    if (!_ready) return;

    final dueAt = DateTime.now().add(readyAfter);

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final alert = OrderAlert(
        orderId: orderId,
        title: 'Your order is ready',
        body: '${item.label} is ready to collect.',
        dueAt: dueAt,
        imageUrl: item.imageUrl,
        imageAsset: item.imageAsset,
      );

      // Distinct per item, and stable per order, so a re-schedule replaces
      // rather than stacks. Kept inside 32-bit range, which Android requires.
      final id = (orderId.hashCode & 0x7FFFFF) * 8 + (i % 8);

      await _schedule(id, alert);

      // The OS handles the alert itself; this timer only exists to fold the
      // same message into the in-app Alerts list while the app is running.
      _timers.add(Timer(readyAfter, () => _fired.add(alert)));
    }
  }

  Future<void> _schedule(int id, OrderAlert alert) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: alert.title,
        body: alert.body,
        scheduledDate: tz.TZDateTime.from(alert.dueAt, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            // `timeSensitive` would punch through Focus modes, but it needs a
            // provisioning entitlement — `active` behaves the same without it.
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('[OrderAlertService] schedule failed: $e');
    }
  }

  /// Best-effort IANA zone name. Falls back to UTC, which only shifts the
  /// wall-clock label — the one-minute offset is computed from `now` either
  /// way, so the alert still lands a minute out.
  Future<String> _localTimeZone() async {
    try {
      final offset = DateTime.now().timeZoneOffset;
      // Cambodia and most of the region sit at +07:00; anything else falls
      // back to UTC rather than guessing a city.
      if (offset == const Duration(hours: 7)) return 'Asia/Phnom_Penh';
    } catch (_) {
      // fall through
    }
    return 'UTC';
  }

  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }
}

/// One line on the receipt, with whatever picture identifies it.
class OrderAlertItem {
  const OrderAlertItem({
    required this.label,
    this.imageUrl,
    this.imageAsset,
  });

  /// Dish name including quantity, e.g. "Fried rice ×2".
  final String label;

  /// The dish photo served by the backend, when it has one.
  final String? imageUrl;

  /// Bundled fallback image for dishes shipped with the app.
  final String? imageAsset;
}

/// A single "ready to collect" message.
class OrderAlert {
  const OrderAlert({
    required this.orderId,
    required this.title,
    required this.body,
    required this.dueAt,
    this.imageUrl,
    this.imageAsset,
  });

  final String orderId;
  final String title;
  final String body;
  final DateTime dueAt;
  final String? imageUrl;
  final String? imageAsset;
}
