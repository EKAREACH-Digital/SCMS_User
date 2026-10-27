import 'package:logger/logger.dart';

/// The app's only logger — never use `print` / `debugPrint` directly.
///
/// Backed by `logger`'s default DevelopmentFilter, so nothing is printed in
/// release builds. That is what makes it safe to log values like auth tokens
/// while debugging. Every level (trace and up) prints in debug builds.
///
/// Each entry shows the call chain that led to it, so a log line can be traced
/// back to the widget / ViewModel / datasource that wrote it.
abstract final class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 5, // every log now shows the 5 calls that led to it. Before was 0 
      errorMethodCount: 10, // show error chain. Before 8
      dateTimeFormat: DateTimeFormat.none,
      // Skip this wrapper's own frame so the first line is the real caller.
      excludePaths: const [
        'package:smart_canteen_user_frontend/core/utils/logger.dart',
      ],
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
