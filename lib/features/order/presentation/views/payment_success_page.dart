import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:smart_canteen_user_frontend/core/constants/images_constant.dart';
import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';

/// Shown after the backend confirms payment (`paid`).
/// Plays [ImageConst.checkMark] once, waits 1 500 ms, then navigates to
/// the History tab via GoRouter.
class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              child: Lottie.asset(
                ImageConst.checkMark,
                width: 220,
                height: 220,
                repeat: false,
                onLoaded: (composition) {
                  // Capture router before the async gap to satisfy the lint.
                  final router = GoRouter.of(context);
                  Future.delayed(
                    composition.duration + const Duration(milliseconds: 1500),
                    () {
                      if (mounted) router.go(AppPaths.history);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Successful!',
              style: AppFonts.heading1.copyWith(
                color: context.textColor,
                fontWeight: AppFonts.semiBold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order has been confirmed.',
              style: AppFonts.heading3.copyWith(color: context.mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}
