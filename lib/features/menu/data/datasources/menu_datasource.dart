import 'package:smart_canteen_user_frontend/features/menu/data/models/active_menu_dto.dart';
import 'package:smart_canteen_user_frontend/features/menu/data/models/menu_dto.dart';

abstract class MenuDatasource {
  /// One date's menu for [branchId] (today when [date] is null), optionally
  /// for one canteen only.
  Future<ActiveMenuDto> getActiveMenu({
    required String branchId,
    String? canteenId,
    DateTime? date,
  });

  Future<MenuItemDto> getMenuItem(String menuItemId);

  Future<List<MenuItemDto>> getMenuItems({String? schoolId});

  /// The published weekly menu covering today, or null if there is none.
  Future<WeeklyMenuDto?> getCurrentWeeklyMenu({String? schoolId});
}
