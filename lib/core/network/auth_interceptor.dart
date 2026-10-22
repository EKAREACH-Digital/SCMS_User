import 'package:dio/dio.dart';

import 'package:smart_canteen_user_frontend/core/config/api_config.dart';
import 'package:smart_canteen_user_frontend/core/config/app_config.dart';
import 'package:smart_canteen_user_frontend/core/services/storage_service.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';

/// Attaches the stored access token to every request, and recovers from an
/// expired one.
///
/// - **onRequest** — sends the stored access token as a `Bearer` header.
/// - **onError** — on a `401` for a request that carried a token, refreshes
///   via `POST /auth/refresh` and retries the original request **once**.
///
/// Only one refresh runs at a time: the backend rotates the refresh token on
/// every call and treats reuse of an old one as theft (signing the account out
/// everywhere), so concurrent 401s wait on the same refresh. A request whose
/// token was already replaced by another refresh just retries with the new
/// one. If refreshing fails, the stored tokens are cleared.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required Dio dio, required StorageService storage})
    : _dio = dio,
      _storage = storage;

  /// The client this interceptor is attached to — used to replay the request.
  final Dio _dio;
  final StorageService _storage;

  /// The refresh in flight, shared by every request that hits a 401 meanwhile.
  Future<String>? _refreshing;

  static const _retriedFlag = '__retried';
  static const _bearer = 'Bearer ';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = '$_bearer$token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    final sentToken = _tokenOf(req);
    final is401 = err.response?.statusCode == 401;
    final isRefreshCall = req.path == ApiConfig.refreshToken;
    final alreadyRetried = req.extra[_retriedFlag] == true;

    // Only recover from a genuine 401 on an authenticated request that isn't
    // the refresh call itself and hasn't been retried. A 401 without a token
    // (e.g. wrong password on login) is a real answer, not an expired session.
    if (!is401 || sentToken == null || isRefreshCall || alreadyRetried) {
      return handler.next(err);
    }

    try {
      final current = await _storage.readAccessToken();
      // Another request already refreshed — reuse its token.
      final newAccess = current != null && current != sentToken
          ? current
          : await (_refreshing ??= _refresh().whenComplete(
              () => _refreshing = null,
            ));

      req.headers['Authorization'] = '$_bearer$newAccess';
      req.extra[_retriedFlag] = true;
      return handler.resolve(await _dio.fetch(req));
    } on DioException catch (e) {
      // The retried request itself failed — hand that error on.
      if (e.requestOptions.extra[_retriedFlag] == true) return handler.next(e);
      // The refresh never reached the server (offline, timeout): keep the
      // session so the next attempt can refresh again.
      if (e.response == null) return handler.next(err);
      return _signOut(err, handler, e);
    } catch (e) {
      return _signOut(err, handler, e);
    }
  }

  /// Refresh failed — the session is dead; clear it so the app goes to login.
  Future<void> _signOut(
    DioException err,
    ErrorInterceptorHandler handler,
    Object cause,
  ) async {
    AppLogger.w('Token refresh failed, clearing session: $cause');
    await _storage.clear();
    handler.next(err);
  }

  String? _tokenOf(RequestOptions req) {
    final header = req.headers['Authorization'];
    if (header is! String || !header.startsWith(_bearer)) return null;
    return header.substring(_bearer.length);
  }

  /// Exchanges the stored refresh token for a new pair, stores **both** (the
  /// old refresh token stops working immediately), and returns the new access
  /// token.
  Future<String> _refresh() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) throw StateError('No refresh token stored');

    // A bare client (no interceptors) so the refresh call can't recurse.
    final refreshDio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
    // POST /auth/refresh — rotates the token pair.
    final resp = await refreshDio.post(
      ApiConfig.refreshToken,
      data: {'refresh_token': refreshToken},
    );
    final data = resp.data['data'] as Map<String, dynamic>;
    final newAccess = data['access_token'] as String;
    await _storage.saveTokens(
      accessToken: newAccess,
      refreshToken: data['refresh_token'] as String,
    );
    return newAccess;
  }
}
