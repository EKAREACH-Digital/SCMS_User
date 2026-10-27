import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';

/// `[−]  n  [+]` row with isolated filled-circle buttons.
///
/// [quantity]    — current count.
/// [onIncrement] — called when `+` is tapped.
/// [onDecrement] — called when `−` is tapped (caller decides what to do at 0).
/// [minQuantity] — lowest allowed value; the `−` button is disabled at this
///                 value (defaults to 1).
/// [size]        — diameter of each circle button (defaults to 32).
class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.minQuantity = 1,
    this.size = 32.0,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int minQuantity;
  final double size;

  @override
  Widget build(BuildContext context) {
    final canDecrement = quantity > minQuantity;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleButton(
          icon: Icons.remove_rounded,
          size: size,
          onTap: canDecrement
              ? () {
                  HapticFeedback.lightImpact();
                  onDecrement();
                }
              : null,
        ),
        SizedBox(
          width: size,
          child: Center(
            child: Text(
              '$quantity',
              style: AppFonts.heading3.copyWith(
                color: context.textColor,
                fontWeight: AppFonts.semiBold,
              ),
            ),
          ),
        ),
        _CircleButton(
          icon: Icons.add_rounded,
          size: size,
          onTap: () {
            HapticFeedback.lightImpact();
            onIncrement();
          },
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.size, required this.onTap});

  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.3),
        ),
        child: Icon(icon, color: AppColors.onPrimary, size: size * 0.5),
      ),
    );
  }
}
