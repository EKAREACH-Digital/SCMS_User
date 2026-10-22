import '../../data/dtos/coupon_dto.dart';

class CouponPlan {
  final String id;
  final String name;
  final String description;
  final int mealsIncluded;
  final double priceUsd;
  final double discountPercent;
  final CouponValidity validity;

  const CouponPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.mealsIncluded,
    required this.priceUsd,
    required this.discountPercent,
    required this.validity,
  });

  double get originalPrice => priceUsd / (1 - discountPercent / 100);
  double get savingsUsd => originalPrice - priceUsd;

  factory CouponPlan.fromDto(CouponPlanDto dto) => CouponPlan(
        id: dto.id,
        name: dto.name,
        description: dto.description,
        mealsIncluded: dto.mealsIncluded,
        priceUsd: dto.priceUsd,
        discountPercent: dto.discountPercent,
        validity: CouponValidity.fromString(dto.validity),
      );
}

class ActiveCoupon {
  final String couponId;
  final String planId;
  final String studentId;
  final int mealsRemaining;
  final String session;
  final DateTime expiresAt;
  final String qrPayload;

  const ActiveCoupon({
    required this.couponId,
    required this.planId,
    required this.studentId,
    required this.mealsRemaining,
    required this.session,
    required this.expiresAt,
    required this.qrPayload,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory ActiveCoupon.fromDto(ActiveCouponDto dto) => ActiveCoupon(
        couponId: dto.couponId,
        planId: dto.planId,
        studentId: dto.studentId,
        mealsRemaining: dto.mealsRemaining,
        session: dto.session,
        expiresAt: dto.expiresAt,
        qrPayload: dto.qrPayload,
      );
}

enum CouponValidity {
  daily,
  weekly,
  monthly;

  static CouponValidity fromString(String value) => switch (value) {
        'weekly' => CouponValidity.weekly,
        'monthly' => CouponValidity.monthly,
        _ => CouponValidity.daily,
      };

  String get label => switch (this) {
        CouponValidity.daily => 'Daily',
        CouponValidity.weekly => 'Weekly',
        CouponValidity.monthly => 'Monthly',
      };
}
