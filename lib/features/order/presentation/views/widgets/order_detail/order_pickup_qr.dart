import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/core/widgets/qr_code_view.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order_status.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/order_detail_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/order_history_viewmodel.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// The order's pickup QR with a "Download" button that saves it to the photo
/// library. Which state to show is decided by
/// [OrderDetailViewModel.qrState]; this widget only renders it.
class OrderPickupQr extends StatefulWidget {
  const OrderPickupQr({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderPickupQr> createState() => _OrderPickupQrState();
}

class _OrderPickupQrState extends State<OrderPickupQr> {
  // Marks the white QR card, so Download saves exactly what the canteen scans.
  final _qrKey = GlobalKey();

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      if (!await Gal.hasAccess()) await Gal.requestAccess();
      await Gal.putImageBytes(
        png!.buffer.asUint8List(),
        name: 'order_${widget.orderId}',
      );
      messenger.showSnackBar(SnackBar(content: Text(l10n.orderDetailSaved)));
    } catch (e, s) {
      AppLogger.e('Saving pickup QR failed', e, s);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.orderDetailSaveFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Consumer<OrderDetailViewModel>(
        builder: (context, vm, _) {
          final listStatus = context
              .select<OrderHistoryViewModel, OrderStatus?>(
                (h) => h.orderById(widget.orderId)?.status,
              );
          return switch (vm.qrState(listStatus)) {
            PickupQrState.available => _QrWithActions(
              qrKey: _qrKey,
              token: vm.pickup!.pickupQrToken!,
              onSave: _save,
            ),
            PickupQrState.loading => const SizedBox(
              height: 252,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            final state => _QrMessage(
              state: state,
              onRetry: () => vm.loadPickup(widget.orderId),
            ),
          };
        },
      ),
    );
  }
}

class _QrWithActions extends StatelessWidget {
  const _QrWithActions({
    required this.qrKey,
    required this.token,
    required this.onSave,
  });

  final GlobalKey qrKey;
  final String token;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        RepaintBoundary(
          key: qrKey,
          child: Container(
            color: AppColors.card,
            padding: const EdgeInsets.all(8),
            child: QrCodeView(data: token, size: 236),
          ),
        ),
        const SizedBox(height: 16),
        const _ScanCaption(),
        const SizedBox(height: 20),
        Material(
          color: AppColors.primary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onSave,
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Icon(
                Icons.download_rounded,
                size: 18,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.orderDetailDownload,
          style: AppFonts.heading5.copyWith(color: context.textColor),
        ),
      ],
    );
  }
}

/// "Smart Canteen | Scan and enjoy the meals" under the QR.
class _ScanCaption extends StatelessWidget {
  const _ScanCaption();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final style = AppFonts.heading5.copyWith(
      fontWeight: AppFonts.regular,
      color: context.textColor,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.restaurant_rounded, size: 14, color: context.textColor),
        const SizedBox(width: 4),
        Text(l10n.appTitle, style: style),
        Container(
          width: 1,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: context.textColor,
        ),
        Flexible(child: Text(l10n.orderDetailScanCaption, style: style)),
      ],
    );
  }
}

/// Stands in for the QR when there is none to show: not paid yet, picked up,
/// cancelled, or the fetch failed (with a retry).
class _QrMessage extends StatelessWidget {
  const _QrMessage({required this.state, required this.onRetry});

  final PickupQrState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (icon, message) = switch (state) {
      PickupQrState.cancelled => (
        Icons.cancel_outlined,
        l10n.orderDetailQrCancelled,
      ),
      PickupQrState.pickedUp => (
        Icons.check_circle_outline_rounded,
        l10n.orderDetailQrPickedUp,
      ),
      PickupQrState.preparing => (
        Icons.soup_kitchen_outlined,
        l10n.orderDetailQrPreparing,
      ),
      PickupQrState.error => (
        Icons.cloud_off_rounded,
        l10n.orderDetailErrorTitle,
      ),
      _ => (Icons.hourglass_empty_rounded, l10n.orderDetailQrPending),
    };

    return SizedBox(
      height: 252,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: context.mutedColor),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppFonts.heading3.copyWith(color: context.mutedColor),
          ),
          if (state == PickupQrState.error)
            TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
        ],
      ),
    );
  }
}
