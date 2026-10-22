import 'package:flutter/foundation.dart';

import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/features/notification/domain/entities/notification_item.dart';
import 'package:smart_canteen_user_frontend/features/notification/domain/repositories/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  NotificationViewModel(this._repository);

  final NotificationRepository _repository;

  // Starts as loading: the Alerts screen shows a spinner until its first fetch.
  ViewState _state = ViewState.loading;
  List<NotificationItem> _items = const [];
  String? _errorMessage;

  ViewState get state => _state;

  /// The feed, newest first. Only meaningful once [state] is
  /// [ViewState.success].
  List<NotificationItem> get items => _items;

  /// Why the last fetch failed; null unless [state] is [ViewState.error].
  String? get errorMessage => _errorMessage;

  int get unreadCount =>
      _state == ViewState.success ? _items.where((n) => !n.isRead).length : 0;

  // Unread count for the home-screen bell badge. Kept independent of [_items]
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
      _setState(_state);
    } catch (e) {
      // Leave the last known count if the fetch fails.
      AppLogger.w('Unread count refresh failed: $e');
    }
  }

  Future<void> fetchNotifications() async {
    _setState(ViewState.loading);

    try {
      final fetched = await _repository.getNotifications();
      _items = [..._local, ...fetched];
      _unreadBadge = _items.where((n) => !n.isRead).length;
      _setState(ViewState.success);
    } catch (e, s) {
      AppLogger.e('Loading notifications failed', e, s);
      // A failed fetch shouldn't throw away alerts we raised ourselves.
      if (_local.isEmpty) {
        _errorMessage = e is ApiException
            ? e.message
            : "Couldn't load your alerts. Please try again.";
        _setState(ViewState.error);
      } else {
        _items = List.of(_local);
        _unreadBadge = _localUnread;
        _setState(ViewState.success);
      }
    }
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
    final current = _state == ViewState.success
        ? _items
        : const <NotificationItem>[];
    _items = [item, ...current];
    _unreadBadge += 1;
    _setState(ViewState.success);
  }

  /// Marks everything read. Optimistic — flips the UI immediately, persists the
  /// personal ones on the server, and rolls back if that fails. Announcements
  /// are already shown as read, so only personal items change.
  Future<void> markAllRead() async {
    if (_state != ViewState.success) return;
    if (_items.every((n) => n.isRead)) return;

    final previous = _items;
    final previousBadge = _unreadBadge;
    final previousLocal = List.of(_local);
    _items = _items.map((n) => n.copyWith(isRead: true)).toList();
    // Locally-raised alerts have no server row to mark, so flip them here or
    // they'd come back unread on the next fetch.
    for (var i = 0; i < _local.length; i++) {
      _local[i] = _local[i].copyWith(isRead: true);
    }
    _unreadBadge = 0;
    _setState(ViewState.success);

    try {
      await _repository.markAllRead();
    } catch (e) {
      AppLogger.w('Mark all read failed, rolled back: $e');
      _items = previous;
      _local
        ..clear()
        ..addAll(previousLocal);
      _unreadBadge = previousBadge;
      _setState(ViewState.success);
    }
  }

  /// Removes an item. Personal notifications are deleted on the server;
  /// announcements can't be dismissed server-side, so removing one only lasts
  /// until the next fetch. Rolls back a failed server delete.
  Future<void> dismiss(NotificationItem item) async {
    if (_state != ViewState.success) return;

    final previous = _items;
    final previousBadge = _unreadBadge;
    _items = _items.where((n) => n.id != item.id).toList();
    if (item.isPersonal && !item.isRead && _unreadBadge > 0) _unreadBadge--;

    // A locally-raised alert exists only here, so dropping it from the feed
    // isn't enough — the next fetch would merge it straight back in.
    final wasLocal = _local.any((n) => n.id == item.id);
    if (wasLocal) _local.removeWhere((n) => n.id == item.id);
    _setState(ViewState.success);
    if (wasLocal || !item.isPersonal) return;

    try {
      await _repository.dismiss(item.id);
    } catch (e) {
      AppLogger.w('Dismiss failed, rolled back: $e');
      _items = previous;
      _unreadBadge = previousBadge;
      _setState(ViewState.success);
    }
  }

  /// The only place listeners are notified. Leaving the error state clears
  /// the error message.
  void _setState(ViewState newState) {
    _state = newState;
    if (newState != ViewState.error) _errorMessage = null;
    notifyListeners();
  }
}
