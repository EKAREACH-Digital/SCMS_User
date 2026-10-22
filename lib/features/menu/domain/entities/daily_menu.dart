import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';

/// What a branch serves on one date: its canteens, each split into
/// categories of orderable dishes.
class DailyMenu {
  /// The date this menu is for (Cambodia time).
  final DateTime date;

  /// 0 = Monday … 6 = Sunday.
  final int dayOfWeek;
  final String branchId;
  final String branchName;

  /// The published weekly menu this day comes from. Null when nothing is
  /// published for [date].
  final String? menuId;
  final String? menuName;

  final List<MenuCanteen> canteens;

  const DailyMenu({
    required this.date,
    required this.dayOfWeek,
    required this.branchId,
    required this.branchName,
    this.menuId,
    this.menuName,
    this.canteens = const [],
  });

  /// False means "No menu today": nothing is published for [date].
  bool get isPublished => menuId != null;

  /// Published but nothing scheduled: "Nothing scheduled for this day".
  bool get isEmpty => canteens.every((c) => c.items.isEmpty);

  /// Every dish across all canteens and categories, e.g. for the home page.
  List<FoodItem> get items => [for (final c in canteens) ...c.items];

  DailyMenu copyWith({
    DateTime? date,
    int? dayOfWeek,
    String? branchId,
    String? branchName,
    String? menuId,
    String? menuName,
    List<MenuCanteen>? canteens,
  }) {
    return DailyMenu(
      date: date ?? this.date,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      menuId: menuId ?? this.menuId,
      menuName: menuName ?? this.menuName,
      canteens: canteens ?? this.canteens,
    );
  }
}

/// A canteen of the branch: one tab on the menu screen.
class MenuCanteen {
  final String id;
  final String name;
  final List<MenuCategory> categories;

  const MenuCanteen({
    required this.id,
    required this.name,
    this.categories = const [],
  });

  List<FoodItem> get items => [for (final c in categories) ...c.items];

  MenuCanteen copyWith({
    String? id,
    String? name,
    List<MenuCategory>? categories,
  }) {
    return MenuCanteen(
      id: id ?? this.id,
      name: name ?? this.name,
      categories: categories ?? this.categories,
    );
  }
}

/// A section of a canteen's menu, e.g. "Lunch". [id] is null for dishes
/// without a category, which the backend names "Other".
class MenuCategory {
  final String? id;
  final String name;
  final List<FoodItem> items;

  const MenuCategory({this.id, required this.name, this.items = const []});

  MenuCategory copyWith({String? id, String? name, List<FoodItem>? items}) {
    return MenuCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }
}
