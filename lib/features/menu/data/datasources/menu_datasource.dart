import 'package:smart_canteen_user_frontend/features/menu/data/models/menu_dto.dart';

abstract class MenuDatasource {
  Future<List<MenuItemDto>> getMenuItems({String? schoolId});

  /// The published weekly menu covering today, or null if there is none.
  Future<WeeklyMenuDto?> getCurrentWeeklyMenu({String? schoolId});
}
