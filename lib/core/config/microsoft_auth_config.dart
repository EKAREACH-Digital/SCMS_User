import 'package:smart_canteen_user_frontend/core/config/app_config.dart';

/// Microsoft (MSAL) sign-in settings. IDs and the redirect URI come from
/// `.env` (see [AppConfig]); the scopes are fixed by this app.
abstract final class MicrosoftAuthConfig {
  /// Application (client) ID from Azure "App registrations".
  ///
  /// Public by design — it travels in every auth request and is the `aud`
  /// claim the backend checks. A client *secret* must never appear here: this
  /// app is a public client and cannot keep one.
  static String get clientId => AppConfig.microsoftClientId;

  /// Directory (tenant) ID — must match backend MICROSOFT_TENANT_ID so the
  /// ID token's issuer/audience are what the backend verifies.
  static String get tenantId => AppConfig.microsoftTenantId;

  static String get authority => 'https://login.microsoftonline.com/$tenantId';

  /// `msauth://<applicationId>/<url-encoded signature hash>`. Must match the
  /// Android platform entry in the Azure app registration exactly, and the
  /// hash is tied to the signing key — so a release build needs its own entry
  /// in Azure and its own value in `.env`.
  static String get androidRedirectUri => AppConfig.microsoftAndroidRedirectUri;

  /// Scopes requested at `acquireToken`.
  ///
  /// `openid`, `profile` and `offline_access` must NOT appear here — MSAL adds
  /// them itself and rejects the call ("reserved scopes ... may not be
  /// specified") if they're passed in. The ID token still carries the claims
  /// the backend reads (`oid`, `preferred_username`, `given_name`,
  /// `family_name`), because those come from the implicit OIDC scopes rather
  /// than anything requested here.
  ///
  /// `User.Read` is a delegated Microsoft Graph permission granted by default
  /// on a new app registration, so it needs no admin consent.
  static const List<String> scopes = ['User.Read'];
}
