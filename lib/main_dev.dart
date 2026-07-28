import 'package:flutter/material.dart';

import 'data/repositories/auth/auth_repository_mock.dart';
import 'data/repositories/coupon/coupon_repository_mock.dart';
import 'data/repositories/menu/menu_repository_mock.dart';
import 'data/repositories/notification/notification_repository_mock.dart';
import 'data/repositories/order/order_repository_mock.dart';
import 'data/repositories/wallet/wallet_repository_mock.dart';
import 'data/repositories/payment/payment_repository_mock.dart';
import 'main_common.dart';

void main() {
  runApp(
    SmartCanteenApp(
      authRepository:   AuthRepositoryMock(),
      menuRepository:   MenuRepositoryMock(),
      couponRepository: CouponRepositoryMock(),
      walletRepository: WalletRepositoryMock(),
      orderRepository:  OrderRepositoryMock(),
      notificationRepository: NotificationRepositoryMock(),
      paymentRepository: PaymentRepositoryMock(),
    ),
  );
}
