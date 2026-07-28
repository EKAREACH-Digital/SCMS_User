import '../../dtos/payment_dto.dart';

/// Wallet top-ups paid through an external gateway (currently ABA PayWay).
///
/// The gateway is entirely a backend concern — this interface only speaks in
/// terms of "start a payment" and "has it been paid yet", so switching or
/// adding providers changes nothing in the app.
abstract class PaymentRepository {
  /// Opens a payment session for [amountUsd] and returns the QR / deeplink.
  Future<TopupSessionDto> startTopUp(double amountUsd);

  /// Current state of a previously started top-up.
  Future<TopupStatus> checkStatus(String tranId);
}
