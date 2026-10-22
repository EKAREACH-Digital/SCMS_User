import 'package:smart_canteen_user_frontend/features/auth/domain/entities/branch.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/entities/school.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/entities/user.dart';

/// Sign-in, session and account operations.
///
/// Every sign-in method stores the session and returns the signed-in [User],
/// so callers never handle tokens. After any sign-in, a user whose
/// [User.needsProfileCompletion] is true must see Complete Profile first.
abstract class AuthRepository {
  /// Email + password sign-in. [rememberDevice] keeps the session for 30 days
  /// instead of 7. A 401 "verify your email" means the account was never
  /// verified: call [resendVerification] and show the code screen.
  Future<User> login({
    required String email,
    required String password,
    bool rememberDevice = true,
  });

  /// Email sign-up, step 1 — creates an inactive account and emails a 6-digit
  /// code. Returns the new user's id, needed by [verifyEmail] and [resendOtp].
  /// Does not sign in.
  Future<String> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  /// Sign-up, step 2 — activates the account with the emailed [code], then
  /// signs in with [email] and [password] (the same ones used at sign-up).
  Future<User> verifyEmail({
    required String userId,
    required String email,
    required String password,
    required String code,
  });

  /// Sends a new sign-up code when the user id is known (60 s cooldown).
  Future<void> resendOtp(String userId);

  /// Sends a new sign-up code when only the email is known.
  Future<void> resendVerification(String email);

  /// Runs the native Google sign-in flow and exchanges the resulting ID token
  /// with the backend for our own session. The first sign-in creates the
  /// student account.
  Future<User> loginWithGoogle();

  /// Runs the native Microsoft (MSAL) sign-in flow and exchanges the resulting
  /// ID token with the backend for our own session.
  Future<User> loginWithMicrosoft();

  /// True when a session token is stored on this device.
  Future<bool> hasSession();

  Future<User> getProfile();

  /// Updates the signed-in user's own profile and returns the fresh record.
  /// Only non-null fields are sent, so callers can patch a subset.
  Future<User> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    String? schoolId,
  });

  /// Lists the schools a user can pick from during onboarding.
  Future<List<School>> getSchools();

  /// Lists the active pickup branches of [schoolId] for the onboarding
  /// branch dropdown.
  Future<List<Branch>> getBranches(String schoolId);

  /// Onboarding: saves name, phone, school and home branch, and optionally
  /// sets an initial password (which also enables email/password sign-in for
  /// accounts created via Google). Marks the account `profile_completed` and
  /// replaces the stored session, since the new token carries the school.
  Future<User> completeProfile({
    required String fullName,
    required String phone,
    required String schoolId,
    String? homeBranchId,
    String? password,
  });

  /// Adds a password to an account that has none (e.g. created via Google),
  /// enabling email/password sign-in alongside it.
  Future<void> setPassword(String password);

  /// Temporary-password flow, step 1 — checks the emailed code.
  Future<void> verifyAccountOtp(String otp);

  /// Temporary-password flow, step 2 — replaces the current password.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Password reset, step 1 — asks the backend to email a 6-digit code.
  /// Always succeeds, even for an unknown address, so it can't be used to work
  /// out which emails are registered.
  Future<void> requestPasswordReset(String email);

  /// Step 2 — checks the emailed code.
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  });

  /// Step 3 — sets the new password.
  Future<void> resetPassword({required String email, required String password});

  /// Signs this device out on the server (best effort) and always clears the
  /// local session.
  Future<void> logout();
}
