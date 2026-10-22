/// Thrown by repositories when a backend call fails.
///
/// [message] is the human-readable error the backend returned (see backend
/// `AllExceptionsFilter`, which always responds with `{ message, statusCode }`).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
