import 'package:flutter/material.dart';

import '../../model/cart/cart_model.dart';
import '../../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

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
    final cart = CartProvider.of(context);

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
            color: AppTheme.green.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.green.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: Items and price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    itemsLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.mutedColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        usdLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.green,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• $khrLabel',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.mutedColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Right: Buttons
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
            color: isFilled ? AppTheme.green : Colors.transparent,
            border: isFilled
                ? null
                : Border.all(
                    color: AppTheme.green.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isFilled ? Colors.white : AppTheme.green,
            ),
          ),
        ),
      ),
    );
  }
}
