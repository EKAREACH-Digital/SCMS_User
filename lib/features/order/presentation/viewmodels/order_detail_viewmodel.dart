import 'package:flutter/foundation.dart';

import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order_pickup.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order_status.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/repositories/order_repository.dart';

/// What the QR area of Order Detail shows.
enum PickupQrState {
  loading,

  /// Ready for pickup, with a token: show the QR and the Download button.
  available,
  awaitingPayment,

  /// Paid but still cooking: no QR until it's ready.
  preparing,
  pickedUp,
  cancelled,
  error,
}

/// The Order Detail page's pickup ticket (the QR token). Prices and dates are
/// not here: the page reads those from [OrderHistoryViewModel], which already
/// owns the order list.
class OrderDetailViewModel extends ChangeNotifier {
  OrderDetailViewModel(this._orderRepository);

  final OrderRepository _orderRepository;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  OrderPickup? _pickup;
  OrderPickup? get pickup => _pickup;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// `GET /pickup/my/{orderId}` — the QR token the canteen scans at pickup.
  Future<void> loadPickup(String orderId) async {
    // Don't flash the previous order's QR while another one loads.
    if (_pickup?.orderId != orderId) _pickup = null;
    _setState(ViewState.loading);
    try {
      _pickup = await _orderRepository.getMyPickup(orderId);
      _setState(ViewState.success);
    } catch (e, s) {
      AppLogger.e('Loading pickup for order $orderId failed', e, s);
      _errorMessage = e is ApiException
          ? e.message
          : "Couldn't load this order. Check your connection and try again.";
      _setState(ViewState.error);
    }
  }

  /// Decides the QR area from the pickup ticket and [listStatus], the order's
  /// status in the history list. The QR only shows once the food is ready:
  /// before that the student would queue for food that is still cooking.
  ///
  /// A final status (completed, cancelled) from either source wins. Otherwise
  /// the pickup ticket is preferred, since it was just fetched; unpaid and
  /// cancelled orders have no ticket, so the list is their only source.
  PickupQrState qrState(OrderStatus? listStatus) {
    bool either(OrderStatus s) => listStatus == s || _pickup?.status == s;

    if (either(OrderStatus.cancelled)) return PickupQrState.cancelled;
    // A completed order may still return its token; it is hidden either way.
    if (either(OrderStatus.completed)) return PickupQrState.pickedUp;

    final status = _pickup?.status ?? listStatus;
    if (status == OrderStatus.pendingPayment) {
      return PickupQrState.awaitingPayment;
    }
    if (status == OrderStatus.ready && _pickup?.pickupQrToken != null) {
      return PickupQrState.available;
    }
    return switch (_state) {
      ViewState.error => PickupQrState.error,
      // Paid, or marked ready before its ticket was issued.
      ViewState.success => PickupQrState.preparing,
      // The list already says it's cooking; no need to wait for the ticket.
      ViewState.idle || ViewState.loading =>
        status == OrderStatus.paid
            ? PickupQrState.preparing
            : PickupQrState.loading,
    };
  }

  /// The only place listeners are notified.
  void _setState(ViewState newState) {
    _state = newState;
    notifyListeners();
  }
}
