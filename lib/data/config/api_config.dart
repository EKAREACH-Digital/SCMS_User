import 'package:flutter/foundation.dart'
    show kDebugMode, kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  ApiConfig._();

  /// An explicit override, e.g. for a physical device on your LAN:
  /// `--dart-define=API_BASE_URL=http://<your-mac-lan-ip>:3000/api/v1`.
  /// When set, it always wins.
  static const String _override = String.fromEnvironment('API_BASE_URL');

  static const String _prodUrl = 'https://api.smartcanteen.cadt.edu.kh/v1';

  /// Base URL resolution:
  /// - `--dart-define=API_BASE_URL=...` always wins.
  /// - Release builds hit production.
  /// - Debug builds hit the local Docker backend, but the host differs by
  ///   platform: the Android *emulator* reaches the host machine at the
  ///   special alias `10.0.2.2`, while iOS simulator / desktop / web use
  ///   `localhost`. (A physical device can't use either — pass the override.)
  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kDebugMode) return _prodUrl;
    return 'http://$_debugHost:3000/api/v1';
  }

  static String get _debugHost {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // Only the Android emulator maps the host machine to 10.0.2.2.
      return '10.0.2.2';
    }
    // iOS simulator, desktop and web all share the host's network stack.
    //
    // A *physical* device can't reach either alias — it needs the Mac's
    // current LAN address, which changes with the network and so must not be
    // hard-coded here. Pass it at launch instead:
    //   flutter run -t lib/main_prod.dart \
    //     --dart-define=API_BASE_URL=http://<mac-lan-ip>:3000/api/v1
    return 'localhost';
  }

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String googleLogin = '/auth/google';
  static const String microsoftLogin = '/auth/microsoft';
  static const String profile = '/users/me';

  /// `POST /auth/complete-profile` — onboarding: saves name/phone/school and
  /// optionally sets an initial password. Marks the account profile_completed
  /// and returns a fresh token pair.
  static const String completeProfile = '/auth/complete-profile';

  /// `POST /auth/set-password` — adds a password to an account that has none
  /// (e.g. created via Google), enabling email/password login alongside it.
  static const String setPassword = '/auth/set-password';

  // Password reset — a three step flow: request a code by email, exchange the
  // code for a single-use token, then set the new password with that token.
  static const String forgotPassword = '/auth/password/forgot';
  static const String verifyResetCode = '/auth/password/verify-code';
  static const String resetPassword = '/auth/password/reset';

  /// `PATCH /users/:id/profile` — update the signed-in user's own profile
  /// (first/last name, phone, avatar, school). See backend `UsersController.updateProfile`.
  static String userProfile(String id) => '/users/$id/profile';

  /// `PATCH /users/:id/notification-preferences` — update the signed-in user's
  /// push-notification preferences. See backend
  /// `UsersController.updateNotificationPreferences`.
  static String userNotificationPreferences(String id) =>
      '/users/$id/notification-preferences';

  /// `GET /schools` — list of selectable schools for onboarding.
  static const String schools = '/schools';

  // Menu
  /// `GET /menu-items` — menu items, filterable by `school_id`,
  /// `availability_status`, paginated (`limit` max 100).
  static const String menuItems = '/menu-items';

  // Orders
  /// `POST /orders` — place an order (auto-mints a QR coupon per item);
  /// `GET /orders/my` — the signed-in user's orders.
  static const String orders = '/orders';
  static const String ordersMy = '/orders/my';

  // Coupons
  /// `GET /coupons?user_id=&status=` — staff/manager/admin only.
  static const String coupons = '/coupons';

  /// `GET /coupons/my?status=` — the signed-in user's own meal-ticket coupons.
  /// The plain `/coupons` list is role-guarded to staff and above, so the app
  /// must use this route; the user is taken from the JWT.
  static const String couponsMy = '/coupons/my';

  // Wallet
  /// `GET /wallet/my` — all wallets for the signed-in user (one per school).
  static const String walletMy = '/wallet/my';

  /// `POST /wallet/:id/top-up` — add funds to a wallet.
  static String walletTopUp(String walletId) => '/wallet/$walletId/top-up';

  /// `POST /wallet/:id/pay` — deduct a payment from a wallet.
  static String walletPay(String walletId) => '/wallet/$walletId/pay';

  /// `GET /wallet/:id/transactions` — transaction history for a wallet.
  static String walletTransactions(String walletId) =>
      '/wallet/$walletId/transactions';

  // Payments — gateway-backed wallet top-ups (ABA PayWay). The gateway itself
  // is never contacted from the app; the backend signs and proxies everything.

  /// `POST /payments/topup` — opens a payment session, returns KHQR + deeplink.
  static const String paymentsTopUp = '/payments/topup';

  /// `GET /payments/status/:tranId` — PENDING | PAID | FAILED | NOT_FOUND.
  static String paymentStatus(String tranId) => '/payments/status/$tranId';

  // Alerts feed — a merge of admin announcements (broadcast) and the user's own
  // event notifications (order status, wallet top-ups/payments, low balance).

  /// `GET /announcements?status=&page=&limit=` — published announcements shown
  /// in the app's Alerts screen. See backend `AnnouncementsController.findAll`.
  static const String announcements = '/announcements';

  /// `GET /notifications?is_read=&page=&limit=` — the signed-in user's own
  /// notifications. See backend `NotificationsController`.
  static const String notifications = '/notifications';

  /// `GET /notifications/unread-count` — unread count for the bell badge.
  static const String notificationsUnreadCount = '/notifications/unread-count';

  /// `PATCH /notifications/read-all` — mark all the user's notifications read.
  static const String notificationsReadAll = '/notifications/read-all';

  /// `DELETE /notifications/:id` — dismiss a single notification.
  static String notificationById(String id) => '/notifications/$id';
}
