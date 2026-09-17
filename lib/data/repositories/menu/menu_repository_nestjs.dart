import 'package:dio/dio.dart';

import '../../config/api_client.dart';
import '../../config/api_config.dart';
import '../../dtos/menu_dto.dart';
import '../../exceptions/api_exception.dart';
import '../../local/token_storage.dart';
import 'menu_repository.dart';

class MenuRepositoryNestjs implements MenuRepository {
  MenuRepositoryNestjs({Dio? dio, TokenStorage? tokenStorage})
      : _dio = dio ?? createApiClient(tokenStorage: tokenStorage);

  final Dio _dio;

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
      throw _mapError(e);
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
      throw _mapError(e);
    } catch (e) {
      throw ApiException('Unexpected error loading the weekly menu: $e');
    }
  }

  ApiException _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) {
        return ApiException(message, statusCode: e.response?.statusCode);
      }
    }
    return ApiException('${e.type.name}: ${e.message ?? e.error ?? e}');
  }
}
