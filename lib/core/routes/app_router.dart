import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/widgets/app_navigation_bar.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/forgot_password_page.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/register_step1.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/register_step2.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/register_step3.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/sign_in_page.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/views/splash_page.dart';
import 'package:smart_canteen_user_frontend/features/home/presentation/views/home_page.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/views/menu_page.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/views/food_detail_page.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/views/weekly_menu_page.dart';
import 'package:smart_canteen_user_frontend/features/notification/presentation/views/notification_page.dart';
import 'package:smart_canteen_user_frontend/features/notification/presentation/views/notification_settings_page.dart';
import 'package:smart_canteen_user_frontend/features/order/domain/entities/order.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/order_history_page.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/order_detail_page.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/order_summary_page.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/payment_qr_page.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/payment_success_page.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/deprecated/qr_page.dart';
import 'package:smart_canteen_user_frontend/features/payment/presentation/views/payment_methods_page.dart';
import 'package:smart_canteen_user_frontend/features/payment/presentation/views/topup_page.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/views/about_page.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/views/change_password_page.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/views/edit_profile_page.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/views/settings_page.dart';

/// The app's single [GoRouter]. Create it once (see `SmartCanteenApp`) and
/// pass it to `MaterialApp.router`.
abstract final class AppRouter {
  /// Pages reachable without a session.
  static const _publicPaths = {
    AppPaths.splash,
    AppPaths.signIn,
    AppPaths.signUp,
    AppPaths.forgotPassword,
    AppPaths.verifyEmail,
  };

  static GoRouter create(AuthViewModel auth) => GoRouter(
    initialLocation: AppPaths.splash,
    // Re-run [_redirect] whenever the session changes (sign-in, logout).
    refreshListenable: auth,
    redirect: (_, state) => _redirect(auth, state),
    routes: [
      GoRoute(
        path: AppPaths.splash,
        name: AppRoutes.splash,
        pageBuilder: (_, state) => _cupertino(state, const SplashPage()),
      ),
      GoRoute(
        path: AppPaths.signIn,
        name: AppRoutes.signIn,
        pageBuilder: (_, state) => _cupertino(state, const SignInPage()),
      ),
      GoRoute(
        path: AppPaths.signUp,
        name: AppRoutes.signUp,
        pageBuilder: (_, state) => _cupertino(state, const RegisterStep1Page()),
      ),
      GoRoute(
        path: AppPaths.forgotPassword,
        name: AppRoutes.forgotPassword,
        // Receives an optional pre-filled email via route extra.
        pageBuilder: (_, state) => _cupertino(
          state,
          ForgotPasswordPage(email: state.extra as String?),
        ),
      ),
      GoRoute(
        path: AppPaths.verifyEmail,
        name: AppRoutes.verifyEmail,
        // Receives the sign-up's userId, email and password via route extra.
        pageBuilder: (_, state) {
          final data = Map<String, String>.from(state.extra as Map);
          return _cupertino(
            state,
            RegisterStep2Page(
              userId: data['userId']!,
              email: data['email']!,
              password: data['password']!,
            ),
          );
        },
      ),
      GoRoute(
        path: AppPaths.completeProfile,
        name: AppRoutes.completeProfile,
        pageBuilder: (_, state) => _cupertino(state, const RegisterStep3Page()),
      ),
      // Bottom-nav tabs. Each branch keeps its own navigation stack and state.
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          _tab(AppPaths.home, AppRoutes.home, const HomePage()),
          _tab(AppPaths.menu, AppRoutes.menu, const MenuPage()),
          _tab(AppPaths.qr, AppRoutes.qr, const QrPage()),
          _tab(AppPaths.history, AppRoutes.history, const OrderHistoryPage()),
          _tab(AppPaths.settings, AppRoutes.settings, const SettingsPage()),
        ],
      ),
      GoRoute(
        path: AppPaths.menuBrowse,
        name: AppRoutes.menuBrowse,
        pageBuilder: (_, state) => _cupertino(state, const MenuPage()),
      ),
      GoRoute(
        path: AppPaths.weeklyMenu,
        name: AppRoutes.weeklyMenu,
        pageBuilder: (_, state) => _cupertino(state, const WeeklyMenuPage()),
      ),
      // Slides up from the bottom like a bottom sheet.
      GoRoute(
        path: AppPaths.orderSummary,
        name: AppRoutes.orderSummary,
        pageBuilder: (_, state) => _slideUp(state, const OrderSummaryPage()),
      ),
      GoRoute(
        path: AppPaths.notifications,
        name: AppRoutes.notifications,
        pageBuilder: (_, state) => _cupertino(state, const NotificationPage()),
      ),
      GoRoute(
        path: AppPaths.editProfile,
        name: AppRoutes.editProfile,
        pageBuilder: (_, state) => _cupertino(state, const EditProfilePage()),
      ),
      GoRoute(
        path: AppPaths.paymentMethods,
        name: AppRoutes.paymentMethods,
        pageBuilder: (_, state) =>
            _cupertino(state, const PaymentMethodsPage()),
      ),
      GoRoute(
        path: AppPaths.notificationSettings,
        name: AppRoutes.notificationSettings,
        pageBuilder: (_, state) =>
            _cupertino(state, const NotificationSettingsPage()),
      ),
      GoRoute(
        path: AppPaths.changePassword,
        name: AppRoutes.changePassword,
        pageBuilder: (_, state) =>
            _cupertino(state, const ChangePasswordPage()),
      ),
      GoRoute(
        path: AppPaths.about,
        name: AppRoutes.about,
        pageBuilder: (_, state) => _cupertino(state, const AboutPage()),
      ),
      GoRoute(
        path: AppPaths.topUp,
        name: AppRoutes.topUp,
        pageBuilder: (_, state) => _cupertino(
          state,
          TopUpPage(amountUsd: (state.extra as num?)?.toDouble()),
        ),
      ),
      GoRoute(
        // Receives the FoodItem entity via `extra`. The `:id` segment is
        // included so the URL is meaningful (and deep-linkable in future).
        path: '${AppPaths.foodDetail}/:id',
        name: AppRoutes.foodDetail,
        pageBuilder: (_, state) =>
            _cupertino(state, FoodDetailPage(item: state.extra as FoodItem)),
      ),
      GoRoute(
        path: AppPaths.paymentQr,
        name: AppRoutes.paymentQr,
        pageBuilder: (_, state) => _cupertino(
          state,
          PaymentQrPage(order: state.extra as PlacedOrder),
        ),
      ),
      GoRoute(
        path: AppPaths.paymentSuccess,
        name: AppRoutes.paymentSuccess,
        pageBuilder: (_, state) => _slideUp(state, const PaymentSuccessPage()),
      ),
      GoRoute(
        path: '${AppPaths.orderDetail}/:id',
        name: AppRoutes.orderDetail,
        pageBuilder: (_, state) => _cupertino(
          state,
          OrderDetailPage(orderId: state.pathParameters['id']!),
        ),
      ),
    ],
  );

  /// The only auth redirect in the app (RULE 7):
  /// - no session --> protected pages bounce to the splash (which offers sign-in);
  /// - signed in with an incomplete profile --> Complete Profile, from any page.
  ///   The backend doesn't block an incomplete profile, so the app must;
  /// - a restored session on the splash --> straight into the app.
  static String? _redirect(AuthViewModel auth, GoRouterState state) {
    final isPublic = _publicPaths.contains(state.matchedLocation);
    switch (auth.status) {
      case AuthStatus.unknown:
        // Still restoring — only the splash can wait for it.
        return state.matchedLocation == AppPaths.splash
            ? null
            : AppPaths.splash;
      case AuthStatus.unauthenticated:
        return isPublic ? null : AppPaths.splash;
      case AuthStatus.authenticated:
        if (auth.user?.needsProfileCompletion ?? false) {
          return state.matchedLocation == AppPaths.completeProfile
              ? null
              : AppPaths.completeProfile;
        }
        return state.matchedLocation == AppPaths.splash ? AppPaths.home : null;
    }
  }

  static StatefulShellBranch _tab(String path, String name, Widget page) =>
      StatefulShellBranch(
        routes: [GoRoute(path: path, name: name, builder: (_, _) => page)],
      );

  static CupertinoPage<void> _cupertino(GoRouterState state, Widget child) =>
      CupertinoPage<void>(key: state.pageKey, child: child);

  static CustomTransitionPage<void> _slideUp(
    GoRouterState state,
    Widget child,
  ) => CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, _, child) => SlideTransition(
      position: animation.drive(
        Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
      ),
      child: child,
    ),
  );
}

/// Bottom-nav shell: the Liquid Glass nav bar around the current tab.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back on any tab but Home returns to Home instead of leaving the app.
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0, initialLocation: true);
        }
      },
      child: Scaffold(
        // Lets the glass bar float over the tab and blur what's behind it.
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: AppNavigationBar(
          currentIndex: navigationShell.currentIndex,
          // Tapping the current tab again resets it to its first page.
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}
