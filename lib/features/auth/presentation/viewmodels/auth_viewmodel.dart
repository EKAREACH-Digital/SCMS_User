import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;

import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/entities/branch.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/entities/school.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/entities/user.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/repositories/auth_repository.dart';

/// Whether a signed-in session exists. Drives the router's auth redirect.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// App-wide session state and the single source of truth for the signed-in
/// [User]: every screen that shows the user's name, email or school reads it
/// from here, so an edit anywhere is reflected everywhere.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authRepository);

  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  File? _photo;
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;

  /// Status of the last sign-in, sign-up or onboarding attempt.
  ViewState get state => _state;

  /// What went wrong in the last attempt, ready to show; null unless [state]
  /// is [ViewState.error].
  String? get errorMessage => _errorMessage;

  // Display helpers for the signed-in user

  /// Backend id, needed to `PATCH /users/:id/...`. Null until signed in.
  String? get userId => _user?.id;
  String get displayName => _user?.fullName ?? '';
  String get email => _user?.email ?? '';
  String get badge => _user?.schoolName ?? '';
  String get initials => _user?.initials ?? '?';

  /// False for Google-only accounts (no password set). Drives the
  /// "Set a password" option in Settings.
  bool get canUseEmailPassword => _user?.canUseEmailPassword ?? true;

  /// Device-local avatar — the backend has no image upload.
  File? get photo => _photo;

  // Session

  /// Restores a stored session at launch: loads the profile if a token is
  /// stored and still valid (the API client refreshes it on a 401).
  Future<void> restoreSession() async {
    if (!await _authRepository.hasSession()) {
      _setSignedOut();
      return;
    }
    try {
      _setSignedIn(await _authRepository.getProfile());
    } catch (e, s) {
      // Invalid/expired session (or offline) — fall back to sign-in. Token
      // clearing on an unrecoverable 401 is handled by the API client.
      AppLogger.w('Session restore failed: $e');
      AppLogger.d(s);
      _setSignedOut();
    }
  }

  Future<void> login({required String email, required String password}) =>
      _runLogin(() => _authRepository.login(email: email, password: password));

  /// Signs in with Google. Reports through the same [state] as [login] since,
  /// from the UI's perspective, it's just another way to end up logged in.
  Future<void> loginWithGoogle() => _runLogin(_authRepository.loginWithGoogle);

  /// Runs the native Microsoft (MSAL) flow. The caller routes on
  /// `needsProfileCompletion` exactly as it does after Google sign-in.
  Future<void> loginWithMicrosoft() =>
      _runLogin(_authRepository.loginWithMicrosoft);

  /// Sign-up, step 1 — `POST /auth/register` creates the inactive account and
  /// emails a code. Returns the new user's id for [verifyEmail], or null on
  /// failure (the reason is in [errorMessage]). Does not sign in.
  Future<String?> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _setState(ViewState.loading);
    try {
      final userId = await _authRepository.register(
        name: fullName.trim(),
        email: email,
        password: password,
        phone: phone,
      );
      _setState(ViewState.idle);
      return userId;
    } catch (e, s) {
      AppLogger.e('Sign-up failed', e, s);
      _errorMessage = _describe(e);
      _setState(ViewState.error);
      return null;
    }
  }

  /// Sign-up, step 2 — `POST /auth/verify-otp` with the emailed [code], then
  /// `POST /auth/login`. Ends signed in, like [login].
  Future<void> verifyEmail({
    required String userId,
    required String email,
    required String password,
    required String code,
  }) => _runLogin(
    () => _authRepository.verifyEmail(
      userId: userId,
      email: email,
      password: password,
      code: code,
    ),
  );

  /// `POST /auth/resend-otp` — a new sign-up code by user id. Returns null on
  /// success, or the reason to show (e.g. the 60 s cooldown's 429).
  Future<String?> resendOtp(String userId) async {
    try {
      await _authRepository.resendOtp(userId);
      return null;
    } catch (e, s) {
      AppLogger.e('Resending the sign-up code failed', e, s);
      return _describe(e);
    }
  }

  /// `POST /auth/resend-verification` — a new sign-up code by email, after a
  /// login rejected with "verify your email".
  Future<void> resendVerification(String email) =>
      _authRepository.resendVerification(email);

  Future<void> _runLogin(Future<User> Function() signIn) async {
    _setState(ViewState.loading);
    try {
      _setSignedIn(await signIn());
    } catch (e, s) {
      AppLogger.e('Sign-in failed', e, s);
      _errorMessage = _describe(e);
      _setState(ViewState.error);
    }
  }

  /// Turns a caught error into copy a user can act on. [ApiException] carries
  /// the backend's actual message (see backend `AllExceptionsFilter`);
  /// anything else (timeouts, no connection) gets a fallback.
  static String _describe(Object error) {
    if (error is ApiException) return error.message;
    // Native sign-in plugins (MSAL, Google) surface setup problems as
    // PlatformException. Swallowing those into "something went wrong" hides
    // the one detail that identifies the cause, so show it in debug builds.
    if (error is PlatformException && kDebugMode) {
      return 'Sign-in failed: ${error.message ?? error.code}';
    }
    return 'Something went wrong. Please try again.';
  }

  /// Ends the session. The router's redirect then sends the user back to the
  /// splash screen.
  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } finally {
      _setSignedOut();
    }
  }

  void _setSignedIn(User user) {
    _user = user;
    _status = AuthStatus.authenticated;
    _setState(ViewState.success);
  }

  void _setSignedOut() {
    _user = null;
    _photo = null;
    _status = AuthStatus.unauthenticated;
    _setState(ViewState.idle);
  }

  /// The only place listeners are notified. Leaving the error state clears
  /// the error message.
  void _setState(ViewState newState) {
    _state = newState;
    if (newState != ViewState.error) _errorMessage = null;
    notifyListeners();
  }

  // Onboarding & password

  /// `GET /schools` — the onboarding school dropdown. Null if it failed.
  Future<List<School>?> loadSchools() async {
    try {
      return await _authRepository.getSchools();
    } catch (e, s) {
      AppLogger.e('Loading schools failed', e, s);
      return null;
    }
  }

  /// `GET /pickup/branches` — the onboarding branch dropdown for [schoolId].
  /// Null if it failed.
  Future<List<Branch>?> loadBranches(String schoolId) async {
    try {
      return await _authRepository.getBranches(schoolId);
    } catch (e, s) {
      AppLogger.e('Loading branches failed', e, s);
      return null;
    }
  }

  /// Saves the onboarding details (name, phone, school) via
  /// `POST /auth/complete-profile`, which also marks the account
  /// `profile_completed`. An optional [password] additionally enables
  /// email/password sign-in — useful for accounts created with Google.
  /// Returns true on success; on failure the reason is in [errorMessage].
  Future<bool> completeProfile({
    required String fullName,
    required String phone,
    required String schoolId,
    String? homeBranchId,
    String? password,
  }) async {
    try {
      final user = await _authRepository.completeProfile(
        fullName: fullName.trim(),
        phone: phone.trim(),
        schoolId: schoolId,
        homeBranchId: homeBranchId,
        password: password,
      );
      _setSignedIn(user);
      return true;
    } catch (e, s) {
      AppLogger.e('Completing the profile failed', e, s);
      _errorMessage = e is ApiException
          ? e.message
          : 'Could not save your details. Please try again.';
      _setState(ViewState.error);
      return false;
    }
  }

  /// Adds a password to a Google-only account so email/password sign-in works
  /// too. Returns null on success, or an error message to show.
  Future<String?> setPassword(String password) async {
    try {
      await _authRepository.setPassword(password);
    } on ApiException catch (e) {
      return e.message;
    } catch (e, s) {
      AppLogger.e('Set password failed', e, s);
      return 'Could not set your password. Please try again.';
    }
    // Flip the flag so the Settings entry disappears immediately.
    final user = _user;
    if (user != null) _setSignedIn(user.copyWith(canUseEmailPassword: true));
    return null;
  }

  /// `POST /auth/password/change` — the Settings "Change Password" screen.
  /// Returns null on success, or an error message to show (for example a
  /// wrong current password).
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e, s) {
      AppLogger.e('Change password failed', e, s);
      return 'Could not change your password. Please try again.';
    }
  }

  /// Password reset, step 1 — emails a 6-digit code.
  Future<void> requestPasswordReset(String email) =>
      _authRepository.requestPasswordReset(email);

  /// Step 2 — checks the emailed code.
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) => _authRepository.verifyPasswordResetCode(email: email, code: code);

  /// Step 3 — sets the new password.
  Future<void> resetPassword({
    required String email,
    required String password,
  }) => _authRepository.resetPassword(email: email, password: password);

  // Profile

  /// Re-fetches the profile, keeping the current one if the backend is
  /// unavailable.
  Future<void> refreshProfile() async {
    if (_status != AuthStatus.authenticated) return;
    try {
      _setSignedIn(await _authRepository.getProfile());
    } catch (e) {
      AppLogger.w('Profile refresh failed, keeping cached profile: $e');
    }
  }

  /// Saves a new display name. The backend stores name as first/last, so the
  /// single "Full Name" field is split the same way onboarding does.
  /// Throws on failure so the caller can show the error.
  Future<void> updateProfile({required String fullName}) async {
    final userId = _user?.id;
    if (userId == null) {
      throw const ApiException('Profile not loaded yet. Please try again.');
    }
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final saved = await _authRepository.updateProfile(
      userId: userId,
      firstName: parts.isNotEmpty ? parts.first : null,
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : null,
    );
    _setSignedIn(saved);
  }

  void setPhoto(File? photo) {
    _photo = photo;
    _setState(_state);
  }
}
