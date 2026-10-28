import 'package:smart_canteen_user_frontend/features/pickup/domain/entities/pickup_checkin.dart';

abstract class PickupRepository {
  /// `POST /pickup/arrive` — check in by stand code; returns today's open
  /// orders at the branch the stand belongs to.
  Future<PickupCheckin> arrive(String code);
}
