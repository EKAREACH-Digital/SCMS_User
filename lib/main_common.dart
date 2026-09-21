import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/local/order_alert_service.dart';
import 'data/repositories/auth/auth_repository.dart';
import 'data/repositories/coupon/coupon_repository.dart';
import 'data/repositories/menu/menu_repository.dart';
import 'data/repositories/notification/notification_repository.dart';
import 'data/repositories/order/order_repository.dart';
import 'data/repositories/payment/payment_repository.dart';
import 'data/repositories/wallet/wallet_repository.dart';
import 'l10n/app_localizations.dart';
import 'model/cart/cart_model.dart';
import 'theme/app_theme.dart';
import 'ui/screens/alerts/notification_screen.dart';
import 'ui/screens/alerts/view_model/notification_view_model.dart';
import 'ui/screens/coupon_purchase/order_summary_screen.dart';
import 'ui/screens/coupon_purchase/payment_method_screen.dart';
import 'ui/screens/coupon_purchase/view_model/purchase_view_model.dart';
import 'ui/screens/digital_wallet/history_screen.dart';
import 'ui/screens/digital_wallet/qr_screen.dart';
import 'ui/screens/digital_wallet/view_model/wallet_view_model.dart';
import 'ui/screens/shell/app_shell.dart';
import 'ui/screens/login/forgot_password_screen.dart';
import 'ui/screens/login/sign_in_screen.dart';
import 'ui/screens/login/sign_up_screen.dart';
import 'ui/screens/login/view_model/auth_view_model.dart';
import 'ui/screens/menu_browsing/menu_screen.dart';
import 'ui/screens/menu_browsing/weekly_menu_screen.dart';
import 'ui/screens/settings/settings_screen.dart';
import 'ui/screens/settings/about_screen.dart';
import 'ui/screens/settings/edit_profile_screen.dart';
import 'ui/screens/settings/notification_settings_screen.dart';
import 'ui/screens/settings/payment_methods_screen.dart';
import 'ui/screens/settings/set_password_screen.dart';
import 'ui/screens/splash/splash_screen.dart';
import 'ui/screens/topup/topup_screen.dart';
import 'ui/states/active_coupon_state.dart';
import 'ui/states/app_settings_state.dart';
import 'ui/states/balance_state.dart';
import 'ui/states/meal_coupons_state.dart';
import 'ui/states/menu_state.dart';
import 'ui/states/notification_prefs_state.dart';
import 'ui/states/order_history_state.dart';
import 'ui/states/payment_methods_state.dart';
import 'ui/states/user_profile_state.dart';
import 'ui/states/weekly_menu_state.dart';

class SmartCanteenApp extends StatefulWidget {
  const SmartCanteenApp({
    super.key,
    required this.authRepository,
    required this.menuRepository,
    required this.couponRepository,
    required this.walletRepository,
    required this.orderRepository,
    required this.notificationRepository,
    required this.paymentRepository,
  });

  final AuthRepository authRepository;
  final MenuRepository menuRepository;
  final CouponRepository couponRepository;
  final WalletRepository walletRepository;
  final OrderRepository orderRepository;
  final NotificationRepository notificationRepository;
  final PaymentRepository paymentRepository;

  @override
  State<SmartCanteenApp> createState() => _SmartCanteenAppState();
}

class _SmartCanteenAppState extends State<SmartCanteenApp> {
  final _cart = CartModel();

  @override
  void initState() {
    super.initState();
    // Asks for notification permission and registers the Android channel.
    // Fire-and-forget: a refusal must not hold up the first frame.
    OrderAlertService.instance.init();
  }

  @override
  void dispose() {
    _cart.dispose();
    OrderAlertService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<AuthRepository>.value(value: widget.authRepository),
        Provider<MenuRepository>.value(value: widget.menuRepository),
        Provider<CouponRepository>.value(value: widget.couponRepository),
        Provider<WalletRepository>.value(value: widget.walletRepository),
        Provider<OrderRepository>.value(value: widget.orderRepository),
        Provider<NotificationRepository>.value(
          value: widget.notificationRepository,
        ),
        Provider<PaymentRepository>.value(value: widget.paymentRepository),

        // Global states
        ChangeNotifierProvider.value(value: _cart),
        ChangeNotifierProvider(
          create: (_) => MealCouponsState(widget.orderRepository),
        ),
        ChangeNotifierProvider(create: (_) => AppSettingsState()),
        ChangeNotifierProvider(create: (_) => UserProfileState()),
        ChangeNotifierProvider(create: (_) => PaymentMethodsState()),
        ChangeNotifierProvider(
          create: (_) => NotificationPrefsState(widget.authRepository),
        ),
        ChangeNotifierProvider(create: (_) => OrderHistoryState()),
        ChangeNotifierProvider(
          create: (_) => BalanceState(widget.walletRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ActiveCouponState(widget.couponRepository),
        ),

        // Screen view models
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(widget.authRepository),
        ),
        ChangeNotifierProvider(create: (_) => MenuState(widget.menuRepository)),
        ChangeNotifierProvider(
          create: (_) => WeeklyMenuState(widget.menuRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => PurchaseViewModel(widget.couponRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              WalletViewModel(widget.walletRepository, widget.couponRepository),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final vm = NotificationViewModel(widget.notificationRepository);
            // Fold each order-ready alert into the Alerts feed as it comes due,
            // so the tab shows the same message the OS just delivered.
            OrderAlertService.instance.onAlert.listen(
              (alert) => vm.addLocal(
                id: 'local-${alert.orderId}-${alert.dueAt.microsecondsSinceEpoch}',
                title: alert.title,
                body: alert.body,
                imageUrl: alert.imageUrl,
                imageAsset: alert.imageAsset,
              ),
            );
            return vm;
          },
        ),
      ],
      child: CartProvider(
        cart: _cart,
        child: Consumer<AppSettingsState>(
          builder: (_, settings, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Canteen',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: SplashScreen.routeName,
            routes: {
              SplashScreen.routeName: (_) => const SplashScreen(),
              SignInScreen.routeName: (_) => const SignInScreen(),
              SignUpScreen.routeName: (_) => const SignUpScreen(),
              ForgotPasswordScreen.routeName: (_) =>
                  const ForgotPasswordScreen(),
              // `arguments` selects the tab, so callers can return to the
              // shell on a specific tab instead of pushing a bare screen.
              AppShell.routeName: (ctx) {
                final tab = ModalRoute.of(ctx)?.settings.arguments;
                return AppShell(initialTab: tab is int ? tab : 0);
              },
              MenuScreen.routeName: (_) => const MenuScreen(),
              WeeklyMenuScreen.routeName: (_) => const WeeklyMenuScreen(),
              OrderSummaryScreen.routeName: (_) => const OrderSummaryScreen(),
              PaymentMethodScreen.routeName: (ctx) {
                final amount = ModalRoute.of(ctx)?.settings.arguments;
                return PaymentMethodScreen(
                  totalAmount: amount is num ? amount.toDouble() : 0,
                );
              },
              QrScreen.routeName: (_) => const QrScreen(),
              HistoryScreen.routeName: (_) => const HistoryScreen(),
              SettingsScreen.routeName: (_) => const SettingsScreen(),
              NotificationScreen.routeName: (_) => const NotificationScreen(),
              EditProfileScreen.routeName: (_) => const EditProfileScreen(),
              PaymentMethodsScreen.routeName: (_) =>
                  const PaymentMethodsScreen(),
              NotificationSettingsScreen.routeName: (_) =>
                  const NotificationSettingsScreen(),
              SetPasswordScreen.routeName: (_) => const SetPasswordScreen(),
              AboutScreen.routeName: (_) => const AboutScreen(),
              TopUpScreen.routeName: (_) => const TopUpScreen(),
            },
          ),
        ),
      ),
    );
  }
}
