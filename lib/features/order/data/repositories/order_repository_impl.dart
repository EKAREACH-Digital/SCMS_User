import 'package:smart_canteen_user_frontend/features/order/data/datasources/order_datasource.dart';
import 'package:smart_canteen_user_frontend/features/order/data/models/order_dto.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/meal_coupon.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._datasource);

  final OrderDatasource _datasource;

  @override
  Future<PlacedOrder> placeOrder({
    required String schoolId,
    required String mealSession,
    required List<NewOrderItem> items,
  }) async {
    final dto = await _datasource.placeOrder(
      schoolId: schoolId,
      mealSession: mealSession,
      items: [
        for (final i in items)
          OrderItemInput(menuItemId: i.menuItemId, quantity: i.quantity),
      ],
    );
    return dto.toEntity();
  }

  @override
  Future<List<MealCoupon>> getActiveCoupons() async =>
      (await _datasource.getActiveCoupons()).map((c) => c.toEntity()).toList();

  @override
  Future<List<Order>> getMyOrders() async =>
      (await _datasource.getMyOrders()).map((o) => o.toEntity()).toList();
}
