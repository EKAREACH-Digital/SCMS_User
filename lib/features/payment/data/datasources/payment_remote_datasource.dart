import 'package:dio/dio.dart';

import 'package:smart_canteen_user_frontend/core/config/api_config.dart';
import 'package:smart_canteen_user_frontend/core/error/error_handler.dart';
import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/features/payment/data/datasources/payment_datasource.dart';
import 'package:smart_canteen_user_frontend/features/payment/data/models/payment_dto.dart';

/// Talks to our own `/payments` endpoints. The gateway's credentials live in
/// the backend's environment and are never sent to, or held by, the app.
class PaymentRemoteDatasource implements PaymentDatasource {
  PaymentRemoteDatasource(this._dio);

  final Dio _dio;

  @override
  Future<TopupSessionDto> startTopUp(double amountUsd) async {
    try {
      final response = await _dio.post(
        ApiConfig.paymentsTopUp,
        data: {'amount': amountUsd},
      );
      return TopupSessionDto.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error starting the top-up: $e');
    }
  }

  @override
  Future<String> checkStatus(String tranId) async {
    try {
      final response = await _dio.get(ApiConfig.paymentStatus(tranId));
      final data = response.data['data'] as Map<String, dynamic>;
      return data['status'] as String? ?? '';
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error checking the payment: $e');
    }
  }
}
