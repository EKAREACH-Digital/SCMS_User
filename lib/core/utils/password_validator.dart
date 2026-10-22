/// Validates a new password against the backend's rule — see the backend
/// `SetPasswordDto` / `CompleteProfileDto`: at least 8 characters, containing
/// an uppercase letter, a lowercase letter, and a number.
///
/// Returns `null` when the password is acceptable, otherwise a message to show
/// the user. Keeping this client-side check in step with the server's means the
/// user gets immediate, specific feedback instead of a round-trip rejection.
String? validateNewPassword(String password) {
  if (password.length < 8) {
    return 'Password must be at least 8 characters.';
  }
  if (!RegExp(r'[a-z]').hasMatch(password)) {
    return 'Password must include a lowercase letter.';
  }
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return 'Password must include an uppercase letter.';
  }
  if (!RegExp(r'\d').hasMatch(password)) {
    return 'Password must include a number.';
  }
  return null;
}
