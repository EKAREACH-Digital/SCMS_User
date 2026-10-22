import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/constants/food_visuals.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/widgets/quantity_selector.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/cart_entry.dart';

/// Single row in the cart list: thumbnail + name + price + delete + quantity.
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
        children: [
          _CartThumbnail(entry: entry),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.accentRed,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              QuantitySelector(
                quantity: entry.quantity,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
                minQuantity: 1,
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartThumbnail extends StatelessWidget {
  const _CartThumbnail({required this.entry});

  final CartEntry entry;

  @override
  Widget build(BuildContext context) {
    final idx = entry.item.colorSeed % kFoodGradients.length;
    final hasUrl =
        entry.item.imageUrl != null && entry.item.imageUrl!.isNotEmpty;
    final hasAsset =
        entry.item.imagePath != null && entry.item.imagePath!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 64,
        height: 64,
        child: hasUrl
            ? Image.network(
                entry.item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, err, st) => _Placeholder(idx: idx),
              )
            : hasAsset
            ? Image.asset(
                entry.item.imagePath!,
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
        size: 24,
      ),
    );
  }
}
