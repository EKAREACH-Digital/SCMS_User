import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/widgets/form/app_dropdown.dart';
import 'package:smart_canteen_user_frontend/core/widgets/app_button.dart';
import 'package:smart_canteen_user_frontend/core/widgets/form/smart_canteen_text_field.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/widgets/step_progress_indicator.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/entities/branch.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/entities/school.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/widgets/auth_field_radius.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/widgets/auth_logo.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Sign-up, step 3 of 3: Complete Profile.
///
/// Shown to every signed-in user whose profile isn't completed (the router
/// sends them here). Collects phone, school and home branch, then saves them
/// with `POST /auth/complete-profile`, which also replaces the stored tokens.
class RegisterStep3Page extends StatefulWidget {
  const RegisterStep3Page({super.key});

  @override
  State<RegisterStep3Page> createState() => _RegisterStep3PageState();
}

class _RegisterStep3PageState extends State<RegisterStep3Page> {
  final _phoneController = TextEditingController();
  List<School>? _schools;
  List<Branch>? _branches;
  String? _selectedSchoolId;
  String? _selectedBranchId;
  bool _loadingBranches = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSchools());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _loadSchools() async {
    // GET /schools — the school dropdown.
    final schools = await context.read<AuthViewModel>().loadSchools();
    if (!mounted) return;
    setState(() => _schools = schools ?? const []);
    if (schools == null) {
      _showError(AppLocalizations.of(context)!.authRegisterLoadFailed);
    }
  }

  Future<void> _selectSchool(String? schoolId) async {
    if (schoolId == null || schoolId == _selectedSchoolId) return;
    setState(() {
      _selectedSchoolId = schoolId;
      _selectedBranchId = null;
      _branches = null;
      _loadingBranches = true;
    });
    // GET /pickup/branches — the chosen school's branches.
    final branches = await context.read<AuthViewModel>().loadBranches(schoolId);
    // Ignore an answer for a school the user has since switched away from.
    if (!mounted || schoolId != _selectedSchoolId) return;
    setState(() {
      _branches = branches ?? const [];
      _loadingBranches = false;
    });
    if (branches == null) {
      _showError(AppLocalizations.of(context)!.authRegisterLoadFailed);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return _showError(l10n.authRegisterErrorPhone);
    if (_selectedSchoolId == null) return _showError(l10n.authRegisterErrorSchool);
    if (_selectedBranchId == null) return _showError(l10n.authRegisterErrorBranch);

    setState(() => _isSubmitting = true);
    final vm = context.read<AuthViewModel>();
    // POST /auth/complete-profile — saves the details, marks the profile done.
    final ok = await vm.completeProfile(
      fullName: vm.displayName,
      phone: phone,
      schoolId: _selectedSchoolId!,
      homeBranchId: _selectedBranchId,
    );
    if (!mounted) return;
    if (ok) return context.go(AppPaths.home);

    setState(() => _isSubmitting = false);
    _showError(vm.errorMessage ?? l10n.authRegisterSaveFailed);
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
              const SizedBox(height: 24),
              Text(
                l10n.authRegisterTitle,
                textAlign: TextAlign.center,
                style: AppFonts.heading1.copyWith(
                  color: AppColors.text,
                  fontWeight: AppFonts.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              const StepProgressIndicator(currentStep: 3, totalSteps: 3),
              const SizedBox(height: 32),
              _RegisterStep3Form(
                phoneController: _phoneController,
                schools: _schools,
                branches: _branches,
                loadingBranches: _loadingBranches,
                selectedSchoolId: _selectedSchoolId,
                selectedBranchId: _selectedBranchId,
                onSchoolChanged: _selectSchool,
                onBranchChanged: (id) => setState(() => _selectedBranchId = id),
                isSubmitting: _isSubmitting,
                onSubmit: _isSubmitting ? null : _submit,
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

// Form body

class _RegisterStep3Form extends StatelessWidget {
  const _RegisterStep3Form({
    required this.phoneController,
    required this.schools,
    required this.branches,
    required this.loadingBranches,
    required this.selectedSchoolId,
    required this.selectedBranchId,
    required this.onSchoolChanged,
    required this.onBranchChanged,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TextEditingController phoneController;
  final List<School>? schools;
  final List<Branch>? branches;
  final bool loadingBranches;
  final String? selectedSchoolId;
  final String? selectedBranchId;
  final ValueChanged<String?> onSchoolChanged;
  final ValueChanged<String?> onBranchChanged;
  final bool isSubmitting;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SmartCanteenTextField(
          controller: phoneController,
          label: l10n.authRegisterPhoneLabel,
          hintText: l10n.authRegisterPhoneHint,
          keyboardType: TextInputType.phone,
          borderRadius: kAuthFieldRadius,
        ),
        const SizedBox(height: 20),
        AppDropdown(
          label: l10n.authRegisterChooseSchool,
          hint: l10n.authSelectSchool,
          value: selectedSchoolId,
          isLoading: schools == null,
          items: [for (final s in schools ?? const <School>[]) (s.id, s.name)],
          onChanged: onSchoolChanged,
        ),
        const SizedBox(height: 20),
        AppDropdown(
          // A new school resets the field (it only reads its value once).
          key: ValueKey(selectedSchoolId),
          label: l10n.authRegisterSelectBranch,
          hint: l10n.authRegisterSelectBranchHint,
          value: selectedBranchId,
          isLoading: loadingBranches,
          items: [for (final b in branches ?? const <Branch>[]) (b.id, b.name)],
          onChanged: onBranchChanged,
        ),
        const SizedBox(height: 32),
        AppButton(
          label: l10n.authRegisterCreateAccount,
          isLoading: isSubmitting,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
