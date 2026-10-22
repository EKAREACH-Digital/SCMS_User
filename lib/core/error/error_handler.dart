import 'package:dio/dio.dart';

import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';

/// Turns transport-level failures into the [ApiException] the rest of the app
/// understands. Every remote datasource maps its `DioException`s through here
/// so the user sees the same, most specific message no matter which call failed.
abstract final class ErrorHandler {
  static ApiException fromDio(DioException e) {
    final data = e.response?.data;
    final statusCode = e.response?.statusCode;
    if (data is Map<String, dynamic>) {
      // Validation failures (class-validator) carry the useful, field-level
      // detail in `errors`; `message` is just a generic "Bad Request Exception".
      // Prefer the specific reason when it's there. See backend
      // `AllExceptionsFilter`.
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return ApiException(errors.join('\n'), statusCode: statusCode);
      }
      final message = data['message'];
      if (message is String) {
        return ApiException(message, statusCode: statusCode);
      }
      if (message is List && message.isNotEmpty) {
        return ApiException(message.join('\n'), statusCode: statusCode);
      }
    }
    // No response reached the app at all (connection refused, CORS block,
    // timeout, DNS failure, ...) — surface Dio's own diagnosis rather than a
    // vague string, since this is a network-layer failure, not a backend one.
    return ApiException('${e.type.name}: ${e.message ?? e.error ?? e}');
  }
}
