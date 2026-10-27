import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';

/// Neutral stand-in for a dish photo, shown when an item has no image or its
/// image fails to load. Fills whatever box the caller gives it, so each screen
/// keeps its own size and corner radius.
class FoodImagePlaceholder extends StatelessWidget {
  const FoodImagePlaceholder({super.key, this.iconSize = 28});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.surfaceColor,
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: iconSize,
          color: context.mutedColor,
        ),
      ),
    );
  }
}
