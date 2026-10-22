import 'package:smart_canteen_user_frontend/features/notification/domain/entities/notification_item.dart';

class NotificationDto {
  final String id;
  final String title;
  final String body;
  final String
  type; // category: 'order'|'wallet'|'promo'|'system'|'announcement'
  final bool isRead;
  final DateTime createdAt;
  final NotificationSource source;

  const NotificationDto({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.source,
  });

  /// A per-user notification from `GET /notifications`.
  factory NotificationDto.fromNotification(Map<String, dynamic> json) =>
      NotificationDto(
        id: json['id'] as String,
        title: json['title'] as String,
        body: (json['body'] as String?) ?? '',
        type: json['category'] as String? ?? 'system',
        isRead: json['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
        source: NotificationSource.personal,
      );

  /// A published announcement from `GET /announcements`. Announcements are
  /// broadcast and have no per-user read state, so they're always shown as read
  /// (no unread dot) and can't be dismissed on the server.
  factory NotificationDto.fromAnnouncement(Map<String, dynamic> json) =>
      NotificationDto(
        id: json['id'] as String,
        title: json['title'] as String,
        body: (json['content'] as String?) ?? '',
        type: 'announcement',
        isRead: true,
        createdAt: DateTime.parse(json['created_at'] as String),
        source: NotificationSource.announcement,
      );

  NotificationItem toEntity() => NotificationItem(
    id: id,
    title: title,
    body: body,
    type: type,
    isRead: isRead,
    createdAt: createdAt,
    source: source,
  );
}
