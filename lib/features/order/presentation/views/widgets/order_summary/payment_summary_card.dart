import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(color: context.cardColor),
      child: Column(
        children: [
          _SummaryRow(
            label: l10n.cartSubtotal,
            value: '\$${subtotal.toStringAsFixed(2)}',
            labelStyle: AppFonts.heading3.copyWith(color: context.mutedColor),
            valueStyle: AppFonts.heading3.copyWith(color: context.textColor),
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: l10n.cartDiscount,
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
            label: l10n.cartTotal,
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

/// Dashed horizontal rule drawn with [CustomPainter] so it fills the exact
/// available width with no gap on the right.
class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1.5,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashPainter(color: AppColors.darkBackground),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.square;

    final y = size.height / 2;
    double x = 0;
    while (x < size.width) {
      final end = (x + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
