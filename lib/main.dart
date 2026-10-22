import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/config/app_config.dart';
import 'package:smart_canteen_user_frontend/core/network/dio_client.dart';
import 'package:smart_canteen_user_frontend/core/routes/app_router.dart';
import 'package:smart_canteen_user_frontend/core/services/order_alert_service.dart';
import 'package:smart_canteen_user_frontend/core/services/storage_service.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:smart_canteen_user_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_canteen_user_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/menu/data/datasources/menu_remote_datasource.dart';
import 'package:smart_canteen_user_frontend/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/repositories/menu_repository.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/cart_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/menu_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/weekly_menu_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:smart_canteen_user_frontend/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:smart_canteen_user_frontend/features/notification/domain/repositories/notification_repository.dart';
import 'package:smart_canteen_user_frontend/features/notification/presentation/viewmodels/notification_prefs_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/notification/presentation/viewmodels/notification_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/order/data/datasources/order_remote_datasource.dart';
import 'package:smart_canteen_user_frontend/features/order/data/repositories/order_repository_impl.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/repositories/order_repository.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/meal_coupons_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/order_history_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:smart_canteen_user_frontend/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:smart_canteen_user_frontend/features/payment/domain/repositories/payment_repository.dart';
import 'package:smart_canteen_user_frontend/features/payment/presentation/viewmodels/payment_methods_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/payment/presentation/viewmodels/topup_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/viewmodels/app_settings_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:smart_canteen_user_frontend/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:smart_canteen_user_frontend/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:smart_canteen_user_frontend/features/wallet/presentation/viewmodels/balance_viewmodel.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

Future<void> main() async {
  // Reads .env. The Dio client captures its base URL once, when first created,
  // so this has to finish before any provider builds it.
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  // Pre-warm Liquid Glass shaders so the nav bar renders without a white flash.
  await LiquidGlassWidgets.initialize();

  runApp(
    LiquidGlassWidgets.wrap(
      child: const SmartCanteenApp(),
      brightnessResolver: Theme.maybeBrightnessOf,
    ),
  );
}

/// Wires every dependency (RULE 3): datasource → repository (provided as its
/// abstract domain type) → view model, each built from the one above it.
///
/// Which datasource backs a repository is decided here. To run a feature
/// without the backend, inject its mock instead, e.g.
/// `AuthRepositoryImpl(AuthMockDatasource(), c.read<StorageService>())`.
class SmartCanteenApp extends StatelessWidget {
  const SmartCanteenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core
        Provider<Dio>.value(value: DioClient.instance),
        Provider<StorageService>.value(value: StorageService.instance),

        // Repositories
        Provider<AuthRepository>(
          create: (c) => AuthRepositoryImpl(
            AuthRemoteDatasource(c.read<Dio>()),
            c.read<StorageService>(),
          ),
        ),
        Provider<MenuRepository>(
          create: (c) => MenuRepositoryImpl(
            MenuRemoteDatasource(c.read<Dio>()),
            imageHost: AppConfig.apiBaseUrl,
          ),
        ),
        Provider<OrderRepository>(
          create: (c) =>
              OrderRepositoryImpl(OrderRemoteDatasource(c.read<Dio>())),
        ),
        Provider<WalletRepository>(
          create: (c) =>
              WalletRepositoryImpl(WalletRemoteDatasource(c.read<Dio>())),
        ),
        Provider<PaymentRepository>(
          create: (c) =>
              PaymentRepositoryImpl(PaymentRemoteDatasource(c.read<Dio>())),
        ),
        Provider<NotificationRepository>(
          create: (c) => NotificationRepositoryImpl(
            NotificationRemoteDatasource(c.read<Dio>()),
          ),
        ),

        // App-wide view models
        ChangeNotifierProvider(
          create: (c) => AuthViewModel(c.read<AuthRepository>()),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, NotificationPrefsViewModel>(
          create: (c) =>
              NotificationPrefsViewModel(c.read<NotificationRepository>()),
          update: (_, auth, prefs) => prefs!..syncFrom(auth.userId),
        ),
        ChangeNotifierProvider(create: (_) => AppSettingsViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(
          create: (c) => MenuViewModel(c.read<MenuRepository>()),
        ),
        ChangeNotifierProvider(
          create: (c) => WeeklyMenuViewModel(c.read<MenuRepository>()),
        ),
        ChangeNotifierProvider(
          create: (c) => MealCouponsViewModel(c.read<OrderRepository>()),
        ),
        ChangeNotifierProvider(
          create: (c) => OrderHistoryViewModel(c.read<OrderRepository>()),
        ),
        ChangeNotifierProvider(
          create: (c) => BalanceViewModel(c.read<WalletRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => PaymentMethodsViewModel()),
        ChangeNotifierProvider(
          create: (c) => TopUpViewModel(c.read<PaymentRepository>()),
        ),
        ChangeNotifierProvider(
          create: (c) =>
              NotificationViewModel(c.read<NotificationRepository>()),
        ),
      ],
      child: const _AppView(),
    );
  }
}

/// The app below the providers: owns the router (which needs [AuthViewModel]
/// for its auth redirect) and the device order-alert service.
class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  /// Created once — rebuilding it would reset the navigation stack.
  late final GoRouter _router = AppRouter.create(context.read<AuthViewModel>());

  StreamSubscription<OrderAlert>? _alertSubscription;

  @override
  void initState() {
    super.initState();
    // Asks for notification permission and registers the Android channel.
    // Fire-and-forget: a refusal must not hold up the first frame.
    OrderAlertService.instance.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Fold each order-ready alert into the Alerts feed as it comes due, so
      // the tab shows the same message the OS just delivered.
      final alerts = context.read<NotificationViewModel>();
      _alertSubscription = OrderAlertService.instance.onAlert.listen(
        (alert) => alerts.addLocal(
          id: 'local-${alert.orderId}-${alert.dueAt.microsecondsSinceEpoch}',
          title: alert.title,
          body: alert.body,
          imageUrl: alert.imageUrl,
          imageAsset: alert.imageAsset,
        ),
      );
    });
  }

  @override
  void dispose() {
    _alertSubscription?.cancel();
    _router.dispose();
    OrderAlertService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsViewModel>();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Smart Canteen',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
