import 'package:flutter/material.dart';
import '../shell/app_shell.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/cart/cart_model.dart';
import '../../../model/food/food_item.dart';
import '../../../theme/app_theme.dart';
import '../../../ui/utils/meal_session.dart';
import 'payment_method_screen.dart';
import '../../widgets/smart_canteen_widgets.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  static const routeName = '/order-summary';

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final bool _placing = false;

  void _openPaymentMethodScreen(double amount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodScreen(totalAmount: amount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);
    final entries = cart.entries;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Smart Canteen',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppTheme.border,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.cartEmptyTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mutedText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.cartEmptyBody,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.mutedText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SmartCanteenButton(
                    label: 'Browse Menu',
                    onPressed: () => AppShell.goToTab(context, AppTab.menu),
                    height: 48,
                    radius: 14,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.cartYourOrder,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.text,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${cart.totalItems} Item${cart.totalItems == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: AppTheme.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 32, color: AppTheme.border),
                    itemBuilder: (context, index) {
                      return OrderItemCard(
                        entry: entries[index],
                        onIncrement: () =>
                            cart.increment(entries[index].item.id),
                        onDecrement: () =>
                            cart.decrement(entries[index].item.id),
                      );
                    },
                  ),
                ),
                _PaymentSummarySection(
                  cart: cart,
                  activeSession: MealSession.activeAt(DateTime.now()),
                  isPlacing: _placing,
                  onPay: () => _openPaymentMethodScreen(cart.total),
                ),
              ],
            ),
      bottomNavigationBar: SmartCanteenNavigationBarButton(
        currentIndex: 1,
        // Always return to the shell on the chosen tab. Pushing each tab's
        // own route builds it standalone, without a navigation bar.
        onTap: (i) => AppShell.goToTab(context, i),
      ),
    );
  }
}

class OrderItemCard extends StatelessWidget {
  const OrderItemCard({
    super.key,
    required this.entry,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartEntry entry;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 80,
            height: 80,
            child: _OrderItemImage(entry: entry),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: entry.item.tags
                    .take(2)
                    .map((t) => _SmallTag(label: t))
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${(entry.item.price * entry.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.green,
                    ),
                  ),
                  QuantityController(
                    quantity: entry.quantity,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderItemImage extends StatelessWidget {
  const _OrderItemImage({required this.entry});
  final CartEntry entry;

  @override
  Widget build(BuildContext context) {
    final url = entry.item.imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _placeholder(),
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    if (entry.item.imagePath != null) {
      return Image.asset(
        entry.item.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    final idx = entry.item.colorSeed % kFoodGradients.length;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: kFoodGradients[idx],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          kFoodIcons[idx % kFoodIcons.length],
          color: AppTheme.green,
          size: 32,
        ),
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppTheme.mutedText),
      ),
    );
  }
}

class QuantityController extends StatelessWidget {
  const QuantityController({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16, color: AppTheme.green),
            onPressed: onDecrement,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 40),
          ),
          Text(
            '$quantity',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16, color: AppTheme.green),
            onPressed: onIncrement,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 40),
          ),
        ],
      ),
    );
  }
}

class _PaymentSummarySection extends StatelessWidget {
  const _PaymentSummarySection({
    required this.cart,
    required this.activeSession,
    required this.isPlacing,
    required this.onPay,
  });

  final CartModel cart;

  /// The session currently open for ordering, or null when between windows.
  final MealSession? activeSession;
  final bool isPlacing;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    // A drinks-only cart isn't bound to a window, so checkout stays open even
    // between sessions.
    final anytimeOnly = cart.isAnytimeOnly;
    final isOpen = activeSession != null || anytimeOnly;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.cartMealSession,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedText,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final s in MealSession.values)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: s == MealSession.dinner ? 0 : 8,
                    ),
                    // Only the session whose time window is open can be picked;
                    // the others are shown disabled.
                    child: _SessionChoiceChip(
                      label: s.label,
                      selected: s == activeSession,
                      enabled: s == activeSession,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            switch ((activeSession, anytimeOnly)) {
              (final s?, _) => '${s.label} is open now (${s.timeRange})',
              (null, true) =>
                'Drinks are available all day — you can order now.',
              (null, false) =>
                'Ordering is closed. Breakfast ${MealSession.breakfast.timeRange}, '
                    'Lunch ${MealSession.lunch.timeRange}, Dinner ${MealSession.dinner.timeRange}.',
            },
            style: TextStyle(
              fontSize: 11,
              color: isOpen ? AppTheme.green : const Color(0xFFE53935),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Subtotal',
            value: '\$${cart.subtotal.toStringAsFixed(2)}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppTheme.border),
          ),
          _SummaryRow(
            label: 'Total Amount',
            value: '\$${cart.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 24),
          SmartCanteenButton(
            label: isPlacing
                ? 'Placing order…'
                : isOpen
                ? 'Proceed to Payment  →'
                : 'Ordering closed',
            onPressed: (isPlacing || !isOpen) ? null : onPay,
            height: 56,
            radius: 16,
          ),
        ],
      ),
    );
  }
}

class _SessionChoiceChip extends StatelessWidget {
  const _SessionChoiceChip({
    required this.label,
    required this.selected,
    required this.enabled,
  });

  final String label;
  final bool selected;

  /// Only the active session is enabled; disabled chips are greyed and inert.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color bg = selected ? AppTheme.green : Colors.transparent;
    final Color borderColor = selected
        ? AppTheme.green
        : enabled
        ? AppTheme.border
        : AppTheme.border.withValues(alpha: 0.4);
    final Color textColor = selected
        ? Colors.white
        : enabled
        ? AppTheme.mutedText
        : AppTheme.mutedText.withValues(alpha: 0.35);

    return Opacity(
      opacity: enabled || selected ? 1 : 0.6,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? AppTheme.text : AppTheme.mutedText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 22 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isTotal ? AppTheme.green : AppTheme.text,
          ),
        ),
      ],
    );
  }
}
