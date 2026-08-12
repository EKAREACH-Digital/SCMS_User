import '../../dtos/menu_dto.dart';

abstract class MenuRepository {
  /// Fetches available menu items. When [schoolId] is given, results are scoped
  /// to that school; otherwise the backend returns items across all schools.
  Future<List<MenuItemDto>> getMenuItems({String? schoolId});

  /// The published weekly menu covering today, with the dishes scheduled on it.
  ///
  /// Returns null when no published menu covers today — the app shows an empty
  /// state rather than inventing a schedule.
  Future<WeeklyMenuDto?> getCurrentWeeklyMenu({String? schoolId});
}
