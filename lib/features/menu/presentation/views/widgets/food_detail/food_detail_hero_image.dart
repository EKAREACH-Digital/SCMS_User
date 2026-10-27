import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/widgets/food_image_placeholder.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';

/// Full-width hero image for the food detail page.
///
/// Falls back to [FoodImagePlaceholder] when there is no image URL or asset,
/// or when the image fails to load.
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
                  const FoodImagePlaceholder(iconSize: 80),
            )
          : hasAsset
          ? Image.asset(
              item.imagePath!,
              fit: BoxFit.cover,
              errorBuilder: (context, err, st) =>
                  const FoodImagePlaceholder(iconSize: 80),
            )
          : const FoodImagePlaceholder(iconSize: 80),
    );
  }
}
