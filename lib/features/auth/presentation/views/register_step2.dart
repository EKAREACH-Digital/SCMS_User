import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/core/widgets/app_dropdown.dart';
import 'package:smart_canteen_user_frontend/core/widgets/smart_canteen_button.dart';
import 'package:smart_canteen_user_frontend/core/widgets/step_progress_indicator.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/widgets/auth_logo.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Placeholder schools until the `/auth/schools` API is wired into the
/// datasource. The backend endpoint already exists; branch data is TBD.
const _mockSchools = [
  ('cadt', 'Cambodia Academy of Digital Technology'),
  ('rupp', 'Royal University of Phnom Penh'),
  ('puc', 'Pannasastra University of Cambodia'),
  ('iu', 'International University'),
  ('other', 'Other'),
];

const _mockBranches = [
  ('ccv', 'CCV'),
  ('main', 'Main Campus'),
  ('annex', 'Annex Building'),
  ('north', 'North Block'),
];

/// Register flow — Step 2.
///
/// Receives the Step 1 data (email, password, fullName) from the router's
/// extra map, collects School and Branch, then creates the account and
/// completes the profile in a single submit.
class RegisterStep2Page extends StatefulWidget {
  const RegisterStep2Page({
    super.key,
    required this.email,
    required this.password,
    required this.fullName,
  });

  final String email;
  final String password;
  final String fullName;

  @override
  State<RegisterStep2Page> createState() => _RegisterStep2PageState();
}

class _RegisterStep2PageState extends State<RegisterStep2Page> {
  String? _selectedSchoolId;
  String? _selectedBranchId;
  bool _isSubmitting = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedSchoolId == null) {
      _showError(l10n.authRegisterErrorSchool);
      return;
    }
    if (_selectedBranchId == null) {
      _showError(l10n.authRegisterErrorBranch);
      return;
    }

    setState(() => _isSubmitting = true);

    final vm = context.read<AuthViewModel>();

    // Step 1: Create the account.
    await vm.register(
      email: widget.email,
      password: widget.password,
      fullName: widget.fullName,
    );

    if (!mounted) return;
    if (vm.state == ViewState.error) {
      setState(() => _isSubmitting = false);
      _showError(vm.errorMessage ?? l10n.authRegisterFailed);
      return;
    }

    // Step 2: Complete the profile with school and branch.
    // NOTE: `phone` is required by the existing API but the new design omits
    // it. Passing an empty string until the backend contract is updated.
    final ok = await vm.completeProfile(
      fullName: widget.fullName,
      phone: '',
      schoolId: _selectedSchoolId!,
    );

    if (!mounted) return;

    if (ok) {
      context.go(AppPaths.home);
      return;
    }

    setState(() => _isSubmitting = false);
    _showError(
      vm.errorMessage ?? AppLocalizations.of(context)!.authRegisterSaveFailed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _BackButton(),
                  Text(
                    l10n.authRegisterTitle,
                    textAlign: TextAlign.center,
                    style: AppFonts.heading1.copyWith(
                      color: AppColors.text,
                      fontWeight: AppFonts.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(width: 48,height: 48)
                ],
              ),
              const SizedBox(height: 20),
              const StepProgressIndicator(currentStep: 2),
              const SizedBox(height: 32),
              _RegisterStep2Form(
                l10n: l10n,
                selectedSchoolId: _selectedSchoolId,
                selectedBranchId: _selectedBranchId,
                onSchoolChanged: (id) => setState(() => _selectedSchoolId = id),
                onBranchChanged: (id) => setState(() => _selectedBranchId = id),
                isSubmitting: _isSubmitting,
                onSubmit: _isSubmitting ? null : _submit,
              ),
              const SizedBox(height: 20),
              _SignInLink(
                label: l10n.authAlreadyHaveAccount,
                linkText: l10n.authSignInLink,
                onTap: () => context.go(AppPaths.signIn),
              ),
              const SizedBox(height: 32),
              const AuthLogo(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// Back button

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: AppColors.text,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}

// Form body

class _RegisterStep2Form extends StatelessWidget {
  const _RegisterStep2Form({
    required this.l10n,
    required this.selectedSchoolId,
    required this.selectedBranchId,
    required this.onSchoolChanged,
    required this.onBranchChanged,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final AppLocalizations l10n;
  final String? selectedSchoolId;
  final String? selectedBranchId;
  final ValueChanged<String?> onSchoolChanged;
  final ValueChanged<String?> onBranchChanged;
  final bool isSubmitting;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDropdown(
          label: l10n.authRegisterChooseSchool,
          hint: 'CADT',
          value: selectedSchoolId,
          items: _mockSchools.toList(),
          onChanged: onSchoolChanged,
        ),
        const SizedBox(height: 20),
        AppDropdown(
          label: l10n.authRegisterSelectBranch,
          hint: 'CCV',
          value: selectedBranchId,
          items: _mockBranches.toList(),
          onChanged: onBranchChanged,
        ),
        const SizedBox(height: 32),
        SmartCanteenButton(
          label: isSubmitting
              ? l10n.authRegisterCreating
              : l10n.authRegisterCreateAccount,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

// "Already have an account?" link

class _SignInLink extends StatelessWidget {
  const _SignInLink({
    required this.label,
    required this.linkText,
    required this.onTap,
  });

  final String label;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppFonts.heading3.copyWith(color: context.mutedColor),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: AppFonts.heading3.copyWith(
              color: AppColors.primary,
              fontWeight: AppFonts.semiBold,
            ),
          ),
        ),
      ],
    );
  }
}
