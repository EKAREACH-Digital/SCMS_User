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
    required String menuId,
    required String mealSession,
    required List<OrderItemInput> items,
    required String provider,
    String currency = 'USD',
    String? branchId,
  }) async {
    try {
      // POST /orders/checkout — reserves stock and opens the payment session.
      final response = await _dio.post(
        ApiConfig.ordersCheckout,
        data: {
          'items': items.map((i) => i.toJson()).toList(),
          'menu_id': menuId,
          'meal_session': mealSession,
          'provider': provider,
          'currency': currency,
          'branch_id': ?branchId,
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
  Future<OrderSummaryDto> getOrderById(String orderId) async {
    try {
      // GET /orders/{id} — live status; also queries the gateway directly.
      final response = await _dio.get(ApiConfig.orderById(orderId));
      return OrderSummaryDto.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error fetching order: $e');
    }
  }

  @override
  Future<List<CouponDto>> getActiveCoupons() async {
    try {
      // GET /coupons/my — scoped to the caller from the JWT; plain /coupons is staff-only.
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
