import '../../dtos/wallet_dto.dart';

abstract class WalletRepository {
  Future<WalletBalanceDto> getBalance();

  /// Adds funds to the wallet.
  ///
  /// [method] is the payment method's display name (e.g. "ABA Pay"). It is
  /// stored on the transaction so history can show which bank the money came
  /// through — without it the backend records a generic note and the method
  /// is lost for good.
  Future<WalletBalanceDto> topUp(double amountUsd, {String? method});

  Future<WalletBalanceDto> payment(double amountUsd);
  Future<List<TransactionDto>> getTransactions();
}
