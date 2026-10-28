import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/views/widgets/empty_state_widget.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order_status.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/order_history_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/widgets/history_page/order_history_card.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/widgets/history_page/order_status_style.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Past orders, one tab per status the student acts on: All, Pending Payment,
/// Processing (paid), Ready (come pick it up) and Completed. Cancelled orders
/// only appear under All.
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  // One tab per entry; null is "All".
  static const _tabs = <OrderStatus?>[
    null,
    OrderStatus.pendingPayment,
    OrderStatus.paid,
    OrderStatus.ready,
    OrderStatus.completed,
  ];

  // Tracks the last TickerMode value so we can detect when this tab
  // becomes active (TickerMode flips false --> true on each tab switch).
  bool? _wasTickerEnabled;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = TickerMode.valuesOf(context).enabled;
    // Load on first visit (null --> true) and on every subsequent tab switch
    // (false --> true). Ignored when the tab goes inactive (true --> false).
    if (_wasTickerEnabled != enabled && enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<OrderHistoryViewModel>().loadFromBackend();
      });
    }
    _wasTickerEnabled = enabled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: context.bgColor,
        appBar: AppBar(
          backgroundColor: context.bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            l10n.historyTitle,
            style: AppFonts.heading2.copyWith(color: AppColors.primary),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: context.mutedColor,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: context.borderColor,
            labelStyle: AppFonts.heading3.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
            unselectedLabelStyle: AppFonts.heading3,
            tabs: [
              for (final status in _tabs)
                Tab(text: status?.label(l10n) ?? l10n.historyTabAll),
            ],
          ),
        ),
        body: Consumer<OrderHistoryViewModel>(
          builder: (context, history, _) =>
              _HistoryBody(history: history, tabs: _tabs),
        ),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({required this.history, required this.tabs});

  final OrderHistoryViewModel history;
  final List<OrderStatus?> tabs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orders = history.orders;
    // Once there is data, keep showing it — a failed background refresh
    // shouldn't blank out a list the user can still read.
    if (orders.isEmpty && history.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (orders.isEmpty && history.error != null) {
      return EmptyStateWidget(
        icon: Icons.cloud_off_rounded,
        title: l10n.historyErrorTitle,
        body: history.error!,
        retryLabel: l10n.historyRetry,
        onRetry: history.loadFromBackend,
      );
    }
    return TabBarView(
      children: [
        for (final status in tabs)
          _OrderList(orders: history.ordersWith(status)),
      ],
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders});

  final List<OrderRecord> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (orders.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: l10n.historyEmptyTitle,
        body: l10n.historyEmptyBody,
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        12,
        16,
        12,
        MediaQuery.paddingOf(context).bottom + 80,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: OrderHistoryCard(
          order: orders[index],
          onView: () =>
              context.push('${AppPaths.orderDetail}/${orders[index].id}'),
        ),
      ),
    );
  }
}
