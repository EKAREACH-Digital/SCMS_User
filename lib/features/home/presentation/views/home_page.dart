import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/core/widgets/cart_bar.dart';
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
        // Allow content to extend behind the floating nav bar.
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Section 1: Top navigation bar
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
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                // Section 2: Auto-scrolling banner carousel
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Text(
                      "CADT's daily food Banner",
                      style: AppFonts.heading3.copyWith(
                        color: context.textColor,
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: HomeBanner()),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Section 3: Menu grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _MenuSectionHeader(
                      onSeeAll: () => context.push(AppPaths.menu),
                    ),
                  ),
                ),
                SliverPadding(
                  // Bottom clears the floating nav bar + system gesture inset.
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    MediaQuery.of(context).padding.bottom + 80,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Consumer<MenuViewModel>(
                      builder: (context, menu, _) {
                        final items = menu.state == ViewState.success
                            ? menu.items
                            : kMenuItems;
                        if (items.isEmpty) return const _EmptyMenu();
                        return HomeFoodGrid(items: items);
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Cart bar floats above the content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CartBar(
                onViewCart: () => context.go(AppPaths.cart),
                onCheckout: () => context.go(AppPaths.cart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Menu section header — "Popular Items" + "See All"

class _MenuSectionHeader extends StatelessWidget {
  const _MenuSectionHeader({required this.onSeeAll});

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

// Empty state when no items are available

class _EmptyMenu extends StatelessWidget {
  const _EmptyMenu();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.restaurant_menu_rounded, size: 40, color: AppColors.border),
          const SizedBox(height: 12),
          Text(
            'No items available',
            style: AppFonts.heading3.copyWith(color: context.mutedColor),
          ),
        ],
      ),
    );
  }
}
