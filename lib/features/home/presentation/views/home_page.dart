import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/core/widgets/cart_bar.dart';
import 'package:smart_canteen_user_frontend/core/widgets/menu_chip.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/home/presentation/views/widgets/home_food_grid.dart';
import 'package:smart_canteen_user_frontend/features/home/presentation/views/widgets/home_header.dart';
import 'package:smart_canteen_user_frontend/features/home/presentation/views/widgets/promo_banner.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/sample_menu_items.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/menu_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _cats = <String>['', 'breakfast', 'lunch', 'dinner', 'drinks'];

  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MenuViewModel>().load();
      context.read<AuthViewModel>().refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Consumer<AuthViewModel>(
                    builder: (context, auth, _) => HomeHeader(
                      authViewModel: auth,
                      onNotificationTap: () =>
                          context.push(AppPaths.notifications),
                      onAvatarTap: () => context.go(AppPaths.settings),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: PromoBanner(
                    title: 'Chef Special: Grilled Chicken',
                    subtitle: '15% off today with code FRESH15',
                    ctaLabel: 'Order Now',
                    onTap: () =>
                        context.go(AppPaths.menu),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                    child: _CategoryChips(
                      selected: _selectedCategory,
                      onSelected: (i) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedCategory = i);
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _SectionHeader(
                      onSeeAll: () =>
                          context.go(AppPaths.menu),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  sliver: SliverToBoxAdapter(
                    child: Consumer<MenuViewModel>(
                      builder: (context, menu, _) {
                        final all = menu.state == ViewState.success
                            ? menu.items
                            : kMenuItems;
                        final cat = _cats[_selectedCategory];
                        final filtered = cat.isEmpty
                            ? all
                            : all.where((f) => f.category == cat).toList();
                        final visible = filtered.take(9).toList();
                        if (visible.isEmpty) {
                          return const _EmptyCategory();
                        }
                        return HomeFoodGrid(items: visible);
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CartBar(
                onViewCart: () => context.push(AppPaths.orderSummary),
                onCheckout: () => context.push(AppPaths.orderSummary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Category chips

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  static const _categories = <String>[
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Drinks',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_categories.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: MenuChip(label: _categories[i], selected: selected == i),
            ),
          );
        }),
      ),
    );
  }
}

// "Popular for Lunch" header

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Popular Items',
          style: AppFonts.heading2.copyWith(
            color: context.textColor,
            fontWeight: AppFonts.bold,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'See All',
            style: AppFonts.heading4.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// Empty category placeholder

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 40,
            color: AppColors.border,
          ),
          const SizedBox(height: 12),
          Text(
            'Nothing here yet',
            style: AppFonts.heading3.copyWith(color: context.mutedColor),
          ),
        ],
      ),
    );
  }
}
