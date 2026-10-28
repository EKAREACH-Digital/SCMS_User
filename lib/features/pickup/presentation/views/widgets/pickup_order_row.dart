import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/widgets/history_page/order_status_badge.dart';
import 'package:smart_canteen_user_frontend/features/pickup/domain/entities/pickup_order.dart';

/// One order card in the check-in result panel.
///
/// Matches the [OrderHistoryCard] shape: white background, 8 dp corners,
/// border, and a one-pixel drop shadow. The body is two columns:
/// - Left: items list, a divider, the check-in time and a truncated order ID.
/// - Right: the large pickup number in primary colour.
///
/// [counter] is the human-readable counter name from [PickupCheckin.counter].
/// [checkedInAt] is stored in UTC; it is formatted to local time inside.
class PickupResultCard extends StatelessWidget {
  const PickupResultCard({
    super.key,
    required this.order,
    required this.counter,
    required this.checkedInAt,
  });

  final PickupOrder order;
  final String counter;
  final DateTime checkedInAt;

  @override
  Widget build(BuildContext context) {
    final local = checkedInAt.toLocal();
    final timeLabel =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final shortId = order.orderId.length > 8
        ? order.orderId.substring(0, 8)
        : order.orderId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header: counter icon + name + status badge
          _CardHeader(counter: counter, status: order.status),
          Divider(height: 1, color: context.borderColor),
          // Body: item list (left) | pickup number (right)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: items, divider, check-in metadata
                Expanded(
                  child: _LeftColumn(
                    order: order,
                    timeLabel: timeLabel,
                    shortId: shortId,
                  ),
                ),
                const SizedBox(width: 12),
                // Right column: large pickup number
                _PickupNumberColumn(no: order.pickupNo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.counter, required this.status});

  final String counter;
  final dynamic status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              counter,
              style: AppFonts.heading3.copyWith(color: AppColors.primary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          OrderStatusBadge(status: status),
        ],
      ),
    );
  }
}

class _LeftColumn extends StatelessWidget {
  const _LeftColumn({
    required this.order,
    required this.timeLabel,
    required this.shortId,
  });

  final PickupOrder order;
  final String timeLabel;
  final String shortId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item rows: • name × qty
        ...order.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '• ${item.name} × ${item.quantity}',
              style: AppFonts.heading4.copyWith(color: context.textColor),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Divider(height: 1, color: context.borderColor),
        const SizedBox(height: 8),
        // Check-in time
        Text(
          'Check In: $timeLabel',
          style: AppFonts.heading5.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        // Truncated order ID
        Text(
          'Order ID: $shortId…',
          style: AppFonts.heading5.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _PickupNumberColumn extends StatelessWidget {
  const _PickupNumberColumn({required this.no});

  final int no;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'PICKUP',
          style: AppFonts.heading5.copyWith(
            color: AppColors.primary,
            fontWeight: AppFonts.semiBold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '#$no',
          style: AppFonts.heading1.copyWith(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: AppFonts.bold,
          ),
        ),
      ],
    );
  }
}
