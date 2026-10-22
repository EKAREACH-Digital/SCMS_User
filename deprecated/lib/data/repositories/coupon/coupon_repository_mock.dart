import '../../dtos/coupon_dto.dart';
import 'coupon_repository.dart';

class CouponRepositoryMock implements CouponRepository {
  @override
  Future<List<CouponPlanDto>> getPlans() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const [
      CouponPlanDto(id: 'plan-daily', name: 'Daily Pass', description: 'One meal per session today', mealsIncluded: 2, priceUsd: 3.50, discountPercent: 10, validity: 'daily'),
      CouponPlanDto(id: 'plan-weekly', name: 'Weekly Bundle', description: '10 meals valid for 7 days', mealsIncluded: 10, priceUsd: 15.00, discountPercent: 20, validity: 'weekly'),
      CouponPlanDto(id: 'plan-monthly', name: 'Monthly Scholar', description: '40 meals valid for 30 days', mealsIncluded: 40, priceUsd: 50.00, discountPercent: 30, validity: 'monthly'),
    ];
  }

  @override
  Future<ActiveCouponDto> purchasePlan(String planId) async {
    await Future.delayed(const Duration(seconds: 1));
    return ActiveCouponDto(
      couponId: 'coupon-${DateTime.now().millisecondsSinceEpoch}',
      planId: planId,
      studentId: '20230042',
      mealsRemaining: 2,
      session: 'breakfast',
      expiresAt: DateTime.now().add(const Duration(hours: 2)),
      qrPayload: 'mock-qr-payload',
    );
  }

  @override
  Future<List<ActiveCouponDto>> getActiveCoupons() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ActiveCouponDto(
        couponId: 'coupon-001',
        planId: 'plan-daily',
        studentId: '20230042',
        mealsRemaining: 1,
        session: 'breakfast',
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
        qrPayload: 'mock-qr-breakfast',
      ),
      ActiveCouponDto(
        couponId: 'coupon-002',
        planId: 'plan-weekly',
        studentId: '20230042',
        mealsRemaining: 8,
        session: 'lunch',
        expiresAt: DateTime.now().add(const Duration(days: 5)),
        qrPayload: 'mock-qr-lunch',
      ),
    ];
  }
}
