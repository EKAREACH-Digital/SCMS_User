import 'package:flutter/foundation.dart';

import '../../../../data/dtos/notification_dto.dart';
import '../../../../data/repositories/notification/notification_repository.dart';
import '../../../utils/async_value.dart';

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

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        title: title,
        body: body,
        type: type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        source: source,
        imageUrl: imageUrl,
        imageAsset: imageAsset,
      );

  factory NotificationItem.fromDto(NotificationDto dto) => NotificationItem(
        id: dto.id,
        title: dto.title,
        body: dto.body,
        type: dto.type,
        isRead: dto.isRead,
        createdAt: dto.createdAt,
        source: dto.source,
      );
}

class NotificationViewModel extends ChangeNotifier {
  NotificationViewModel(this._repository);

  final NotificationRepository _repository;

  AsyncValue<List<NotificationItem>> _state = const AsyncLoading();

  AsyncValue<List<NotificationItem>> get state => _state;

  int get unreadCount => switch (_state) {
        AsyncData(data: final list) => list.where((n) => !n.isRead).length,
        _ => 0,
      };

  // Unread count for the home-screen bell badge. Kept independent of [_state]
  // so it can be shown before the Alerts screen has ever loaded the feed.
  int _unreadBadge = 0;
  int get unreadBadge => _unreadBadge;

  /// Alerts raised on the device rather than fetched — currently the
  /// order-ready notification, which has no backend event behind it.
  ///
  /// Held separately because [fetchNotifications] replaces the feed wholesale
  /// with what the server returned; without this they'd vanish the moment the
  /// Alerts screen opened and refetched. Newest first.
  final List<NotificationItem> _local = [];

  int get _localUnread => _local.where((n) => !n.isRead).length;

  /// Lightweight fetch of just the unread count — call on app landing to show
  /// the bell badge without loading the whole feed. Never throws.
  Future<void> refreshUnreadCount() async {
    try {
      _unreadBadge = await _repository.getUnreadCount() + _localUnread;
      notifyListeners();
    } catch (_) {
      // Leave the last known count if the fetch fails.
    }
  }

  Future<void> fetchNotifications() async {
    _state = const AsyncLoading();
    notifyListeners();

    try {
      final dtos = await _repository.getNotifications();
      final items = [..._local, ...dtos.map(NotificationItem.fromDto)];
      _state = AsyncData(items);
      _unreadBadge = items.where((n) => !n.isRead).length;
    } catch (e, s) {
      // A failed fetch shouldn't throw away alerts we raised ourselves.
      if (_local.isEmpty) {
        _state = AsyncError(e, s);
      } else {
        _state = AsyncData(List.of(_local));
        _unreadBadge = _localUnread;
      }
    }

    notifyListeners();
  }

  /// Inserts a locally-raised alert at the top of the feed.
  ///
  /// Used by the order-ready alert, which is produced on the device rather
  /// than fetched — the backend has no order-ready event yet. It is not sent
  /// to the server, so it survives only until the next [fetchNotifications].
  void addLocal({
    required String id,
    required String title,
    required String body,
    String type = 'order',
    String? imageUrl,
    String? imageAsset,
  }) {
    final item = NotificationItem(
      id: id,
      title: title,
      body: body,
      type: type,
      isRead: false,
      createdAt: DateTime.now(),
      source: NotificationSource.personal,
      imageUrl: imageUrl,
      imageAsset: imageAsset,
    );

    _local.insert(0, item);

    // The feed may not have been opened yet; seed it rather than dropping the
    // alert, so the Alerts screen shows it whenever the user does look.
    final current = switch (_state) {
      AsyncData(data: final list) => list,
      _ => const <NotificationItem>[],
    };

    _state = AsyncData([item, ...current]);
    _unreadBadge += 1;
    notifyListeners();
  }

  /// Marks everything read. Optimistic — flips the UI immediately, persists the
  /// personal ones on the server, and rolls back if that fails. Announcements
  /// are already shown as read, so only personal items change.
  Future<void> markAllRead() async {
    if (_state case AsyncData(data: final list)) {
      if (list.every((n) => n.isRead)) return;
      final previous = list;
      final previousBadge = _unreadBadge;
      final previousLocal = List.of(_local);
      _state = AsyncData(list.map((n) => n.copyWith(isRead: true)).toList());
      // Locally-raised alerts have no server row to mark, so flip them here or
      // they'd come back unread on the next fetch.
      for (var i = 0; i < _local.length; i++) {
        _local[i] = _local[i].copyWith(isRead: true);
      }
      _unreadBadge = 0;
      notifyListeners();

      try {
        await _repository.markAllRead();
      } catch (_) {
        _state = AsyncData(previous);
        _local
          ..clear()
          ..addAll(previousLocal);
        _unreadBadge = previousBadge;
        notifyListeners();
      }
    }
  }

  /// Removes an item. Personal notifications are deleted on the server;
  /// announcements can't be dismissed server-side, so removing one only lasts
  /// until the next fetch. Rolls back a failed server delete.
  Future<void> dismiss(NotificationItem item) async {
    if (_state case AsyncData(data: final list)) {
      final previous = list;
      final previousBadge = _unreadBadge;
      _state = AsyncData(list.where((n) => n.id != item.id).toList());
      if (item.isPersonal && !item.isRead && _unreadBadge > 0) _unreadBadge--;

      // A locally-raised alert exists only here, so dropping it from the feed
      // isn't enough — the next fetch would merge it straight back in.
      final wasLocal = _local.any((n) => n.id == item.id);
      if (wasLocal) {
        _local.removeWhere((n) => n.id == item.id);
        notifyListeners();
        return;
      }

      notifyListeners();

      if (item.isPersonal) {
        try {
          await _repository.dismiss(item.id);
        } catch (_) {
          _state = AsyncData(previous);
          _unreadBadge = previousBadge;
          notifyListeners();
        }
      }
    }
  }
}
