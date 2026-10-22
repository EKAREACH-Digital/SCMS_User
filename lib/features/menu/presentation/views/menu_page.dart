import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/core/widgets/empty_state_widget.dart';
import 'package:smart_canteen_user_frontend/core/widgets/menu_chip.dart';
import 'package:smart_canteen_user_frontend/core/widgets/smart_canteen_button.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/cart_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/menu_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/views/widgets/menu_page/menu_food_list_item.dart';

/// See All / Menu page — vertical list with category filter chips and a
/// sticky "View Cart" button at the bottom.
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  static const _filters = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'Drinks',
    'Desserts',
  ];
  static const _cats = [
    '',
    'breakfast',
    'lunch',
    'dinner',
    'snacks',
    'drinks',
    'desserts',
  ];

  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MenuViewModel>().load();
    });
  }

  List<FoodItem> _visibleItems(List<FoodItem> all) {
    final cat = _cats[_selectedFilter];
    if (cat.isEmpty) return all;
    return all.where((f) => f.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: context.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Home',
          style: AppFonts.heading2.copyWith(color: context.textColor),
        ),
      ),
      body: Consumer<MenuViewModel>(
        builder: (context, menu, _) {
          return Stack(
            children: [
              Column(
                children: [
                  _CategoryChips(
                    selected: _selectedFilter,
                    onSelected: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedFilter = i);
                    },
                    filters: _filters,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: switch (menu.state) {
                      ViewState.error => EmptyStateWidget(
                        icon: Icons.cloud_off_rounded,
                        title: 'Could not load menu',
                        body: menu.errorMessage ?? 'Please try again.',
                        retryLabel: 'Retry',
                        onRetry: () => menu.load(force: true),
                      ),
                      ViewState.loading || ViewState.idle => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                      ViewState.success => _FoodList(
                        items: _visibleItems(menu.items),
                      ),
                    },
                  ),
                ],
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
    );
  }
}

// Category chips

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selected,
    required this.onSelected,
    required this.filters,
  });

  final int selected;
  final ValueChanged<int> onSelected;
  final List<String> filters;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: List.generate(filters.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: MenuChip(label: filters[i], selected: selected == i),
            ),
          );
        }),
      ),
    );
  }
}

// Scrollable food list

class _FoodList extends StatelessWidget {
  const _FoodList({required this.items});

  final List<FoodItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'Nothing in this category',
        body: 'Try a different filter.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: items.length,
      itemBuilder: (context, index) => MenuFoodListItem(item: items[index]),
    );
  }
}

// Sticky "View Cart" bar

class _ViewCartBar extends StatelessWidget {
  const _ViewCartBar({required this.itemCount, required this.onViewCart});

  final int itemCount;
  final VoidCallback onViewCart;

  @override
  Widget build(BuildContext context) {
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
        label: 'View Cart ($itemCount)',
        onPressed: onViewCart,
      ),
    );
  }
}
