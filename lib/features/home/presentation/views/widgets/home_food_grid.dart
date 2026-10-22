import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/constants/food_visuals.dart';
import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
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
          // ── Image section ─────────────────────────────────────────────
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
                child: Consumer<CartViewModel>(
                  builder: (context, cart, _) => _CircularAddButton(
                    inCart: cart.quantityOf(item.id) > 0,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      cart.add(item);
                    },
                  ),
                ),
              ),
            ],
          ),
          // ── Text details ──────────────────────────────────────────────
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
    final idx = item.colorSeed % kFoodGradients.length;
    final hasUrl = item.imageUrl != null && item.imageUrl!.isNotEmpty;
    final hasAsset = item.imagePath != null && item.imagePath!.isNotEmpty;

    if (hasUrl) {
      return Image.network(
        item.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _Placeholder(idx: idx),
      );
    }
    if (hasAsset) {
      return Image.asset(
        item.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _Placeholder(idx: idx),
      );
    }
    return _Placeholder(idx: idx);
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
      child: Center(
        child: Icon(
          kFoodIcons[idx % kFoodIcons.length],
          color: AppColors.onPrimary.withValues(alpha: 0.8),
          size: 36,
        ),
      ),
    );
  }
}

/// Circular add/check button overlaid at the bottom-right of the image.
class _CircularAddButton extends StatelessWidget {
  const _CircularAddButton({required this.inCart, required this.onTap});

  final bool inCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: inCart ? AppColors.secondary : AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          inCart ? Icons.check_rounded : Icons.add_rounded,
          color: AppColors.onPrimary,
          size: 18,
        ),
      ),
    );
  }
}
