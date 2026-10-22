import 'package:smart_canteen_user_frontend/features/order/domain/entities/meal_coupon.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order.dart';

abstract class OrderRepository {
  /// Places an order (backend deducts stock and mints a QR coupon per item),
  /// returning the order with its coupons. Does NOT charge the wallet — pay
  /// separately via the wallet repository using [PlacedOrder.totalAmount].
  Future<PlacedOrder> placeOrder({
    required String schoolId,
    required String mealSession,
    required List<NewOrderItem> items,
  });

  /// The signed-in user's currently active (unredeemed) coupons.
  Future<List<MealCoupon>> getActiveCoupons();

  /// The signed-in user's past orders (most recent first).
  Future<List<Order>> getMyOrders();
}
