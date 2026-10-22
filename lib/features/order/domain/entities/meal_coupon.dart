/// A meal-ticket coupon minted by the backend (one per ordered item). The
/// [qrToken] is the exact string the canteen scanner reads and redeems, so the
/// QR the app shows must encode it verbatim.
class MealCoupon {
  final String id;
  final String qrToken;
  final String? couponCode;
  final String mealSession; // breakfast | lunch | dinner
  final String status; // active | redeemed | expired | cancelled
  final String? validDate; // yyyy-MM-dd
  final String? menuItemName;

  const MealCoupon({
    required this.id,
    required this.qrToken,
    required this.couponCode,
    required this.mealSession,
    required this.status,
    required this.validDate,
    required this.menuItemName,
  });

  bool get isActive => status == 'active';

  MealCoupon copyWith({
    String? id,
    String? qrToken,
    String? couponCode,
    String? mealSession,
    String? status,
    String? validDate,
    String? menuItemName,
  }) {
    return MealCoupon(
      id: id ?? this.id,
      qrToken: qrToken ?? this.qrToken,
      couponCode: couponCode ?? this.couponCode,
      mealSession: mealSession ?? this.mealSession,
      status: status ?? this.status,
      validDate: validDate ?? this.validDate,
      menuItemName: menuItemName ?? this.menuItemName,
    );
  }
}
