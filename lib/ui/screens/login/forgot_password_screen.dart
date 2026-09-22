import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../data/exceptions/api_exception.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../theme/app_theme.dart';
import '../../utils/password_validator.dart';
import '../../widgets/smart_canteen_button.dart';
import '../../widgets/smart_canteen_text_field.dart';

/// Three-step password reset, matching the backend flow:
///   1. `email`    — request a 6-digit code
///   2. `code`     — exchange the code for a single-use reset token
///   3. `password` — set the new password with that token
///
/// The same endpoints back the web client, so both stay in step.
enum _Step { email, code, password }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  static const routeName = '/forgot-password';

  /// Pre-fills the field with whatever was already typed on the sign-in form.
  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  _Step _step = _Step.email;
  String? _resetToken;
  bool _busy = false;
  String? _error;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  AuthRepository get _auth => context.read<AuthRepository>();

  String _describe(Object e) =>
      e is ApiException ? e.message : 'Something went wrong. Please try again.';

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = _describe(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    await _run(() async {
      await _auth.requestPasswordReset(email);
      if (mounted) setState(() => _step = _Step.code);
    });
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter the complete 6-digit code.');
      return;
    }
    await _run(() async {
      final token = await _auth.verifyPasswordResetCode(
        email: _emailController.text.trim(),
        code: code,
      );
      if (mounted) {
        setState(() {
          _resetToken = token;
          _step = _Step.password;
        });
      }
    });
  }

  Future<void> _submitPassword() async {
    final password = _passwordController.text;
    final problem = validateNewPassword(password);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    if (password != _confirmController.text) {
      setState(() => _error = 'The two passwords do not match.');
      return;
    }

    await _run(() async {
      await _auth.resetPassword(resetToken: _resetToken!, password: password);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset — log in with your new password'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.green,
        ),
      );
    });
  }

  void _back() {
    setState(() {
      _error = null;
      _step = switch (_step) {
        _Step.password => _Step.code,
        _Step.code => _Step.email,
        _Step.email => _Step.email,
      };
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
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _busy
                        ? null
                        : _step == _Step.email
                        ? () => Navigator.pop(context)
                        : _back,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: Text(_step == _Step.email ? 'Log In' : 'Back'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.mutedText,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.green, AppTheme.primaryLight],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.green.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(_stepIcon, color: Colors.white, size: 34),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.greenDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: AppTheme.mutedText,
                  ),
                ),
                const SizedBox(height: 28),
                _StepDots(step: _step),
                const SizedBox(height: 24),
                ..._fields(),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(message: _error!),
                ],
                const SizedBox(height: 26),
                SmartCanteenButton(
                  label: _busy ? 'Please wait…' : _actionLabel,
                  onPressed: _busy ? null : _onAction,
                  gradient: const LinearGradient(
                    colors: [AppTheme.green, AppTheme.primaryLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                if (_step == _Step.code) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _busy ? null : _sendCode,
                    child: const Text(
                      'Didn\'t get it? Send another code',
                      style: TextStyle(fontSize: 12.5, color: AppTheme.green),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData get _stepIcon => switch (_step) {
    _Step.email => Icons.mail_outline_rounded,
    _Step.code => Icons.mark_email_read_outlined,
    _Step.password => Icons.lock_reset_rounded,
  };

  String get _title => switch (_step) {
    _Step.email => 'Forgot password?',
    _Step.code => 'Check your email',
    _Step.password => 'Set a new password',
  };

  String get _subtitle => switch (_step) {
    _Step.email =>
      'Enter your email and we\'ll send you a 6-digit code to reset your password.',
    _Step.code =>
      'We sent a 6-digit code to ${_emailController.text.trim()}. It expires in 15 minutes.',
    _Step.password =>
      'Choose a new password. This signs you out everywhere else.',
  };

  String get _actionLabel => switch (_step) {
    _Step.email => 'Send Code',
    _Step.code => 'Verify Code',
    _Step.password => 'Reset Password',
  };

  VoidCallback get _onAction => switch (_step) {
    _Step.email => _sendCode,
    _Step.code => _verifyCode,
    _Step.password => _submitPassword,
  };

  List<Widget> _fields() {
    switch (_step) {
      case _Step.email:
        return [
          SmartCanteenTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(
              Icons.mail_outline_rounded,
              color: AppTheme.green,
              size: 20,
            ),
          ),
        ];
      case _Step.code:
        return [
          SmartCanteenTextField(
            controller: _codeController,
            label: 'Reset Code',
            hintText: '6-digit code',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(
              Icons.pin_outlined,
              color: AppTheme.green,
              size: 20,
            ),
          ),
        ];
      case _Step.password:
        return [
          SmartCanteenTextField(
            controller: _passwordController,
            label: 'New Password',
            hintText: 'At least 8 characters',
            obscureText: _obscure,
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: AppTheme.green,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AppTheme.mutedText,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
              tooltip: _obscure ? 'Show password' : 'Hide password',
            ),
          ),
          const SizedBox(height: 18),
          SmartCanteenTextField(
            controller: _confirmController,
            label: 'Confirm Password',
            hintText: 'Re-enter your password',
            obscureText: _obscure,
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: AppTheme.green,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Use at least 8 characters with an uppercase letter, a lowercase '
            'letter, and a number.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color: AppTheme.mutedText,
            ),
          ),
        ];
    }
  }
}

/// Three dots showing progress through the reset steps.
class _StepDots extends StatelessWidget {
  const _StepDots({required this.step});

  final _Step step;

  @override
  Widget build(BuildContext context) {
    final index = _Step.values.indexOf(step);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_Step.values.length, (i) {
        final done = i <= index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == index ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: done
                ? AppTheme.green
                : AppTheme.green.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
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
