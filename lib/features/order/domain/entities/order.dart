/// A past order, as returned by `GET /orders/my`.
class Order {
  final String id;
  final double totalAmount;
  final String status; // pending | preparing | ready | completed | cancelled
  final String mealSession;
  final DateTime createdAt;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.mealSession,
    required this.createdAt,
    required this.items,
  });

  Order copyWith({
    String? id,
    double? totalAmount,
    String? status,
    String? mealSession,
    DateTime? createdAt,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      mealSession: mealSession ?? this.mealSession,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}

/// One line of an order: a dish and how many of it.
class OrderItem {
  final String name;
  final int quantity;
  final String? imageUrl;

  /// What one unit cost when the order was placed, or null when the backend
  /// gave no price for this line.
  final double? unitPrice;

  const OrderItem({
    required this.name,
    required this.quantity,
    this.imageUrl,
    this.unitPrice,
  });

  OrderItem copyWith({
    String? name,
    int? quantity,
    String? imageUrl,
    double? unitPrice,
  }) {
    return OrderItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

/// A line of a new order to place.
class NewOrderItem {
  final String menuItemId;
  final int quantity;

  const NewOrderItem({required this.menuItemId, required this.quantity});

  NewOrderItem copyWith({String? menuItemId, int? quantity}) {
    return NewOrderItem(
      menuItemId: menuItemId ?? this.menuItemId,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// The result of `POST /orders/checkout`: order id + payment session details.
///
/// [qrImage] is an SVG URL (CutLuy) or a `data:image/png;base64,...` string
/// (ABA PayWay). Render it based on [provider].
/// [deeplink] is the `abamobilebank://` URI for ABA PayWay — may be null for
/// CutLuy or when the gateway doesn't return one.
/// [expiresAt] is the QR expiry time; may be null for ABA PayWay (default 15
/// minutes from checkout).
class PlacedOrder {
  final String orderId;
  final String provider;
  final double totalAmount;
  final String qrString;
  final String qrImage;
  final String? checkoutUrl;
  final String? deeplink;
  final DateTime? expiresAt;

  const PlacedOrder({
    required this.orderId,
    required this.provider,
    required this.totalAmount,
    required this.qrString,
    required this.qrImage,
    this.checkoutUrl,
    this.deeplink,
    this.expiresAt,
  });

  /// True when this is a CutLuy (Bakong) order; false for ABA PayWay.
  bool get isCutluy => provider == 'CUTLUY';

  PlacedOrder copyWith({
    String? orderId,
    String? provider,
    double? totalAmount,
    String? qrString,
    String? qrImage,
    String? checkoutUrl,
    String? deeplink,
    DateTime? expiresAt,
  }) {
    return PlacedOrder(
      orderId: orderId ?? this.orderId,
      provider: provider ?? this.provider,
      totalAmount: totalAmount ?? this.totalAmount,
      qrString: qrString ?? this.qrString,
      qrImage: qrImage ?? this.qrImage,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      deeplink: deeplink ?? this.deeplink,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
