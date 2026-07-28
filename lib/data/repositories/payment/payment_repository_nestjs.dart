import 'package:dio/dio.dart';

import '../../config/api_client.dart';
import '../../config/api_config.dart';
import '../../dtos/payment_dto.dart';
import '../../exceptions/api_exception.dart';
import '../../local/token_storage.dart';
import 'payment_repository.dart';

/// Talks to our own `/payments` endpoints. The gateway's credentials live in
/// the backend's environment and are never sent to, or held by, the app.
class PaymentRepositoryNestjs implements PaymentRepository {
  PaymentRepositoryNestjs({Dio? dio, TokenStorage? tokenStorage})
      : _dio = dio ?? createApiClient(tokenStorage: tokenStorage);

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
      throw _mapError(e);
    } catch (e) {
      throw ApiException('Unexpected error starting the top-up: $e');
    }
  }

  @override
  Future<TopupStatus> checkStatus(String tranId) async {
    try {
      final response = await _dio.get(ApiConfig.paymentStatus(tranId));
      final data = response.data['data'] as Map<String, dynamic>;
      return TopupStatus.parse(data['status'] as String? ?? '');
    } on DioException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw ApiException('Unexpected error checking the payment: $e');
    }
  }

  ApiException _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return ApiException(errors.join('\n'), statusCode: e.response?.statusCode);
      }
      final message = data['message'];
      if (message is String) {
        return ApiException(message, statusCode: e.response?.statusCode);
      }
      if (message is List && message.isNotEmpty) {
        return ApiException(message.join('\n'), statusCode: e.response?.statusCode);
      }
    }
    return ApiException('${e.type.name}: ${e.message ?? e.error ?? e}');
  }
}
