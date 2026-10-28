import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/widgets/dashed_divider.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/order_history_viewmodel.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// The rounded "Order Summary" panel filling the bottom of Order Detail.
/// `GET /orders/{id}` carries no prices, so this reads the order from the
/// history list instead.
class OrderSummaryPanel extends StatelessWidget {
  const OrderSummaryPanel({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
      decoration: BoxDecoration(
        color: isDark ? context.surfaceColor : AppColors.primaryTint,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Consumer<OrderHistoryViewModel>(
        builder: (context, history, _) {
          final order = history.orderById(orderId);
          if (order == null) {
            return history.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : const SizedBox.shrink();
          }
          return _SummaryContent(order: order);
        },
      ),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.order});

  final OrderRecord order;

  static String _usd(double v) => '\$${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lineTotals = order.lines.map((l) => l.lineTotal);
    // Without every line's price the sub total can't be rebuilt, so it falls
    // back to the charged total (and no discount).
    final subTotal = lineTotals.isEmpty || lineTotals.contains(null)
        ? order.total
        : lineTotals.fold<double>(0, (sum, t) => sum + t!);
    final discount = subTotal > order.total
        ? (subTotal - order.total) / subTotal * 100
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.orderDetailSummary,
          style: AppFonts.heading3.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 14),
        _SummaryRow(
          label: l10n.orderDetailDate,
          value: DateFormat(
            'dd/MMM/yyyy  hh:mm a',
          ).format(order.createdAt.toLocal()),
        ),
        for (final line in order.lines)
          _SummaryRow(
            label: '${line.name} x ${line.quantity}',
            value: line.lineTotal == null ? '—' : _usd(line.lineTotal!),
          ),
        const SizedBox(height: 14),
        _SummaryRow(label: l10n.orderDetailSubTotal, value: _usd(subTotal)),
        _SummaryRow(
          label: l10n.orderDetailDiscount,
          value: '${discount.toStringAsFixed(1)}%',
        ),
        const SizedBox(height: 10),
        DashedDivider(color: context.textColor),
        const SizedBox(height: 10),
        _SummaryRow(
          label: l10n.orderDetailTotal,
          value: _usd(order.total),
          emphasized: true,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;

  /// The Total line: dark and bold instead of muted.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = AppFonts.heading4.copyWith(
      fontWeight: emphasized ? AppFonts.semiBold : AppFonts.regular,
      color: emphasized ? context.textColor : context.mutedColor,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 16),
          Text(
            value,
            style: style.copyWith(
              fontWeight: emphasized ? AppFonts.bold : AppFonts.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}
