import 'package:dio/dio.dart';

import 'package:smart_canteen_user_frontend/core/config/api_config.dart';
import 'package:smart_canteen_user_frontend/core/error/error_handler.dart';
import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/features/notification/data/datasources/notification_datasource.dart';
import 'package:smart_canteen_user_frontend/features/notification/data/models/notification_dto.dart';
import 'package:smart_canteen_user_frontend/features/notification/data/models/notification_preferences_dto.dart';

/// Backs the Alerts screen with a merged feed:
///  - the signed-in user's own event notifications (`GET /notifications`), and
///  - published admin announcements (`GET /announcements?status=published`).
/// The two are fetched together and merged newest-first. Read/dismiss operate
/// only on personal notifications; announcements are broadcast and read-only.
class NotificationRemoteDatasource implements NotificationDatasource {
  NotificationRemoteDatasource(this._dio);

  final Dio _dio;

  @override
  Future<List<NotificationDto>> getNotifications() async {
    try {
      final results = await Future.wait([
        _fetchPersonal(),
        _fetchAnnouncements(),
      ]);
      final merged = [...results[0], ...results[1]]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return merged;
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error loading notifications: $e');
    }
  }

  Future<List<NotificationDto>> _fetchPersonal() async {
    final response = await _dio.get(
      ApiConfig.notifications,
      queryParameters: {'limit': 50},
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => NotificationDto.fromNotification(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<NotificationDto>> _fetchAnnouncements() async {
    final response = await _dio.get(
      ApiConfig.announcements,
      queryParameters: {'status': 'published', 'limit': 50},
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => NotificationDto.fromAnnouncement(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get(ApiConfig.notificationsUnreadCount);
      return (response.data['data']['count'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error loading unread count: $e');
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await _dio.patch(ApiConfig.notificationsReadAll);
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error marking notifications read: $e');
    }
  }

  @override
  Future<void> dismiss(String id) async {
    try {
      await _dio.delete(ApiConfig.notificationById(id));
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error dismissing notification: $e');
    }
  }

  @override
  Future<NotificationPreferencesDto> getPreferences() async {
    try {
      // GET /users/me — the switches are columns on the user record.
      final response = await _dio.get(ApiConfig.profile);
      return NotificationPreferencesDto.fromUserJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error loading notification settings: $e');
    }
  }

  @override
  Future<NotificationPreferencesDto> updatePreferences({
    required String userId,
    bool? orderUpdates,
    bool? promotions,
    bool? systemAlerts,
  }) async {
    try {
      // PATCH /users/:id/notification-preferences — returns the full user
      // record; read the switches off it.
      final response = await _dio.patch(
        ApiConfig.userNotificationPreferences(userId),
        data: {
          'notify_order_updates': ?orderUpdates,
          'notify_promotions': ?promotions,
          'notify_system_alerts': ?systemAlerts,
        },
      );
      return NotificationPreferencesDto.fromUserJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error saving notification settings: $e');
    }
  }
}
