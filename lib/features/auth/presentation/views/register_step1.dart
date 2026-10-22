import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/utils/password_validator.dart';
import 'package:smart_canteen_user_frontend/core/widgets/smart_canteen_button.dart';
import 'package:smart_canteen_user_frontend/core/widgets/smart_canteen_text_field.dart';
import 'package:smart_canteen_user_frontend/core/widgets/step_progress_indicator.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/widgets/auth_logo.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Border radius applied to every text field on the register screens.
/// Change this value to adjust the roundness across both steps at once.
const _kFieldRadius = BorderRadius.all(Radius.circular(8));

/// Register flow — Step 1.
///
/// Validates First Name, Last Name, E-mail, Password, and Confirm Password
/// locally, then passes the data to Step 2 via route extra.
/// No API call is made here — account creation happens in Step 2.
class RegisterStep1Page extends StatefulWidget {
  const RegisterStep1Page({super.key});

  @override
  State<RegisterStep1Page> createState() => _RegisterStep1PageState();
}

class _RegisterStep1PageState extends State<RegisterStep1Page> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _handleNext() {
    final l10n = AppLocalizations.of(context)!;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (firstName.isEmpty || lastName.isEmpty) {
      _showError(l10n.authRegisterErrorName);
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError(l10n.authRegisterErrorEmail);
      return;
    }
    final passwordError = validateNewPassword(password);
    if (passwordError != null) {
      _showError(passwordError);
      return;
    }
    if (password != confirm) {
      _showError(l10n.authRegisterErrorPasswordMatch);
      return;
    }

    // Push Step 2 so Step 1 stays in the stack — the user can pop back to edit.
    context.push(
      AppPaths.completeProfile,
      extra: {
        'email': email,
        'password': password,
        'fullName': '$firstName $lastName',
      },
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
              const StepProgressIndicator(currentStep: 1),
              const SizedBox(height: 32),
              _RegisterStep1Form(
                l10n: l10n,
                firstNameController: _firstNameController,
                lastNameController: _lastNameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmController: _confirmController,
                onNext: _handleNext,
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

// Form body

class _RegisterStep1Form extends StatelessWidget {
  const _RegisterStep1Form({
    required this.l10n,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.onNext,
  });

  final AppLocalizations l10n;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NameRow(
          l10n: l10n,
          firstNameController: firstNameController,
          lastNameController: lastNameController,
        ),
        const SizedBox(height: 18),
        SmartCanteenTextField(
          controller: emailController,
          label: l10n.authRegisterEmailLabel,
          hintText: l10n.authRegisterEmailHint,
          keyboardType: TextInputType.emailAddress,
          borderRadius: _kFieldRadius,
        ),
        const SizedBox(height: 18),
        SmartCanteenTextField(
          controller: passwordController,
          label: l10n.authRegisterPasswordLabel,
          hintText: '••••••••',
          obscureText: true,
          borderRadius: _kFieldRadius,
        ),
        const SizedBox(height: 6),
        Text(
          l10n.authRegisterPasswordRequirement,
          style: AppFonts.heading5.copyWith(color: AppColors.mutedText),
        ),
        const SizedBox(height: 18),
        SmartCanteenTextField(
          controller: confirmController,
          label: l10n.authRegisterConfirmPasswordLabel,
          hintText: '••••••••',
          obscureText: true,
          borderRadius: _kFieldRadius,
        ),
        const SizedBox(height: 32),
        SmartCanteenButton(
          label: l10n.authRegisterNext,
          onPressed: onNext,
        ),
      ],
    );
  }
}

// Name row — First Name and Last Name side by side

class _NameRow extends StatelessWidget {
  const _NameRow({
    required this.l10n,
    required this.firstNameController,
    required this.lastNameController,
  });

  final AppLocalizations l10n;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SmartCanteenTextField(
            controller: firstNameController,
            label: l10n.authRegisterFirstName,
            hintText: l10n.authRegisterFirstNameHint,
            keyboardType: TextInputType.name,
            borderRadius: _kFieldRadius,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SmartCanteenTextField(
            controller: lastNameController,
            label: l10n.authRegisterLastName,
            hintText: l10n.authRegisterLastNameHint,
            keyboardType: TextInputType.name,
            borderRadius: _kFieldRadius,
          ),
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
