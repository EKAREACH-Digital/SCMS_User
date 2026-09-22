import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/dtos/payment_dto.dart';
import '../../../data/exceptions/api_exception.dart';
import '../../../data/repositories/payment/payment_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../states/balance_state.dart';

/// Gateway-backed wallet top-up.
///
/// Flow: ask our backend to open a payment session → show the KHQR (and an
/// "open ABA" shortcut for same-device payment) → poll until the backend says
/// it's paid → refresh the wallet balance.
///
/// Confirmation is poll-driven because the gateway's callback can't reach a
/// local dev backend. In production both paths run; the backend settles once.
class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  static const routeName = '/top-up';

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

/// [_Stage.amount] is only reached when the screen is opened without a chosen
/// amount, or when starting a payment failed. The normal path in — from the
/// wallet sheet, which has already asked for an amount — skips straight to
/// [_Stage.preparing] so the user isn't asked the same question twice.
enum _Stage { amount, preparing, waiting, paid, failed }

class _TopUpScreenState extends State<TopUpScreen> with WidgetsBindingObserver {
  static const _pollInterval = Duration(seconds: 3);

  /// Matches the gateway's QR lifetime; after this we stop polling and tell
  /// the user to start again rather than spinning forever.
  static const _pollTimeout = Duration(minutes: 15);

  final _amountController = TextEditingController(text: '5.00');

  /// Set once from the route argument, when the user already picked an amount
  /// on the wallet sheet before choosing ABA.
  bool _amountPrefilled = false;

  _Stage _stage = _Stage.amount;
  TopupSessionDto? _session;
  Timer? _pollTimer;
  DateTime? _startedAt;
  bool _starting = false;
  bool _checking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_amountPrefilled) return;
    _amountPrefilled = true;

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is! num || arg <= 0) return;

    // The amount was already chosen upstream — open the payment session
    // immediately rather than showing a second amount form.
    _amountController.text = arg.toDouble().toStringAsFixed(2);
    _stage = _Stage.preparing;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _start();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  /// Returning from the banking app is the strongest signal that something
  /// changed — check immediately rather than waiting for the next tick.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _stage == _Stage.waiting) {
      _checkOnce();
    }
  }

  Future<void> _start() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() {
        _stage = _Stage.amount;
        _error = l10n.topupInvalidAmount;
      });
      return;
    }

    setState(() {
      _starting = true;
      _error = null;
    });

    try {
      final session = await context.read<PaymentRepository>().startTopUp(
        amount,
      );
      if (!mounted) return;
      setState(() {
        _session = session;
        _stage = _Stage.waiting;
        _starting = false;
        _startedAt = DateTime.now();
      });
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(_pollInterval, (_) => _checkOnce());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _starting = false;
        // Surface it as a terminal failure with a retry, rather than dropping
        // the user onto an amount form they already filled in upstream.
        _stage = _Stage.failed;
        _error = e is ApiException ? e.message : l10n.topupStartError;
      });
    }
  }

  Future<void> _openAba() async {
    final session = _session;
    if (session == null || session.abapayDeeplink.isEmpty) return;
    HapticFeedback.selectionClick();

    final uri = Uri.parse(session.abapayDeeplink);
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        setState(() => _error = AppLocalizations.of(context)!.topupAbaNotFound);
      }
    } on PlatformException {
      // No handler for the abamobilebank:// scheme on this device.
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context)!.topupAbaNotFound);
      }
    }
  }

  Future<void> _checkOnce() async {
    final session = _session;
    if (session == null || _checking || _stage != _Stage.waiting) return;

    final startedAt = _startedAt;
    if (startedAt != null &&
        DateTime.now().difference(startedAt) > _pollTimeout) {
      _pollTimer?.cancel();
      if (mounted) {
        setState(() {
          _stage = _Stage.failed;
          _error = AppLocalizations.of(context)!.topupExpired;
        });
      }
      return;
    }

    _checking = true;
    try {
      final status = await context.read<PaymentRepository>().checkStatus(
        session.tranId,
      );
      if (!mounted) return;

      if (status == TopupStatus.paid) {
        _pollTimer?.cancel();
        setState(() => _stage = _Stage.paid);
        // The balance shown elsewhere in the app is now stale.
        unawaited(context.read<BalanceState>().fetchBalance());
      } else if (status == TopupStatus.failed) {
        _pollTimer?.cancel();
        setState(() {
          _stage = _Stage.failed;
          _error = AppLocalizations.of(context)!.topupFailed;
        });
      }
    } catch (_) {
      // A dropped poll is not fatal — the next tick tries again.
    } finally {
      _checking = false;
    }
  }

  /// Abandons the current attempt. The pending transaction is left alone — the
  /// gateway expires it on its own after the QR lifetime, and nothing was
  /// charged, so there is no state to unwind on our side.
  void _cancel() {
    _pollTimer?.cancel();
    setState(() {
      _stage = _Stage.failed;
      _session = null;
      _error = AppLocalizations.of(context)!.topupCancelledBody;
    });
  }

  /// Starts a fresh payment for the same amount.
  void _retry() {
    setState(() {
      _stage = _Stage.preparing;
      _session = null;
      _error = null;
    });
    _start();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.topupTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: switch (_stage) {
            _Stage.amount => _AmountForm(
              controller: _amountController,
              busy: _starting,
              error: _error,
              onSubmit: _start,
            ),
            _Stage.preparing => _PreparingView(
              amountUsd: double.tryParse(_amountController.text) ?? 0,
            ),
            _Stage.waiting => _WaitingView(
              session: _session!,
              error: _error,
              onOpenAba: _openAba,
              onCancel: _cancel,
            ),
            _Stage.failed => _FailedView(
              message: _error ?? '',
              onRetry: _retry,
              onBack: () => Navigator.of(context).pop(false),
            ),
            _Stage.paid => _PaidView(
              amountUsd: _session?.amountUsd ?? 0,
              onDone: () => Navigator.of(context).pop(true),
            ),
          },
        ),
      ),
    );
  }
}

// ── Amount entry ───────────────────────────────────────────────────────────

class _AmountForm extends StatelessWidget {
  const _AmountForm({
    required this.controller,
    required this.busy,
    required this.error,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool busy;
  final String? error;
  final VoidCallback onSubmit;

  static const _presets = [1.0, 5.0, 10.0, 20.0];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.topupAmountLabel,
            prefixText: '\$ ',
            border: const OutlineInputBorder(),
            errorText: error,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            for (final amount in _presets)
              ActionChip(
                label: Text('\$${amount.toStringAsFixed(0)}'),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  controller.text = amount.toStringAsFixed(2);
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: busy ? null : onSubmit,
          child: busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.topupPayWithAba),
        ),
      ],
    );
  }
}

// ── Opening the payment session ────────────────────────────────────────────

/// Bridges the gap between arriving with a chosen amount and the QR coming
/// back from the gateway — typically under a second, but it needs to show the
/// amount so the user can confirm they're paying what they picked.
class _PreparingView extends StatelessWidget {
  const _PreparingView({required this.amountUsd});

  final double amountUsd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Text(
            '\$${amountUsd.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 28),
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.topupPreparing,
            style: TextStyle(fontSize: 13.5, color: context.mutedColor),
          ),
        ],
      ),
    );
  }
}

// ── Waiting for payment ────────────────────────────────────────────────────

class _WaitingView extends StatelessWidget {
  const _WaitingView({
    required this.session,
    required this.error,
    required this.onOpenAba,
    required this.onCancel,
  });

  final TopupSessionDto session;
  final String? error;
  final VoidCallback onOpenAba;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '\$${session.amountUsd.toStringAsFixed(2)}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        // Rendered from qrString rather than the gateway's PNG so it matches
        // the app's own look and stays crisp at any size.
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: QrImageView(
              data: session.qrString,
              size: 220,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.topupScanHint,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: context.mutedColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: onOpenAba,
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: Text(l10n.topupOpenAba),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 14),
          Text(
            error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFFE53935)),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.topupWaiting,
              style: TextStyle(fontSize: 13.5, color: context.mutedColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onCancel, child: Text(l10n.topupCancel)),
      ],
    );
  }
}

// ── Cancelled / failed ─────────────────────────────────────────────────────

/// Terminal state for a payment that didn't complete — cancelled, declined, or
/// expired. Deliberately explicit that no money moved, since an ambiguous exit
/// from a payment screen is exactly where users worry they've been charged.
class _FailedView extends StatelessWidget {
  const _FailedView({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  static const _kRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: _kRed.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_rounded, color: _kRed, size: 48),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.topupNotCompletedTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: context.textColor,
          ),
        ),
        if (message.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.mutedColor,
              height: 1.5,
            ),
          ),
        ],
        const SizedBox(height: 32),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: onRetry,
          child: Text(l10n.topupTryAgain),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onBack, child: Text(l10n.topupBackToWallet)),
      ],
    );
  }
}

// ── Success ────────────────────────────────────────────────────────────────

class _PaidView extends StatelessWidget {
  const _PaidView({required this.amountUsd, required this.onDone});

  final double amountUsd;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.success,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.topupSuccessTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.topupSuccessBody('\$${amountUsd.toStringAsFixed(2)}'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: context.mutedColor),
        ),
        const SizedBox(height: 32),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: onDone,
          child: Text(l10n.topupDone),
        ),
      ],
    );
  }
}
