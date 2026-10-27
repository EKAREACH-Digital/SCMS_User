import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/views/widgets/empty_state_widget.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
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
      if (!mounted) return;
      final branchId = context.read<AuthViewModel>().user?.homeBranchId;
      context.read<MenuViewModel>().load(branchId: branchId);
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
          backgroundColor: context.bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            l10n.navMenu,
            style: AppFonts.heading2.copyWith(color: context.textColor),
          ),
          actions: [
            Consumer<CartViewModel>(
              builder: (context, cart, _) => _AppBarCartButton(
                itemCount: cart.totalItems,
                onTap: () => context.push(AppPaths.orderSummary),
              ),
            ),
            const SizedBox(width: 20),
          ],
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
          builder: (context, menu, _) => switch (menu.state) {
            ViewState.error => EmptyStateWidget(
              icon: Icons.cloud_off_rounded,
              title: l10n.menuErrorTitle,
              body: menu.errorMessage ?? l10n.commonRetry,
              retryLabel: l10n.commonRetry,
              onRetry: () => menu.load(force: true),
            ),
            ViewState.loading ||
            ViewState.idle => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            ViewState.success => TabBarView(
              children: List.generate(
                tabs.length,
                (i) => _FoodList(items: _filtered(menu.items, _cats[i])),
              ),
            ),
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
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.paddingOf(context).bottom + 80,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => MenuFoodListItem(item: items[index]),
    );
  }
}

class _AppBarCartButton extends StatelessWidget {
  const _AppBarCartButton({required this.itemCount, required this.onTap});

  final int itemCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 26),
          if (itemCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.accentRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  itemCount > 9 ? '9+' : '$itemCount',
                  style: AppFonts.heading5.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: AppFonts.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
