import 'package:smart_canteen_user_frontend/features/order/data/models/order_dto.dart';

abstract class OrderDatasource {
  /// `POST /orders/checkout` — reserves stock, creates the order and opens a
  /// payment session for [provider]. Returns the order id + KHQR / deeplink.
  Future<PlacedOrderDto> placeOrder({
    required String menuId,
    required String mealSession,
    required List<OrderItemInput> items,
    required String provider,
    String currency,
    String? branchId,
  });

  /// `GET /orders/{id}` — live order status. Each call also queries the
  /// gateway directly, so `paid` shows immediately after payment.
  Future<OrderSummaryDto> getOrderById(String orderId);

  Future<List<OrderSummaryDto>> getMyOrders();

  /// `GET /coupons/my?status=active` — the signed-in user's active coupons.
  Future<List<CouponDto>> getActiveCoupons();
}
