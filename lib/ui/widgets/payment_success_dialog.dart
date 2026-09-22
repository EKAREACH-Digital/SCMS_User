import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import 'smart_canteen_button.dart';

enum _Phase { processing, success }

/// Payment result modal. Opens in a *processing* phase (wallet icon +
/// spinner) and, after [processingDuration], transitions in-place to a
/// *success* phase (scale-in checkmark, glow, sparkles). The card keeps a
/// single compact size and animates height changes smoothly.
///
/// Closes on the Continue button or automatically [autoDismiss] after success;
/// [onDismiss] runs exactly once when it closes.
class PaymentSuccessDialog extends StatefulWidget {
  const PaymentSuccessDialog({
    super.key,
    required this.onDismiss,
    this.amount,
    this.title = 'Payment Successful!',
    this.message = 'Your order has been added to history.',
    this.buttonLabel = 'Continue',
    this.processingDuration = const Duration(seconds: 3),
    this.autoDismiss = const Duration(milliseconds: 3500),
  });

  final VoidCallback onDismiss;

  /// Amount shown in the processing text, e.g. "Processing $5.00…".
  final double? amount;
  final String title;
  final String message;
  final String buttonLabel;
  final Duration processingDuration;
  final Duration autoDismiss;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onDismiss,
    double? amount,
    String title = 'Payment Successful!',
    String message = 'Your order has been added to history.',
    String buttonLabel = 'Continue',
    Duration processingDuration = const Duration(seconds: 3),
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentSuccessDialog(
        onDismiss: onDismiss,
        amount: amount,
        title: title,
        message: message,
        buttonLabel: buttonLabel,
        processingDuration: processingDuration,
      ),
    );
  }

  @override
  State<PaymentSuccessDialog> createState() => _PaymentSuccessDialogState();
}

class _PaymentSuccessDialogState extends State<PaymentSuccessDialog>
    with TickerProviderStateMixin {
  late final AnimationController _entryController; // checkmark scale + sparkles
  late final AnimationController _glowController; // continuous soft glow pulse
  late final Animation<double> _circleScale;
  late final Animation<double> _checkScale;
  late final Animation<double> _contentFade;

  _Phase _phase = _Phase.processing;
  Timer? _processingTimer;
  Timer? _autoTimer;
  bool _closed = false;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeInOut),
      ),
    );
    _contentFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.45, 1.0, curve: Curves.easeInOut),
    );

    if (widget.processingDuration == Duration.zero) {
      // Caller already showed a processing step — open straight to success.
      _phase = _Phase.success;
      _entryController.forward();
      HapticFeedback.mediumImpact();
      _autoTimer = Timer(widget.autoDismiss, _close);
    } else {
      // Simulate payment processing, then reveal success.
      _processingTimer = Timer(widget.processingDuration, _toSuccess);
    }
  }

  void _toSuccess() {
    if (!mounted) return;
    setState(() => _phase = _Phase.success);
    _entryController.forward();
    HapticFeedback.mediumImpact();
    _autoTimer = Timer(widget.autoDismiss, _close);
  }

  @override
  void dispose() {
    _processingTimer?.cancel();
    _autoTimer?.cancel();
    _entryController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _close() {
    if (_closed) return;
    _closed = true;
    _processingTimer?.cancel();
    _autoTimer?.cancel();
    if (mounted) Navigator.of(context).pop();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = _phase == _Phase.success;
    return Dialog(
      backgroundColor: context.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        // Smoothly grow/shrink as the button appears in the success phase.
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon area: spinner ↔ checkmark ──────────────────────────
              SizedBox(
                width: 110,
                height: 110,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: isSuccess
                      ? _buildSuccessIcon()
                      : const _ProcessingIcon(key: ValueKey('processing')),
                ),
              ),
              const SizedBox(height: 16),
              // ── Text + button: crossfade between phases ─────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: isSuccess ? _buildSuccessText() : _buildProcessingText(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Processing phase ──────────────────────────────────────────────────────

  Widget _buildProcessingText() {
    final amountLabel = widget.amount != null
        ? 'Processing \$${widget.amount!.toStringAsFixed(2)}…'
        : 'Processing payment…';
    return Column(
      key: const ValueKey('processing-text'),
      children: [
        Text(
          amountLabel,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.greenDark,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please wait a moment.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.mutedColor,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Success phase ─────────────────────────────────────────────────────────

  Widget _buildSuccessIcon() {
    return AnimatedBuilder(
      key: const ValueKey('success'),
      animation: Listenable.merge([_entryController, _glowController]),
      builder: (context, _) {
        final glow = Curves.easeInOut.transform(_glowController.value);
        return Stack(
          alignment: Alignment.center,
          children: [
            ..._buildSparkles(),
            Transform.scale(
              scale: _circleScale.value.clamp(0.0, 1.2),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.success.withValues(
                        alpha: 0.30 + 0.25 * glow,
                      ),
                      blurRadius: 16 + 14 * glow,
                      spreadRadius: 1 + 2 * glow,
                    ),
                  ],
                ),
                child: Transform.scale(
                  scale: _checkScale.value.clamp(0.0, 1.0),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuccessText() {
    return FadeTransition(
      key: const ValueKey('success-text'),
      opacity: _contentFade,
      child: Column(
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.greenDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.mutedColor,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SmartCanteenButton(
            label: widget.buttonLabel,
            height: 52,
            gradient: const LinearGradient(
              colors: [AppTheme.tertiaryLight, AppTheme.tertiaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onPressed: _close,
          ),
        ],
      ),
    );
  }

  /// Six small sparkles that fan out and fade as the checkmark settles.
  List<Widget> _buildSparkles() {
    const count = 6;
    final t = Curves.easeInOut.transform(_entryController.value);
    return List.generate(count, (i) {
      final angle = (2 * math.pi / count) * i - math.pi / 2;
      final distance = 30.0 + 18.0 * t;
      final dx = math.cos(angle) * distance;
      final dy = math.sin(angle) * distance;
      final appear = (t * 1.6).clamp(0.0, 1.0);
      final fade = (1.0 - (t - 0.55).clamp(0.0, 0.45) / 0.45);
      return Transform.translate(
        offset: Offset(dx, dy),
        child: Opacity(
          opacity: (appear * fade).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.5 + 0.5 * appear,
            child: Icon(
              i.isEven ? Icons.star_rounded : Icons.auto_awesome_rounded,
              size: i.isEven ? 12 : 10,
              color: AppTheme.success.withValues(alpha: 0.8),
            ),
          ),
        ),
      );
    });
  }
}

// ── Processing spinner with wallet icon ──────────────────────────────────────

class _ProcessingIcon extends StatelessWidget {
  const _ProcessingIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 72,
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.success,
                ),
                backgroundColor: AppTheme.success.withValues(alpha: 0.12),
              ),
            ),
            const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppTheme.success,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
