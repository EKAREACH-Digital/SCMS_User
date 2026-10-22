import 'package:smart_canteen_user_frontend/features/wallet/domain/entities/wallet_balance.dart';
import 'package:smart_canteen_user_frontend/features/wallet/domain/entities/wallet_transaction.dart';

class WalletBalanceDto {
  final String walletId;
  final double balanceKhr;
  final double balanceUsd;
  final bool isActive;

  const WalletBalanceDto({
    required this.walletId,
    required this.balanceKhr,
    required this.balanceUsd,
    required this.isActive,
  });

  factory WalletBalanceDto.fromJson(Map<String, dynamic> json) => WalletBalanceDto(
        walletId: json['wallet_id'] as String,
        balanceKhr: (json['balance_khr'] as num).toDouble(),
        balanceUsd: (json['balance_usd'] as num).toDouble(),
        isActive: json['is_active'] as bool,
      );

  WalletBalance toEntity() => WalletBalance(
        walletId: walletId,
        balanceKhr: balanceKhr,
        balanceUsd: balanceUsd,
        isActive: isActive,
      );
}

class TransactionDto {
  final String id;
  final String type; // 'topup' | 'purchase' | 'refund'
  final double amountUsd;
  final String description;
  final DateTime createdAt;

  const TransactionDto({
    required this.id,
    required this.type,
    required this.amountUsd,
    required this.description,
    required this.createdAt,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) => TransactionDto(
        id: json['id'] as String,
        type: json['type'] as String,
        amountUsd: (json['amount_usd'] as num).toDouble(),
        description: json['description'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  WalletTransaction toEntity() => WalletTransaction(
        id: id,
        type: TransactionType.fromString(type),
        amountUsd: amountUsd,
        description: description,
        createdAt: createdAt,
      );
}
