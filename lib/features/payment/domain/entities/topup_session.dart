/// A wallet top-up payment session opened by our backend against the gateway
/// (currently ABA PayWay). The app never sees gateway credentials.
class TopupSession {
  /// Our reference for this payment; used to poll for completion.
  final String tranId;

  /// Raw EMVCo KHQR payload — rendered by the app so the QR matches its own
  /// styling instead of the gateway's template.
  final String qrString;

  /// `abamobilebank://...` — opens the bank app on this device.
  final String abapayDeeplink;

  final double amountUsd;

  const TopupSession({
    required this.tranId,
    required this.qrString,
    required this.abapayDeeplink,
    required this.amountUsd,
  });

  TopupSession copyWith({
    String? tranId,
    String? qrString,
    String? abapayDeeplink,
    double? amountUsd,
  }) {
    return TopupSession(
      tranId: tranId ?? this.tranId,
      qrString: qrString ?? this.qrString,
      abapayDeeplink: abapayDeeplink ?? this.abapayDeeplink,
      amountUsd: amountUsd ?? this.amountUsd,
    );
  }
}

/// Where a top-up currently stands.
enum TopupStatus {
  pending,
  paid,
  failed,
  notFound;

  /// True once polling should stop, whether or not the payment succeeded.
  bool get isTerminal => this != TopupStatus.pending;
}
