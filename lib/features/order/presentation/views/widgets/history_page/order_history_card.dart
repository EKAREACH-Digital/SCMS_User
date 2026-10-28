import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/order_history_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/widgets/history_page/order_food_image.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/widgets/history_page/order_status_badge.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// One past order on the History tab: date and status on top, a strip of the
/// dishes in the middle, totals and a "View Order" button at the bottom.
class OrderHistoryCard extends StatelessWidget {
  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.onView,
  });

  final OrderRecord order;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(order: order),
          Divider(height: 1, color: context.borderColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _DishStrip(order: order),
                _TotalsRow(order: order),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: onView,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: AppFonts.heading5,
                  ),
                  child: Text(l10n.historyViewOrder),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.order});

  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              DateFormat('dd/MMM/yyyy').format(order.createdAt.toLocal()),
              style: AppFonts.heading4.copyWith(color: context.textColor),
            ),
          ),
          OrderStatusBadge(status: order.status),
        ],
      ),
    );
  }
}

/// The ordered dishes side by side, scrolling sideways when they don't fit.
class _DishStrip extends StatelessWidget {
  const _DishStrip({required this.order});

  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    // Optimistically-added orders have no lines until the next refresh, so
    // fall back to the summary and the order's own photo.
    final lines = order.lines.isNotEmpty
        ? order.lines
        : [OrderLine(name: order.items, quantity: 1, imageUrl: order.imageUrl)];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: lines.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) => _DishThumb(
          line: lines[index],
          imagePath: order.lines.isEmpty ? order.imagePath : null,
        ),
      ),
    );
  }
}

class _DishThumb extends StatelessWidget {
  const _DishThumb({required this.line, this.imagePath});

  final OrderLine line;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 40,
              height: 30,
              child: OrderFoodImage(
                imageUrl: line.imageUrl,
                imagePath: imagePath,
                iconSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${line.name} x ${line.quantity}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.heading5.copyWith(
              fontWeight: AppFonts.regular,
              color: context.mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.order});

  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dishCount = order.lines.isEmpty ? 1 : order.lines.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          l10n.historyTotalItems(dishCount),
          style: AppFonts.heading5.copyWith(
            fontWeight: AppFonts.regular,
            color: context.mutedColor,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          l10n.historyTotal('\$${order.total.toStringAsFixed(2)}'),
          style: AppFonts.heading5.copyWith(color: context.textColor),
        ),
      ],
    );
  }
}
