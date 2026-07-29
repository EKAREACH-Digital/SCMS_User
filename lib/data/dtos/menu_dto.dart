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
