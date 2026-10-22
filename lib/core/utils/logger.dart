import 'package:logger/logger.dart';

/// The app's only logger — never use `print` / `debugPrint` directly.
///
/// Backed by `logger`'s default DevelopmentFilter, so nothing is printed in
/// release builds. That is what makes it safe to log values like auth tokens
/// while debugging.
abstract final class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  /// General info / lifecycle events.
  static void i(Object? message) => _logger.i(message);

  /// Debug values, response payloads.
  static void d(Object? message) => _logger.d(message);

  /// Non-critical warnings.
  static void w(Object? message) => _logger.w(message);

  /// Errors, with an optional error object and stack trace.
  static void e(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
