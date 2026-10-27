import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/widgets/food_image_placeholder.dart';
import 'package:smart_canteen_user_frontend/core/widgets/quantity_selector.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/cart_viewmodel.dart';

/// 2-column food grid used on the Home screen.
class HomeFoodGrid extends StatelessWidget {
  const HomeFoodGrid({super.key, required this.items});

  final List<FoodItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // Square image + ~60px for the two text rows below.
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) => HomeFoodCard(item: items[index]),
    );
  }
}

/// Card layout:
///   Column
///   ├── Stack (image + positioned circular + button)
///   │   ├── ClipRRect > AspectRatio 1:1 (square image)
///   │   └── Positioned bottom-right: circular add button
///   └── Padding (name text, price text)
class HomeFoodCard extends StatelessWidget {
  const HomeFoodCard({super.key, required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('${AppPaths.foodDetail}/${item.id}', extra: item);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _FoodImage(item: item),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                // Watches the cart quantity for this item.
                // When quantity is 0 --> shows a '+' circle that adds the item
                // directly to the cart on tap.
                // When quantity > 0 --> transforms into an inline QuantitySelector
                // so the user can adjust without leaving the screen.
                // Tapping the card image still navigates to the detail page.
                child: Consumer<CartViewModel>(
                  builder: (context, cart, _) {
                    final qty = cart.quantityOf(item.id);
                    if (qty == 0) {
                      return _CircularAddButton(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          cart.add(item);
                        },
                      );
                    }
                    return _OverlayQuantity(
                      quantity: qty,
                      onIncrement: () {
                        HapticFeedback.lightImpact();
                        cart.increment(item.id);
                      },
                      onDecrement: () {
                        HapticFeedback.lightImpact();
                        cart.decrement(item.id);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Text details
          const SizedBox(height: 8),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.heading4.copyWith(
              color: context.textColor,
              fontWeight: AppFonts.semiBold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '\$${item.price.toStringAsFixed(2)}',
            style: AppFonts.heading4.copyWith(
              color: AppColors.primary,
              fontWeight: AppFonts.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodImage extends StatelessWidget {
  const _FoodImage({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    final hasUrl = item.imageUrl != null && item.imageUrl!.isNotEmpty;
    final hasAsset = item.imagePath != null && item.imagePath!.isNotEmpty;

    if (hasUrl) {
      return Image.network(
        item.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const FoodImagePlaceholder(iconSize: 36),
      );
    }
    if (hasAsset) {
      return Image.asset(
        item.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const FoodImagePlaceholder(iconSize: 36),
      );
    }
    return const FoodImagePlaceholder(iconSize: 36);
  }
}

/// Initial state: a single filled circle with a `+` icon.
/// Tapping immediately adds one unit to the cart, which causes the parent
/// [Consumer] to rebuild with qty > 0 and swap this for [_OverlayQuantity].
class _CircularAddButton extends StatelessWidget {
  const _CircularAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.onPrimary,
          size: 18,
        ),
      ),
    );
  }
}

/// Transformed state: replaces the `+` circle once qty > 0.
/// Uses [QuantitySelector] at a compact size to fit the image overlay.
/// Decrementing to 0 causes the parent [Consumer] to swap back to
/// [_CircularAddButton].
class _OverlayQuantity extends StatelessWidget {
  const _OverlayQuantity({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: context.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
      ),
      child: QuantitySelector(
        quantity: quantity,
        onIncrement: onIncrement,
        onDecrement: onDecrement,
        size: 26,
      ),
    );
  }
}
