/// Where an order is in its life, as the backend reports it on `GET /orders/my`,
/// `GET /orders/{id}` and `GET /pickup/my/{id}`.
enum OrderStatus {
  /// Checked out, waiting for the student to pay. No pickup QR yet.
  pendingPayment,

  /// Paid; the canteen is preparing it.
  paid,

  /// Prepared and waiting at the counter: the student can come pick it up.
  ready,

  /// Handed over. The pickup QR can't be used again.
  completed,

  /// Not paid in time or cancelled. Never charged.
  cancelled,
}
