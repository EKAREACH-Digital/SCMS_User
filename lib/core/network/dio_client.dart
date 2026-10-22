import 'package:dio/dio.dart';

import 'package:smart_canteen_user_frontend/core/config/app_config.dart';
import 'package:smart_canteen_user_frontend/core/network/auth_interceptor.dart';
import 'package:smart_canteen_user_frontend/core/services/storage_service.dart';

/// The shared HTTP client used by every remote datasource.
abstract final class DioClient {
  /// App-wide client, created on first use.
  ///
  /// `BaseOptions.baseUrl` is captured at creation, so first use must come
  /// after `AppConfig.load()` — `main()` awaits it before building anything.
  static final Dio instance = create();

  /// Builds a client with the [AuthInterceptor] attached. Exposed so tests
  /// can create one against a fake [storage].
  static Dio create({StorageService? storage}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    dio.interceptors.add(
      AuthInterceptor(dio: dio, storage: storage ?? StorageService.instance),
    );
    return dio;
  }
}
