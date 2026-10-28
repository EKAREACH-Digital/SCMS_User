import 'package:dio/dio.dart';

import 'package:smart_canteen_user_frontend/core/config/api_config.dart';
import 'package:smart_canteen_user_frontend/core/error/error_handler.dart';
import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/features/pickup/data/datasources/pickup_datasource.dart';
import 'package:smart_canteen_user_frontend/features/pickup/data/models/pickup_arrive_request_dto.dart';
import 'package:smart_canteen_user_frontend/features/pickup/data/models/pickup_checkin_dto.dart';

class PickupRemoteDatasource implements PickupDatasource {
  PickupRemoteDatasource(this._dio);

  final Dio _dio;

  @override
  Future<PickupCheckinDto> arrive(String code) async {
    try {
      // POST /pickup/arrive — check in at counter stand; returns today's open orders.
      final response = await _dio.post(
        ApiConfig.pickupArrive,
        data: PickupArriveRequestDto(code: code).toJson(),
      );
      return PickupCheckinDto.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error during pickup check-in: $e');
    }
  }
}
