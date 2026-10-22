/// Backend routes, each prefixed with the API [version]. They're relative to
/// the server in `.env` (`AppConfig.apiBaseUrl`), which carries no version.
abstract final class ApiConfig {
  /// API version this app is built against. Bump it here when the backend
  /// ships a breaking `/v2`; every route follows.
  static const String version = 'v1';

  // Auth — see docs/features/student-auth-api.md

  /// `POST /auth/login` — email + password → tokens + user.
  static const String login = '/$version/auth/login';

  /// `POST /auth/register` — creates an inactive student and emails a
  /// 6-digit code. Returns the user (no tokens).
  static const String register = '/$version/auth/register';

  /// `POST /auth/verify-otp` — activates a new account with the emailed code.
  /// Returns a message only; the app then calls [login].
  static const String verifyOtp = '/$version/auth/verify-otp';

  /// `POST /auth/resend-otp` — new sign-up code by `userId` (60 s cooldown).
  static const String resendOtp = '/$version/auth/resend-otp';

  /// `POST /auth/resend-verification` — new sign-up code by email, for a
  /// login that failed with "verify your email".
  static const String resendVerification = '/$version/auth/resend-verification';

  /// `POST /auth/refresh` — rotates the token pair; the old refresh token
  /// stops working immediately.
  static const String refreshToken = '/$version/auth/refresh';

  /// `POST /auth/logout` — with a `refresh_token` body signs out this device;
  /// without one, every device.
  static const String logout = '/$version/auth/logout';
  static const String googleLogin = '/$version/auth/google';
  static const String microsoftLogin = '/$version/auth/microsoft';
  static const String profile = '/$version/users/me';

  /// `POST /auth/otp/verify` (Bearer) — checks the emailed code for an account
  /// that signed in with a temporary password (`mustChangePassword`).
  static const String accountOtpVerify = '/$version/auth/otp/verify';

  /// `POST /auth/password/change` (Bearer) — replaces the current password.
  static const String changePassword = '/$version/auth/password/change';

  /// `POST /auth/complete-profile` — onboarding: saves name/phone/school and
  /// optionally sets an initial password. Marks the account profile_completed
  /// and returns a fresh token pair.
  static const String completeProfile = '/$version/auth/complete-profile';

  /// `POST /auth/set-password` — adds a password to an account that has none
  /// (e.g. created via Google), enabling email/password login alongside it.
  static const String setPassword = '/$version/auth/set-password';

  // Password reset — a three step flow keyed by email: request a code, check
  // the code, then set the new password.
  static const String forgotPassword = '/$version/auth/forgot-password';
  static const String verifyResetCode =
      '/$version/auth/forgot-password/verify-otp';
  static const String resetPassword = '/$version/auth/forgot-password/reset';

  /// `PATCH /users/:id/profile` — update the signed-in user's own profile
  /// (first/last name, phone, avatar, school). See backend `UsersController.updateProfile`.
  static String userProfile(String id) => '/$version/users/$id/profile';

  /// `PATCH /users/:id/notification-preferences` — update the signed-in user's
  /// push-notification preferences. See backend
  /// `UsersController.updateNotificationPreferences`.
  static String userNotificationPreferences(String id) =>
      '/$version/users/$id/notification-preferences';

  /// `GET /schools` — list of selectable schools for onboarding.
  static const String schools = '/$version/schools';

  /// `GET /pickup/branches?school_id=` (Bearer) — a school's active branches,
  /// `is_home` marking the student's saved one.
  static const String pickupBranches = '/$version/pickup/branches';

  // Menu — see docs/features/student-menu-api.md

  /// `GET /menus/active?branch_id=&canteen_id=&date=` (public) — the student
  /// menu: one date's orderable dishes for a branch, grouped by canteen and
  /// category.
  static const String menusActive = '/$version/menus/active';

  /// `GET /menu-items/:id` (public) — one dish's detail.
  static String menuItemById(String id) => '/$version/menu-items/$id';

  /// `GET /menu-items` — menu items, filterable by `school_id`,
  /// `availability_status`, paginated (`limit` max 100).
  static const String menuItems = '/$version/menu-items';

  /// `GET /menus?status=published` — weekly menus (a manager-published
  /// schedule covering a date range). Readable by students.
  static const String menus = '/$version/menus';

  /// `GET /menu-menu-items?menu_id=` — the dishes scheduled on a menu, each
  /// with its `day_of_week` and quantity.
  static const String menuMenuItems = '/$version/menu-menu-items';

  // Orders
  /// `POST /orders` — place an order (auto-mints a QR coupon per item);
  /// `GET /orders/my` — the signed-in user's orders.
  static const String orders = '/$version/orders';
  static const String ordersMy = '/$version/orders/my';

  // Coupons
  /// `GET /coupons/my?status=` — the signed-in user's own meal-ticket coupons.
  /// The plain `/coupons` list is role-guarded to staff and above, so the app
  /// must use this route; the user is taken from the JWT.
  static const String couponsMy = '/$version/coupons/my';

  // Wallet
  /// `GET /wallet/my` — all wallets for the signed-in user (one per school).
  static const String walletMy = '/$version/wallet/my';

  /// `POST /wallet/:id/top-up` — add funds to a wallet.
  static String walletTopUp(String walletId) =>
      '/$version/wallet/$walletId/top-up';

  /// `POST /wallet/:id/pay` — deduct a payment from a wallet.
  static String walletPay(String walletId) => '/$version/wallet/$walletId/pay';

  /// `GET /wallet/:id/transactions` — transaction history for a wallet.
  static String walletTransactions(String walletId) =>
      '/$version/wallet/$walletId/transactions';

  // Payments — gateway-backed wallet top-ups (ABA PayWay). The gateway itself
  // is never contacted from the app; the backend signs and proxies everything.

  /// `POST /payments/topup` — opens a payment session, returns KHQR + deeplink.
  static const String paymentsTopUp = '/$version/payments/topup';

  /// `GET /payments/status/:tranId` — PENDING | PAID | FAILED | NOT_FOUND.
  static String paymentStatus(String tranId) =>
      '/$version/payments/status/$tranId';

  // Alerts feed — a merge of admin announcements (broadcast) and the user's own
  // event notifications (order status, wallet top-ups/payments, low balance).

  /// `GET /announcements?status=&page=&limit=` — published announcements shown
  /// in the app's Alerts screen. See backend `AnnouncementsController.findAll`.
  static const String announcements = '/$version/announcements';

  /// `GET /notifications?is_read=&page=&limit=` — the signed-in user's own
  /// notifications. See backend `NotificationsController`.
  static const String notifications = '/$version/notifications';

  /// `GET /notifications/unread-count` — unread count for the bell badge.
  static const String notificationsUnreadCount =
      '/$version/notifications/unread-count';

  /// `PATCH /notifications/read-all` — mark all the user's notifications read.
  static const String notificationsReadAll = '/$version/notifications/read-all';

  /// `DELETE /notifications/:id` — dismiss a single notification.
  static String notificationById(String id) => '/$version/notifications/$id';
}
