import 'package:flutter/foundation.dart';

import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/meal_coupon.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/repositories/order_repository.dart';

/// Holds the signed-in user's active meal-ticket coupons (the ones shown as QR
/// codes in the QR screen). Populated after checkout and refreshable from the
/// backend.
class MealCouponsViewModel extends ChangeNotifier {
  MealCouponsViewModel(this._orderRepository);

  final OrderRepository _orderRepository;

  ViewState _state = ViewState.idle;
  List<MealCoupon> _coupons = const [];
  String? _errorMessage;

  ViewState get state => _state;

  /// Why the last fetch failed; null unless [state] is [ViewState.error].
  String? get errorMessage => _errorMessage;

  /// Every active coupon, whatever session it was filed under.
  ///
  /// All-day items (drinks) are attributed to the nearest meal session because
  /// the backend has no "anytime" value, which means filtering strictly by
  /// session can hide a ticket the user just bought. This is what the QR
  /// screen shows by default.
  List<MealCoupon> get activeAll => _coupons.where((c) => c.isActive).toList();

  /// Active coupons for a given meal session (breakfast/lunch/dinner).
  List<MealCoupon> forSession(String session) =>
      _coupons.where((c) => c.isActive && c.mealSession == session).toList();

  Future<void> fetchActive() async {
    // Nothing is shown while (re)loading, so a stale ticket can't be scanned.
    _coupons = const [];
    _setState(ViewState.loading);
    try {
      _coupons = await _orderRepository.getActiveCoupons();
      _setState(ViewState.success);
    } catch (e, s) {
      AppLogger.e('Loading meal coupons failed', e, s);
      _errorMessage = e is ApiException
          ? e.message
          : "Couldn't load your meal tickets. Please try again.";
      _setState(ViewState.error);
    }
  }

  /// Merges freshly minted coupons (from a just-placed order) into the list so
  /// they appear immediately, without waiting for a refetch.
  void addFromOrder(List<MealCoupon> newCoupons) {
    final existingIds = _coupons.map((c) => c.id).toSet();
    _coupons = [
      ..._coupons,
      ...newCoupons.where((c) => !existingIds.contains(c.id)),
    ];
    _setState(ViewState.success);
  }

  /// The only place listeners are notified. Leaving the error state clears
  /// the error message.
  void _setState(ViewState newState) {
    _state = newState;
    if (newState != ViewState.error) _errorMessage = null;
    notifyListeners();
  }
}
