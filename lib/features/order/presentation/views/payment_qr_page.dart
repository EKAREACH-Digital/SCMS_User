import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/widgets/dialog/message_dialog.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/cart_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/order_placement_viewmodel.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Shows the payment QR after checkout and polls for confirmation.
///
/// [order] is the [PlacedOrder] returned by `POST /orders/checkout`.
/// For CutLuy: [PlacedOrder.qrImage] is an SVG URL rendered with
/// [SvgPicture.network]. For ABA PayWay: it is a
/// `data:image/png;base64,...` string rendered with [Image.memory].
class PaymentQrPage extends StatefulWidget {
  const PaymentQrPage({super.key, required this.order});

  final PlacedOrder order;

  @override
  State<PaymentQrPage> createState() => _PaymentQrPageState();
}

class _PaymentQrPageState extends State<PaymentQrPage> {
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;
  late OrderPlacementViewModel _vm;

  /// Prevents the `paid` branch from firing more than once across rebuilds.
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache while context is still active — used in dispose() where context
    // is no longer safe to read from.
    _vm = context.read<OrderPlacementViewModel>();
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    final expires = widget.order.expiresAt ??
        // Backend did not return expires_at — cap at 3 min for safety.
        DateTime.now().add(const Duration(minutes: 3));
    _remaining = expires.difference(DateTime.now());
    if (_remaining.isNegative) _remaining = Duration.zero;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final next = _remaining - const Duration(seconds: 1);
      setState(() => _remaining = next.isNegative ? Duration.zero : next);
    });
  }

  /// Prompts the user before leaving — stops polling only if confirmed.
  Future<void> _confirmQuit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    // Capture before the async gap to satisfy use_build_context_synchronously.
    final vm = context.read<OrderPlacementViewModel>();
    final router = GoRouter.of(context);
    final confirmed = await showConfirmDialog(
      context,
      type: MessageDialogType.warning,
      title: l10n.paymentQuitTitle,
      message: l10n.paymentQuitBody,
      confirmLabel: l10n.paymentQuitConfirm,
      cancelLabel: l10n.commonCancel,
    );
    if (confirmed && mounted) {
      vm.reset();
      router.pop();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    // Safety net: stops polling for programmatic exits that bypass _confirmQuit
    // (e.g. session expiry redirect, deep link navigation).
    // cancelPolling() only cancels the timer — no notifyListeners() call,
    // so it is safe during Flutter's lockState/unmount phase.
    _vm.cancelPolling();
    super.dispose();
  }

  String get _countdownLabel {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _openDeeplink() async {
    final url = widget.order.isCutluy
        ? widget.order.checkoutUrl
        : widget.order.deeplink ?? widget.order.checkoutUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the payment app.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderPlacementViewModel>(
      builder: (context, vm, _) {
        // Push to the success page once — guard prevents duplicate triggers
        // across Consumer rebuilds.
        if (vm.state == OrderPlacementState.paid && !_navigated) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.read<CartViewModel>().clear();
            vm.reset();
            context.push(AppPaths.paymentSuccess);
          });
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            _confirmQuit(context);
          },
          child: Scaffold(
          backgroundColor: context.bgColor,
          appBar: AppBar(
            backgroundColor: context.bgColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, size: 22),
              onPressed: () => _confirmQuit(context),
            ),
            title: Text(
              'Payment',
              style: AppFonts.heading2.copyWith(color: context.textColor),
            ),
          ),
          body: switch (vm.state) {
            OrderPlacementState.cancelled => _CancelledState(
              onRetry: () {
                vm.reset();
                context.pop();
              },
            ),
            _ => _QrBody(
              order: widget.order,
              countdownLabel: _countdownLabel,
              isExpired: _remaining == Duration.zero,
              onOpenApp: _openDeeplink,
            ),
          },
          ),
        );
      },
    );
  }
}

// QR display with amount, countdown, and open-in-app button

class _QrBody extends StatelessWidget {
  const _QrBody({
    required this.order,
    required this.countdownLabel,
    required this.isExpired,
    required this.onOpenApp,
  });

  final PlacedOrder order;
  final String countdownLabel;
  final bool isExpired;
  final VoidCallback onOpenApp;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Scan to pay',
            style: AppFonts.heading2.copyWith(
              color: context.textColor,
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.isCutluy ? 'Any Cambodian bank app' : 'ABA Mobile',
            style: AppFonts.heading4.copyWith(color: context.mutedColor),
          ),
          const SizedBox(height: 24),
          _QrImage(order: order, isExpired: isExpired),
          const SizedBox(height: 20),
          _CountdownBadge(label: countdownLabel, isExpired: isExpired),
          const SizedBox(height: 24),
          _AmountRow(amount: order.totalAmount),
          const SizedBox(height: 32),
          _OpenAppButton(order: order, onTap: onOpenApp),
          const SizedBox(height: 16),
          Consumer<OrderPlacementViewModel>(
            builder: (context, vm, child) => vm.state == OrderPlacementState.awaitingPayment
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Waiting for payment…',
                        style: AppFonts.heading4.copyWith(
                          color: context.mutedColor,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// QR image: SVG URL (CutLuy) or base64 PNG (ABA PayWay)

class _QrImage extends StatelessWidget {
  const _QrImage({required this.order, required this.isExpired});

  final PlacedOrder order;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final qr = order.isCutluy
        ? _SvgQr(url: order.qrImage)
        : _Base64QR(data: order.qrImage);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.onPrimary,
            borderRadius: BorderRadius.circular(16),
            // boxShadow: [
            //   BoxShadow(
            //     color: AppColors.primary.withValues(alpha: 0.08),
            //     blurRadius: 20,
            //     offset: const Offset(0, 4),
            //   ),
            // ],
          ),
          padding: const EdgeInsets.all(16),
          child: qr,
        ),
        if (isExpired)
          Container(
            width: 248,
            height: 248,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_off_rounded, color: AppColors.onPrimary, size: 36),
                const SizedBox(height: 8),
                Text(
                  'QR Expired',
                  style: AppFonts.heading3.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SvgQr extends StatelessWidget {
  const _SvgQr({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      url,
      width: 416,
      height: 416,
      placeholderBuilder: (_) => const SizedBox(
        width: 416,
        height: 416,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }
}

/// Decodes the base64 bytes once in [initState] so [Image.memory] always
/// receives the same [Uint8List] reference — prevents a flicker on every
/// countdown tick that would occur if decoding happened inside [build].
class _Base64QR extends StatefulWidget {
  const _Base64QR({required this.data});

  final String data;

  @override
  State<_Base64QR> createState() => _Base64QRState();
}

class _Base64QRState extends State<_Base64QR> {
  late final Uint8List _bytes;

  @override
  void initState() {
    super.initState();
    // ABA PayWay returns `data:image/png;base64,<bytes>`.
    final raw = widget.data;
    _bytes = base64Decode(raw.contains(',') ? raw.split(',').last : raw);
  }

  @override
  Widget build(BuildContext context) {
    return Image.memory(_bytes, width: 216, height: 216, fit: BoxFit.contain);
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.label, required this.isExpired});

  final String label;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      // decoration: BoxDecoration(
      //   color: isExpired
      //       ? AppColors.accentRed.withValues(alpha: 0.1)
      //       : AppColors.primary.withValues(alpha: 0.08),
      //   borderRadius: BorderRadius.circular(20),
      // ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: isExpired ? AppColors.accentRed : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            isExpired ? 'Expired' : 'Expires in $label',
            style: AppFonts.heading4.copyWith(
              color: isExpired ? AppColors.accentRed : AppColors.primary,
              fontWeight: AppFonts.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Total: ',
          style: AppFonts.heading3.copyWith(color: context.mutedColor),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: AppFonts.heading2.copyWith(
            color: AppColors.primary,
            fontWeight: AppFonts.bold,
          ),
        ),
      ],
    );
  }
}

class _OpenAppButton extends StatelessWidget {
  const _OpenAppButton({required this.order, required this.onTap});

  final PlacedOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Only show when there's a URL to open.
    final hasLink = order.deeplink != null || order.checkoutUrl != null;
    if (!hasLink) return const SizedBox.shrink();

    final label = order.isCutluy ? 'Pay on CutLuy' : 'Open ABA Mobile';

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.open_in_new_rounded, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: AppFonts.heading3.copyWith(fontWeight: AppFonts.medium),
        ),
      ),
    );
  }
}

// Cancelled state: QR expired, stock released

class _CancelledState extends StatelessWidget {
  const _CancelledState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cancel_outlined,
              size: 64,
              color: AppColors.accentRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Order Cancelled',
              style: AppFonts.heading2.copyWith(
                color: context.textColor,
                fontWeight: AppFonts.semiBold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The QR expired and your order was cancelled. Stock has been released.',
              textAlign: TextAlign.center,
              style: AppFonts.heading3.copyWith(color: context.mutedColor),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: AppFonts.heading3.copyWith(
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
