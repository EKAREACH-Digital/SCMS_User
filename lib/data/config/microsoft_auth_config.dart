class MicrosoftAuthConfig {
  MicrosoftAuthConfig._();

  /// Application (client) ID from Azure "App registrations".
  ///
  /// Public by design — it travels in every auth request and is the `aud`
  /// claim the backend checks. A client *secret* must never appear here: this
  /// app is a public client and cannot keep one.
  static const String clientId = '59200395-ce45-495d-81c7-f6227e11499d';

  /// Directory (tenant) ID — must match backend MICROSOFT_TENANT_ID so the
  /// ID token's issuer/audience are what the backend verifies.
  static const String tenantId = '1e9461ec-5362-4329-ae46-61fa3e91c6d2';

  static const String authority = 'https://login.microsoftonline.com/$tenantId';

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
