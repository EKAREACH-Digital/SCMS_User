import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class QuickCheckoutBottomSheet extends StatelessWidget {
  const QuickCheckoutBottomSheet({
    super.key,
    required this.itemCount,
    required this.subtotal,
    required this.discount,
    required this.serviceFee,
    required this.total,
    required this.onCheckout,
  });

  final int itemCount;
  final double subtotal;
  final double discount;
  final double serviceFee;
  final double total;
  final VoidCallback onCheckout;

  static Future<void> show(
    BuildContext context, {
    required int itemCount,
    required double subtotal,
    required double discount,
    required double serviceFee,
    required double total,
    required VoidCallback onCheckout,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickCheckoutBottomSheet(
        itemCount: itemCount,
        subtotal: subtotal,
        discount: discount,
        serviceFee: serviceFee,
        total: total,
        onCheckout: onCheckout,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.cartItemsInCart(itemCount),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.text),
          ),
          const SizedBox(height: 16),
          _Row(label: AppLocalizations.of(context)!.cartSubtotal, value: '\$${subtotal.toStringAsFixed(2)}'),
          if (discount > 0) _Row(label: AppLocalizations.of(context)!.cartScholarDiscount, value: '-\$${discount.toStringAsFixed(2)}', valueColor: AppTheme.green),
          _Row(label: AppLocalizations.of(context)!.cartServiceFee, value: '\$${serviceFee.toStringAsFixed(2)}'),
          const Divider(height: 24, color: AppTheme.border),
          _Row(
            label: AppLocalizations.of(context)!.cartTotal,
            value: '\$${total.toStringAsFixed(2)}',
            labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.text),
            valueColor: AppTheme.green,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                AppLocalizations.of(context)!.cartProceedToPayment,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.valueColor = AppTheme.text, this.labelStyle});
  final String label;
  final String value;
  final Color valueColor;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: labelStyle ?? const TextStyle(color: AppTheme.mutedText, fontSize: 13)),
          const Spacer(),
          Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
