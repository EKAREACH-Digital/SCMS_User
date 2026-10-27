import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/widgets/order_summary/payment_summary_card.dart';
import 'package:smart_canteen_user_frontend/core/widgets/app_button.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/cart_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/menu_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/order_placement_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/widgets/order_summary/cart_item_row.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/widgets/order_summary/payment_method_picker.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// View Cart / Order Summary screen.
///
/// Shows cart items, payment summary card, apply-coupon button,
/// payment method picker, and a sticky Checkout button.
class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  CartPaymentMethod _paymentMethod = CartPaymentMethod.bakong;

  Future<void> _checkout(CartViewModel cart) async {
    final menuId = context.read<MenuViewModel>().dailyMenu?.menuId;
    if (menuId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Today's menu isn't loaded yet. Please go back and try again."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final branchId = context.read<AuthViewModel>().user?.homeBranchId;
    final provider = _paymentMethod == CartPaymentMethod.bakong ? 'CUTLUY' : 'PAYWAY';

    // Determine meal session from current time (Cambodia time UTC+7).
    final hour = DateTime.now().toUtc().add(const Duration(hours: 7)).hour;
    final mealSession = hour < 11 ? 'breakfast' : hour < 15 ? 'lunch' : 'dinner';

    final vm = context.read<OrderPlacementViewModel>();
    // POST /orders/checkout — places the order and opens the payment session.
    await vm.placeOrder(
      cartEntries: cart.entries,
      menuId: menuId,
      mealSession: mealSession,
      provider: provider,
      branchId: branchId,
    );

    if (!mounted) return;
    if (vm.state == OrderPlacementState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Could not place your order.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Navigate to the QR screen passing the placed order.
    context.push(AppPaths.paymentQr, extra: vm.placedOrder);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          l10n.cartTitle,
          style: AppFonts.heading2.copyWith(color: context.textColor),
        ),
      ),
      body: Consumer<CartViewModel>(
        builder: (context, cart, _) {
          if (cart.entries.isEmpty) {
            return _EmptyCart(onBrowse: () => context.go(AppPaths.menu));
          }
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                children: [
                  _SectionLabel(l10n.cartItemSection),
                  const SizedBox(height: 10),
                  ...cart.entries.map(
                    (entry) => CartItemRow(
                      key: ValueKey(entry.item.id),
                      entry: entry,
                      onIncrement: () => cart.increment(entry.item.id),
                      onDecrement: () => cart.decrement(entry.item.id),
                      onDelete: () {
                        for (var i = 0; i < entry.quantity; i++) {
                          cart.decrement(entry.item.id);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  _SectionLabel(l10n.cartPaymentSummary),
                  const SizedBox(height: 10),
                  PaymentSummaryCard(
                    subtotal: cart.subtotal,
                    discount: cart.discount,
                    total: cart.total,
                  ),
                  const SizedBox(height: 12),
                  const _ApplyCouponButton(),
                  const SizedBox(height: 30),
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
                child: Consumer<OrderPlacementViewModel>(
                  builder: (context, vm, _) => _CheckoutBar(
                    total: cart.total,
                    isLoading: vm.state == OrderPlacementState.submitting,
                    onCheckout: () => _checkout(cart),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Blue section label matching the design

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppFonts.heading2.copyWith(
        color: AppColors.primary,
        fontWeight: AppFonts.semiBold,
      ),
    );
  }
}

// Apply coupon button — tappable outline button, no action yet

class _ApplyCouponButton extends StatelessWidget {
  const _ApplyCouponButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.sell_outlined, size: 18),
      label: Text(AppLocalizations.of(context)!.cartApplyCoupon),
      style: OutlinedButton.styleFrom(
        foregroundColor: context.textColor,
        side: BorderSide(color: context.borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: AppFonts.heading3.copyWith(fontWeight: AppFonts.medium),
        minimumSize: const Size(double.infinity, 0),
      ),
    );
  }
}

// Empty cart state

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              l10n.cartEmptyTitle,
              style: AppFonts.heading2.copyWith(color: context.textColor),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cartEmptyBody,
              textAlign: TextAlign.center,
              style: AppFonts.heading3.copyWith(color: context.mutedColor),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: l10n.cartBrowseMenu,
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
  const _CheckoutBar({
    required this.total,
    required this.onCheckout,
    required this.isLoading,
  });

  final double total;
  final VoidCallback onCheckout;
  final bool isLoading;

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
      child: AppButton(
        label: AppLocalizations.of(context)!.cartCheckout,
        onPressed: isLoading ? null : onCheckout,
        isLoading: isLoading,
      ),
    );
  }
}
