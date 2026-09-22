import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../data/dtos/auth_dto.dart';
import '../../../data/exceptions/api_exception.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../model/user/user.dart';
import '../../../theme/app_theme.dart';
import '../../../ui/utils/async_value.dart';
import '../../../ui/utils/password_validator.dart';
import '../../states/user_profile_state.dart';
import '../../widgets/smart_canteen_button.dart';
import '../../widgets/smart_canteen_text_field.dart';
import '../shell/app_shell.dart';
import 'view_model/auth_view_model.dart';

/// Brand gradient used for the primary action button (#4CAF50 → #81C784).
const _primaryGradient = LinearGradient(
  colors: [AppTheme.primary, AppTheme.primaryLight],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

String _describeError(Object error) {
  if (error is ApiException) return error.message;
  return 'Something went wrong. Please try again.';
}

/// Shown right after sign-in for an account whose profile is incomplete
/// (missing name, phone, or school — typical for a freshly created Google
/// account). Collects those details, patches them to the backend, then
/// continues into the app.
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key, required this.user});

  static const routeName = '/complete-profile';

  final User user;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;
  bool _obscurePassword = true;

  /// Google accounts arrive with no password. Offering to set one here (it's
  /// optional) lets them also sign in with email + password on another device.
  bool get _canSetPassword => !widget.user.canUseEmailPassword;

  List<SchoolDto> _schools = const [];
  String? _selectedSchoolId;
  bool _loadingSchools = true;
  String? _schoolsError;

  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existingName = [
      widget.user.firstName,
      widget.user.lastName,
    ].where((p) => p != null && p.trim().isNotEmpty).join(' ');
    _nameController = TextEditingController(text: existingName);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    _selectedSchoolId = widget.user.schoolId;
    _loadSchools();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    setState(() {
      _loadingSchools = true;
      _schoolsError = null;
    });
    try {
      final schools = await context.read<AuthRepository>().getSchools();
      if (!mounted) return;
      setState(() {
        _schools = schools;
        // Drop a stale pre-selection that isn't in the list.
        if (!schools.any((s) => s.id == _selectedSchoolId)) {
          _selectedSchoolId = null;
        }
        _loadingSchools = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _schoolsError = _describeError(e);
        _loadingSchools = false;
      });
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final schoolId = _selectedSchoolId;

    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name.');
      return;
    }
    if (phone.isEmpty) {
      setState(() => _error = 'Please enter your phone number.');
      return;
    }
    if (schoolId == null) {
      setState(() => _error = 'Please select your school.');
      return;
    }

    // Password is optional here — only validate it if they typed something.
    final password = _passwordController.text;
    if (_canSetPassword && password.isNotEmpty) {
      final passwordError = validateNewPassword(password);
      if (passwordError != null) {
        setState(() => _error = passwordError);
        return;
      }
      if (password != _confirmController.text) {
        setState(() => _error = 'The two passwords do not match.');
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final authViewModel = context.read<AuthViewModel>();
    final ok = await authViewModel.completeProfile(
      fullName: name,
      phone: phone,
      schoolId: schoolId,
      password: _canSetPassword && password.isNotEmpty ? password : null,
    );
    if (!mounted) return;

    if (ok) {
      // Keep the local display state in sync so the name shows across the app.
      context.read<UserProfileState>().updateProfile(
        name: name,
        email: widget.user.email,
      );
      Navigator.pushReplacementNamed(context, AppShell.routeName);
      return;
    }

    final state = authViewModel.loginState;
    setState(() {
      _isSubmitting = false;
      _error = state is AsyncError<User>
          ? _describeError(state.error)
          : 'Could not save your details. Please try again.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.greenSurface, Color(0xFFF7F8FA)],
            begin: Alignment.topCenter,
            end: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.badge_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.authCompleteProfileTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.greenDark,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.authCompleteProfileBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.text.withValues(alpha: 0.5),
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null) ...[
                        _ErrorBanner(message: _error!),
                        const SizedBox(height: 16),
                      ],
                      SmartCanteenTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hintText: 'Enter your full name',
                        keyboardType: TextInputType.name,
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SchoolField(
                        schools: _schools,
                        selectedId: _selectedSchoolId,
                        loading: _loadingSchools,
                        error: _schoolsError,
                        onChanged: (id) =>
                            setState(() => _selectedSchoolId = id),
                        onRetry: _loadSchools,
                      ),
                      const SizedBox(height: 18),
                      SmartCanteenTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hintText: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      if (_canSetPassword) ...[
                        const SizedBox(height: 26),
                        const _OptionalPasswordHeader(),
                        const SizedBox(height: 14),
                        SmartCanteenTextField(
                          controller: _passwordController,
                          label: 'Password (optional)',
                          hintText: 'At least 8 characters',
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppTheme.mutedText,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                          ),
                        ),
                        const SizedBox(height: 18),
                        SmartCanteenTextField(
                          controller: _confirmController,
                          label: 'Confirm Password',
                          hintText: 'Re-enter your password',
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SmartCanteenButton(
                        label: _isSubmitting ? 'Saving…' : 'Continue',
                        onPressed: _isSubmitting ? null : _submit,
                        gradient: _primaryGradient,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── School picker ────────────────────────────────────────────────────────────

class _SchoolField extends StatelessWidget {
  const _SchoolField({
    required this.schools,
    required this.selectedId,
    required this.loading,
    required this.error,
    required this.onChanged,
    required this.onRetry,
  });

  final List<SchoolDto> schools;
  final String? selectedId;
  final bool loading;
  final String? error;
  final ValueChanged<String?> onChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.authSchool,
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        if (loading)
          _FieldBox(
            child: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.authLoadingSchools,
                  style: const TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else if (error != null)
          _FieldBox(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    error!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: onRetry,
                  child: Text(AppLocalizations.of(context)!.commonRetry),
                ),
              ],
            ),
          )
        else
          DropdownButtonFormField<String>(
            initialValue: selectedId,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
            hint: Text(
              AppLocalizations.of(context)!.authSelectSchool,
              style: const TextStyle(color: AppTheme.mutedText, fontSize: 15),
            ),
            items: [
              for (final s in schools)
                DropdownMenuItem(value: s.id, child: Text(s.name)),
            ],
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.text,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.school_outlined,
                color: AppTheme.primary,
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE8E8E8),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE8E8E8),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.primary, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1.5),
      ),
      child: child,
    );
  }
}

// ── Inline error banner ──────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Explains why an optional password is offered during onboarding: the account
/// was created with Google and has no password, so setting one here is what
/// makes email + password sign-in possible on another device later.
class _OptionalPasswordHeader extends StatelessWidget {
  const _OptionalPasswordHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.key_outlined, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add a password?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'You signed up with Google. Set a password to also log in '
                  'with your email on another device. You can skip this and '
                  'add one later in Settings.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
