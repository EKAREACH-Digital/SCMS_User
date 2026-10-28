/// Route names, for `context.goNamed` / `context.pushNamed`.
abstract final class AppRoutes {
  static const splash = 'splash';
  static const signIn = 'signIn';
  static const signUp = 'signUp';
  static const forgotPassword = 'forgotPassword';
  static const verifyEmail = 'verifyEmail';
  static const completeProfile = 'completeProfile';
  static const home = 'home';
  static const menu = 'menu';
  static const menuBrowse = 'menuBrowse';
  static const cart = 'cart';
  static const weeklyMenu = 'weeklyMenu';
  static const orderSummary = 'orderSummary';
  static const qr = 'qr';
  static const history = 'history';
  static const settings = 'settings';
  static const notifications = 'notifications';
  static const editProfile = 'editProfile';
  static const paymentMethods = 'paymentMethods';
  static const notificationSettings = 'notificationSettings';
  static const setPassword = 'setPassword';
  static const changePassword = 'changePassword';
  static const about = 'about';
  static const topUp = 'topUp';
  static const foodDetail = 'foodDetail';
  static const paymentQr = 'paymentQr';
  static const paymentSuccess = 'paymentSuccess';
  static const orderDetail = 'orderDetail';
}

/// Route paths, for `context.go` / `context.push`.
///
/// Routes that take an argument receive it through `extra`:
/// - [forgotPassword]  `String?` — email to pre-fill
/// - [verifyEmail]     `Map<String, String>` — `userId`, `email`, `password`
///                     from sign-up
/// - [topUp]           `double?` — amount already chosen upstream
abstract final class AppPaths {
  static const splash = '/';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';
  static const verifyEmail = '/verify-email';
  static const completeProfile = '/complete-profile';
  static const home = '/home';
  static const menu = '/menu';
  static const menuBrowse = '/menu-browse';
  static const cart = '/cart';
  static const weeklyMenu = '/weekly-menu';
  static const orderSummary = '/order-summary';
  static const qr = '/qr';
  static const history = '/history';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const editProfile = '/edit-profile';
  static const paymentMethods = '/payment-methods';
  static const notificationSettings = '/notification-settings';
  static const setPassword = '/set-password';
  static const changePassword = '/change-password';
  static const about = '/about';
  static const topUp = '/top-up';

  /// Base path for a food detail page.
  /// Pass item id as a path segment: `'${AppPaths.foodDetail}/$id'`.
  /// Pass the [FoodItem] entity via `extra`.
  static const foodDetail = '/food';

  /// Payment QR screen. Pass the [PlacedOrder] entity via `extra`.
  /// Slides up from the bottom, same as [orderSummary].
  static const paymentQr = '/payment-qr';

  /// Full-screen success animation shown after payment is confirmed.
  static const paymentSuccess = '/payment-success';

  /// Base path for one past order's detail (pickup QR + summary).
  /// Pass the order id as a path segment: `'${AppPaths.orderDetail}/$id'`.
  static const orderDetail = '/order';

  /// The bottom-nav tabs, in bar order. Each is a branch of the shell route,
  /// so `context.go(AppPaths.menu)` switches tab and keeps each tab's state.
  static const tabs = [home, menu, qr, history, settings];
}
