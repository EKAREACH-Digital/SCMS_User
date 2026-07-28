import 'package:flutter/material.dart';

import 'data/repositories/auth/auth_repository_nestjs.dart';
import 'data/repositories/coupon/coupon_repository_nestjs.dart';
import 'data/repositories/menu/menu_repository_nestjs.dart';
import 'data/repositories/notification/notification_repository_nestjs.dart';
import 'data/repositories/order/order_repository_nestjs.dart';
import 'data/repositories/wallet/wallet_repository_nestjs.dart';
import 'data/repositories/payment/payment_repository_nestjs.dart';
import 'main_common.dart';

void main() {
  runApp(
    SmartCanteenApp(
      authRepository: AuthRepositoryNestjs(),
      menuRepository: MenuRepositoryNestjs(),
      couponRepository: CouponRepositoryNestjs(),
      walletRepository: WalletRepositoryNestjs(),
      orderRepository: OrderRepositoryNestjs(),
      notificationRepository: NotificationRepositoryNestjs(),
      paymentRepository: PaymentRepositoryNestjs(),
    ),
  );
}
