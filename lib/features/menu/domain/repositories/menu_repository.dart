import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/weekly_menu.dart';

abstract class MenuRepository {
  /// Available menu items. When [schoolId] is given, results are scoped to
  /// that school; otherwise the backend returns items across all schools.
  Future<List<FoodItem>> getMenuItems({String? schoolId});

  /// The published weekly menu covering today, with the dishes scheduled on it.
  ///
  /// Returns null when no published menu covers today — the app shows an empty
  /// state rather than inventing a schedule.
  Future<WeeklyMenu?> getCurrentWeeklyMenu({String? schoolId});
}
