import 'package:smart_canteen_user_frontend/features/wallet/domain/entities/wallet_balance.dart';
import 'package:smart_canteen_user_frontend/features/wallet/domain/entities/wallet_transaction.dart';

abstract class WalletRepository {
  Future<WalletBalance> getBalance();

  /// Adds funds to the wallet.
  ///
  /// [method] is the payment method's display name (e.g. "ABA Pay"). It is
  /// stored on the transaction so history can show which bank the money came
  /// through — without it the backend records a generic note and the method
  /// is lost for good.
  Future<WalletBalance> topUp(double amountUsd, {String? method});

  Future<WalletBalance> payment(double amountUsd);

  Future<List<WalletTransaction>> getTransactions();
}
