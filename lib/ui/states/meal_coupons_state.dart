import 'package:flutter/foundation.dart';

import '../../data/dtos/order_dto.dart';
import '../../data/repositories/order/order_repository.dart';
import '../utils/async_value.dart';

/// Holds the signed-in user's active meal-ticket coupons (the ones shown as QR
/// codes in the QR screen). Populated after checkout and refreshable from the
/// backend.
class MealCouponsState extends ChangeNotifier {
  final OrderRepository _orderRepository;

  MealCouponsState(this._orderRepository);

  AsyncValue<List<CouponDto>> _coupons = const AsyncData([]);
  AsyncValue<List<CouponDto>> get coupons => _coupons;

  List<CouponDto> get _list => switch (_coupons) {
        AsyncData(:final data) => data,
        _ => const [],
      };

  /// Every active coupon, whatever session it was filed under.
  ///
  /// All-day items (drinks) are attributed to the nearest meal session because
  /// the backend has no "anytime" value, which means filtering strictly by
  /// session can hide a ticket the user just bought. This is what the QR
  /// screen shows by default.
  List<CouponDto> get activeAll => _list.where((c) => c.isActive).toList();

  /// Active coupons for a given meal session (breakfast/lunch/dinner).
  List<CouponDto> forSession(String session) =>
      _list.where((c) => c.isActive && c.mealSession == session).toList();

  Future<void> fetchActive() async {
    _coupons = const AsyncLoading();
    notifyListeners();
    try {
      _coupons = AsyncData(await _orderRepository.getActiveCoupons());
    } catch (e, s) {
      _coupons = AsyncError(e, s);
    }
    notifyListeners();
  }

  /// Merges freshly minted coupons (from a just-placed order) into the list so
  /// they appear immediately, without waiting for a refetch.
  void addFromOrder(List<CouponDto> newCoupons) {
    final existingIds = _list.map((c) => c.id).toSet();
    final merged = [
      ..._list,
      ...newCoupons.where((c) => !existingIds.contains(c.id)),
    ];
    _coupons = AsyncData(merged);
    notifyListeners();
  }
}
