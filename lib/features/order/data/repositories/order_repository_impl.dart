import 'package:smart_canteen_user_frontend/features/order/data/datasources/order_datasource.dart';
import 'package:smart_canteen_user_frontend/features/order/data/models/order_dto.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/meal_coupon.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order_pickup.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._datasource);

  final OrderDatasource _datasource;

  @override
  Future<PlacedOrder> placeOrder({
    required String menuId,
    required String mealSession,
    required List<NewOrderItem> items,
    required String provider,
    String currency = 'USD',
    String? branchId,
  }) async {
    final dto = await _datasource.placeOrder(
      menuId: menuId,
      mealSession: mealSession,
      items: [
        for (final i in items)
          OrderItemInput(menuItemId: i.menuItemId, quantity: i.quantity),
      ],
      provider: provider,
      currency: currency,
      branchId: branchId,
    );
    return dto.toEntity();
  }

  @override
  Future<Order> getOrderById(String orderId) async =>
      (await _datasource.getOrderById(orderId)).toEntity();

  @override
  Future<List<Order>> getMyOrders() async =>
      (await _datasource.getMyOrders()).map((o) => o.toEntity()).toList();

  @override
  Future<OrderPickup> getMyPickup(String orderId) async =>
      (await _datasource.getMyPickup(orderId)).toEntity();

  @override
  Future<List<MealCoupon>> getActiveCoupons() async =>
      (await _datasource.getActiveCoupons()).map((c) => c.toEntity()).toList();
}
