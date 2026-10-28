import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/order_detail_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/order_history_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/widgets/order_detail/order_pickup_qr.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/widgets/order_detail/order_summary_panel.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// One past order, opened from its History card by [orderId]: the pickup QR
/// on top, the price breakdown in a panel below.
class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OrderDetailViewModel>().loadPickup(widget.orderId);
      // Prices and the date come from the history list. Opened by a deep link,
      // the list may not hold this order yet.
      final history = context.read<OrderHistoryViewModel>();
      if (history.orderById(widget.orderId) == null) {
        history.loadFromBackend();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Text(
          AppLocalizations.of(context)!.orderDetailTitle,
          style: AppFonts.heading2.copyWith(color: AppColors.primary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.borderColor),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: OrderPickupQr(orderId: widget.orderId)),
          SliverFillRemaining(
            hasScrollBody: false,
            child: OrderSummaryPanel(orderId: widget.orderId),
          ),
        ],
      ),
    );
  }
}
