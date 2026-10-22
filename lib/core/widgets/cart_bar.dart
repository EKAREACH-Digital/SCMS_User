import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/utils/currency_formatter.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/cart_viewmodel.dart';

class CartBar extends StatefulWidget {
  const CartBar({
    super.key,
    required this.onViewCart,
    required this.onCheckout,
  });

  final VoidCallback onViewCart;
  final VoidCallback onCheckout;

  @override
  State<CartBar> createState() => _CartBarState();
}

class _CartBarState extends State<CartBar> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartViewModel>();

    if (cart.totalItems == 0) {
      _animController.reverse();
      return const SizedBox.shrink();
    }

    _animController.forward();

    final itemsLabel =
        '${cart.totalItems} item${cart.totalItems == 1 ? '' : 's'}';
    final usdLabel = CurrencyFormatter.formatUSD(cart.total);
    final khrLabel = CurrencyFormatter.usdToKhr(cart.total);

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    itemsLabel,
                    style: AppFonts.heading5.copyWith(
                      color: context.mutedColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        usdLabel,
                        style: AppFonts.heading2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• $khrLabel',
                        style: AppFonts.heading5.copyWith(
                          color: context.mutedColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CartBarButton(
                    label: 'View Cart',
                    onPressed: widget.onViewCart,
                    variant: 'outline',
                  ),
                  const SizedBox(width: 6),
                  _CartBarButton(
                    label: 'Checkout',
                    onPressed: widget.onCheckout,
                    variant: 'filled',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartBarButton extends StatefulWidget {
  const _CartBarButton({
    required this.label,
    required this.onPressed,
    required this.variant,
  });

  final String label;
  final VoidCallback onPressed;
  final String variant;

  @override
  State<_CartBarButton> createState() => _CartBarButtonState();
}

class _CartBarButtonState extends State<_CartBarButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isFilled = widget.variant == 'filled';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isFilled ? AppColors.primary : Colors.transparent,
            border: isFilled
                ? null
                : Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: AppFonts.heading4.copyWith(
              color: isFilled ? AppColors.onPrimary : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
