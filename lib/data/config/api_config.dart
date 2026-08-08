import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'
    show kDebugMode, kIsWeb, debugPrint, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  ApiConfig._();

  /// An explicit override, e.g. for a one-off host:
  /// `--dart-define=API_BASE_URL=http://<your-mac-lan-ip>:3000/api/v1`.
  /// When set, it always wins and no probing happens.
  static const String _override = String.fromEnvironment('API_BASE_URL');

  static const String _prodUrl = 'https://api.smartcanteen.cadt.edu.kh/v1';

  static const int _port = 3000;
  static const String _prefix = '/api/v1';

  /// Hosts the debug build will try, in priority order, before the
  /// platform default is appended.
  ///
  /// A simulator and a physical phone need different addresses, and the Mac's
  /// LAN address moves with the network — so rather than editing one value
  /// every time, list every address you use here. Startup probes them all and
  /// keeps whichever answers, so the same build runs everywhere.
  ///
  /// Find a new one with `ipconfig getifaddr en0` and add it to the list; old
  /// entries cost nothing once they stop responding.
  static const List<String> lanHosts = [
    '172.20.10.3', // Mac on the iPhone hotspot
    '192.168.2.1', // Mac sharing internet over Wi-Fi
  ];

  /// Resolved once at startup by [resolveDebugHost]; null until then.
  static String? _resolvedHost;

  /// The host reachable right now, or null if probing hasn't run or found
  /// nothing. Exposed so a debug screen can show what the app settled on.
  static String? get resolvedHost => _resolvedHost;

  /// Base URL resolution:
  /// - `--dart-define=API_BASE_URL=...` always wins.
  /// - Release builds hit production.
  /// - Debug builds use whichever candidate host answered at startup, falling
  ///   back to the platform default if none did.
  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kDebugMode) return _prodUrl;
    return 'http://${_resolvedHost ?? _platformDefaultHost}:$_port$_prefix';
  }

  /// Where the host machine lives when the app runs *beside* it: the Android
  /// emulator maps it to `10.0.2.2`, while the iOS simulator, desktop and web
  /// share the host's own network stack. Neither works from a physical device.
  static String get _platformDefaultHost {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2';
    }
    return 'localhost';
  }

  /// Every candidate, in the order they're preferred.
  static List<String> get debugHostCandidates => [
        ...lanHosts,
        _platformDefaultHost,
      ];

  /// Finds a reachable backend and remembers it for the rest of the session.
  ///
  /// Call once before `runApp`. All candidates are probed concurrently, so the
  /// cost is one timeout rather than one per host, and the winner is the
  /// highest-priority host that answered — not merely the fastest, which would
  /// make the choice vary between runs.
  ///
  /// A no-op in release, and when an explicit override is set.
  static Future<void> resolveDebugHost({
    Duration timeout = const Duration(milliseconds: 1200),
  }) async {
    if (!kDebugMode || _override.isNotEmpty) return;

    final hosts = debugHostCandidates;
    final reachable = await Future.wait(
      hosts.map((h) => _probe(h, timeout)),
    );

    for (var i = 0; i < hosts.length; i++) {
      if (reachable[i]) {
        _resolvedHost = hosts[i];
        debugPrint('[ApiConfig] backend found at $baseUrl');
        return;
      }
    }

    debugPrint(
      '[ApiConfig] no backend answered on ${hosts.join(", ")} — '
      'falling back to $_platformDefaultHost. Is Docker up, and is this '
      "machine's LAN address in ApiConfig.lanHosts?",
    );
  }

  /// True if anything answers on this host.
  ///
  /// Any HTTP reply counts — the API prefix itself returns a 404 envelope,
  /// which still proves a server is listening and costs no database work. The
  /// question here is "is the backend at this address", not "is this route ok".
  static Future<bool> _probe(String host, Duration timeout) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: timeout,
        receiveTimeout: timeout,
        validateStatus: (_) => true,
      ),
    );
    try {
      final res = await dio.get<void>('http://$host:$_port$_prefix');
      return res.statusCode != null;
    } catch (_) {
      return false;
    } finally {
      dio.close(force: true);
    }
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
