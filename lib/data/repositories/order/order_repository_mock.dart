import '../../dtos/order_dto.dart';
import 'order_repository.dart';

class OrderRepositoryMock implements OrderRepository {
  final List<CouponDto> _coupons = [];

  @override
  Future<PlacedOrderDto> placeOrder({
    required String schoolId,
    required String mealSession,
    required List<OrderItemInput> items,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final coupons = items
        .map((i) => CouponDto(
              id: 'mock-coupon-${DateTime.now().microsecondsSinceEpoch}-${i.menuItemId}',
              qrToken: 'mock-${DateTime.now().millisecondsSinceEpoch}-${i.menuItemId}',
              couponCode: 'MOCK123',
              mealSession: mealSession,
              status: 'active',
              validDate: DateTime.now().toIso8601String().substring(0, 10),
              menuItemName: 'Mock item',
            ))
        .toList();
    _coupons.addAll(coupons);
    return PlacedOrderDto(
      id: 'mock-order-${DateTime.now().millisecondsSinceEpoch}',
      totalAmount: 0,
      mealSession: mealSession,
      status: 'pending',
      coupons: coupons,
    );
  }

  @override
  Future<List<CouponDto>> getActiveCoupons() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _coupons.where((c) => c.isActive).toList();
  }

  /// Sample past orders so the History screen has something to render in the
  /// dev flavour. Dates are relative to now, so the list always looks current.
  @override
  Future<List<OrderSummaryDto>> getMyOrders() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return [
      OrderSummaryDto(
        id: 'mock-order-1',
        totalAmount: 5.75,
        status: 'completed',
        mealSession: 'lunch',
        createdAt: now.subtract(const Duration(hours: 3)),
        items: const [
          OrderLineDto(name: 'Chicken with Rice', quantity: 2, unitPrice: 2.00),
          OrderLineDto(name: 'Pork with Rice', quantity: 1, unitPrice: 1.75),
        ],
      ),
      OrderSummaryDto(
        id: 'mock-order-2',
        totalAmount: 1.25,
        status: 'pending',
        mealSession: 'breakfast',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        items: const [
          OrderLineDto(name: 'Fried Egg Rice', quantity: 1, unitPrice: 1.25),
        ],
      ),
      OrderSummaryDto(
        id: 'mock-order-3',
        totalAmount: 4.00,
        status: 'cancelled',
        mealSession: 'dinner',
        createdAt: now.subtract(const Duration(days: 3)),
        items: const [
          OrderLineDto(name: 'Khmer Noodle', quantity: 2, unitPrice: 2.00),
        ],
      ),
    ];
  }
}
