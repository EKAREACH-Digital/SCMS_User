import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_canteen_user_frontend/core/widgets/app_button.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/widgets/step_progress_indicator.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/widgets/auth_logo.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/widgets/verify_email/resend_code_button.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Sign-up, step 2 of 3: enter the 6-digit code emailed at sign-up.
///
/// Verifying activates the account and signs in with the sign-up [email] and
/// [password]; the router then opens Complete Profile.
class RegisterStep2Page extends StatefulWidget {
  const RegisterStep2Page({
    super.key,
    required this.userId,
    required this.email,
    required this.password,
  });

  final String userId;
  final String email;
  final String password;

  @override
  State<RegisterStep2Page> createState() => _RegisterStep2PageState();
}

class _RegisterStep2PageState extends State<RegisterStep2Page> {
  String _code = '';

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.read<AuthViewModel>();
    // POST /auth/verify-otp, then POST /auth/login — ends signed in.
    await vm.verifyEmail(
      userId: widget.userId,
      email: widget.email,
      password: widget.password,
      code: _code,
    );
    if (!mounted) return;
    if (vm.status == AuthStatus.authenticated) {
      context.go(AppPaths.completeProfile);
    } else {
      _showMessage(vm.errorMessage ?? l10n.authVerifyFailed);
    }
  }

  Future<bool> _resend() async {
    final l10n = AppLocalizations.of(context)!;
    // POST /auth/resend-otp — a new code, after the 60 s cooldown.
    final error = await context.read<AuthViewModel>().resendOtp(widget.userId);
    if (mounted) _showMessage(error ?? l10n.authCodeResent);
    return error == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _VerifyHeader(email: widget.email),
              const SizedBox(height: 24),
              const _ExpiryCountdown(),
              const SizedBox(height: 24),
              _OtpInput(onChanged: (v) => setState(() => _code = v)),
              const SizedBox(height: 32),
              _VerifyButton(onPressed: _verify),
              const SizedBox(height: 12),
              ResendCodeButton(onResend: _resend),
              const SizedBox(height: 32),
              const AuthLogo(),
            ],
          ),
        ),
      ),
    );
  }
}

// Title, progress and where the code was sent

class _VerifyHeader extends StatelessWidget {
  const _VerifyHeader({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.authVerifyEmailTitle,
          textAlign: TextAlign.center,
          style: AppFonts.heading1.copyWith(
            color: AppColors.text,
            fontWeight: AppFonts.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 20),
        const StepProgressIndicator(currentStep: 2, totalSteps: 3),
        const SizedBox(height: 24),
        Text(
          l10n.authVerifyEmailBody(email),
          textAlign: TextAlign.center,
          style: AppFonts.heading3.copyWith(color: AppColors.mutedText),
        ),
      ],
    );
  }
}

// 6-digit OTP input using Pinput

class _OtpInput extends StatelessWidget {
  const _OtpInput({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: AppFonts.heading2.copyWith(
        color: AppColors.text,
        fontWeight: AppFonts.bold,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
    );

    return Pinput(
      length: 6,
      keyboardType: TextInputType.number,
      defaultPinTheme: defaultTheme,
      focusedPinTheme: defaultTheme.copyWith(
        decoration: defaultTheme.decoration!.copyWith(
          border: Border.all(color: AppColors.primary, width: 2),
          color: AppColors.primaryTint,
        ),
      ),
      submittedPinTheme: defaultTheme.copyWith(
        decoration: defaultTheme.decoration!.copyWith(
          border: Border.all(color: AppColors.primary),
          color: AppColors.primaryTint,
        ),
      ),
      onChanged: onChanged,
    );
  }
}

// 10-minute code expiry countdown

class _ExpiryCountdown extends StatefulWidget {
  const _ExpiryCountdown();

  @override
  State<_ExpiryCountdown> createState() => _ExpiryCountdownState();
}

class _ExpiryCountdownState extends State<_ExpiryCountdown> {
  static const _totalSeconds = 10 * 60;

  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _totalSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _secondsLeft == 0) return;
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _label {
    if (_secondsLeft == 0) return 'Code expired';
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return 'Code expires in ${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final expired = _secondsLeft == 0;
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            expired ? Icons.timer_off_rounded : Icons.timer_rounded,
            size: 16,
            color: expired ? AppColors.accentRed : AppColors.mutedText,
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: AppFonts.heading4.copyWith(
              color: expired ? AppColors.accentRed : AppColors.mutedText,
              fontWeight: expired ? AppFonts.semiBold : AppFonts.regular,
            ),
          ),
        ],
      ),
    );
  }
}

// Verify button, disabled while the request runs

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AuthViewModel>(
      builder: (_, vm, _) {
        final busy = vm.state == ViewState.loading;
        return AppButton(
          label: l10n.authVerifyButton,
          isLoading: busy,
          onPressed: onPressed,
        );
      },
    );
  }
}
