import 'package:smart_canteen_user_frontend/features/pickup/data/models/pickup_checkin_dto.dart';

abstract class PickupDatasource {
  /// `POST /pickup/arrive` — check in by stand code; returns today's open orders.
  Future<PickupCheckinDto> arrive(String code);
}
