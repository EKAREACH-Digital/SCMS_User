import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/cart_entry.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order_status.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/repositories/order_repository.dart';

enum OrderPlacementState {
  idle,
  submitting,
  awaitingPayment,
  paid,
  cancelled,
  error,
}

/// Orchestrates checkout: places the order, then polls `GET /orders/{id}` until
/// `paid` or `cancelled`. One instance is kept app-wide so the payment screen
/// can be left and resumed.
class OrderPlacementViewModel extends ChangeNotifier {
  OrderPlacementViewModel(this._orderRepository);

  final OrderRepository _orderRepository;

  OrderPlacementState _state = OrderPlacementState.idle;
  PlacedOrder? _placedOrder;
  String? _errorMessage;
  Timer? _pollTimer;

  OrderPlacementState get state => _state;
  PlacedOrder? get placedOrder => _placedOrder;
  String? get errorMessage => _errorMessage;

  bool get isAwaitingPayment => _state == OrderPlacementState.awaitingPayment;

  /// `POST /orders/checkout` — places the order and starts payment polling.
  /// [provider] is `CUTLUY` (Bakong) or `PAYWAY` (ABA).
  /// Never called automatically on retry: each call reserves stock again.
  Future<void> placeOrder({
    required List<CartEntry> cartEntries,
    required String menuId,
    required String mealSession,
    required String provider,
    String? branchId,
  }) async {
    _stopPolling();
    _setState(OrderPlacementState.submitting);
    try {
      // POST /orders/checkout — one call per student tap; never retry automatically.
      final placed = await _orderRepository.placeOrder(
        menuId: menuId,
        mealSession: mealSession,
        items: [
          for (final e in cartEntries)
            NewOrderItem(menuItemId: e.item.id, quantity: e.quantity),
        ],
        provider: provider,
        branchId: branchId,
      );
      _placedOrder = placed;
      _setState(OrderPlacementState.awaitingPayment);
      _startPolling(placed.orderId);
    } catch (e, s) {
      AppLogger.e('Checkout failed', e, s);
      _errorMessage = e is ApiException
          ? e.message
          : 'Could not place your order. Please try again.';
      _setState(OrderPlacementState.error);
    }
  }

  /// Starts polling `GET /orders/{id}` every 3 seconds until the order is
  /// `paid` or `cancelled`.
  void _startPolling(String orderId) {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        // GET /orders/{id} — each call also queries the gateway directly.
        final order = await _orderRepository.getOrderById(orderId);
        AppLogger.d('Polling order ${order.id}: ${order.status}');
        if (order.status == OrderStatus.paid) {
          _stopPolling();
          _setState(OrderPlacementState.paid);
        } else if (order.status == OrderStatus.cancelled) {
          _stopPolling();
          _setState(OrderPlacementState.cancelled);
        }
      } catch (e, s) {
        // Keep polling on transient network errors; only log.
        AppLogger.w('Poll failed (will retry): $e');
        AppLogger.d(s);
      }
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Stops the polling timer without calling [notifyListeners].
  ///
  /// Safe to call from a widget's [dispose] — the framework tree is locked
  /// during unmounting, so any call to [notifyListeners] at that point throws
  /// "setState() called when widget tree was locked". Cancelling the timer
  /// is a pure side effect that requires no rebuild.
  void cancelPolling() => _stopPolling();

  /// Resets to idle so a new checkout can start (e.g. after cancellation).
  void reset() {
    _stopPolling();
    _placedOrder = null;
    _errorMessage = null;
    _setState(OrderPlacementState.idle);
  }

  void _setState(OrderPlacementState newState) {
    _state = newState;
    if (newState != OrderPlacementState.error) _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
