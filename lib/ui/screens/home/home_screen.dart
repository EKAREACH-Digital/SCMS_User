import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../model/cart/cart_model.dart';
import '../../../model/food/food_item.dart';
import '../../../model/user/user.dart';
import '../../../theme/app_theme.dart';
import '../../../ui/states/menu_state.dart';
import '../../../ui/states/user_profile_state.dart';
import '../../../ui/utils/async_value.dart';
import '../alerts/notification_screen.dart';
import '../menu_browsing/menu_screen.dart';
import '../shell/app_shell.dart';
import '../../widgets/cart_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const categories = <String>[
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Drinks',
  ];

  int _selectedCategory = 0;
  final PageController _dealsController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuState>().load();
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _dealsController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = User.fromDto(
        await context.read<AuthRepository>().getProfile(),
      );
      if (!mounted) return;
      context.read<UserProfileState>().setFromUser(
        id: user.id,
        name: user.fullName,
        email: user.email,
        schoolName: user.schoolName,
        canUseEmailPassword: user.canUseEmailPassword,
      );
    } catch (_) {
      // Keep the cached profile when the backend is unavailable.
    }
  }

  List<FoodItem> _filteredItems(List<FoodItem> source) {
    final category = categories[_selectedCategory].toLowerCase();
    if (_selectedCategory == 0) return source.take(4).toList();
    return source
        .where((item) => item.category.toLowerCase() == category)
        .take(4)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileState>();
    final menu = context.watch<MenuState>();
    final items = switch (menu.items) {
      AsyncData<List<FoodItem>>(:final data) => _filteredItems(data),
      _ => _filteredItems(kMenuItems),
    };

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: CartBar(
        onViewCart: () => Navigator.pushNamed(context, '/order-summary'),
        onCheckout: () => Navigator.pushNamed(context, '/order-summary'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                profile: profile,
                onNotifications: () =>
                    Navigator.pushNamed(context, NotificationScreen.routeName),
                onProfile: () =>
                    AppShellScope.maybeOf(context)?.setTab(AppTab.settings),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _ActiveOrderCard(),
                  const SizedBox(height: 16),
                  _DealsCarousel(controller: _dealsController),
                  const SizedBox(height: 8),
                  _DealIndicators(controller: _dealsController),
                  const SizedBox(height: 12),
                  _CategoryBar(
                    selected: _selectedCategory,
                    onSelected: (index) =>
                        setState(() => _selectedCategory = index),
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    onSeeAll: () =>
                        AppShellScope.maybeOf(context)?.setTab(AppTab.menu),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    reverseDuration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _FoodGrid(
                      key: ValueKey(_selectedCategory),
                      items: items,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _ExpressBanner(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.profile,
    required this.onNotifications,
    required this.onProfile,
  });

  final UserProfileState profile;
  final VoidCallback onProfile;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = profile.name.trim().split(RegExp(r'\s+')).first;
    final muted = context.mutedColor;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: theme.brightness == Brightness.dark
                ? AppTheme.darkBorder
                : AppTheme.border,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'CADT Campus',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              Icon(Icons.keyboard_arrow_down, size: 18, color: muted),
              const Spacer(),
              IconButton(
                onPressed: onNotifications,
                icon: const Icon(Icons.notifications_outlined),
              ),
              Semantics(
                button: true,
                label: 'Open profile settings',
                child: InkWell(
                  onTap: onProfile,
                  customBorder: const CircleBorder(),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.secondary,
                    backgroundImage: profile.photo != null
                        ? FileImage(profile.photo!)
                        : null,
                    child: profile.photo == null
                        ? Text(
                            profile.initials,
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hi, $firstName 👋',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 5),
              Text(
                'Engineering Dining Hall B',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.keyboard_arrow_down, size: 17, color: muted),
              const Spacer(),
              const _KitchenStatus(),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Tag(
                text: 'ACTIVE ORDER #CE-8821',
                background: Color(0xFFE6F4EA),
                foreground: Color(0xFF137333),
              ),
              const Spacer(),
              const _Tag(
                text: 'Ready in 12 Mins',
                background: AppTheme.secondary,
                foreground: AppTheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Lunch Pickup Ready in 12 Mins',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: context.mutedColor),
              SizedBox(width: 5),
              Text(
                '12:15 PM - 12:35 PM',
                style: TextStyle(fontSize: 11, color: context.mutedColor),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.storefront_outlined,
                size: 14,
                color: context.mutedColor,
              ),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Counter 02 (Grill Station)',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: context.mutedColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  AppShellScope.maybeOf(context)?.setTab(AppTab.qr),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('View QR Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KitchenStatus extends StatelessWidget {
  const _KitchenStatus();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 7, color: AppTheme.tertiary),
        SizedBox(width: 5),
        Text(
          'Kitchen Open',
          style: TextStyle(
            color: AppTheme.tertiaryDark,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ExpressBanner extends StatelessWidget {
  const _ExpressBanner();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.secondary,
      border: Border.all(color: AppTheme.border),
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE0BC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.bolt_outlined, color: AppTheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rush Hour Express Lanes Active',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Grab & go lockers 1-12 operating normally.',
                style: TextStyle(color: context.mutedColor, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DealsCarousel extends StatelessWidget {
  const _DealsCarousel({required this.controller});

  final PageController controller;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 150,
    child: PageView.builder(
      controller: controller,
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final page = controller.hasClients && controller.page != null
                ? controller.page!
                : 0.0;
            final distance = (page - index).abs().clamp(0.0, 1.0);
            return Opacity(
              opacity: 1.0 - (distance * 0.18),
              child: Transform.scale(
                scale: 1.0 - (distance * 0.035),
                child: child,
              ),
            );
          },
          child: _DealCard(index: index),
        ),
      ),
    ),
  );
}

class _DealCard extends StatelessWidget {
  const _DealCard({required this.index});

  final int index;

  static const _headlines = [
    'Chef Special: Grilled Salmon Teriyaki',
    'Fresh Bowls, Fast Pickup',
    'Afternoon Drinks, Campus Price',
  ];
  static const _subtitles = [
    '15% off today with code TERA15',
    'Save 10% on selected grain bowls',
    'Free size upgrade after 2 PM',
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(
          color: Color(0x22000000),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CAMPUS DEAL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                _headlines[index],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                _subtitles[index],
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              SizedBox(
                height: 28,
                child: ElevatedButton(
                  onPressed: () =>
                      AppShellScope.maybeOf(context)?.setTab(AppTab.menu),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Order Now',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'asset/foods/salmon_teriyaki.png',
            width: 92,
            height: 118,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 92,
              height: 118,
              color: AppTheme.primaryLight,
              child: const Icon(
                Icons.restaurant_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _DealIndicators extends StatelessWidget {
  const _DealIndicators({required this.controller});

  final PageController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      final page = controller.hasClients && controller.page != null
          ? controller.page!.round()
          : 0;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final active = index == page;
          return Container(
            width: active ? 18 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: active ? AppTheme.primary : AppTheme.border,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      );
    },
  );
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: List.generate(_HomeScreenState.categories.length, (index) {
        final active = selected == index;
        return Padding(
          padding: EdgeInsets.only(
            right: index == _HomeScreenState.categories.length - 1 ? 0 : 8,
          ),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(index);
            },
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: active ? AppTheme.primary : Theme.of(context).cardColor,
                border: Border.all(
                  color: active
                      ? AppTheme.primary
                      : (Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkBorder
                            : AppTheme.border),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _HomeScreenState.categories[index],
                style: TextStyle(
                  color: active ? Colors.white : context.mutedColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Text(
          'Popular for Lunch',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      TextButton(
        onPressed: onSeeAll,
        child: const Text(
          'See All',
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class _FoodGrid extends StatelessWidget {
  const _FoodGrid({super.key, required this.items});

  final List<FoodItem> items;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: items.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: .72,
    ),
    itemBuilder: (context, index) => _FoodCard(item: items[index]),
  );
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);
    void addToCart() {
      HapticFeedback.selectionClick();
      cart.add(item);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showDetails(context),
      child: Consumer<CartModel>(
        builder: (context, cart, _) => _SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: SizedBox(
                      height: 116,
                      width: double.infinity,
                      child: _HomeFoodImage(item: item),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .70),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '5 min wait',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 7, 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: context.mutedColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const Spacer(),
                        _CartControl(
                          quantity: cart.quantityOf(item.id),
                          onAdd: addToCart,
                          onIncrement: () => cart.increment(item.id),
                          onDecrement: () => cart.decrement(item.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (context, controller) => Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            controller: controller,
            child: FoodItemCard(
              item: item,
              isExpanded: true,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartControl extends StatelessWidget {
  const _CartControl({
    required this.quantity,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return SizedBox(
        width: 36,
        height: 36,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: onAdd,
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
          ),
          icon: const Icon(Icons.add, size: 20),
        ),
      );
    }

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 30, height: 36),
            color: AppTheme.primary,
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 30, height: 36),
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class _FoodPlaceholder extends StatelessWidget {
  const _FoodPlaceholder({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).brightness == Brightness.dark
        ? AppTheme.darkGreenSurface
        : AppTheme.secondary,
    child: const Center(
      child: Icon(Icons.restaurant_outlined, size: 35, color: AppTheme.primary),
    ),
  );
}

class _HomeFoodImage extends StatelessWidget {
  const _HomeFoodImage({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl;
    final imagePath = item.imagePath;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _assetOrPlaceholder(imagePath),
      );
    }

    return _assetOrPlaceholder(imagePath);
  }

  Widget _assetOrPlaceholder(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return _FoodPlaceholder(item: item);
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _FoodPlaceholder(item: item),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: dark ? AppTheme.darkBorder : AppTheme.border),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: foreground,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
