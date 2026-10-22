import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/widgets/payment_summary_card.dart';
import 'package:smart_canteen_user_frontend/core/widgets/smart_canteen_button.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/cart_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/widgets/order_summary/cart_item_row.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/widgets/order_summary/payment_method_picker.dart';

/// View Cart / Order Summary screen.
///
/// Shows cart items, payment summary card, payment method picker and a
/// sticky Checkout button.
class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  CartPaymentMethod _paymentMethod = CartPaymentMethod.bakong;

  void _checkout(CartViewModel cart) {
    context.push(AppPaths.paymentMethod, extra: cart.total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Cart',
          style: AppFonts.heading2.copyWith(color: context.textColor),
        ),
      ),
      body: Consumer<CartViewModel>(
        builder: (context, cart, _) {
          if (cart.entries.isEmpty) {
            return _EmptyCart(
              onBrowse: () => context.go(AppPaths.menu),
            );
          }
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                children: [
                  ...cart.entries.map(
                    (entry) => CartItemRow(
                      key: ValueKey(entry.item.id),
                      entry: entry,
                      onIncrement: () => cart.increment(entry.item.id),
                      onDecrement: () => cart.decrement(entry.item.id),
                      onDelete: () {
                        // Remove entirely by decrementing to 0.
                        for (var i = 0; i < entry.quantity; i++) {
                          cart.decrement(entry.item.id);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  PaymentSummaryCard(
                    subtotal: cart.subtotal,
                    discount: cart.discount,
                    total: cart.total,
                  ),
                  const SizedBox(height: 20),
                  PaymentMethodPicker(
                    selected: _paymentMethod,
                    onChanged: (m) => setState(() => _paymentMethod = m),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _CheckoutBar(
                  total: cart.total,
                  onCheckout: () => _checkout(cart),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Empty cart

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.border,
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: AppFonts.heading2.copyWith(color: context.textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some food to get started.',
              style: AppFonts.heading3.copyWith(color: context.mutedColor),
            ),
            const SizedBox(height: 24),
            SmartCanteenButton(
              label: 'Browse Menu',
              onPressed: onBrowse,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}

// Sticky checkout bar

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total, required this.onCheckout});

  final double total;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SmartCanteenButton(
        label: 'Checkout  •  \$${total.toStringAsFixed(2)}',
        onPressed: onCheckout,
      ),
    );
  }
}
