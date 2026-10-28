import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order_status.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/widgets/history_page/order_status_style.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Solid status pill on an order, colored by [OrderStatusStyle].
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label(AppLocalizations.of(context)!),
        style: AppFonts.heading5.copyWith(color: AppColors.onPrimary),
      ),
    );
  }
}
