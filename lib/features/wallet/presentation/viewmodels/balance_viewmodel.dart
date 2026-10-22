import 'package:flutter/foundation.dart';

import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:smart_canteen_user_frontend/features/wallet/domain/repositories/wallet_repository.dart';

/// The wallet balance (shown in Settings) and its transactions.
class BalanceViewModel extends ChangeNotifier {
  BalanceViewModel(this._walletRepository);

  final WalletRepository _walletRepository;

  ViewState _state = ViewState.idle;
  double? _balanceUsd;
  String? _errorMessage;

  ViewState _transactionsState = ViewState.idle;
  List<WalletTransaction> _transactions = const [];

  /// Status of the balance.
  ViewState get state => _state;

  /// The balance in USD, or null while loading or after a failed load.
  double? get balanceUsd => _balanceUsd;

  /// Why the last balance load failed; null unless [state] is
  /// [ViewState.error].
  String? get errorMessage => _errorMessage;

  ViewState get transactionsState => _transactionsState;
  List<WalletTransaction> get transactions => _transactions;

  Future<void> fetchBalance() async {
    _balanceUsd = null;
    _setState(ViewState.loading);
    try {
      _balanceUsd = (await _walletRepository.getBalance()).balanceUsd;
      _setState(ViewState.success);
    } catch (e, s) {
      AppLogger.e('Loading the wallet balance failed', e, s);
      _errorMessage = _describe(e, "Couldn't load your balance.");
      _setState(ViewState.error);
    }
  }

  /// Adds funds and shows the new balance. Throws on failure.
  Future<void> topUp(double amountUsd, {String? method}) async {
    final balance = await _walletRepository.topUp(amountUsd, method: method);
    _balanceUsd = balance.balanceUsd;
    _setState(ViewState.success);
  }

  /// Pays from the wallet and shows the new balance. Throws on failure.
  Future<void> payment(double amountUsd) async {
    final balance = await _walletRepository.payment(amountUsd);
    _balanceUsd = balance.balanceUsd;
    _setState(ViewState.success);
  }

  Future<void> fetchTransactions() async {
    _transactionsState = ViewState.loading;
    _setState(_state);
    try {
      _transactions = await _walletRepository.getTransactions();
      _transactionsState = ViewState.success;
    } catch (e, s) {
      AppLogger.e('Loading wallet transactions failed', e, s);
      _transactionsState = ViewState.error;
    }
    _setState(_state);
  }

  static String _describe(Object e, String fallback) =>
      e is ApiException ? e.message : '$fallback Please try again.';

  /// The only place listeners are notified. Leaving the error state clears
  /// the error message.
  void _setState(ViewState newState) {
    _state = newState;
    if (newState != ViewState.error) _errorMessage = null;
    notifyListeners();
  }
}
