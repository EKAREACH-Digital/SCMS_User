import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/core/widgets/app_widgets.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/widgets/auth_logo.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

const _kFieldRadius = BorderRadius.all(Radius.circular(8));

/// Sign-in screen. For registration navigate to [AppPaths.signUp].
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

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
                l10n.authSignInTitle,
                textAlign: TextAlign.center,
                style: AppFonts.heading1.copyWith(
                  color: AppColors.text,
                  fontWeight: AppFonts.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 32),
              const _SignInForm(),
              const SizedBox(height: 20),
              _SignUpLink(onTap: () => context.go(AppPaths.signUp)),
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

// Sign-in form — email, password, remember me, forgot password, social row

class _SignInForm extends StatefulWidget {
  const _SignInForm();

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError(l10n.authSignInErrorEmpty);
      return;
    }

    setState(() => _isSubmitting = true);

    final vm = context.read<AuthViewModel>();
    await vm.login(email: email, password: password);
    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (vm.state == ViewState.success && vm.user != null) {
      context.go(AppPaths.home);
    } else {
      _showError(vm.errorMessage ?? l10n.authSignInFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SmartCanteenTextField(
          controller: _emailController,
          label: l10n.authSignInEmailLabel,
          hintText: l10n.authSignInEmailHint,
          keyboardType: TextInputType.emailAddress,
          borderRadius: _kFieldRadius,
        ),
        const SizedBox(height: 18),
        SmartCanteenTextField(
          controller: _passwordController,
          label: l10n.authSignInPasswordLabel,
          hintText: l10n.authSignInPasswordHint,
          obscureText: true,
          borderRadius: _kFieldRadius,
        ),
        const SizedBox(height: 12),
        _RememberMeRow(
          rememberMe: _rememberMe,
          onChanged: (v) => setState(() => _rememberMe = v ?? false),
          onForgotTap: () => context.push(
            AppPaths.forgotPassword,
            extra: _emailController.text.trim(),
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: _isSubmitting ? l10n.authSignInLoading : l10n.authSignInButton,
          onPressed: _isSubmitting ? null : _handleLogin,
        ),
        const SizedBox(height: 24),
        // SmartCanteenDividerText(label: l10n.authOrContinueWith),
        // const SizedBox(height: 20),
        // _SocialRow(
        //   isBusy: _isSubmitting,
        //   onGoogleTap: _handleGoogleLogin,
        //   onMicrosoftTap: _handleMicrosoftLogin,
        // ),
      ],
    );
  }
}

// Remember me + forgot password row

class _RememberMeRow extends StatelessWidget {
  const _RememberMeRow({
    required this.rememberMe,
    required this.onChanged,
    required this.onForgotTap,
  });

  final bool rememberMe;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onForgotTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        // Checkbox(
        //   value: rememberMe,
        //   activeColor: AppColors.primary,
        //   checkColor: AppColors.onPrimary,
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        //   side: const BorderSide(color: AppColors.border, width: 1.5),
        //   onChanged: onChanged,
        // ),
        // Text(
        //   l10n.authRememberMe,
        //   style: AppFonts.heading3.copyWith(color: AppColors.mutedText),
        // ),
        const Spacer(),
        GestureDetector(
          onTap: onForgotTap,
          child: Text(
            l10n.authForgotPassword,
            style: AppFonts.heading3.copyWith(
              color: AppColors.primary,
              fontWeight: AppFonts.semiBold,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

// "Don't have an account?" link

class _SignUpLink extends StatelessWidget {
  const _SignUpLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.authDontHaveAccount,
          style: AppFonts.heading3.copyWith(color: context.mutedColor),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            l10n.authSignUpLink,
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

