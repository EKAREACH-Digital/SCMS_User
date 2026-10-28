import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order_status.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// How an [OrderStatus] looks on screen. Shared by the History tabs and the
/// status badge, so a tab and the badges under it always read the same.
extension OrderStatusStyle on OrderStatus {
  /// A paid order shows as "Processing": from the student's side it is being
  /// prepared.
  String label(AppLocalizations l10n) => switch (this) {
    OrderStatus.pendingPayment => l10n.statusPendingPayment,
    OrderStatus.paid => l10n.statusProcessing,
    OrderStatus.ready => l10n.statusReady,
    OrderStatus.completed => l10n.statusCompleted,
    OrderStatus.cancelled => l10n.statusCancelled,
  };

  Color get color => switch (this) {
    OrderStatus.pendingPayment => AppColors.orange,
    OrderStatus.paid => AppColors.warning,
    OrderStatus.ready => AppColors.primary,
    OrderStatus.completed => AppColors.success,
    OrderStatus.cancelled => AppColors.accentRed,
  };
}
