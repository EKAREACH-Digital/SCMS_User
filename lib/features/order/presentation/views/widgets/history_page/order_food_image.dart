import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/widgets/food_image_placeholder.dart';

/// A dish photo for the history screens. The remote photo is preferred — it is
/// the same picture the menu shows; a bundled [imagePath] is only present on
/// optimistically-added orders.
class OrderFoodImage extends StatelessWidget {
  const OrderFoodImage({
    super.key,
    this.imageUrl,
    this.imagePath,
    this.iconSize = 22,
  });

  final String? imageUrl;
  final String? imagePath;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final placeholder = FoodImagePlaceholder(iconSize: iconSize);
    final asset = imagePath == null
        ? placeholder
        : Image.asset(
            imagePath!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder,
          );
    if (imageUrl == null) return asset;
    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder,
      errorBuilder: (_, _, _) => asset,
    );
  }
}
