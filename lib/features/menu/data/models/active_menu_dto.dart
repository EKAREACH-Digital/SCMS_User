import 'package:json_annotation/json_annotation.dart';

import 'package:smart_canteen_user_frontend/features/menu/domain/entities/daily_menu.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';

part 'active_menu_dto.g.dart';

/// The `data` of `GET /menus/active`: one date's menu for a branch.
@JsonSerializable()
class ActiveMenuDto {
  final String date;
  @JsonKey(defaultValue: 0)
  final int dayOfWeek;
  final ActiveMenuBranchDto branch;

  /// Null when nothing is published for [date]; [canteens] is then empty.
  final ActiveMenuInfoDto? menu;
  @JsonKey(defaultValue: <ActiveMenuCanteenDto>[])
  final List<ActiveMenuCanteenDto> canteens;

  const ActiveMenuDto({
    required this.date,
    required this.dayOfWeek,
    required this.branch,
    this.menu,
    required this.canteens,
  });

  factory ActiveMenuDto.fromJson(Map<String, dynamic> json) =>
      _$ActiveMenuDtoFromJson(json);

  /// [imageHost] turns relative `image_url`s (`/uploads/...`) into full URLs;
  /// pass the API base URL. Without it they're left as they came.
  DailyMenu toEntity({String? imageHost}) {
    var seed = 0;
    return DailyMenu(
      date: DateTime.tryParse(date) ?? DateTime.now(),
      dayOfWeek: dayOfWeek,
      branchId: branch.id,
      branchName: branch.name,
      menuId: menu?.id,
      menuName: menu?.name,
      canteens: [
        for (final canteen in canteens)
          MenuCanteen(
            id: canteen.id,
            name: canteen.name,
            categories: [
              for (final category in canteen.categories)
                MenuCategory(
                  id: category.id,
                  name: category.name,
                  items: [
                    for (final item in category.items)
                      item.toEntity(
                        canteenId: canteen.id,
                        categoryName: category.name,
                        colorSeed: seed++,
                        imageHost: imageHost,
                      ),
                  ],
                ),
            ],
          ),
      ],
    );
  }
}

@JsonSerializable()
class ActiveMenuBranchDto {
  final String id;
  @JsonKey(defaultValue: '')
  final String name;
  final String? schoolId;

  const ActiveMenuBranchDto({
    required this.id,
    required this.name,
    this.schoolId,
  });

  factory ActiveMenuBranchDto.fromJson(Map<String, dynamic> json) =>
      _$ActiveMenuBranchDtoFromJson(json);
}

/// The published weekly menu the day comes from.
@JsonSerializable()
class ActiveMenuInfoDto {
  final String id;
  @JsonKey(defaultValue: '')
  final String name;

  const ActiveMenuInfoDto({required this.id, required this.name});

  factory ActiveMenuInfoDto.fromJson(Map<String, dynamic> json) =>
      _$ActiveMenuInfoDtoFromJson(json);
}

@JsonSerializable()
class ActiveMenuCanteenDto {
  final String id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: <ActiveMenuCategoryDto>[])
  final List<ActiveMenuCategoryDto> categories;

  const ActiveMenuCanteenDto({
    required this.id,
    required this.name,
    required this.categories,
  });

  factory ActiveMenuCanteenDto.fromJson(Map<String, dynamic> json) =>
      _$ActiveMenuCanteenDtoFromJson(json);
}

@JsonSerializable()
class ActiveMenuCategoryDto {
  /// Null for dishes without a category.
  final String? id;
  @JsonKey(defaultValue: 'Other')
  final String name;
  @JsonKey(defaultValue: <ActiveMenuItemDto>[])
  final List<ActiveMenuItemDto> items;

  const ActiveMenuCategoryDto({
    this.id,
    required this.name,
    required this.items,
  });

  factory ActiveMenuCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$ActiveMenuCategoryDtoFromJson(json);
}

@JsonSerializable()
class ActiveMenuItemDto {
  /// The dish's row on the weekly menu.
  @JsonKey(defaultValue: '')
  final String compositionId;

  /// The dish itself: what the cart, the order and the detail call use.
  final String menuItemId;
  final String name;
  final String? description;

  /// Decimal columns may arrive as strings.
  @JsonKey(fromJson: _toDouble)
  final double price;

  /// Items seeded without a photo may carry an empty string.
  @JsonKey(fromJson: _nonEmpty)
  final String? imageUrl;
  final int? calories;
  final int? quantityAvailable;
  @JsonKey(defaultValue: false)
  final bool soldOut;

  const ActiveMenuItemDto({
    required this.compositionId,
    required this.menuItemId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.calories,
    this.quantityAvailable,
    this.soldOut = false,
  });

  factory ActiveMenuItemDto.fromJson(Map<String, dynamic> json) =>
      _$ActiveMenuItemDtoFromJson(json);

  FoodItem toEntity({
    required String canteenId,
    required String categoryName,
    int colorSeed = 0,
    String? imageHost,
  }) => FoodItem(
    id: menuItemId,
    name: name,
    description: description ?? '',
    price: price,
    rating: 0.0,
    tags: [categoryName],
    category: categoryName.toLowerCase(),
    imageUrl: _absolute(imageUrl, imageHost),
    colorSeed: colorSeed,
    canteenId: canteenId,
    calories: calories,
    quantityAvailable: quantityAvailable,
    soldOut: soldOut,
  );

  /// `/uploads/x.jpg` + `http://host:3000/api` → `http://host:3000/uploads/x.jpg`.
  static String? _absolute(String? url, String? host) {
    if (url == null || host == null || url.startsWith('http')) return url;
    return Uri.parse(host).resolve(url).toString();
  }

  static double _toDouble(Object? value) => switch (value) {
    num n => n.toDouble(),
    String s => double.tryParse(s) ?? 0.0,
    _ => 0.0,
  };

  static String? _nonEmpty(String? value) =>
      (value == null || value.isEmpty) ? null : value;
}
