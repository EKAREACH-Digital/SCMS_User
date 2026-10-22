import 'package:flutter/foundation.dart';

import 'package:smart_canteen_user_frontend/features/payment/domain/entities/topup_session.dart';
import 'package:smart_canteen_user_frontend/features/payment/domain/repositories/payment_repository.dart';

/// Gateway calls for the top-up page. The page owns the stage machine and the
/// polling timer (both tied to its lifecycle); this view model owns the calls.
class TopUpViewModel extends ChangeNotifier {
  TopUpViewModel(this._paymentRepository);

  final PaymentRepository _paymentRepository;

  /// Opens a payment session for [amountUsd]. Throws on failure.
  Future<TopupSession> startTopUp(double amountUsd) =>
      _paymentRepository.startTopUp(amountUsd);

  /// Current state of the top-up [tranId]. Throws on failure.
  Future<TopupStatus> checkStatus(String tranId) =>
      _paymentRepository.checkStatus(tranId);
}
