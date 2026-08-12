/// Mirrors a backend `MenuItem` (`GET /menu-items`). Prices arrive as decimal
/// strings. The backend has no ratings/tags, so the app supplies those visually
/// (gradient + icon placeholders); photos it does have, per item, in
/// [imageUrl].
class MenuItemDto {
  final String id;
  final String name;
  final String description;
  final double price;

  /// Category name (e.g. "Breakfast", "Lunch", "Drinks"), or null if uncategorised.
  final String? categoryName;
  final String availabilityStatus;

  /// The school this item belongs to — the tenant an order for it is scoped to.
  final String? schoolId;

  /// Per-dish photo (`image_url`), or null when the item has none — the card
  /// falls back to its gradient + icon placeholder.
  final String? imageUrl;

  const MenuItemDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryName,
    required this.availabilityStatus,
    required this.schoolId,
    this.imageUrl,
  });

  factory MenuItemDto.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    // Items seeded without a photo carry an empty string rather than null.
    final image = json['image_url'] as String?;
    return MenuItemDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      price: _toDouble(json['price']),
      categoryName:
          category is Map<String, dynamic> ? category['name'] as String? : null,
      availabilityStatus: json['availability_status'] as String? ?? 'available',
      schoolId: json['school_id'] as String?,
      imageUrl: (image != null && image.isNotEmpty) ? image : null,
    );
  }

  static double _toDouble(dynamic value) => switch (value) {
        num n => n.toDouble(),
        String s => double.tryParse(s) ?? 0.0,
        _ => 0.0,
      };
}

/// A weekly menu (`GET /menus`) — the schedule a manager publishes covering a
/// date range. The dishes themselves come from [MenuEntryDto].
class MenuDto {
  final String id;
  final String name;

  /// Inclusive date range the menu covers, as `yyyy-MM-dd`.
  final DateTime validFrom;
  final DateTime validTo;

  /// `draft` | `published` | `archived`. Only published menus are shown.
  final String status;

  const MenuDto({
    required this.id,
    required this.name,
    required this.validFrom,
    required this.validTo,
    required this.status,
  });

  bool coversDate(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(validFrom) && !d.isAfter(validTo);
  }

  factory MenuDto.fromJson(Map<String, dynamic> json) => MenuDto(
        id: json['id'] as String,
        name: (json['name'] as String?) ?? 'Menu',
        validFrom: DateTime.tryParse(json['valid_from'] as String? ?? '') ??
            DateTime.now(),
        validTo: DateTime.tryParse(json['valid_to'] as String? ?? '') ??
            DateTime.now(),
        status: (json['status'] as String?) ?? 'draft',
      );
}

/// One line of a weekly menu (`GET /menu-menu-items?menu_id=`): a dish, the
/// day it's served, and how much of it was scheduled.
class MenuEntryDto {
  final String id;
  final MenuItemDto menuItem;

  /// Day of the week the dish is served on, **0 = Monday … 6 = Sunday**, or
  /// null meaning "served every day of this menu". This matches the manager
  /// dashboard's convention exactly — see `groupByDayAndSession` there.
  final int? dayOfWeek;

  final int quantityAvailable;

  const MenuEntryDto({
    required this.id,
    required this.menuItem,
    required this.dayOfWeek,
    required this.quantityAvailable,
  });

  factory MenuEntryDto.fromJson(Map<String, dynamic> json) => MenuEntryDto(
        id: json['id'] as String,
        menuItem:
            MenuItemDto.fromJson(json['menuItem'] as Map<String, dynamic>),
        dayOfWeek: (json['day_of_week'] as num?)?.toInt(),
        quantityAvailable:
            (json['quantity_available'] as num?)?.toInt() ?? 0,
      );
}

/// A published menu together with the dishes scheduled on it.
class WeeklyMenuDto {
  const WeeklyMenuDto({required this.menu, required this.entries});

  final MenuDto menu;
  final List<MenuEntryDto> entries;
}
