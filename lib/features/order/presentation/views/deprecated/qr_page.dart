import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_colors.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_fonts.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/deprecated/qr_viewfinder.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/meal_coupons_viewmodel.dart';

/// [Deprecated_File]
///  Left over from before refactor

/// Full-screen QR camera scanner.
///
/// Scans QR codes using the device camera and redeems the coupon via
/// [MealCouponsViewModel.fetchActive]. A "Enter Code Manually" text button
/// opens an [AlertDialog] with a text field as a fallback.
class QrPage extends StatefulWidget {
  const QrPage({super.key});

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  late final MobileScannerController _scannerCtrl;
  bool _torchOn = false;
  bool _detected = false;

  @override
  void initState() {
    super.initState();
    _scannerCtrl = MobileScannerController(
      torchEnabled: false,
      formats: const [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _scannerCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detected) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    _detected = true;
    AppLogger.i('QR code detected: $raw');
    _handleCode(raw);
  }

  Future<void> _handleCode(String code) async {
    await _scannerCtrl.stop();
    if (!mounted) return;

    final vm = context.read<MealCouponsViewModel>();
    await vm.fetchActive();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.secondary,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'Code redeemed successfully',
          style: AppFonts.heading4.copyWith(color: AppColors.onPrimary),
        ),
      ),
    );

    // Resume scanning for next code.
    _detected = false;
    await _scannerCtrl.start();
  }

  Future<void> _toggleTorch() async {
    await _scannerCtrl.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  void _showManualEntry() {
    showDialog<void>(
      context: context,
      builder: (ctx) => _ManualEntryDialog(
        onSubmit: (code) {
          Navigator.pop(ctx);
          if (code.trim().isNotEmpty) {
            _handleCode(code.trim());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Scan QR',
          style: AppFonts.heading1.copyWith(color: AppColors.onPrimary),
        ),
        actions: [
          _TorchButton(torchOn: _torchOn, onTap: _toggleTorch),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _scannerCtrl, onDetect: _onDetect),
          const QrViewfinder(),
          _ScannerInstructions(),
          _ManualEntryButton(onTap: _showManualEntry),
        ],
      ),
    );
  }
}

// Torch toggle button (top-right of AppBar)

class _TorchButton extends StatelessWidget {
  const _TorchButton({required this.torchOn, required this.onTap});

  final bool torchOn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: torchOn
              ? AppColors.warning
              : AppColors.onPrimary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          color: torchOn ? Colors.black : AppColors.onPrimary,
          size: 20,
        ),
      ),
    );
  }
}

// Instructional text below the viewfinder

class _ScannerInstructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, 0.45),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          'Point your camera at the canteen QR code to redeem your meal ticket',
          textAlign: TextAlign.center,
          style: AppFonts.heading4.copyWith(
            color: AppColors.onPrimary.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

// "Enter Code Manually" text button pinned above the bottom safe area

class _ManualEntryButton extends StatelessWidget {
  const _ManualEntryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPadding + 24,
      child: Center(
        child: TextButton(
          onPressed: onTap,
          child: Text(
            'Enter Code Manually',
            style: AppFonts.heading3.copyWith(
              color: AppColors.primaryLight,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

// Manual-entry AlertDialog

class _ManualEntryDialog extends StatefulWidget {
  const _ManualEntryDialog({required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Enter QR Code',
        style: AppFonts.heading2.copyWith(color: AppColors.text),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => widget.onSubmit(_controller.text),
        style: AppFonts.heading3.copyWith(color: AppColors.text),
        decoration: InputDecoration(
          hintText: 'Paste or type your code here',
          hintStyle: AppFonts.heading3.copyWith(color: AppColors.mutedText),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppFonts.heading3.copyWith(color: AppColors.mutedText),
          ),
        ),
        TextButton(
          onPressed: () => widget.onSubmit(_controller.text),
          child: Text(
            'Redeem',
            style: AppFonts.heading3.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
