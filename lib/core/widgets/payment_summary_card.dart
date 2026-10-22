import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';

/// Subtotal / Discount / Total card with a dotted divider above the total row.
///
/// Used on the View Cart / Order Summary screen.
class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  final double subtotal;
  final double discount;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Sub Total',
            value: '\$${subtotal.toStringAsFixed(2)}',
            labelStyle: AppFonts.heading3.copyWith(color: context.mutedColor),
            valueStyle: AppFonts.heading3.copyWith(color: context.textColor),
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Discount',
            value: discount > 0
                ? '-\$${discount.toStringAsFixed(2)}'
                : '\$0.00',
            labelStyle: AppFonts.heading3.copyWith(color: context.mutedColor),
            valueStyle: AppFonts.heading3.copyWith(
              color: discount > 0 ? AppColors.secondary : context.textColor,
            ),
          ),
          const SizedBox(height: 12),
          const _DottedDivider(),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Total',
            value: '\$${total.toStringAsFixed(2)}',
            labelStyle: AppFonts.heading2.copyWith(color: context.textColor),
            valueStyle: AppFonts.heading2.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}

/// A row of evenly-spaced dashes that mimics a dashed/dotted horizontal rule.
class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(
            count,
            (_) => Container(
              width: dashWidth,
              height: 1.5,
              margin: const EdgeInsets.only(right: dashSpace),
              color: AppColors.border,
            ),
          ),
        );
      },
    );
  }
}
