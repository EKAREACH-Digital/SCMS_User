import 'package:dio/dio.dart';

import 'package:smart_canteen_user_frontend/core/config/api_config.dart';
import 'package:smart_canteen_user_frontend/core/error/error_handler.dart';
import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/features/menu/data/datasources/menu_datasource.dart';
import 'package:smart_canteen_user_frontend/features/menu/data/models/active_menu_dto.dart';
import 'package:smart_canteen_user_frontend/features/menu/data/models/menu_dto.dart';

class MenuRemoteDatasource implements MenuDatasource {
  MenuRemoteDatasource(this._dio);

  final Dio _dio;

  @override
  Future<ActiveMenuDto> getActiveMenu({
    required String branchId,
    String? canteenId,
    DateTime? date,
  }) async {
    try {
      // GET /menus/active — the student menu for the branch on one date.
      final response = await _dio.get(
        ApiConfig.menusActive,
        queryParameters: {
          'branch_id': branchId,
          'canteen_id': ?canteenId,
          if (date != null) 'date': _formatDate(date),
        },
      );
      return ActiveMenuDto.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error loading the menu: $e');
    }
  }

  @override
  Future<MenuItemDto> getMenuItem(String menuItemId) async {
    try {
      // GET /menu-items/:id — one dish's detail.
      final response = await _dio.get(ApiConfig.menuItemById(menuItemId));
      return MenuItemDto.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error loading the dish: $e');
    }
  }

  /// `YYYY-MM-DD`, the format the backend's `date` param expects.
  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Future<List<MenuItemDto>> getMenuItems({String? schoolId}) async {
    try {
      final response = await _dio.get(
        ApiConfig.menuItems,
        queryParameters: {
          'availability_status': 'available',
          'limit': 100, // fetch the full menu in one page (backend max)
          'school_id': ?schoolId,
        },
      );
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => MenuItemDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error loading menu: $e');
    }
  }

  @override
  Future<WeeklyMenuDto?> getCurrentWeeklyMenu({String? schoolId}) async {
    try {
      // Only published menus are shown; drafts are the manager's work in
      // progress and must not leak to students.
      final menusRes = await _dio.get(
        ApiConfig.menus,
        queryParameters: {
          'status': 'published',
          'limit': 50,
          'school_id': ?schoolId,
        },
      );
      final menus = (menusRes.data['data'] as List<dynamic>)
          .map((e) => MenuDto.fromJson(e as Map<String, dynamic>))
          .toList();

      final today = DateTime.now();
      MenuDto? current;
      for (final m in menus) {
        if (m.coversDate(today)) {
          current = m;
          break;
        }
      }
      if (current == null) return null;

      final entriesRes = await _dio.get(
        ApiConfig.menuMenuItems,
        queryParameters: {'menu_id': current.id, 'limit': 100},
      );
      final entries = (entriesRes.data['data'] as List<dynamic>)
          .map((e) => MenuEntryDto.fromJson(e as Map<String, dynamic>))
          .toList();

      return WeeklyMenuDto(menu: current, entries: entries);
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error loading the weekly menu: $e');
    }
  }
}
