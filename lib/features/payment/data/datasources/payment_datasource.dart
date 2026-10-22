import 'package:smart_canteen_user_frontend/features/payment/data/models/payment_dto.dart';

abstract class PaymentDatasource {
  /// Opens a payment session for [amountUsd] and returns the QR / deeplink.
  Future<TopupSessionDto> startTopUp(double amountUsd);

  /// The backend's raw status string for a started top-up.
  Future<String> checkStatus(String tranId);
}
