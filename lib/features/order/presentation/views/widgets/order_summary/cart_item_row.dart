import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/widgets/food_image_placeholder.dart';
import 'package:smart_canteen_user_frontend/core/widgets/quantity_selector.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/cart_entry.dart';

/// Single row in the cart list: thumbnail · name · price · delete · quantity.
///
/// Layout matches the order-summary design:
///   [image] | name (top)
///            price
///            [trash]  ···  [− qty +]
class CartItemRow extends StatelessWidget {
  const CartItemRow({
    super.key,
    required this.entry,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  final CartEntry entry;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _CartThumbnail(entry: entry),
          const SizedBox(width: 12),
          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.item.name.isNotEmpty)
                  Text(
                    entry.item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.heading3.copyWith(
                      color: context.textColor,
                      fontWeight: AppFonts.semiBold,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '\$${(entry.item.price * entry.quantity).toStringAsFixed(2)}',
                  style: AppFonts.heading3.copyWith(
                    color: AppColors.primary,
                    fontWeight: AppFonts.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Delete + quantity controls
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DeleteButton(onDelete: onDelete),
                  const SizedBox(width: 20),
                  QuantitySelector(
                    quantity: entry.quantity,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement,
                    minQuantity: 1,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDelete,
      child: const Icon(
        Icons.delete_outline_rounded,
        color: AppColors.accentRed,
        size: 28,
      ),
    );
  }
}

class _CartThumbnail extends StatelessWidget {
  const _CartThumbnail({required this.entry});

  final CartEntry entry;

  @override
  Widget build(BuildContext context) {
    final hasUrl =
        entry.item.imageUrl != null && entry.item.imageUrl!.isNotEmpty;
    final hasAsset =
        entry.item.imagePath != null && entry.item.imagePath!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 88,
        height: 88,
        child: hasUrl
            ? Image.network(
                entry.item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const FoodImagePlaceholder(),
              )
            : hasAsset
            ? Image.asset(
                entry.item.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const FoodImagePlaceholder(),
              )
            : const FoodImagePlaceholder(),
      ),
    );
  }
}
