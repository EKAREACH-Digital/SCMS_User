/// The signed-in user.
class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatarUrl;
  final String? schoolId;
  final String? schoolName;

  /// The branch whose menu the student orders from. Null until chosen.
  final String? homeBranchId;
  final UserRole role;

  /// False for Google-only accounts (no password set). The app offers
  /// "Set a password" so they can also sign in with email + password.
  final bool canUseEmailPassword;

  /// The backend's `profile_completed`. The backend does not block an
  /// incomplete profile, so the app must send the user to Complete Profile.
  final bool profileCompleted;

  /// Set after a sign-in with a temporary password: the user must verify the
  /// emailed code and choose a new password before using the app.
  final bool mustChangePassword;

  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatarUrl,
    this.schoolId,
    this.schoolName,
    this.homeBranchId,
    required this.role,
    this.canUseEmailPassword = true,
    this.profileCompleted = true,
    this.mustChangePassword = false,
  });

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? schoolId,
    String? schoolName,
    String? homeBranchId,
    UserRole? role,
    bool? canUseEmailPassword,
    bool? profileCompleted,
    bool? mustChangePassword,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      homeBranchId: homeBranchId ?? this.homeBranchId,
      role: role ?? this.role,
      canUseEmailPassword: canUseEmailPassword ?? this.canUseEmailPassword,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }

  /// True when we have no name on file — e.g. a Google account that didn't
  /// share `given_name`/`family_name`.
  bool get needsName =>
      (firstName == null || firstName!.trim().isEmpty) &&
      (lastName == null || lastName!.trim().isEmpty);

  /// True until the backend marks the profile completed. Gates the onboarding
  /// screen shown after every sign-in path.
  bool get needsProfileCompletion => !profileCompleted;

  String get fullName {
    final name = [
      firstName,
      lastName,
    ].where((p) => p != null && p.isNotEmpty).join(' ');
    return name.isNotEmpty ? name : email;
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}

enum UserRole {
  student,
  staff,
  manager,
  systemAdmin;

  static UserRole fromString(String? value) => switch (value) {
    'staff' => UserRole.staff,
    'manager' => UserRole.manager,
    'system-admin' => UserRole.systemAdmin,
    _ => UserRole.student,
  };

  String get displayLabel => switch (this) {
    UserRole.student => 'Student',
    UserRole.staff => 'Staff',
    UserRole.manager => 'Manager',
    UserRole.systemAdmin => 'Admin',
  };
}
