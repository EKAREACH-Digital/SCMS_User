import 'package:flutter/foundation.dart';

import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/features/notification/domain/repositories/notification_repository.dart';

/// User-controllable notification preferences shown in Settings --> Notifications.
///
/// Loaded for the signed-in user (`GET /users/me`) and persisted
/// (`PATCH /users/:id/notification-preferences`) on every toggle. Updates are
/// optimistic: the switch flips immediately and rolls back if the request
/// fails.
class NotificationPrefsViewModel extends ChangeNotifier {
  NotificationPrefsViewModel(this._repository);

  final NotificationRepository _repository;

  String? _userId;
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _systemAlerts = true;
  ViewState _state = ViewState.idle;

  bool get orderUpdates => _orderUpdates;
  bool get promotions => _promotions;
  bool get systemAlerts => _systemAlerts;

  /// Status of the last load or save.
  ViewState get state => _state;

  /// True while a toggle is being persisted.
  bool get isSaving => _state == ViewState.loading;

  /// Follows the signed-in user's id from `AuthViewModel` (wired with a
  /// `ChangeNotifierProxyProvider`). A different user reloads the switches;
  /// the same user keeps them, so an in-flight change isn't overwritten.
  void syncFrom(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    if (userId != null) load();
  }

  /// `GET /users/me` — reads the current switches.
  Future<void> load() async {
    try {
      final prefs = await _repository.getPreferences();
      _orderUpdates = prefs.orderUpdates;
      _promotions = prefs.promotions;
      _systemAlerts = prefs.systemAlerts;
      _setState(ViewState.success);
    } catch (e, s) {
      AppLogger.e('Loading notification preferences failed', e, s);
      _setState(ViewState.error);
    }
  }

  /// Returns true once the change is saved, false if it failed (and was rolled
  /// back). The caller can surface an error when false.
  Future<bool> setOrderUpdates(bool value) => _persist(orderUpdates: value);
  Future<bool> setPromotions(bool value) => _persist(promotions: value);
  Future<bool> setSystemAlerts(bool value) => _persist(systemAlerts: value);

  Future<bool> _persist({
    bool? orderUpdates,
    bool? promotions,
    bool? systemAlerts,
  }) async {
    final userId = _userId;
    if (userId == null) return false;

    // Snapshot for rollback, then apply optimistically.
    final prevOrderUpdates = _orderUpdates;
    final prevPromotions = _promotions;
    final prevSystemAlerts = _systemAlerts;
    if (orderUpdates != null) _orderUpdates = orderUpdates;
    if (promotions != null) _promotions = promotions;
    if (systemAlerts != null) _systemAlerts = systemAlerts;
    _setState(ViewState.loading);

    try {
      // PATCH /users/:id/notification-preferences — saves the toggle.
      final prefs = await _repository.updatePreferences(
        userId: userId,
        orderUpdates: orderUpdates,
        promotions: promotions,
        systemAlerts: systemAlerts,
      );
      _orderUpdates = prefs.orderUpdates;
      _promotions = prefs.promotions;
      _systemAlerts = prefs.systemAlerts;
      _setState(ViewState.success);
      return true;
    } catch (e, s) {
      AppLogger.e('Saving notification preferences failed, rolled back', e, s);
      _orderUpdates = prevOrderUpdates;
      _promotions = prevPromotions;
      _systemAlerts = prevSystemAlerts;
      _setState(ViewState.error);
      return false;
    }
  }

  /// The only place listeners are notified.
  void _setState(ViewState newState) {
    _state = newState;
    notifyListeners();
  }
}
