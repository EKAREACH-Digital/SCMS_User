import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/widgets/smart_canteen_navigation_bar.dart';
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
import 'package:smart_canteen_user_frontend/features/order/presentation/views/bank_selection_page.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/history_page.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/order_summary_page.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/payment_method_page.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/views/qr_page.dart';
import 'package:smart_canteen_user_frontend/features/payment/presentation/views/payment_methods_page.dart';
import 'package:smart_canteen_user_frontend/features/payment/presentation/views/topup_page.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/views/about_page.dart';
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
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: AppPaths.signIn,
        name: AppRoutes.signIn,
        builder: (_, _) => const SignInPage(),
      ),
      GoRoute(
        path: AppPaths.signUp,
        name: AppRoutes.signUp,
        builder: (_, _) => const RegisterStep1Page(),
      ),
      GoRoute(
        path: AppPaths.forgotPassword,
        name: AppRoutes.forgotPassword,
        // Receives an optional pre-filled email via route extra.
        builder: (_, state) => ForgotPasswordPage(
          email: state.extra as String?,
        ),
      ),
      GoRoute(
        path: AppPaths.verifyEmail,
        name: AppRoutes.verifyEmail,
        // Receives the sign-up's userId, email and password via route extra.
        builder: (_, state) {
          final data = Map<String, String>.from(state.extra as Map);
          return RegisterStep2Page(
            userId: data['userId']!,
            email: data['email']!,
            password: data['password']!,
          );
        },
      ),
      GoRoute(
        path: AppPaths.completeProfile,
        name: AppRoutes.completeProfile,
        builder: (_, _) => const RegisterStep3Page(),
      ),
      // Bottom-nav tabs. Each branch keeps its own navigation stack and state.
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          _tab(AppPaths.home, AppRoutes.home, const HomePage()),
          _tab(AppPaths.cart, AppRoutes.cart, const OrderSummaryPage()),
          _tab(AppPaths.qr, AppRoutes.qr, const QrPage()),
          _tab(AppPaths.history, AppRoutes.history, const HistoryPage()),
          _tab(AppPaths.settings, AppRoutes.settings, const SettingsPage()),
        ],
      ),
      GoRoute(
        path: AppPaths.menu,
        name: AppRoutes.menu,
        builder: (_, _) => const MenuPage(),
      ),
      GoRoute(
        path: AppPaths.weeklyMenu,
        name: AppRoutes.weeklyMenu,
        builder: (_, _) => const WeeklyMenuPage(),
      ),
      GoRoute(
        path: AppPaths.orderSummary,
        name: AppRoutes.orderSummary,
        builder: (_, _) => const OrderSummaryPage(),
      ),
      GoRoute(
        path: AppPaths.paymentMethod,
        name: AppRoutes.paymentMethod,
        builder: (_, state) => PaymentMethodPage(
          totalAmount: (state.extra as num?)?.toDouble() ?? 0,
        ),
      ),
      GoRoute(
        path: AppPaths.bankSelection,
        name: AppRoutes.bankSelection,
        builder: (_, _) => const BankSelectionPage(),
      ),
      GoRoute(
        path: AppPaths.notifications,
        name: AppRoutes.notifications,
        builder: (_, _) => const NotificationPage(),
      ),
      GoRoute(
        path: AppPaths.editProfile,
        name: AppRoutes.editProfile,
        builder: (_, _) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppPaths.paymentMethods,
        name: AppRoutes.paymentMethods,
        builder: (_, _) => const PaymentMethodsPage(),
      ),
      GoRoute(
        path: AppPaths.notificationSettings,
        name: AppRoutes.notificationSettings,
        builder: (_, _) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: AppPaths.about,
        name: AppRoutes.about,
        builder: (_, _) => const AboutPage(),
      ),
      GoRoute(
        path: AppPaths.topUp,
        name: AppRoutes.topUp,
        builder: (_, state) =>
            TopUpPage(amountUsd: (state.extra as num?)?.toDouble()),
      ),
      GoRoute(
        // Receives the FoodItem entity via `extra`. The `:id` segment is
        // included so the URL is meaningful (and deep-linkable in future).
        path: '${AppPaths.foodDetail}/:id',
        name: AppRoutes.foodDetail,
        builder: (_, state) => FoodDetailPage(item: state.extra as FoodItem),
      ),
    ],
  );

  /// The only auth redirect in the app (RULE 7):
  /// - no session → protected pages bounce to the splash (which offers sign-in);
  /// - signed in with an incomplete profile → Complete Profile, from any page.
  ///   The backend doesn't block an incomplete profile, so the app must;
  /// - a restored session on the splash → straight into the app.
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
        bottomNavigationBar: SmartCanteenNavigationBarButton(
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
