import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/cart/cart_model.dart';
import '../../../model/food/food_item.dart';
import '../../../theme/app_theme.dart';
import '../../../ui/states/menu_state.dart';
import '../../../ui/utils/async_value.dart';
import '../../widgets/cart_bar.dart';
import 'weekly_menu_screen.dart';

enum _SortBy { recommended, priceLowHigh, priceHighLow, rating }

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  static const routeName = '/menu';

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedFilter = 0;
  String _search = '';
  String? _expandedItemId;
  _SortBy _sortBy = _SortBy.recommended;
  final ScrollController _scrollController = ScrollController();

  // Mirrors the real backend categories so nothing is hidden (Dinner was
  // missing before). The chip row scrolls horizontally.
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MenuState>().load();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<FoodItem> _visibleItems(List<FoodItem> all) {
    final cat = _cats[_selectedFilter];
    final list = all.where((f) {
      final matchCat = cat.isEmpty || f.category == cat;
      final matchSearch =
          _search.isEmpty ||
          f.name.toLowerCase().contains(_search.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    switch (_sortBy) {
      case _SortBy.priceLowHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
      case _SortBy.priceHighLow:
        list.sort((a, b) => b.price.compareTo(a.price));
      case _SortBy.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case _SortBy.recommended:
        break;
    }
    return list;
  }

  Widget _buildItemsBody(BuildContext context, List<FoodItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 36,
                color: AppTheme.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.menuEmptyTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.menuEmptyBody,
              style: TextStyle(
                fontSize: 13,
                color: context.mutedColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isExpanded = _expandedItemId == item.id;
        return _FadeInItem(
          // Re-key per filter+item so the fade replays on switch.
          key: ValueKey('${_selectedFilter}_${item.id}'),
          index: index,
          child: Consumer<CartModel>(
            builder: (context, _, _) {
              return FoodItemCard(
                item: item,
                isExpanded: isExpanded,
                onTap: () => setState(() {
                  _expandedItemId = isExpanded ? null : item.id;
                }),
              );
            },
          ),
        );
      },
    );
  }

  void _onFilterChanged(int i) {
    HapticFeedback.selectionClick();
    setState(() => _selectedFilter = i);
    // Smoothly scroll back to the top when switching categories.
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSortMenu() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        current: _sortBy,
        onSelected: (s) => setState(() => _sortBy = s),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);
    final menuAsync = context.watch<MenuState>().items;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.green.withValues(alpha: 0.08), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Text(
          'Smart Canteen',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: context.textColor,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          // Read-only view of what the canteen is serving each day this week.
          Tooltip(
            message: AppLocalizations.of(context)!.weeklyMenuOpen,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pushNamed(context, WeeklyMenuScreen.routeName);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 20,
                  color: context.textColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/order-summary'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 20,
                      color: context.textColor,
                    ),
                  ),
                ),
                if (cart.totalItems > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFE53935,
                            ).withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${cart.totalItems}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: _SearchBar(
                  onChanged: (v) => setState(() => _search = v),
                  onFilterTap: _showSortMenu,
                  isSortActive: _sortBy != _SortBy.recommended,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(_filters.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _ModernFilterChip(
                        label: _filters[i],
                        isSelected: _selectedFilter == i,
                        onTap: () => _onFilterChanged(i),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: switch (menuAsync) {
                  AsyncLoading<List<FoodItem>>() => const Center(
                    child: CircularProgressIndicator(color: AppTheme.green),
                  ),
                  AsyncError<List<FoodItem>>() => _MenuLoadError(
                    onRetry: () => context.read<MenuState>().load(force: true),
                  ),
                  AsyncData<List<FoodItem>>(:final data) => _buildItemsBody(
                    context,
                    _visibleItems(data),
                  ),
                },
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CartBar(
              onViewCart: () => Navigator.pushNamed(context, '/order-summary'),
              // Checkout happens on the order-summary screen (pick session,
              // place the real order, pay, then get the QR coupon).
              onCheckout: () => Navigator.pushNamed(context, '/order-summary'),
            ),
          ),
        ],
      ),
    );
  }
}

class FoodItemCard extends StatefulWidget {
  const FoodItemCard({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onTap,
  });

  final FoodItem item;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  State<FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isFavorite = false;
  late AnimationController _expandController;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(FoodItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded && !oldWidget.isExpanded) {
      _expandController.forward();
    } else if (!widget.isExpanded && oldWidget.isExpanded) {
      _expandController.reverse();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _addItem() {
    final cart = CartProvider.of(context);
    cart.add(widget.item);
  }

  void _increment() {
    final cart = CartProvider.of(context);
    cart.increment(widget.item.id);
  }

  void _decrement() {
    final cart = CartProvider.of(context);
    cart.decrement(widget.item.id);
  }

  int _getCartQuantity() {
    final cart = CartProvider.of(context);
    return cart.quantityOf(widget.item.id);
  }

  Map<String, Color> _getTagColors() => {
    'Soup': Colors.blue,
    'Traditional': AppTheme.green,
    'Sweet': Colors.pink,
    'Spicy': Colors.red,
    'Healthy': Colors.teal,
    'Vegan': Colors.amber,
    'Drink': Colors.lightBlue,
    'Grilled': Colors.orange,
    'Soft': Colors.purple,
    'Simple': Colors.indigo,
    'Quick': Colors.cyan,
    'Cold': Colors.blueAccent,
    'Fresh': Colors.greenAccent,
  };

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'high protein':
      case 'healthy':
        return Colors.teal;
      case 'chef choice':
      case 'grilled':
        return const Color(0xFFB7793E);
      case 'vegetarian':
      case 'vegan':
      case 'fresh':
        return const Color(0xFF3E8E62);
      case 'gluten free':
      case 'traditional':
        return const Color(0xFFB58B5A);
      case 'chilled':
      case 'cold':
        return const Color(0xFF6F7C86);
      default:
        return _getTagColors()[tag] ?? AppTheme.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isExpanded) {
      return _buildExpandedCard(context);
    }
    return _buildCollapsedCard(context);
  }

  Widget _buildCollapsedCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 85,
                        height: 85,
                        child: _FoodImage(item: widget.item, aspectRatio: 1.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: context.textColor,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${widget.item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.green,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: context.mutedColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: widget.item.tags.isNotEmpty
                                  ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: _buildTag(
                                        context,
                                        widget.item.tags.first,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            const SizedBox(width: 8),
                            _buildCartControl(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String tag) {
    final color = _getTagColor(tag);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_tagIcon(tag), size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            tag,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartControl() {
    if (_getCartQuantity() == 0) {
      return _BounceAddButton(onTap: _addItem);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.green.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _decrement,
            child: Container(
              width: 36,
              height: 40,
              alignment: Alignment.center,
              child: const Icon(
                Icons.remove_rounded,
                color: AppTheme.green,
                size: 18,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: AppTheme.green.withValues(alpha: 0.2),
          ),
          SizedBox(
            width: 36,
            height: 40,
            child: Center(
              child: Text(
                '${_getCartQuantity()}',
                style: const TextStyle(
                  color: AppTheme.green,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: AppTheme.green.withValues(alpha: 0.2),
          ),
          GestureDetector(
            onTap: _increment,
            child: Container(
              width: 36,
              height: 40,
              alignment: Alignment.center,
              child: const Icon(
                Icons.add_rounded,
                color: AppTheme.green,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: _FoodImage(item: widget.item, aspectRatio: 16 / 9),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => setState(() => _isFavorite = !_isFavorite),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        color: _isFavorite ? Colors.red : Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 64,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB74D).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _ShimmerStar(size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.item.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: context.textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.item.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: context.mutedColor,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.menuFoodType,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.mutedColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.item.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getTagColor(tag).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getTagColor(tag).withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _tagIcon(tag),
                              size: 13,
                              color: _getTagColor(tag),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              tag,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getTagColor(tag),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildNutritionInfo(context),
                  const SizedBox(height: 16),
                  _buildAllergenInfo(context),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.menuPrice,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.mutedColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${widget.item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.green,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      if (_getCartQuantity() == 0)
                        _BounceAddButton(
                          onTap: _addItem,
                          size: 56,
                          iconSize: 28,
                          radius: 14,
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.green.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: _decrement,
                                child: Container(
                                  width: 48,
                                  height: 56,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.remove_rounded,
                                    color: AppTheme.green,
                                    size: 22,
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: AppTheme.green.withValues(alpha: 0.2),
                              ),
                              SizedBox(
                                width: 48,
                                height: 56,
                                child: Center(
                                  child: Text(
                                    '${_getCartQuantity()}',
                                    style: const TextStyle(
                                      color: AppTheme.green,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: AppTheme.green.withValues(alpha: 0.2),
                              ),
                              GestureDetector(
                                onTap: _increment,
                                child: Container(
                                  width: 48,
                                  height: 56,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: AppTheme.green,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.menuNutritionInfo,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.mutedColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.green.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _nutritionItem('Calories', '250-350', 'kcal'),
              _nutritionItem('Protein', '12-15', 'g'),
              _nutritionItem('Fat', '8-12', 'g'),
              _nutritionItem('Carbs', '35-45', 'g'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _nutritionItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppTheme.green,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 9,
            color: AppTheme.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAllergenInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.menuAllergenInfo,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.mutedColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_rounded, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.menuAllergenBody,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FoodImage extends StatefulWidget {
  const _FoodImage({required this.item, this.aspectRatio = 1.0});

  final FoodItem item;
  final double aspectRatio;

  @override
  State<_FoodImage> createState() => _FoodImageState();
}

class _FoodImageState extends State<_FoodImage> {
  late ImageProvider _imageProvider;
  bool _imageLoaded = false;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    _initializeImage();
  }

  bool get _hasImage =>
      (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty) ||
      (widget.item.imagePath != null && widget.item.imagePath!.isNotEmpty);

  void _initializeImage() {
    final url = widget.item.imageUrl;
    final asset = widget.item.imagePath;
    try {
      if (url != null && url.isNotEmpty) {
        _imageProvider = NetworkImage(url);
      } else if (asset != null && asset.isNotEmpty) {
        _imageProvider = AssetImage(asset);
      } else {
        setState(() => _imageError = true);
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _precacheImage();
      });
    } catch (e) {
      setState(() => _imageError = true);
    }
  }

  void _precacheImage() {
    if (!mounted) return;
    try {
      precacheImage(_imageProvider, context).then(
        (_) {
          if (mounted) {
            setState(() => _imageLoaded = true);
          }
        },
        onError: (error, stackTrace) {
          if (mounted) {
            setState(() => _imageError = true);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _imageError = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    if (!_hasImage || _imageError) {
      return _buildPlaceholder();
    }

    if (!_imageLoaded) {
      return _buildLoadingPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image(
        image: _imageProvider,
        fit: BoxFit.cover,
        errorBuilder: (_, exception, stackTrace) {
          Future.microtask(() {
            if (mounted) {
              setState(() => _imageError = true);
            }
          });
          return _buildPlaceholder();
        },
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    final idx = widget.item.colorSeed % kFoodGradients.length;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kFoodGradients[idx][0].withValues(alpha: 0.3),
            kFoodGradients[idx][1].withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.green.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final idx = widget.item.colorSeed % kFoodGradients.length;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: kFoodGradients[idx],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          kFoodIcons[idx % kFoodIcons.length],
          color: Colors.white.withValues(alpha: 0.8),
          size: 40,
        ),
      ),
    );
  }
}

// ── Modern Filter Chip ────────────────────────────────────────────────────

class _ModernFilterChip extends StatefulWidget {
  const _ModernFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_ModernFilterChip> createState() => _ModernFilterChipState();
}

class _ModernFilterChipState extends State<_ModernFilterChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? null
                : Border.all(color: context.borderColor, width: 1.2),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.green.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: widget.isSelected ? Colors.white : context.mutedColor,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated search bar with filter/sort button ───────────────────────────────

class _SearchBar extends StatefulWidget {
  const _SearchBar({
    required this.onChanged,
    required this.onFilterTap,
    required this.isSortActive,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final bool isSortActive;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search field — grows/elevates and shows a green border when focused.
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _focused
                    ? AppTheme.green.withValues(alpha: 0.6)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _focused
                      ? AppTheme.green.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: _focused ? 16 : 12,
                  offset: Offset(0, _focused ? 5 : 3),
                ),
              ],
            ),
            child: TextField(
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: 'Find your favorite food',
                hintStyle: TextStyle(
                  color: context.mutedColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: AnimatedScale(
                    scale: _focused ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.search_rounded,
                      color: _focused ? AppTheme.green : context.mutedColor,
                      size: 20,
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.textColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Sort / filter button
        GestureDetector(
          onTap: widget.onFilterTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: widget.isSortActive
                  ? const LinearGradient(
                      colors: [AppTheme.greenDark, AppTheme.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.isSortActive ? null : context.cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: widget.isSortActive
                      ? AppTheme.green.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 22,
              color: widget.isSortActive ? Colors.white : context.textColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sort options bottom sheet ─────────────────────────────────────────────────

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current, required this.onSelected});

  final _SortBy current;
  final ValueChanged<_SortBy> onSelected;

  static const _options = [
    (_SortBy.recommended, 'Recommended', Icons.auto_awesome_rounded),
    (_SortBy.priceLowHigh, 'Price: Low to High', Icons.arrow_upward_rounded),
    (_SortBy.priceHighLow, 'Price: High to Low', Icons.arrow_downward_rounded),
    (_SortBy.rating, 'Top Rated', Icons.star_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppLocalizations.of(context)!.commonSortBy,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 12),
            for (final (value, label, icon) in _options)
              _SortTile(
                label: label,
                icon: icon,
                selected: current == value,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(value);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  const _SortTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.green.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.green : context.borderColor,
            width: selected ? 1.5 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppTheme.green : context.mutedColor,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppTheme.green : context.textColor,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.green,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Staggered fade-in wrapper for list items ──────────────────────────────────

class _FadeInItem extends StatefulWidget {
  const _FadeInItem({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_FadeInItem> createState() => _FadeInItemState();
}

class _FadeInItemState extends State<_FadeInItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    // Stagger by index, capped so long lists don't lag.
    final delay = Duration(milliseconds: 60 * (widget.index.clamp(0, 8)));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Tag icon mapping ──────────────────────────────────────────────────────────

IconData _tagIcon(String tag) {
  switch (tag) {
    case 'Soup':
      return Icons.ramen_dining_rounded;
    case 'Traditional':
      return Icons.rice_bowl_rounded;
    case 'Sweet':
      return Icons.cake_rounded;
    case 'Spicy':
      return Icons.local_fire_department_rounded;
    case 'Healthy':
      return Icons.eco_rounded;
    case 'Vegan':
      return Icons.spa_rounded;
    case 'Drink':
      return Icons.local_cafe_rounded;
    case 'Grilled':
      return Icons.outdoor_grill_rounded;
    case 'Soft':
      return Icons.bubble_chart_rounded;
    case 'Simple':
      return Icons.restaurant_rounded;
    case 'Quick':
      return Icons.bolt_rounded;
    case 'Cold':
      return Icons.ac_unit_rounded;
    case 'Fresh':
      return Icons.grass_rounded;
    default:
      return Icons.label_rounded;
  }
}

// ── Shimmering rating star ─────────────────────────────────────────────────────

class _ShimmerStar extends StatefulWidget {
  const _ShimmerStar({this.size = 13});

  final double size;

  @override
  State<_ShimmerStar> createState() => _ShimmerStarState();
}

class _ShimmerStarState extends State<_ShimmerStar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Gentle shimmer — scale + brightness pulse.
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.scale(
          scale: 1.0 + 0.12 * t,
          child: Icon(
            Icons.star_rounded,
            color: Color.lerp(Colors.white, const Color(0xFFFFF3D6), t),
            size: widget.size,
          ),
        );
      },
    );
  }
}

// ── Bouncing add (+) button with ripple ───────────────────────────────────────

class _BounceAddButton extends StatefulWidget {
  const _BounceAddButton({
    required this.onTap,
    this.size = 40,
    this.iconSize = 20,
    this.radius = 8,
  });

  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final double radius;

  @override
  State<_BounceAddButton> createState() => _BounceAddButtonState();
}

class _BounceAddButtonState extends State<_BounceAddButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    // Bounce: shrink then overshoot back via elasticOut.
    _scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _controller
      ..reset()
      ..forward();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Material(
        color: AppTheme.green,
        borderRadius: BorderRadius.circular(widget.radius),
        elevation: 0,
        shadowColor: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.radius),
          splashColor: Colors.white.withValues(alpha: 0.3),
          onTap: _handleTap,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.green.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: widget.iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown when the menu fails to load from the backend.
class _MenuLoadError extends StatelessWidget {
  const _MenuLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 40, color: AppTheme.green),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.menuErrorTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context)!.commonRetry),
          ),
        ],
      ),
    );
  }
}
