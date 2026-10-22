import 'package:smart_canteen_user_frontend/features/wallet/data/datasources/wallet_datasource.dart';
import 'package:smart_canteen_user_frontend/features/wallet/domain/entities/wallet_balance.dart';
import 'package:smart_canteen_user_frontend/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:smart_canteen_user_frontend/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._datasource);

  final WalletDatasource _datasource;

  @override
  Future<WalletBalance> getBalance() async =>
      (await _datasource.getBalance()).toEntity();

  @override
  Future<WalletBalance> topUp(double amountUsd, {String? method}) async =>
      (await _datasource.topUp(amountUsd, method: method)).toEntity();

  @override
  Future<WalletBalance> payment(double amountUsd) async =>
      (await _datasource.payment(amountUsd)).toEntity();

  @override
  Future<List<WalletTransaction>> getTransactions() async =>
      (await _datasource.getTransactions()).map((t) => t.toEntity()).toList();
}
