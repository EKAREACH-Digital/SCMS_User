import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/constants/food_visuals.dart';
import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/cart_viewmodel.dart';

/// 3-column food grid used on the Home screen.
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
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 172,
      ),
      itemBuilder: (context, index) => HomeFoodCard(item: items[index]),
    );
  }
}

/// Single item card for the home grid: image + name + price + add button.
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
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FoodImage(item: item),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.heading5.copyWith(
                        color: context.textColor,
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: AppFonts.heading5.copyWith(
                            color: AppColors.primary,
                            fontWeight: AppFonts.bold,
                          ),
                        ),
                        Consumer<CartViewModel>(
                          builder: (context, cart, _) => _AddButton(
                            inCart: cart.quantityOf(item.id) > 0,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              cart.add(item);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      child: SizedBox(
        height: 90,
        width: double.infinity,
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
        size: 32,
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.inCart, required this.onTap});

  final bool inCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: inCart ? AppColors.secondary : AppColors.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          inCart ? Icons.check_rounded : Icons.add_rounded,
          color: AppColors.onPrimary,
          size: 14,
        ),
      ),
    );
  }
}
