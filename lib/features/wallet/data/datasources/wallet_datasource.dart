import 'package:smart_canteen_user_frontend/features/wallet/data/models/wallet_dto.dart';

abstract class WalletDatasource {
  Future<WalletBalanceDto> getBalance();

  /// [method] is the payment method's display name, stored on the transaction.
  Future<WalletBalanceDto> topUp(double amountUsd, {String? method});

  Future<WalletBalanceDto> payment(double amountUsd);

  Future<List<TransactionDto>> getTransactions();
}
