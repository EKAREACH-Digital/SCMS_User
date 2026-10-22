import '../../dtos/coupon_dto.dart';

abstract class CouponRepository {
  Future<List<CouponPlanDto>> getPlans();
  Future<ActiveCouponDto> purchasePlan(String planId);
  Future<List<ActiveCouponDto>> getActiveCoupons();
}
