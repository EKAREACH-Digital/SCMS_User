import '../../dtos/wallet_dto.dart';
import 'wallet_repository.dart';

class WalletRepositoryMock implements WalletRepository {
  double _balanceUsd = 16.25;

  @override
  Future<WalletBalanceDto> getBalance() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return WalletBalanceDto(
      walletId: 'wallet-mock-001',
      balanceKhr: _balanceUsd * 4000,
      balanceUsd: _balanceUsd,
      isActive: true,
    );
  }

  @override
  Future<WalletBalanceDto> topUp(double amountUsd, {String? method}) async {
    await Future.delayed(const Duration(seconds: 3));
    _balanceUsd += amountUsd;
    return WalletBalanceDto(
      walletId: 'wallet-mock-001',
      balanceKhr: _balanceUsd * 4000,
      balanceUsd: _balanceUsd,
      isActive: true,
    );
  }

  @override
  Future<WalletBalanceDto> payment(double amountUsd) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (_balanceUsd < amountUsd) {
      throw Exception('Insufficient balance');
    }
    _balanceUsd -= amountUsd;
    return WalletBalanceDto(
      walletId: 'wallet-mock-001',
      balanceKhr: _balanceUsd * 4000,
      balanceUsd: _balanceUsd,
      isActive: true,
    );
  }

  @override
  Future<List<TransactionDto>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      TransactionDto(id: 'tx-001', type: 'topup', amountUsd: 10.00, description: 'Wallet top-up', createdAt: DateTime.now().subtract(const Duration(days: 1))),
      TransactionDto(id: 'tx-002', type: 'purchase', amountUsd: 2.00, description: 'Khmer Noodle', createdAt: DateTime.now().subtract(const Duration(hours: 6))),
      TransactionDto(id: 'tx-003', type: 'purchase', amountUsd: 1.75, description: 'Pork with Rice', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
    ];
  }
}
