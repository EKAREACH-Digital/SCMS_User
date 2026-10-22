import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/constants/food_visuals.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';

/// Full-width hero image for the food detail page.
///
/// Falls back to the gradient placeholder when there is no image URL or asset.
class FoodDetailHeroImage extends StatelessWidget {
  const FoodDetailHeroImage({super.key, required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    final hasUrl = item.imageUrl != null && item.imageUrl!.isNotEmpty;
    final hasAsset = item.imagePath != null && item.imagePath!.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: hasUrl
          ? Image.network(
              item.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, err, st) =>
                  _GradientPlaceholder(item: item),
            )
          : hasAsset
          ? Image.asset(
              item.imagePath!,
              fit: BoxFit.cover,
              errorBuilder: (context, err, st) =>
                  _GradientPlaceholder(item: item),
            )
          : _GradientPlaceholder(item: item),
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  const _GradientPlaceholder({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    final idx = item.colorSeed % kFoodGradients.length;
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
        size: 80,
        color: AppColors.onPrimary.withValues(alpha: 0.7),
      ),
    );
  }
}
