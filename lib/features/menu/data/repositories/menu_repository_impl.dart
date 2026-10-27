import 'package:smart_canteen_user_frontend/features/menu/data/datasources/menu_datasource.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/daily_menu.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/weekly_menu.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  /// [imageHost] (the API base URL) turns the menu's relative image paths
  /// into full URLs.
  MenuRepositoryImpl(this._datasource, {String? imageHost})
    : _imageHost = imageHost;

  final MenuDatasource _datasource;
  final String? _imageHost;

  @override
  Future<DailyMenu> getActiveMenu({
    required String branchId,
    String? canteenId,
    DateTime? date,
  }) async {
    final dto = await _datasource.getActiveMenu(
      branchId: branchId,
      canteenId: canteenId,
      date: date,
    );
    return dto.toEntity(imageHost: _imageHost);
  }

  @override
  Future<FoodItem> getMenuItem(String menuItemId) async =>
      (await _datasource.getMenuItem(
        menuItemId,
      )).toEntity(fallbackImageUrl: kFallbackFoodImageUrl);

  @override
  Future<List<FoodItem>> getMenuItems({String? schoolId}) async {
    final dtos = await _datasource.getMenuItems(schoolId: schoolId);
    // Each item carries its own photo, falling back to the shared placeholder
    // for the handful of dishes seeded without one.
    return [
      for (final dto in dtos)
        dto.toEntity(fallbackImageUrl: kFallbackFoodImageUrl),
    ];
  }

  @override
  Future<WeeklyMenu?> getCurrentWeeklyMenu({String? schoolId}) async =>
      (await _datasource.getCurrentWeeklyMenu(schoolId: schoolId))?.toEntity();
}
