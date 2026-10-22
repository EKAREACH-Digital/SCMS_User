/// A movement of money in or out of the wallet.
class WalletTransaction {
  final String id;
  final TransactionType type;
  final double amountUsd;
  final String description;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amountUsd,
    required this.description,
    required this.createdAt,
  });

  WalletTransaction copyWith({
    String? id,
    TransactionType? type,
    double? amountUsd,
    String? description,
    DateTime? createdAt,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amountUsd: amountUsd ?? this.amountUsd,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedAmount {
    final prefix = type == TransactionType.topup ? '+' : '-';
    return '$prefix\$${amountUsd.toStringAsFixed(2)}';
  }
}

enum TransactionType {
  topup,
  purchase,
  refund;

  static TransactionType fromString(String value) => switch (value) {
        'purchase' => TransactionType.purchase,
        'refund' => TransactionType.refund,
        _ => TransactionType.topup,
      };

  String get label => switch (this) {
        TransactionType.topup => 'Top Up',
        TransactionType.purchase => 'Purchase',
        TransactionType.refund => 'Refund',
      };
}
