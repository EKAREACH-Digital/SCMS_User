import 'package:flutter/foundation.dart';

import '../../data/repositories/coupon/coupon_repository.dart';
import '../../model/coupon/coupon_plan.dart';
import 'package:smart_canteen_user_frontend/core/utils/async_value.dart';

class ActiveCouponState extends ChangeNotifier {
  final CouponRepository _couponRepository;

  AsyncValue<List<ActiveCoupon>> _coupons = const AsyncLoading();

  ActiveCouponState(this._couponRepository);

  AsyncValue<List<ActiveCoupon>> get coupons => _coupons;

  ActiveCoupon? get breakfastCoupon => switch (_coupons) {
    AsyncData(data: final list) =>
      list.where((c) => c.session == 'breakfast' && !c.isExpired).firstOrNull,
    _ => null,
  };

  ActiveCoupon? get lunchCoupon => switch (_coupons) {
    AsyncData(data: final list) =>
      list.where((c) => c.session == 'lunch' && !c.isExpired).firstOrNull,
    _ => null,
  };

  Future<void> fetchActiveCoupons() async {
    _coupons = const AsyncLoading();
    notifyListeners();

    try {
      final dtos = await _couponRepository.getActiveCoupons();
      _coupons = AsyncData(dtos.map(ActiveCoupon.fromDto).toList());
    } catch (e, s) {
      _coupons = AsyncError(e, s);
    }

    notifyListeners();
  }
}
