import 'package:smart_canteen_user_frontend/features/pickup/data/datasources/pickup_datasource.dart';
import 'package:smart_canteen_user_frontend/features/pickup/data/models/pickup_checkin_dto.dart';

/// Offline mock — returns a mix of ready and preparing orders for manual testing.
class PickupMockDatasource implements PickupDatasource {
  @override
  Future<PickupCheckinDto> arrive(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return PickupCheckinDto(
      counter: 'Counter 1',
      checkedInAt: DateTime.now().toUtc().toIso8601String(),
      orders: [
        const PickupOrderDto(
          orderId: 'mock-order-1',
          pickupNo: 3,
          status: 'ready',
          ready: true,
          items: [
            PickupOrderItemDto(name: 'Noodle', quantity: 1),
            PickupOrderItemDto(name: 'បាយស្រូប', quantity: 1),
          ],
        ),
        const PickupOrderDto(
          orderId: 'mock-order-2',
          pickupNo: 4,
          status: 'paid',
          ready: false,
          items: [
            PickupOrderItemDto(name: 'Noodle', quantity: 1),
          ],
        ),
      ],
    );
  }
}
