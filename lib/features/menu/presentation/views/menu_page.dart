import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/core/widgets/empty_state_widget.dart';
import 'package:smart_canteen_user_frontend/core/widgets/smart_canteen_button.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/cart_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/menu_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/views/widgets/menu_page/menu_food_list_item.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Full menu list — sticky tab bar at the top filters by category,
/// sticky "View Cart" button floats above the list at the bottom.
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Backend category identifiers — parallel to the tab labels built in build().
  static const _cats = [
    '',
    'breakfast',
    'lunch',
    'dinner',
    'snacks',
    'drinks',
    'desserts',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MenuViewModel>().load();
    });
  }

  List<FoodItem> _filtered(List<FoodItem> all, String cat) =>
      cat.isEmpty ? all : all.where((f) => f.category == cat).toList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      l10n.menuTabAll,
      l10n.slotBreakfast,
      l10n.slotLunch,
      l10n.slotDinner,
      l10n.menuTabSnacks,
      l10n.menuTabDrinks,
      l10n.menuTabDesserts,
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: context.bgColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: context.bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => context.pop(),
          ),
          title: Text(
            l10n.navMenu,
            style: AppFonts.heading2.copyWith(color: context.textColor),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: context.mutedColor,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: context.borderColor,
            labelStyle: AppFonts.heading4.copyWith(
              fontWeight: AppFonts.semiBold,
            ),
            unselectedLabelStyle: AppFonts.heading4,
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: Consumer<MenuViewModel>(
          builder: (context, menu, _) {
            return Stack(
              children: [
                Positioned.fill(
                  child: switch (menu.state) {
                    ViewState.error => EmptyStateWidget(
                      icon: Icons.cloud_off_rounded,
                      title: l10n.menuErrorTitle,
                      body: menu.errorMessage ?? l10n.commonRetry,
                      retryLabel: l10n.commonRetry,
                      onRetry: () => menu.load(force: true),
                    ),
                    ViewState.loading ||
                    ViewState.idle => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    ViewState.success => TabBarView(
                      children: List.generate(
                        tabs.length,
                        (i) => _FoodList(
                          items: _filtered(menu.items, _cats[i]),
                        ),
                      ),
                    ),
                  },
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Consumer<CartViewModel>(
                    builder: (context, cart, _) {
                      if (cart.totalItems == 0) return const SizedBox.shrink();
                      return _ViewCartBar(
                        itemCount: cart.totalItems,
                        onViewCart: () => context.push(AppPaths.orderSummary),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FoodList extends StatelessWidget {
  const _FoodList({required this.items});

  final List<FoodItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: l10n.menuEmptyTitle,
        body: l10n.menuEmptyBody,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: items.length,
      itemBuilder: (context, index) => MenuFoodListItem(item: items[index]),
    );
  }
}

class _ViewCartBar extends StatelessWidget {
  const _ViewCartBar({required this.itemCount, required this.onViewCart});

  final int itemCount;
  final VoidCallback onViewCart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SmartCanteenButton(
        label: l10n.menuViewCart(itemCount),
        onPressed: onViewCart,
      ),
    );
  }
}
