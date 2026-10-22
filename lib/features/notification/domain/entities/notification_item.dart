/// Where a feed item came from. Personal notifications are per-user and support
/// server-side read/dismiss; announcements are broadcast and informational only.
enum NotificationSource { personal, announcement }

/// One entry in the Alerts feed.
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final NotificationSource source;

  /// Remote photo of the thing this alert is about — the dish that's ready.
  /// Preferred over [imageAsset] when both are set.
  final String? imageUrl;

  /// Bundled asset instead of a remote photo: the bank logo on a top-up, or a
  /// dish shipped with the app. Falls back to the category icon when null.
  final String? imageAsset;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.source,
    this.imageUrl,
    this.imageAsset,
  });

  bool get isPersonal => source == NotificationSource.personal;

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    NotificationSource? source,
    String? imageUrl,
    String? imageAsset,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      source: source ?? this.source,
      imageUrl: imageUrl ?? this.imageUrl,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}
