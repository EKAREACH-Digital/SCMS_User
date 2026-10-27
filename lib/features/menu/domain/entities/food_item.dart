// A dish on the menu — used by the menu/home screens and the cart. Loaded from
// the backend via MenuViewModel.

/// Stand-in photo for dishes the backend has no `image_url` for. Items that do
/// have one render it instead (see MenuItemDto.toEntity).
const String kFallbackFoodImageUrl =
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80';

class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final List<String> tags;
  final String category; // 'breakfast' | 'lunch' | 'drinks'
  final String? imagePath; // bundled asset (local)
  final String? imageUrl; // remote photo (network)

  /// The school (tenant) this dish belongs to — an order is scoped to it.
  final String? schoolId;

  /// The canteen serving this dish on the daily menu.
  final String? canteenId;

  final int? calories;

  /// Portions planned for the day, when the menu says.
  final int? quantityAvailable;

  /// True when the dish is out for the day: show it greyed out and block
  /// ordering.
  final bool soldOut;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.tags,
    required this.category,
    this.imagePath,
    this.imageUrl,
    this.schoolId,
    this.canteenId,
    this.calories,
    this.quantityAvailable,
    this.soldOut = false,
  });

  FoodItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? rating,
    List<String>? tags,
    String? category,
    String? imagePath,
    String? imageUrl,
    String? schoolId,
    String? canteenId,
    int? calories,
    int? quantityAvailable,
    bool? soldOut,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      schoolId: schoolId ?? this.schoolId,
      canteenId: canteenId ?? this.canteenId,
      calories: calories ?? this.calories,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      soldOut: soldOut ?? this.soldOut,
    );
  }
}
