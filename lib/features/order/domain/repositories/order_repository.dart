import 'package:smart_canteen_user_frontend/features/order/domain/entities/meal_coupon.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order_pickup.dart';

abstract class OrderRepository {
  /// `POST /orders/checkout` — reserves stock, creates the order and opens a
  /// payment session. [provider] is `CUTLUY` (Bakong, default) or `PAYWAY`
  /// (ABA). Never retry automatically: each call reserves stock again.
  Future<PlacedOrder> placeOrder({
    required String menuId,
    required String mealSession,
    required List<NewOrderItem> items,
    required String provider,
    String currency,
    String? branchId,
  });

  /// `GET /orders/{id}` — live order status. Also queries the payment gateway
  /// directly, so `paid` shows immediately after the student pays.
  Future<Order> getOrderById(String orderId);

  /// The signed-in user's past orders (most recent first).
  Future<List<Order>> getMyOrders();

  /// `GET /pickup/my/{orderId}` — a paid order's pickup ticket. The QR token
  /// lives only here, not on the order itself.
  Future<OrderPickup> getMyPickup(String orderId);

  /// `GET /coupons/my?status=active` — the signed-in user's active meal-ticket
  /// coupons (unredeemed tickets shown in the QR tab).
  Future<List<MealCoupon>> getActiveCoupons();
}
