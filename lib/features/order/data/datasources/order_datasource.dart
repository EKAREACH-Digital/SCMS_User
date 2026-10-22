import 'package:smart_canteen_user_frontend/features/order/data/models/order_dto.dart';

abstract class OrderDatasource {
  Future<PlacedOrderDto> placeOrder({
    required String schoolId,
    required String mealSession,
    required List<OrderItemInput> items,
  });

  Future<List<CouponDto>> getActiveCoupons();

  Future<List<OrderSummaryDto>> getMyOrders();
}
