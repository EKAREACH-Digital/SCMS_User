import 'package:flutter/foundation.dart';

import '../../../../data/repositories/coupon/coupon_repository.dart';
import '../../../../data/repositories/wallet/wallet_repository.dart';
import '../../../../model/coupon/coupon_plan.dart';
import '../../../../model/transaction/receipt.dart';
import 'package:smart_canteen_user_frontend/core/utils/async_value.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletRepository _walletRepository;
  final CouponRepository _couponRepository;

  AsyncValue<double> _balanceState = const AsyncLoading();
  AsyncValue<List<Receipt>> _transactionsState = const AsyncLoading();
  AsyncValue<List<ActiveCoupon>> _couponsState = const AsyncLoading();

  WalletViewModel(this._walletRepository, this._couponRepository);

  AsyncValue<double> get balanceState => _balanceState;
  AsyncValue<List<Receipt>> get transactionsState => _transactionsState;
  AsyncValue<List<ActiveCoupon>> get couponsState => _couponsState;

  Future<void> fetchAll() async {
    await Future.wait([
      fetchBalance(),
      fetchTransactions(),
      fetchActiveCoupons(),
    ]);
  }

  Future<void> fetchBalance() async {
    _balanceState = const AsyncLoading();
    notifyListeners();

    try {
      final dto = await _walletRepository.getBalance();
      _balanceState = AsyncData(dto.balanceUsd);
    } catch (e, s) {
      _balanceState = AsyncError(e, s);
    }

    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    _transactionsState = const AsyncLoading();
    notifyListeners();

    try {
      final dtos = await _walletRepository.getTransactions();
      _transactionsState = AsyncData(dtos.map(Receipt.fromDto).toList());
    } catch (e, s) {
      _transactionsState = AsyncError(e, s);
    }

    notifyListeners();
  }

  Future<void> fetchActiveCoupons() async {
    _couponsState = const AsyncLoading();
    notifyListeners();

    try {
      final dtos = await _couponRepository.getActiveCoupons();
      _couponsState = AsyncData(dtos.map(ActiveCoupon.fromDto).toList());
    } catch (e, s) {
      _couponsState = AsyncError(e, s);
    }

    notifyListeners();
  }
}
