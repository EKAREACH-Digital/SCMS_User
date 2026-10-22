import 'package:dio/dio.dart';

import 'package:smart_canteen_user_frontend/core/config/api_config.dart';
import 'package:smart_canteen_user_frontend/core/error/error_handler.dart';
import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/features/wallet/data/datasources/wallet_datasource.dart';
import 'package:smart_canteen_user_frontend/features/wallet/data/models/wallet_dto.dart';

/// Talks to the NestJS wallet endpoints. The backend stores a single `balance`
/// (in USD) per wallet and exposes wallets by id, so this datasource first resolves
/// the signed-in user's wallet via `GET /wallet/my`, then acts on it by id.
class WalletRemoteDatasource implements WalletDatasource {
  WalletRemoteDatasource(this._dio);

  final Dio _dio;

  /// Riel per USD. Matches [CurrencyFormatter]'s default so displayed KHR/USD
  /// stay consistent across the app.
  static const double _khrPerUsd = 4000.0;

  /// Cached id of the user's wallet, resolved lazily from `GET /wallet/my`.
  String? _walletId;

  @override
  Future<WalletBalanceDto> getBalance() async {
    final wallet = await _fetchPrimaryWallet();
    return _toBalanceDto(wallet);
  }

  @override
  Future<WalletBalanceDto> topUp(double amountUsd, {String? method}) async {
    final walletId = await _resolveWalletId();
    final response = await _post(ApiConfig.walletTopUp(walletId), {
      'amount': amountUsd,
      if (method != null && method.isNotEmpty) 'notes': 'Top-up via $method',
    });
    return _toBalanceDto(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<WalletBalanceDto> payment(double amountUsd) async {
    final walletId = await _resolveWalletId();
    final response = await _post(ApiConfig.walletPay(walletId), {
      'amount': amountUsd,
    });
    return _toBalanceDto(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<TransactionDto>> getTransactions() async {
    final walletId = await _resolveWalletId();
    try {
      final response = await _dio.get(ApiConfig.walletTransactions(walletId));
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => _toTransactionDto(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error loading transactions: $e');
    }
  }

  /// Fetches the user's wallets and returns the first one, caching its id.
  Future<Map<String, dynamic>> _fetchPrimaryWallet() async {
    try {
      final response = await _dio.get(ApiConfig.walletMy);
      final list = response.data['data'] as List<dynamic>;
      if (list.isEmpty) {
        throw const ApiException('No wallet found for this account.');
      }
      final wallet = list.first as Map<String, dynamic>;
      _walletId = wallet['id'] as String;
      return wallet;
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Unexpected error loading wallet: $e');
    }
  }

  Future<String> _resolveWalletId() async {
    return _walletId ??= (await _fetchPrimaryWallet())['id'] as String;
  }

  WalletBalanceDto _toBalanceDto(Map<String, dynamic> wallet) {
    final balanceUsd = _toDouble(wallet['balance']);
    return WalletBalanceDto(
      walletId: wallet['id'] as String,
      balanceUsd: balanceUsd,
      balanceKhr: balanceUsd * _khrPerUsd,
      isActive: true,
    );
  }

  TransactionDto _toTransactionDto(Map<String, dynamic> tx) {
    final backendType = tx['transaction_type'] as String?;
    return TransactionDto(
      id: tx['id'] as String,
      type: _mapTransactionType(backendType),
      amountUsd: _toDouble(tx['amount']),
      description: (tx['notes'] as String?) ?? _defaultDescription(backendType),
      createdAt: DateTime.parse(tx['created_at'] as String),
    );
  }

  /// Maps the backend `transaction_type` to the string [TransactionType] parses.
  String _mapTransactionType(String? backendType) => switch (backendType) {
    'payment' => 'purchase',
    'refund' => 'refund',
    _ => 'topup', // 'top_up' and 'transfer' both read as a credit
  };

  String _defaultDescription(String? backendType) => switch (backendType) {
    'payment' => 'Payment',
    'refund' => 'Refund',
    'transfer' => 'Transfer',
    _ => 'Wallet top-up',
  };

  /// Decimal columns arrive as JSON strings (e.g. "25.00"); coerce safely.
  double _toDouble(dynamic value) => switch (value) {
    num n => n.toDouble(),
    String s => double.tryParse(s) ?? 0.0,
    _ => 0.0,
  };

  Future<Response<dynamic>> _post(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw ErrorHandler.fromDio(e);
    } catch (e) {
      throw ApiException('Unexpected error calling $path: $e');
    }
  }
}
