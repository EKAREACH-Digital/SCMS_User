class CouponPlanDto {
  final String id;
  final String name;
  final String description;
  final int mealsIncluded;
  final double priceUsd;
  final double discountPercent;
  final String validity; // 'daily' | 'weekly' | 'monthly'

  const CouponPlanDto({
    required this.id,
    required this.name,
    required this.description,
    required this.mealsIncluded,
    required this.priceUsd,
    required this.discountPercent,
    required this.validity,
  });

  factory CouponPlanDto.fromJson(Map<String, dynamic> json) => CouponPlanDto(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        mealsIncluded: json['meals_included'] as int,
        priceUsd: (json['price_usd'] as num).toDouble(),
        discountPercent: (json['discount_percent'] as num).toDouble(),
        validity: json['validity'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'meals_included': mealsIncluded,
        'price_usd': priceUsd,
        'discount_percent': discountPercent,
        'validity': validity,
      };
}

class ActiveCouponDto {
  final String couponId;
  final String planId;
  final String studentId;
  final int mealsRemaining;
  final String session;
  final DateTime expiresAt;
  final String qrPayload;

  const ActiveCouponDto({
    required this.couponId,
    required this.planId,
    required this.studentId,
    required this.mealsRemaining,
    required this.session,
    required this.expiresAt,
    required this.qrPayload,
  });

  factory ActiveCouponDto.fromJson(Map<String, dynamic> json) => ActiveCouponDto(
        couponId: json['coupon_id'] as String,
        planId: json['plan_id'] as String,
        studentId: json['student_id'] as String,
        mealsRemaining: json['meals_remaining'] as int,
        session: json['session'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String),
        qrPayload: json['qr_payload'] as String,
      );
}
