import 'package:smart_canteen_user_frontend/features/payment/data/datasources/payment_datasource.dart';
import 'package:smart_canteen_user_frontend/features/payment/data/models/payment_dto.dart';
import 'package:smart_canteen_user_frontend/features/payment/domain/entities/topup_session.dart';
import 'package:smart_canteen_user_frontend/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._datasource);

  final PaymentDatasource _datasource;

  @override
  Future<TopupSession> startTopUp(double amountUsd) async =>
      (await _datasource.startTopUp(amountUsd)).toEntity();

  @override
  Future<TopupStatus> checkStatus(String tranId) async =>
      parseTopupStatus(await _datasource.checkStatus(tranId));
}
