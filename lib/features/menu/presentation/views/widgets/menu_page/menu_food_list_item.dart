import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/constants/food_visuals.dart';
import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/widgets/food_tag_chip.dart';
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
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
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
                  switch (foodDescriptiveTag(item.tags)) {
                    final tag? => FoodTagChip(tag: tag),
                    null => Text(
                      item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.heading5.copyWith(
                        color: context.mutedColor,
                      ),
                    ),
                  },
                  const SizedBox(height: 6),
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
            Consumer<CartViewModel>(
              builder: (context, cart, _) => _AddButton(
                quantity: cart.quantityOf(item.id),
                onAdd: () {
                  HapticFeedback.selectionClick();
                  cart.add(item);
                },
                onIncrement: () {
                  HapticFeedback.selectionClick();
                  cart.increment(item.id);
                },
                onDecrement: () {
                  HapticFeedback.selectionClick();
                  cart.decrement(item.id);
                },
              ),
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
    final idx = item.colorSeed % kFoodGradients.length;
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
                errorBuilder: (context, err, st) => _Placeholder(idx: idx),
              )
            : hasAsset
            ? Image.asset(
                item.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, err, st) => _Placeholder(idx: idx),
              )
            : _Placeholder(idx: idx),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.idx});

  final int idx;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: kFoodGradients[idx],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        kFoodIcons[idx % kFoodIcons.length],
        color: AppColors.onPrimary.withValues(alpha: 0.8),
        size: 28,
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
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
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(
            Icons.add_rounded,
            color: AppColors.onPrimary,
            size: 18,
          ),
        ),
      );
    }

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: const SizedBox(
              width: 30,
              height: 32,
              child: Icon(
                Icons.remove_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ),
          Text(
            '$quantity',
            style: AppFonts.heading4.copyWith(
              color: AppColors.primary,
              fontWeight: AppFonts.bold,
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: const SizedBox(
              width: 30,
              height: 32,
              child: Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
