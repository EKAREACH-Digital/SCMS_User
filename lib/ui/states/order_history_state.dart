import 'package:flutter/foundation.dart';

import '../../data/dtos/order_dto.dart';
import '../../data/dtos/wallet_dto.dart';
import '../../data/exceptions/api_exception.dart';
import '../../data/repositories/order/order_repository.dart';
import '../../data/repositories/wallet/wallet_repository.dart';

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.type = 'order',
    this.session,
    this.imagePath,
    this.imageUrl,
    this.logoAsset,
    this.colorSeed = 0,
  });

  final String id;
  final String date;
  final String items;
  final double total;

  /// Real timestamp, used to sort the merged orders + top-ups chronologically.
  final DateTime createdAt;

  /// 'Pending', 'Completed', or 'Failed'.
  final String status;

  /// 'order' or 'deposit'.
  final String type;

  /// 'Breakfast' or 'Lunch' for food orders; null for deposits.
  final String? session;

  /// First item's bundled asset path — set for optimistically-added orders.
  final String? imagePath;

  /// First item's remote photo, from the backend's `image_url`. Preferred over
  /// [imagePath]; both null falls back to the gradient placeholder.
  final String? imageUrl;

  /// Payment-method logo for a top-up (`asset/payment method/*.png`), so a
  /// deposit shows the bank it came through rather than a generic icon.
  final String? logoAsset;

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

  /// Loads the signed-in user's real history — food orders (`GET /orders/my`)
  /// and wallet top-ups (`GET /wallet/:id/transactions`) — merges them, sorts
  /// newest-first, and replaces the list. On failure the current list is kept
  /// and [error] is set.
  Future<void> loadFromBackend(
    OrderRepository orderRepo,
    WalletRepository walletRepo,
  ) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        orderRepo.getMyOrders(),
        _safeTransactions(walletRepo),
      ]);
      final orderDtos = results[0] as List<OrderSummaryDto>;
      final txDtos = results[1] as List<TransactionDto>;

      final records = <OrderRecord>[
        for (final (i, o) in orderDtos.indexed) _toOrderRecord(o, i),
        // Only "money in" (top-ups / refunds). Wallet 'payment' rows are the
        // same as the food orders above, so we skip them to avoid duplicates.
        for (final t
            in txDtos.where((t) => t.type == 'topup' || t.type == 'refund'))
          _toDepositRecord(t),
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

  /// Wallet transactions throw if the user has no wallet yet — treat as empty.
  Future<List<TransactionDto>> _safeTransactions(WalletRepository repo) async {
    try {
      return await repo.getTransactions();
    } catch (_) {
      return const [];
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
    );
  }

  /// Bundled logos for the top-up methods the app offers.
  static const _methodLogos = <String, String>{
    'aba': 'asset/payment method/aba.png',
    'bakong': 'asset/payment method/bakong.png',
    'acleda': 'asset/payment method/acleda.png',
  };

  /// Picks a bank logo from the transaction note.
  ///
  /// The backend stores the method in free text (`notes`), e.g.
  /// "ABA PayWay top-up PW…" — there's no structured method column on
  /// wallet_transactions, so match on the name. Null keeps the generic
  /// wallet icon.
  static String? _logoForDescription(String description) {
    final text = description.toLowerCase();
    for (final entry in _methodLogos.entries) {
      if (text.contains(entry.key)) return entry.value;
    }
    return null;
  }

  OrderRecord _toDepositRecord(TransactionDto t) {
    return OrderRecord(
      id: t.id,
      date: _fmtDate(t.createdAt),
      items: t.description.isEmpty ? 'Wallet Top-up' : t.description,
      total: t.amountUsd,
      status: 'Completed',
      createdAt: t.createdAt,
      type: 'deposit',
      logoAsset: _logoForDescription(t.description),
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
