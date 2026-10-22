import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';

/// `[−]  n  [+]` row used on Food Detail and Cart item rows.
///
/// [quantity]    — current count.
/// [onIncrement] — called when `+` is tapped.
/// [onDecrement] — called when `−` is tapped (caller decides what to do at 0).
/// [minQuantity] — lowest allowed value; the `−` button is disabled at this
///                 value (defaults to 1).
class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.minQuantity = 1,
    this.size = 40.0,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int minQuantity;

  /// Height (and width) of each side button.
  final double size;

  @override
  Widget build(BuildContext context) {
    final canDecrement = quantity > minQuantity;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SideButton(
            icon: Icons.remove_rounded,
            size: size,
            onTap: canDecrement
                ? () {
                    HapticFeedback.selectionClick();
                    onDecrement();
                  }
                : null,
          ),
          _Divider(height: size * 0.6),
          SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Text(
                '$quantity',
                style: AppFonts.heading3.copyWith(
                  color: AppColors.primary,
                  fontWeight: AppFonts.bold,
                ),
              ),
            ),
          ),
          _Divider(height: size * 0.6),
          _SideButton(
            icon: Icons.add_rounded,
            size: size,
            onTap: () {
              HapticFeedback.selectionClick();
              onIncrement();
            },
          ),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          icon,
          color: onTap != null
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.3),
          size: 18,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: height,
      color: AppColors.primary.withValues(alpha: 0.2),
    );
  }
}
