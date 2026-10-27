import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Kind of message — picks the dialog's icon and icon color.
enum MessageDialogType { success, error, warning, info }

extension on MessageDialogType {
  IconData get icon => switch (this) {
        MessageDialogType.success => Icons.check_circle,
        MessageDialogType.error => Icons.error,
        MessageDialogType.warning => Icons.error_outline,
        MessageDialogType.info => Icons.info_outline,
      };

  Color get color => switch (this) {
        MessageDialogType.success => AppColors.success,
        MessageDialogType.error => AppColors.accentRed,
        MessageDialogType.warning => AppColors.warning,
        MessageDialogType.info => AppColors.primary,
      };
}

/// App-wide message dialog — white card with shadow, icon, title, message and
/// a full-width button. Use it for success / error / warning / info messages
/// instead of creating a new dialog file. Pass already-localized strings.
///
/// ```dart
/// // Warning with OK button
/// showMessageDialog(
///   context,
///   type: MessageDialogType.warning,
///   title: l10n.sharingIntentUnsupportedTitle,
///   message: l10n.sharingIntentUnsupportedBody(type, accepted),
/// );
///
/// // Success that closes by itself (no button)
/// await showMessageDialog(
///   context,
///   type: MessageDialogType.success,
///   title: l10n.someSuccessTitle,
///   message: l10n.someSuccessBody,
///   autoCloseAfter: const Duration(milliseconds: 2500),
/// );
/// ```
///
/// - [type] sets the icon + color; [icon] / [iconColor] override it for one-off cases.
/// - [buttonLabel] defaults to the localized "OK".
/// - [autoCloseAfter]: when set, the button is hidden, tapping outside is
///   disabled, and the dialog closes itself after that duration.
/// - The returned future completes when the dialog closes.
Future<void> showMessageDialog(
  BuildContext context, {
  required String title,
  required String message,
  MessageDialogType type = MessageDialogType.warning,
  String? buttonLabel,
  IconData? icon,
  Color? iconColor,
  Duration? autoCloseAfter,
  bool barrierDismissible = true,
}) {
  return showDialog<void>(
    context: context,
    // An auto-closing dialog must not also be dismissed by the user, or the
    // timer would pop the route underneath it.
    barrierDismissible: autoCloseAfter == null && barrierDismissible,
    barrierColor: const Color(0x99000000),
    builder: (_) => Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: const Alignment(0, -0.2),
        child: _MessageDialog(
          title: title,
          message: message,
          buttonLabel: buttonLabel,
          icon: icon ?? type.icon,
          iconColor: iconColor ?? type.color,
          autoCloseAfter: autoCloseAfter,
        ),
      ),
    ),
  );
}

class _MessageDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? buttonLabel;
  final IconData icon;
  final Color iconColor;
  final Duration? autoCloseAfter;

  const _MessageDialog({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.icon,
    required this.iconColor,
    required this.autoCloseAfter,
  });

  @override
  State<_MessageDialog> createState() => _MessageDialogState();
}

class _MessageDialogState extends State<_MessageDialog> {
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    final delay = widget.autoCloseAfter;
    if (delay != null) {
      _autoCloseTimer = Timer(delay, () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: widget.iconColor, size: 52),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: AppFonts.heading1.copyWith(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: AppFonts.heading3.copyWith(
                color: const Color(0xFF9E9E9E),
                height: 1.5,
              ),
            ),
            if (widget.autoCloseAfter == null) ...[
              const SizedBox(height: 24),
              _MessageDialogButton(label: widget.buttonLabel),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageDialogButton extends StatelessWidget {
  final String? label;

  const _MessageDialogButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => context.pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label ?? AppLocalizations.of(context)!.dialogOkButton,
          style: AppFonts.heading2.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

/// Two-button confirmation dialog — same card style as [showMessageDialog].
///
/// Returns `true` if the user tapped Confirm, `false` if they tapped Cancel
/// or dismissed the dialog.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  MessageDialogType type = MessageDialogType.warning,
  String? confirmLabel,
  String? cancelLabel,
  IconData? icon,
  Color? iconColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x99000000),
    builder: (_) => Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: const Alignment(0, -0.2),
        child: _ConfirmDialog(
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          icon: icon ?? type.icon,
          iconColor: iconColor ?? type.color,
        ),
      ),
    ),
  );
  return result ?? false;
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 52),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppFonts.heading1.copyWith(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.heading3.copyWith(
                color: const Color(0xFF9E9E9E),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Cancel — prominent filled button (safe action)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.pop(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  cancelLabel ?? l10n.commonCancel,
                  style: AppFonts.heading2.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Confirm — ghost text button (destructive action, de-emphasised)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => context.pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  confirmLabel ?? l10n.dialogOkButton,
                  style: AppFonts.heading3.copyWith(
                    color: AppColors.primary,
                    fontWeight: AppFonts.medium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
