import 'package:smart_canteen_user_frontend/features/order/data/datasources/order_datasource.dart';
import 'package:smart_canteen_user_frontend/features/order/data/models/order_dto.dart';
import 'package:smart_canteen_user_frontend/features/order/data/models/order_pickup_dto.dart';

/// In-memory [OrderDatasource] for tests and offline work.
class OrderMockDatasource implements OrderDatasource {
  @override
  Future<PlacedOrderDto> placeOrder({
    required String menuId,
    required String mealSession,
    required List<OrderItemInput> items,
    required String provider,
    String currency = 'USD',
    String? branchId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final orderId = 'mock-order-${DateTime.now().millisecondsSinceEpoch}';
    return PlacedOrderDto(
      orderId: orderId,
      provider: provider,
      totalAmount: items.length * 1.5,
      // A minimal valid KHQR-style string for mock rendering.
      qrString: '00020101021230160012mock-khqr-string5204000053031165802KH6304ABCD',
      qrImage: 'https://cutluy.com/api/render/khqr/mock-qr.svg',
      checkoutUrl: 'https://cutluy.com/pay/mock',
      deeplink: provider == 'PAYWAY' ? 'abamobilebank://pay/mock' : null,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
    );
  }

  @override
  Future<OrderSummaryDto> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock always returns pending_payment so polling can be tested manually.
    return OrderSummaryDto(
      id: orderId,
      totalAmount: 1.5,
      status: 'pending_payment',
      mealSession: 'lunch',
      createdAt: DateTime.now(),
      items: const [],
    );
  }

  @override
  Future<OrderPickupDto> getMyPickup(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return OrderPickupDto(
      orderId: orderId,
      status: 'ready',
      pickupNo: 1,
      pickupQrToken: 'mock-pickup-$orderId',
    );
  }

  @override
  Future<List<CouponDto>> getActiveCoupons() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [];
  }

  /// Sample past orders so the History screen has something to render.
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
        status: 'pending_payment',
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
