import 'package:smart_canteen_user_frontend/features/menu/data/datasources/menu_datasource.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/weekly_menu.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  MenuRepositoryImpl(this._datasource);

  final MenuDatasource _datasource;

  @override
  Future<List<FoodItem>> getMenuItems({String? schoolId}) async {
    final dtos = await _datasource.getMenuItems(schoolId: schoolId);
    // Each item carries its own photo, falling back to the shared placeholder
    // for the handful of dishes seeded without one.
    return [
      for (final (i, dto) in dtos.indexed)
        dto.toEntity(colorSeed: i, fallbackImageUrl: kFallbackFoodImageUrl),
    ];
  }

  @override
  Future<WeeklyMenu?> getCurrentWeeklyMenu({String? schoolId}) async =>
      (await _datasource.getCurrentWeeklyMenu(schoolId: schoolId))?.toEntity();
}
