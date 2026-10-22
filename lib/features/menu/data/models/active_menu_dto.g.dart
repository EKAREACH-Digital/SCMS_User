// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_menu_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActiveMenuDto _$ActiveMenuDtoFromJson(
  Map<String, dynamic> json,
) => ActiveMenuDto(
  date: json['date'] as String,
  dayOfWeek: (json['day_of_week'] as num?)?.toInt() ?? 0,
  branch: ActiveMenuBranchDto.fromJson(json['branch'] as Map<String, dynamic>),
  menu: json['menu'] == null
      ? null
      : ActiveMenuInfoDto.fromJson(json['menu'] as Map<String, dynamic>),
  canteens:
      (json['canteens'] as List<dynamic>?)
          ?.map((e) => ActiveMenuCanteenDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

ActiveMenuBranchDto _$ActiveMenuBranchDtoFromJson(Map<String, dynamic> json) =>
    ActiveMenuBranchDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      schoolId: json['school_id'] as String?,
    );

ActiveMenuInfoDto _$ActiveMenuInfoDtoFromJson(Map<String, dynamic> json) =>
    ActiveMenuInfoDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
    );

ActiveMenuCanteenDto _$ActiveMenuCanteenDtoFromJson(
  Map<String, dynamic> json,
) => ActiveMenuCanteenDto(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map(
            (e) => ActiveMenuCategoryDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
);

ActiveMenuCategoryDto _$ActiveMenuCategoryDtoFromJson(
  Map<String, dynamic> json,
) => ActiveMenuCategoryDto(
  id: json['id'] as String?,
  name: json['name'] as String? ?? 'Other',
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ActiveMenuItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

ActiveMenuItemDto _$ActiveMenuItemDtoFromJson(Map<String, dynamic> json) =>
    ActiveMenuItemDto(
      compositionId: json['composition_id'] as String? ?? '',
      menuItemId: json['menu_item_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: ActiveMenuItemDto._toDouble(json['price']),
      imageUrl: ActiveMenuItemDto._nonEmpty(json['image_url'] as String?),
      calories: (json['calories'] as num?)?.toInt(),
      quantityAvailable: (json['quantity_available'] as num?)?.toInt(),
      soldOut: json['sold_out'] as bool? ?? false,
    );
