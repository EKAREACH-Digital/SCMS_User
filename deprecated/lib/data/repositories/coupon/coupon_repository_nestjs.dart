import '../../dtos/coupon_dto.dart';
import 'coupon_repository.dart';

/// Legacy "coupon plans" repository. The backend has no subscription-plan model —
/// real meal-ticket coupons are minted per order and handled by
/// `OrderRepository` (place order) + `MealCouponsState`. Kept only to satisfy
/// the interface; these methods are unused in the order → coupon → QR flow.
class CouponRepositoryNestjs implements CouponRepository {
  @override
  Future<List<CouponPlanDto>> getPlans() async => const [];

  @override
  Future<ActiveCouponDto> purchasePlan(String planId) {
    throw UnimplementedError('Coupon plans are not part of the backend model');
  }

  @override
  Future<List<ActiveCouponDto>> getActiveCoupons() async => const [];
}
