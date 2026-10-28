import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_colors.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_fonts.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/features/pickup/domain/entities/pickup_checkin.dart';
import 'package:smart_canteen_user_frontend/features/pickup/presentation/viewmodels/pickup_scan_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/pickup/presentation/views/widgets/checkin_result_panel.dart';
import 'package:smart_canteen_user_frontend/features/pickup/presentation/views/widgets/scanner_overlay.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Camera scanner page for checking in at a pickup counter stand.
///
/// The student scans the QR on the stand, or taps "Enter Code" to type the
/// stand code manually in a dialog. Both paths call
/// [PickupScanViewModel.arrive] and show [CheckinResultPanel] as a bottom
/// sheet on success.
///
/// ---
/// ## Camera lifecycle and why the reset works the way it does
///
/// ### How MobileScanner owns the camera
///
/// [MobileScanner] is a [StatefulWidget]. Its internal state holds a reference
/// to the [MobileScannerController] and calls `controller.start()` exactly
/// once — inside `initState`. This is what "auto-start" means: the camera
/// opens when the widget is first inserted into the tree, not on every rebuild.
///
/// When the widget receives a *different* controller via `didUpdateWidget`,
/// it switches its internal reference but does **not** call `start()` again.
/// That means swapping the controller prop on an already-live [MobileScanner]
/// leaves the camera in whatever state the new controller is in — stopped,
/// by default — producing a black screen.
///
/// ### Why the camera goes black after an error
///
/// The scan flow is:
/// ```
/// idle  -->  loading (_scannerCtrl.stop())  -->  error  -->  idle
/// ```
/// During the `loading` step the camera is explicitly stopped. On the `error`
/// transition we reset the ViewModel back to `idle`, but [_CameraArea] never
/// left the widget tree — it was visible throughout. So [MobileScanner] is
/// still alive and only gets `didUpdateWidget` when the controller is swapped,
/// not a fresh `initState`. The camera stays stopped. Black screen.
///
/// This is different from the *success* path: on success, the result is shown
/// in a modal bottom sheet while [_CameraArea] remains in the tree. When the
/// user taps "Scan again", the sheet closes, the ViewModel resets to `idle`,
/// and `_resetCamera` fires a key bump so [MobileScanner] restarts cleanly.
///
/// ### The fix: bump the key to force initState
///
/// Every time the camera needs to restart (both on error recovery and on
/// "Scan again"), [_resetCamera] does two things atomically inside `setState`:
///
/// 1. Creates a brand-new [MobileScannerController] (`_makeController()`).
/// 2. Increments `_cameraKey`.
///
/// `_cameraKey` is passed as `key: ValueKey(_cameraKey)` to [_CameraArea].
/// In Flutter, changing a widget's key tells the framework to throw away the
/// old element and create a brand new one. This means [MobileScanner] inside
/// [_CameraArea] goes through `dispose` → `initState`, and `initState` calls
/// `start()` on the new controller. The camera opens cleanly every time,
/// regardless of which state it was in before.
///
/// ### Why the old controller must be disposed post-frame
///
/// [MobileScannerController] exposes a `ValueListenable<MobileScannerState>`.
/// [MobileScanner] wraps this in a [ValueListenableBuilder] to rebuild its
/// camera preview. Calling `dispose()` on the controller notifies that
/// listenable, which schedules a rebuild of the [ValueListenableBuilder].
/// If the old controller is disposed *synchronously* inside `setState`, that
/// rebuild fires in the same frame — before Flutter has swapped the element
/// for [_CameraArea] — and the [ValueListenableBuilder] calls
/// `controller.buildCameraView()` on an already-disposed controller, throwing
/// `MobileScannerException(controllerDisposed)`.
///
/// Deferring with `WidgetsBinding.instance.addPostFrameCallback` ensures the
/// frame fully commits the new [_CameraArea] element (and its new
/// [MobileScanner] attached to the new controller) before the old controller
/// is disposed. By that point no widget holds a reference to the old
/// controller's listenable, so disposal is silent.
class PickupScanPage extends StatefulWidget {
  const PickupScanPage({super.key});

  @override
  State<PickupScanPage> createState() => _PickupScanPageState();
}

class _PickupScanPageState extends State<PickupScanPage> {
  // Not final — recreated on every "Scan again" so the camera pipeline is fresh.
  late MobileScannerController _scannerCtrl;
  late final TextEditingController _codeCtrl;
  bool _torchOn = false;
  // Incremented each time the camera resets so _CameraArea gets a new key,
  // forcing MobileScanner.initState to run and auto-start the new controller.
  int _cameraKey = 0;
  // Throttles _onDetect to at most one attempt every 6 seconds.
  // Must be longer than the error-restart delay (3 s) so the camera doesn't
  // immediately re-detect the same wrong QR after it restarts.
  DateTime _lastDetection = DateTime(0);

  MobileScannerController _makeController() => MobileScannerController(
    torchEnabled: false,
    formats: const [BarcodeFormat.qrCode],
  );

  @override
  void initState() {
    super.initState();
    _scannerCtrl = _makeController();
    _codeCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PickupScanViewModel>().addListener(_onStateChange);
    });
  }

  @override
  void dispose() {
    context.read<PickupScanViewModel>().removeListener(_onStateChange);
    _scannerCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  // Swaps in a fresh controller and bumps _cameraKey so _CameraArea is
  // replaced entirely. MobileScanner.initState on the new widget auto-starts
  // the controller — no manual start() needed, which avoids the
  // controllerNotAttached race when start() fires before the widget attaches.
  // The old controller is disposed post-frame so its ValueListenable is no
  // longer wired to any widget before it notifies on disposal.
  void _resetCamera() {
    final old = _scannerCtrl;
    setState(() {
      _scannerCtrl = _makeController();
      _cameraKey++;
      _torchOn = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  void _onStateChange() {
    if (!mounted) return;
    final vm = context.read<PickupScanViewModel>();
    switch (vm.state) {
      case PickupScanState.idle:
        break;
      case PickupScanState.loading:
        _scannerCtrl.stop();
      case PickupScanState.success:
        _showResultSheet(vm.checkin!);
      case PickupScanState.error:
        final msg = vm.errorMessage ??
            AppLocalizations.of(context)!.pickupScanErrorUnknown;
        // final msg = AppLocalizations.of(context)!.pickupScanErrorUnknown;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.accentRed,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              msg,
              style: AppFonts.heading4.copyWith(color: AppColors.onPrimary),
            ),
          ),
        );
        // Delay restart by 3 s so the snackbar is visible and the user has time
        // to move the phone away. The detection throttle (6 s) is intentionally
        // longer than this delay so the camera can't re-detect the same QR the
        // moment it restarts.
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          _resetCamera();
          context.read<PickupScanViewModel>().reset();
        });
    }
  }

  void _showResultSheet(PickupCheckin checkin) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CheckinResultPanel(
        checkin: checkin,
        onScanAgain: () {
          // Navigator.pop is allowed here — it closes the modal bottom sheet.
          Navigator.pop(context);
          context.read<PickupScanViewModel>().reset();
          _resetCamera();
        },
      ),
    ).then((_) {
      // Handle sheet dismissed by swipe — reset so the camera accepts new scans.
      if (!mounted) return;
      final vm = context.read<PickupScanViewModel>();
      if (vm.state == PickupScanState.success) {
        vm.reset();
        _resetCamera();
      }
    });
  }

  void _onDetect(BarcodeCapture capture) {
    final now = DateTime.now();
    if (now.difference(_lastDetection) < const Duration(seconds: 6)) return;
    _lastDetection = now;
    final vm = context.read<PickupScanViewModel>();
    if (vm.state != PickupScanState.idle) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    AppLogger.i('Pickup stand QR detected: $raw');
    vm.arrive(raw);
  }

  void _onEnterCode() {
    final l10n = AppLocalizations.of(context)!;
    _codeCtrl.clear();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          l10n.pickupEnterCode,
          style: AppFonts.heading2,
        ),
        content: TextField(
          controller: _codeCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            Navigator.pop(dialogCtx);
            _submitCode();
          },
          style: AppFonts.heading3,
          decoration: InputDecoration(
            hintText: l10n.pickupScanManualHint,
            hintStyle: AppFonts.heading3.copyWith(color: AppColors.grey500),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryLight, width: 1.5),
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _submitCode();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              textStyle: AppFonts.heading3,
            ),
            child: Text(l10n.pickupEnterCodeConfirm),
          ),
        ],
      ),
    );
  }

  void _submitCode() {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    final vm = context.read<PickupScanViewModel>();
    if (vm.state != PickupScanState.idle) return;
    AppLogger.i('Manual pickup stand code submitted: $code');
    _codeCtrl.clear();
    vm.arrive(code);
  }

  Future<void> _toggleTorch() async {
    await _scannerCtrl.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Center(
          child: Text(
            l10n.pickupScanTitle,
            style: AppFonts.heading1.copyWith(color: AppColors.primaryDark),
          ),
        ),
      ),
      body: Consumer<PickupScanViewModel>(
        builder: (ctx, vm, _) {
          return Stack(
            children: [
              // Camera fills the full body behind the controls.
              Positioned.fill(
                child: _CameraArea(
                  key: ValueKey(_cameraKey),
                  controller: _scannerCtrl,
                  onDetect: _onDetect,
                  isLoading: vm.state == PickupScanState.loading,
                ),
              ),
              // Controls float over the camera at the bottom.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BottomControls(
                  subtitle: l10n.pickupScanSubtitle,
                  flashLabel: l10n.pickupFlash,
                  enterCodeLabel: l10n.pickupEnterCode,
                  torchOn: _torchOn,
                  isLoading: vm.state == PickupScanState.loading,
                  onFlash: _toggleTorch,
                  onEnterCode: _onEnterCode,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Camera view with loading overlay and scanner overlay

class _CameraArea extends StatelessWidget {
  const _CameraArea({
    super.key,
    required this.controller,
    required this.onDetect,
    required this.isLoading,
  });

  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(controller: controller, onDetect: onDetect),
        const ScannerOverlay(),
        if (isLoading)
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.55),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.onPrimary),
            ),
          ),
      ],
    );
  }
}

// Bottom controls: subtitle, flash button, and "Enter Code" pill

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.subtitle,
    required this.flashLabel,
    required this.enterCodeLabel,
    required this.torchOn,
    required this.isLoading,
    required this.onFlash,
    required this.onEnterCode,
  });

  final String subtitle;
  final String flashLabel;
  final String enterCodeLabel;
  final bool torchOn;
  final bool isLoading;
  final VoidCallback onFlash;
  final VoidCallback onEnterCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.paddingOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtitle row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu_rounded,
                color: AppColors.onPrimary.withValues(alpha: 0.6),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                subtitle,
                style: AppFonts.heading4.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Flash button
          _FlashButton(torchOn: torchOn, label: flashLabel, onTap: onFlash),
          const SizedBox(height: 50),
          // Enter Code pill button
          FilledButton(
            onPressed: isLoading ? null : onEnterCode,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              textStyle: AppFonts.heading3,
              minimumSize: const Size(double.infinity, 48),
              shape: const StadiumBorder(),
            ),
            child: Text(enterCodeLabel),
          ),
        ],
      ),
    );
  }
}

// Flash toggle button in the body — dark circle with icon and label

class _FlashButton extends StatelessWidget {
  const _FlashButton({
    required this.torchOn,
    required this.label,
    required this.onTap,
  });

  final bool torchOn;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: torchOn
                  ? AppColors.warning
                  : AppColors.onPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: torchOn ? Colors.black : AppColors.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppFonts.heading5.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
