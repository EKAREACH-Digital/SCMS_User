import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Colour for a food tag. Synonyms share a colour ("Healthy" and "High
/// Protein" are both teal) so the same dish reads consistently wherever its
/// tags surface.
Color foodTagColor(String tag) {
  switch (tag.toLowerCase()) {
    case 'high protein':
    case 'healthy':
      return Colors.teal;
    case 'chef choice':
    case 'grilled':
      return const Color(0xFFB7793E);
    case 'vegetarian':
    case 'vegan':
    case 'fresh':
      return const Color(0xFF3E8E62);
    case 'gluten free':
    case 'traditional':
      return const Color(0xFFB58B5A);
    case 'chilled':
    case 'cold':
      return const Color(0xFF6F7C86);
    case 'soup':
      return Colors.blue;
    case 'sweet':
      return Colors.pink;
    case 'spicy':
      return Colors.red;
    case 'drink':
      return Colors.lightBlue;
    case 'soft':
      return Colors.purple;
    case 'simple':
      return Colors.indigo;
    case 'quick':
      return Colors.cyan;
    default:
      return AppTheme.primary;
  }
}

IconData foodTagIcon(String tag) {
  switch (tag) {
    case 'Soup':
      return Icons.ramen_dining_rounded;
    case 'Traditional':
      return Icons.rice_bowl_rounded;
    case 'Sweet':
      return Icons.cake_rounded;
    case 'Spicy':
      return Icons.local_fire_department_rounded;
    case 'Healthy':
      return Icons.eco_rounded;
    case 'Vegan':
      return Icons.spa_rounded;
    case 'Drink':
      return Icons.local_cafe_rounded;
    case 'Grilled':
      return Icons.outdoor_grill_rounded;
    case 'Soft':
      return Icons.bubble_chart_rounded;
    case 'Simple':
      return Icons.restaurant_rounded;
    case 'Quick':
      return Icons.bolt_rounded;
    case 'Cold':
      return Icons.ac_unit_rounded;
    case 'Fresh':
      return Icons.grass_rounded;
    default:
      return Icons.label_rounded;
  }
}

/// Meal sessions double as categories, and MenuState synthesises a item's
/// only tag from its category name when the backend supplies one. Those say
/// nothing a card's own context doesn't already say, so they are not worth a
/// chip.
const _categoryTags = {
  'breakfast',
  'lunch',
  'dinner',
  'drinks',
  'snacks',
  'other',
};

/// The first tag that actually describes the dish, or null when an item only
/// carries its category. Callers show something else in that case rather than
/// a chip that repeats the section they are already looking at.
String? foodDescriptiveTag(List<String> tags) {
  for (final tag in tags) {
    if (!_categoryTags.contains(tag.toLowerCase())) return tag;
  }
  return null;
}

/// The tinted tag pill used on food cards across Home and Menu.
class FoodTagChip extends StatelessWidget {
  const FoodTagChip({super.key, required this.tag, this.large = false});

  final String tag;

  /// The roomier variant used in the expanded detail sheet.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final color = foodTagColor(tag);
    return Container(
      padding: large
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(large ? 8 : 6),
        border: Border.all(
          color: color.withValues(alpha: large ? 0.4 : 0.3),
          width: large ? 1 : 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(foodTagIcon(tag), size: large ? 13 : 11, color: color),
          SizedBox(width: large ? 5 : 4),
          Flexible(
            child: Text(
              tag,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: large ? 12 : 10,
                color: color,
                fontWeight: large ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
