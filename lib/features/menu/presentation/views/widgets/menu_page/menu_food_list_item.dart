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

/// Horizontal list-row for the See All / Menu page.
/// Thumbnail left — name + tag + price right — `+` button far right.
class MenuFoodListItem extends StatelessWidget {
  const MenuFoodListItem({super.key, required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('${AppPaths.foodDetail}/${item.id}', extra: item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.cardColor,
          // borderRadius: BorderRadius.circular(10),
          borderRadius: BorderRadius.circular(8), // History card
          boxShadow: [
            // BoxShadow(
            //   color: AppColors.primary.withValues(alpha: 0.05),
            //   blurRadius: 10,
            //   offset: const Offset(0, 3),
            // ),

            // Version the same as history card
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            _Thumbnail(item: item),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.heading3.copyWith(
                      color: context.textColor,
                      fontWeight: AppFonts.semiBold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: AppFonts.heading3.copyWith(
                      color: AppColors.primary,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Watches the cart quantity for this item.
            // When quantity is 0 --> shows a `+` circle that adds the item
            // directly to the cart on tap.
            // When quantity > 0 --> transforms into a QuantitySelector so the
            // user can adjust without navigating away.
            // Tapping the row itself still navigates to the detail page.
            Consumer<CartViewModel>(
              builder: (context, cart, _) {
                final qty = cart.quantityOf(item.id);
                if (qty == 0) {
                  return _CircleAddButton(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      cart.add(item);
                    },
                  );
                }
                return QuantitySelector(
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
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    final hasUrl = item.imageUrl != null && item.imageUrl!.isNotEmpty;
    final hasAsset = item.imagePath != null && item.imagePath!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 76,
        height: 76,
        child: hasUrl
            ? Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, err, st) =>
                    const FoodImagePlaceholder(),
              )
            : hasAsset
            ? Image.asset(
                item.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, err, st) =>
                    const FoodImagePlaceholder(),
              )
            : const FoodImagePlaceholder(),
      ),
    );
  }
}

/// Initial state: a single filled circle with a `+` icon.
/// Tapping immediately adds one unit to the cart, which causes the parent
/// [Consumer] to rebuild with qty > 0 and swap this for [QuantitySelector].
class _CircleAddButton extends StatelessWidget {
  const _CircleAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
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
