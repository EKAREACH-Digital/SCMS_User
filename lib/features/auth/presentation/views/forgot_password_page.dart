import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/utils/password_validator.dart';
import 'package:smart_canteen_user_frontend/core/widgets/smart_canteen_button.dart';
import 'package:smart_canteen_user_frontend/core/widgets/smart_canteen_text_field.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/widgets/auth_logo.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/widgets/verify_email/resend_code_button.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Forgot-password flow — three sequential steps on one page:
///
/// 1. Email — `POST /auth/forgot-password`; the backend always responds with
///    "check your email" regardless of whether the address exists.
/// 2. OTP — `POST /auth/forgot-password/verify-otp` with the 6-digit code.
/// 3. New password — `POST /auth/forgot-password/reset` sets the password and
///    the user is redirected back to sign-in.
///
/// Receives an optional pre-filled [email] via `state.extra as String?`.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.email});

  final String? email;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  /// Which of the three steps is visible.
  int _step = 0;
  String _email = '';
  String _code = '';

  @override
  void initState() {
    super.initState();
    _email = widget.email ?? '';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _advanceTo(int step) => setState(() => _step = step);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: switch (_step) {
            0 => _EmailStep(
              initialEmail: _email,
              onSuccess: (email) {
                _email = email;
                _advanceTo(1);
              },
              showMessage: _showMessage,
            ),
            1 => _OtpStep(
              email: _email,
              onCodeChanged: (v) => _code = v,
              onSuccess: () => _advanceTo(2),
              showMessage: _showMessage,
            ),
            _ => _NewPasswordStep(
              email: _email,
              code: _code,
              onSuccess: () {
                final l10n = AppLocalizations.of(context)!;
                context.pop();
                _showMessage(l10n.authPasswordReset);
              },
              showMessage: _showMessage,
            ),
          },
        ),
      ),
    );
  }
}

// Step 1 — email input

class _EmailStep extends StatefulWidget {
  const _EmailStep({
    required this.initialEmail,
    required this.onSuccess,
    required this.showMessage,
  });

  final String initialEmail;
  final void Function(String email) onSuccess;
  final void Function(String) showMessage;

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  late final TextEditingController _controller;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _controller.text.trim();
    if (!email.contains('@')) {
      widget.showMessage(l10n.authForgotPasswordErrorEmail);
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<AuthViewModel>().requestPasswordReset(email);
      if (!mounted) return;
      widget.onSuccess(email);
    } on ApiException catch (e) {
      if (mounted) widget.showMessage(e.message);
    } catch (_) {
      if (mounted) widget.showMessage(l10n.authForgotPasswordSending);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PageTitle(title: l10n.authForgotPasswordPageTitle),
        const SizedBox(height: 12),
        Text(
          l10n.authForgotPasswordEmailBody,
          textAlign: TextAlign.center,
          style: AppFonts.heading3.copyWith(color: AppColors.mutedText),
        ),
        const SizedBox(height: 32),
        SmartCanteenTextField(
          label: l10n.authForgotPasswordEmailLabel,
          hintText: l10n.authForgotPasswordEmailHint,
          controller: _controller,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        SmartCanteenButton(
          label: _busy
              ? l10n.authForgotPasswordSending
              : l10n.authForgotPasswordSendCode,
          isLoading: _busy,
          onPressed: _send,
        ),
        const SizedBox(height: 32),
        const AuthLogo(),
      ],
    );
  }
}

// Step 2 — OTP entry

class _OtpStep extends StatelessWidget {
  const _OtpStep({
    required this.email,
    required this.onCodeChanged,
    required this.onSuccess,
    required this.showMessage,
  });

  final String email;
  final void Function(String) onCodeChanged;
  final VoidCallback onSuccess;
  final void Function(String) showMessage;

  Future<void> _verify(BuildContext context, String code) async {
    final l10n = AppLocalizations.of(context)!;
    if (code.length < 6) {
      showMessage(l10n.authVerifyErrorCode);
      return;
    }
    try {
      await context.read<AuthViewModel>().verifyPasswordResetCode(
        email: email,
        code: code,
      );
      if (!context.mounted) return;
      onSuccess();
    } on ApiException catch (e) {
      showMessage(e.message);
    } catch (_) {
      if (context.mounted) showMessage(l10n.authForgotPasswordVerifyFailed);
    }
  }

  Future<bool> _resend(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await context.read<AuthViewModel>().requestPasswordReset(email);
      if (context.mounted) showMessage(l10n.authCodeResent);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String localCode = '';

    return StatefulBuilder(
      builder: (context, setLocal) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PageTitle(title: l10n.authForgotPasswordPageTitle),
            const SizedBox(height: 12),
            Text(
              l10n.authForgotPasswordCodeSentBody(email),
              textAlign: TextAlign.center,
              style: AppFonts.heading3.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            const _ExpiryCountdown(),
            const SizedBox(height: 24),
            _OtpInput(onChanged: (v) {
              localCode = v;
              onCodeChanged(v);
            }),
            const SizedBox(height: 32),
            _VerifyButton(
              onPressed: () => _verify(context, localCode),
            ),
            const SizedBox(height: 12),
            ResendCodeButton(onResend: () => _resend(context)),
            const SizedBox(height: 32),
            const AuthLogo(),
          ],
        );
      },
    );
  }
}

// Step 3 — new password

class _NewPasswordStep extends StatefulWidget {
  const _NewPasswordStep({
    required this.email,
    required this.code,
    required this.onSuccess,
    required this.showMessage,
  });

  final String email;
  final String code;
  final VoidCallback onSuccess;
  final void Function(String) showMessage;

  @override
  State<_NewPasswordStep> createState() => _NewPasswordStepState();
}

class _NewPasswordStepState extends State<_NewPasswordStep> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    final l10n = AppLocalizations.of(context)!;
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    final validationError = validateNewPassword(password);
    if (validationError != null) {
      widget.showMessage(validationError);
      return;
    }
    if (password != confirm) {
      widget.showMessage(l10n.authForgotPasswordErrorPasswordMatch);
      return;
    }

    setState(() => _busy = true);
    try {
      await context.read<AuthViewModel>().resetPassword(
        email: widget.email,
        password: password,
      );
      if (!mounted) return;
      widget.onSuccess();
    } on ApiException catch (e) {
      if (mounted) widget.showMessage(e.message);
    } catch (_) {
      if (mounted) widget.showMessage(l10n.authForgotPasswordResetFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PageTitle(title: l10n.authForgotPasswordNewPasswordTitle),
        const SizedBox(height: 12),
        Text(
          l10n.authForgotPasswordNewPasswordBody,
          textAlign: TextAlign.center,
          style: AppFonts.heading3.copyWith(color: AppColors.mutedText),
        ),
        const SizedBox(height: 32),
        SmartCanteenTextField(
          label: l10n.authForgotPasswordNewPasswordLabel,
          hintText: l10n.authForgotPasswordNewPasswordHint,
          controller: _passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        SmartCanteenTextField(
          label: l10n.authForgotPasswordConfirmLabel,
          hintText: l10n.authForgotPasswordConfirmHint,
          controller: _confirmController,
          obscureText: true,
        ),
        const SizedBox(height: 24),
        SmartCanteenButton(
          label: _busy
              ? l10n.authForgotPasswordResetting
              : l10n.authForgotPasswordResetButton,
          isLoading: _busy,
          onPressed: _reset,
        ),
        const SizedBox(height: 32),
        const AuthLogo(),
      ],
    );
  }
}

// Shared title widget

class _PageTitle extends StatelessWidget {
  const _PageTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: AppFonts.heading1.copyWith(
        color: AppColors.text,
        fontWeight: AppFonts.bold,
        fontSize: 24,
      ),
    );
  }
}

// 6-digit OTP input

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

// Verify button — disabled while the ViewModel is loading

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AuthViewModel>(
      builder: (_, vm, _) => SmartCanteenButton(
        label: l10n.authForgotPasswordVerifyButton,
        isLoading: false,
        onPressed: onPressed,
      ),
    );
  }
}
