import 'package:dio/dio.dart';

import 'package:smart_canteen_user_frontend/core/config/api_config.dart';
import 'package:smart_canteen_user_frontend/core/error/error_handler.dart';
import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/features/order/data/datasources/order_datasource.dart';
import 'package:smart_canteen_user_frontend/features/order/data/models/order_dto.dart';

class OrderRemoteDatasource implements OrderDatasource {
  OrderRemoteDatasource(this._dio);

  final Dio _dio;

  @override
  Future<PlacedOrderDto> placeOrder({
    required String schoolId,
    required String mealSession,
    required List<OrderItemInput> items,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.orders,
        data: {
          'school_id': schoolId,
          'meal_session': mealSession,
          'items': items.map((i) => i.toJson()).toList(),
        },
      );
      return PlacedOrderDto.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error placing order: $e');
    }
  }

  @override
  Future<List<CouponDto>> getActiveCoupons() async {
    try {
      // `/coupons/my` scopes to the caller from the JWT. The plain `/coupons`
      // list is staff-only and 403s for students.
      final response = await _dio.get(
        ApiConfig.couponsMy,
        queryParameters: {'status': 'active', 'limit': 100},
      );
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => CouponDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error loading coupons: $e');
    }
  }

  @override
  Future<List<OrderSummaryDto>> getMyOrders() async {
    try {
      final response = await _dio.get(
        ApiConfig.ordersMy,
        queryParameters: {'limit': 100},
      );
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => OrderSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error loading orders: $e');
    }
  }
}
