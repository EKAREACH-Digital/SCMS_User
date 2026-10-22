import 'dart:async';

import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// "Send another code" link with the backend's 60 s resend cooldown counted
/// down on it. Starts counting on open, since the code was just sent.
class ResendCodeButton extends StatefulWidget {
  const ResendCodeButton({super.key, required this.onResend});

  /// Sends a new code; returns true when it went out (restarting the wait).
  final Future<bool> Function() onResend;

  @override
  State<ResendCodeButton> createState() => _ResendCodeButtonState();
}

class _ResendCodeButtonState extends State<ResendCodeButton> {
  static const _cooldown = 60;

  Timer? _timer;
  int _secondsLeft = _cooldown;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _cooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  Future<void> _resend() async {
    setState(() => _sending = true);
    final sent = await widget.onResend();
    if (!mounted) return;
    setState(() => _sending = false);
    if (sent) _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final waiting = _secondsLeft > 0;

    return RepaintBoundary(
      child: TextButton(
        onPressed: waiting || _sending ? null : _resend,
        child: Text(
          waiting ? l10n.authResendIn(_secondsLeft) : l10n.authResendCode,
          style: AppFonts.heading3.copyWith(
            color: waiting ? AppColors.mutedText : AppColors.primary,
            fontWeight: AppFonts.semiBold,
          ),
        ),
      ),
    );
  }
}
