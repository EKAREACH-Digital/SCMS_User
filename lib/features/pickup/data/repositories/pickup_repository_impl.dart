import 'package:smart_canteen_user_frontend/features/pickup/data/datasources/pickup_datasource.dart';
import 'package:smart_canteen_user_frontend/features/pickup/domain/entities/pickup_checkin.dart';
import 'package:smart_canteen_user_frontend/features/pickup/domain/repositories/pickup_repository.dart';

class PickupRepositoryImpl implements PickupRepository {
  PickupRepositoryImpl(this._datasource);

  final PickupDatasource _datasource;

  @override
  Future<PickupCheckin> arrive(String code) async {
    final dto = await _datasource.arrive(code);
    return dto.toEntity();
  }
}
