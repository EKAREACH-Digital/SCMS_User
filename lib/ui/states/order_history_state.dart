import 'package:flutter/foundation.dart';

import '../../data/dtos/order_dto.dart';
import '../../data/exceptions/api_exception.dart';
import '../../data/repositories/order/order_repository.dart';

/// One dish within a past order, as the history screen displays it.
class OrderLine {
  const OrderLine({
    required this.name,
    required this.quantity,
    this.unitPrice,
    this.imageUrl,
  });

  final String name;
  final int quantity;

  /// Price per unit, or null when the backend gave no price for this line.
  final double? unitPrice;
  final String? imageUrl;

  /// What this line cost in total, or null when [unitPrice] is unknown.
  double? get lineTotal => unitPrice == null ? null : unitPrice! * quantity;
}

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.lines = const [],
    this.session,
    this.imagePath,
    this.imageUrl,
    this.colorSeed = 0,
  });

  final String id;
  final String date;

  /// One-line summary of the dishes, for the collapsed card.
  final String items;
  final double total;

  /// The dishes themselves, with quantity and price — what the details sheet
  /// breaks down. Empty for optimistically-added orders until the next
  /// refresh fills them in.
  final List<OrderLine> lines;

  /// Real timestamp, used to sort the list chronologically.
  final DateTime createdAt;

  /// 'Pending', 'Completed', or 'Failed'.
  final String status;

  /// 'Breakfast', 'Lunch' or 'Dinner'.
  final String? session;

  /// First item's bundled asset path — set for optimistically-added orders.
  final String? imagePath;

  /// First item's remote photo, from the backend's `image_url`. Preferred over
  /// [imagePath]; both null falls back to the gradient placeholder.
  final String? imageUrl;

  /// Controls which gradient/icon slot is used for the placeholder.
  final int colorSeed;
}

class OrderHistoryState extends ChangeNotifier {
  final List<OrderRecord> _orders = [];

  List<OrderRecord> get orders => List.unmodifiable(_orders);

  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;

  /// Why the last load failed, or null if it succeeded. Lets the UI tell a
  /// failed fetch apart from a genuinely empty history.
  String? get error => _error;

  /// Loads the signed-in user's food orders (`GET /orders/my`), newest first,
  /// and replaces the list. Wallet top-ups are deliberately not merged in —
  /// history is a record of what was bought, not of money moving in.
  /// On failure the current list is kept and [error] is set.
  Future<void> loadFromBackend(OrderRepository orderRepo) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final orderDtos = await orderRepo.getMyOrders();

      final records = <OrderRecord>[
        for (final (i, o) in orderDtos.indexed) _toOrderRecord(o, i),
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _orders
        ..clear()
        ..addAll(records);
    } catch (e) {
      // Keep whatever is already shown, but record why the refresh failed.
      _error = e is ApiException
          ? e.message
          : "Couldn't load your history. Check your connection and try again.";
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  OrderRecord _toOrderRecord(OrderSummaryDto o, int index) {
    final label = o.items
        .map((i) => i.quantity > 1 ? '${i.name} ×${i.quantity}' : i.name)
        .join(', ');
    // Show the first dish that actually has a photo — an order whose first
    // line happens to lack one shouldn't fall back to a blank placeholder.
    final photo = o.items
        .map((i) => i.imageUrl)
        .firstWhere((url) => url != null, orElse: () => null);
    return OrderRecord(
      id: o.id,
      date: _fmtDate(o.createdAt),
      items: label.isEmpty ? 'Order' : label,
      total: o.totalAmount,
      status: _mapStatus(o.status),
      createdAt: o.createdAt,
      session: _capitalize(o.mealSession),
      imageUrl: photo,
      colorSeed: index,
      lines: [
        for (final i in o.items)
          OrderLine(
            name: i.name,
            quantity: i.quantity,
            unitPrice: i.unitPrice,
            imageUrl: i.imageUrl,
          ),
      ],
    );
  }

  static String _mapStatus(String backend) => switch (backend) {
        'completed' => 'Completed',
        'cancelled' => 'Failed',
        _ => 'Pending',
      };

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static String _fmtDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final d = dt.toLocal();
    final now = DateTime.now();
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    final sameDay = d.year == now.year && d.month == now.month && d.day == now.day;
    return sameDay
        ? 'Today, $h:$m $period'
        : '${months[d.month - 1]} ${d.day}, $h:$m $period';
  }

  /// Inserts a new order at the top of the list (optimistic, pre-refresh).
  void addOrder(OrderRecord order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}
