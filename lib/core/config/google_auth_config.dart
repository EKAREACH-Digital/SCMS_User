import 'package:smart_canteen_user_frontend/core/config/app_config.dart';

/// Google Sign-In client IDs. The values come from `.env` (see [AppConfig]).
///
/// Client IDs are not secrets — Google's own docs have you embed them in
/// mobile apps — but they differ per OAuth client, so they live in env.
abstract final class GoogleAuthConfig {
  /// The backend's Google OAuth "Web application" client ID (backend
  /// `GOOGLE_CLIENT_ID`). Passed as `serverClientId` so the ID token this app
  /// receives has an audience the backend can verify.
  static String get serverClientId => AppConfig.googleServerClientId;

  /// The iOS OAuth client ID (type: iOS). Used only on iOS to identify the app
  /// to Google; the resulting ID token's audience is still [serverClientId].
  ///
  /// The reversed form of this ID must also be registered as a URL scheme in
  /// `ios/Runner/Info.plist` so Google can hand the OAuth result back.
  static String get iosClientId => AppConfig.googleIosClientId;
}
