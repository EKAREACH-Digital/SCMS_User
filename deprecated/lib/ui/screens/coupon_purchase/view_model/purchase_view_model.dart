import 'package:flutter/foundation.dart';

import '../../../../data/repositories/coupon/coupon_repository.dart';
import '../../../../model/coupon/coupon_plan.dart';
import 'package:smart_canteen_user_frontend/core/utils/async_value.dart';

class PurchaseViewModel extends ChangeNotifier {
  final CouponRepository _couponRepository;

  AsyncValue<List<CouponPlan>> _plansState = const AsyncLoading();
  AsyncValue<ActiveCoupon> _purchaseState = const AsyncLoading();

  PurchaseViewModel(this._couponRepository);

  AsyncValue<List<CouponPlan>> get plansState => _plansState;
  AsyncValue<ActiveCoupon> get purchaseState => _purchaseState;

  Future<void> fetchPlans() async {
    _plansState = const AsyncLoading();
    notifyListeners();

    try {
      final dtos = await _couponRepository.getPlans();
      _plansState = AsyncData(dtos.map(CouponPlan.fromDto).toList());
    } catch (e, s) {
      _plansState = AsyncError(e, s);
    }

    notifyListeners();
  }

  Future<void> purchase(String planId) async {
    _purchaseState = const AsyncLoading();
    notifyListeners();

    try {
      final dto = await _couponRepository.purchasePlan(planId);
      _purchaseState = AsyncData(ActiveCoupon.fromDto(dto));
    } catch (e, s) {
      _purchaseState = AsyncError(e, s);
    }

    notifyListeners();
  }

  void resetPurchase() {
    _purchaseState = const AsyncLoading();
    notifyListeners();
  }
}
