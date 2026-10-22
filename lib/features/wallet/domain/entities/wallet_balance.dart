/// The signed-in user's wallet balance.
class WalletBalance {
  final String walletId;
  final double balanceKhr;
  final double balanceUsd;
  final bool isActive;

  const WalletBalance({
    required this.walletId,
    required this.balanceKhr,
    required this.balanceUsd,
    required this.isActive,
  });

  WalletBalance copyWith({
    String? walletId,
    double? balanceKhr,
    double? balanceUsd,
    bool? isActive,
  }) {
    return WalletBalance(
      walletId: walletId ?? this.walletId,
      balanceKhr: balanceKhr ?? this.balanceKhr,
      balanceUsd: balanceUsd ?? this.balanceUsd,
      isActive: isActive ?? this.isActive,
    );
  }
}
