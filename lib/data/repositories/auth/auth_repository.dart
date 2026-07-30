import '../../dtos/auth_dto.dart';

abstract class AuthRepository {
  Future<AuthTokenDto> login({required String email, required String password});
  Future<AuthTokenDto> register({
    required String email,
    required String password,
    required String fullName,
  });

  /// Runs the native Google sign-in flow (via google_sign_in) and exchanges
  /// the resulting ID token with the backend for our own JWT pair.
  Future<AuthTokenDto> loginWithGoogle();

  /// Runs the native Microsoft (MSAL) sign-in flow and exchanges the resulting
  /// ID token with the backend for our own JWT pair.
  Future<AuthTokenDto> loginWithMicrosoft();

  Future<AuthTokenDto> refreshToken(String refreshToken);
  Future<UserProfileDto> getProfile();

  /// Updates the signed-in user's own profile and returns the fresh record.
  /// Only non-null fields are sent, so callers can patch a subset.
  Future<UserProfileDto> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? schoolId,
  });

  /// Updates the signed-in user's notification preferences and returns the
  /// fresh set. Only non-null flags are sent, so callers can patch a subset.
  Future<NotificationPreferencesDto> updateNotificationPreferences({
    required String userId,
    bool? orderUpdates,
    bool? promotions,
    bool? systemAlerts,
  });

  /// Onboarding: saves the signed-in user's name, phone and school, and
  /// optionally sets an initial password (which also enables email/password
  /// sign-in for accounts created via Google). Marks the account
  /// `profile_completed` and stores the fresh token pair the backend returns.
  Future<UserProfileDto> completeProfile({
    required String fullName,
    required String phone,
    required String schoolId,
    String? password,
  });

  /// Adds a password to an account that has none (e.g. created via Google),
  /// enabling email/password sign-in alongside it.
  Future<void> setPassword(String password);

  /// Password reset, step 1 — asks the backend to email a 6-digit code.
  /// Always succeeds, even for an unknown address, so it can't be used to work
  /// out which emails are registered.
  Future<void> requestPasswordReset(String email);

  /// Step 2 — exchanges the emailed code for a single-use reset token.
  Future<String> verifyPasswordResetCode({
    required String email,
    required String code,
  });

  /// Step 3 — sets the new password. Signs out every existing session.
  Future<void> resetPassword({
    required String resetToken,
    required String password,
  });

  /// Lists the schools a user can pick from during onboarding.
  Future<List<SchoolDto>> getSchools();

  Future<void> logout();
}
