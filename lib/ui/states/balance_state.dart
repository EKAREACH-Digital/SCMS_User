import 'package:flutter/foundation.dart';

import '../../data/repositories/wallet/wallet_repository.dart';
import '../../model/transaction/receipt.dart';
import '../utils/async_value.dart';

class BalanceState extends ChangeNotifier {
  final WalletRepository _walletRepository;

  AsyncValue<double> _balanceUsd = const AsyncLoading();
  AsyncValue<List<Receipt>> _transactions = const AsyncLoading();

  BalanceState(this._walletRepository);

  AsyncValue<double> get balanceUsd => _balanceUsd;
  AsyncValue<List<Receipt>> get transactions => _transactions;

  Future<void> fetchBalance() async {
    _balanceUsd = const AsyncLoading();
    notifyListeners();

    try {
      final dto = await _walletRepository.getBalance();
      _balanceUsd = AsyncData(dto.balanceUsd);
    } catch (e, s) {
      _balanceUsd = AsyncError(e, s);
    }

    notifyListeners();
  }

  Future<void> topUp(double amountUsd, {String? method}) async {
    final dto = await _walletRepository.topUp(amountUsd, method: method);
    _balanceUsd = AsyncData(dto.balanceUsd);
    notifyListeners();
  }

  Future<void> payment(double amountUsd) async {
    final dto = await _walletRepository.payment(amountUsd);
    _balanceUsd = AsyncData(dto.balanceUsd);
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    _transactions = const AsyncLoading();
    notifyListeners();

    try {
      final dtos = await _walletRepository.getTransactions();
      _transactions = AsyncData(dtos.map(Receipt.fromDto).toList());
    } catch (e, s) {
      _transactions = AsyncError(e, s);
    }

    notifyListeners();
  }
}
