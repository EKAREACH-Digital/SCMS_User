import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration, read from the bundled `.env` file (see
/// `.env.example`). Call [load] once in `main()` before anything reads it.
///
/// `.env` ships inside the app, so it holds public identifiers only — never a
/// secret.
abstract final class AppConfig {
  static Future<void> load() => dotenv.load(fileName: '.env');

  /// Backend server URL including any path prefix, but **without** the API
  /// version (e.g. `http://localhost:3000/api`) — every `ApiConfig` route
  /// carries the version itself.
  static String get apiBaseUrl => _require('API_BASE_URL');

  /// The backend's Google OAuth "Web application" client ID. Passed as
  /// `serverClientId` so the ID token's audience is one the backend verifies.
  static String get googleServerClientId => _require('GOOGLE_SERVER_CLIENT_ID');

  /// The iOS OAuth client ID, used only on iOS to identify the app to Google.
  static String get googleIosClientId => _require('GOOGLE_IOS_CLIENT_ID');

  /// Azure "App registrations" Application (client) ID.
  static String get microsoftClientId => _require('MICROSOFT_CLIENT_ID');

  /// Azure Directory (tenant) ID — must match the backend's.
  static String get microsoftTenantId => _require('MICROSOFT_TENANT_ID');

  /// MSAL Android redirect URI: `msauth://<applicationId>/<signature hash>`.
  static String get microsoftAndroidRedirectUri =>
      _require('MICROSOFT_ANDROID_REDIRECT_URI');

  /// Fails loudly on a missing key rather than calling a blank URL or client.
  static String _require(String key) {
    final value = dotenv.maybeGet(key)?.trim() ?? '';
    if (value.isEmpty) {
      throw StateError('Missing $key in .env — see .env.example.');
    }
    return value;
  }
}
