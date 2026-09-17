// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Canteen';

  @override
  String get splashTagline => 'Scan Eat Enjoy — The Smart Way';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonViewAll => 'View all';

  @override
  String get commonActive => 'Active';

  @override
  String get commonSortBy => 'Sort By';

  @override
  String get commonPleaseWait => 'Please wait a moment';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonTopUp => 'Top Up';

  @override
  String get navHome => 'Home';

  @override
  String get navMenu => 'Menu';

  @override
  String get navQrPay => 'QR Pay';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get historyTitle => 'Order History';

  @override
  String get historySubtitle => 'Your transactions & top-ups';

  @override
  String get historyTotalSpent => 'Total Spent';

  @override
  String get historyTopUps => 'Top-ups';

  @override
  String get historyEmptyTitle => 'No orders yet';

  @override
  String get historyEmptyBody => 'Your orders and top-ups will appear here';

  @override
  String get historyErrorTitle => 'Couldn\'t load history';

  @override
  String get historyRetry => 'Try again';

  @override
  String get historyRetrying => 'Retrying…';

  @override
  String get historySortNewest => 'Most recent';

  @override
  String get historySortAmountHigh => 'Amount: high to low';

  @override
  String get historySortAmountLow => 'Amount: low to high';

  @override
  String get historyOrderDetails => 'Order Details';

  @override
  String get historyTopUpDetails => 'Top-up Details';

  @override
  String get historyTopUpSuccessful => 'Top-Up Successful';

  @override
  String get historyItems => 'Items';

  @override
  String get historyTotalAmount => 'Total Amount';

  @override
  String get historyInKhr => 'In KHR';

  @override
  String get historyPaymentMethod => 'Payment Method';

  @override
  String get historyStatus => 'Status';

  @override
  String get historyAmountAdded => 'Amount Added';

  @override
  String get historyTransactionId => 'Transaction ID';

  @override
  String get historyMethodWallet => 'Wallet';

  @override
  String get historyMethodBankTransfer => 'Bank Transfer';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusRedeemed => 'Redeemed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusFailed => 'Failed';

  @override
  String get walletMyWallet => 'My Wallet';

  @override
  String get walletTopUpBalance => 'Top Up Balance';

  @override
  String get walletTopUpPrompt => 'Select an amount to add to your wallet';

  @override
  String get walletEnterCustomAmount => 'Enter Custom Amount';

  @override
  String get walletChoosePaymentMethod => 'Choose Payment Method';

  @override
  String get walletChoosePaymentPrompt =>
      'Select how you want to top up your wallet';

  @override
  String get walletTopUpAmount => 'Top-up Amount';

  @override
  String get walletTopUpFailed => 'Top-up failed. Please try again.';

  @override
  String get walletLowBalance => 'Low balance — top up to keep ordering';

  @override
  String get walletTotalAmount => 'Total Amount';

  @override
  String get walletPaymentPrompt =>
      'Select your preferred payment option below';

  @override
  String get walletPayWithBank => 'or pay with bank';

  @override
  String get homeScholarBadge => 'CADT Scholar';

  @override
  String get homePromoExclusive => 'EXCLUSIVE';

  @override
  String get homePromoTitle => 'Fresh Daily Campus Food';

  @override
  String get homePromoBody => '20% off for CADT Scholars this week only';

  @override
  String get homeCouponApplied => 'Discount coupon applied!';

  @override
  String get homeClaimNow => 'Claim Now';

  @override
  String homeProcessing(String amount) {
    return 'Processing $amount…';
  }

  @override
  String get topupTitle => 'Top up wallet';

  @override
  String get topupAmountLabel => 'Amount (USD)';

  @override
  String get topupPayWithAba => 'Pay with ABA';

  @override
  String get topupScanHint =>
      'Scan this QR with any banking app, or tap below to open ABA Mobile on this phone.';

  @override
  String get topupOpenAba => 'Open ABA Mobile';

  @override
  String get topupPreparing => 'Preparing your payment…';

  @override
  String get topupWaiting => 'Waiting for payment…';

  @override
  String get topupCancel => 'Cancel payment';

  @override
  String get topupInvalidAmount => 'Please enter a valid amount';

  @override
  String get topupStartError => 'Could not start the top-up. Please try again.';

  @override
  String get topupAbaNotFound =>
      'ABA Mobile isn\'t installed on this device. Scan the QR with another phone instead.';

  @override
  String get topupFailed => 'The payment failed or was cancelled.';

  @override
  String get topupExpired => 'This QR has expired. Please start again.';

  @override
  String get topupNotCompletedTitle => 'Payment not completed';

  @override
  String get topupCancelledBody =>
      'You cancelled the payment. Nothing was charged.';

  @override
  String get topupTryAgain => 'Try again';

  @override
  String get topupBackToWallet => 'Back to wallet';

  @override
  String get topupSuccessTitle => 'Top-up successful';

  @override
  String topupSuccessBody(String amount) {
    return '$amount has been added to your wallet.';
  }

  @override
  String get topupDone => 'Done';

  @override
  String get qrTitle => 'My Meal Ticket';

  @override
  String get qrRefreshed => 'QR code refreshed';

  @override
  String get qrViewReceipt => 'View Receipt';

  @override
  String get qrHint =>
      'Show this code at the canteen counter\nto collect your meal';

  @override
  String get qrOrderSummary => 'Order Summary';

  @override
  String get qrTotalPaid => 'Total Paid';

  @override
  String get qrEmptyTitle => 'No orders yet';

  @override
  String get qrEmptyBody =>
      'Place an order from the menu\nto generate your ticket';

  @override
  String get qrReceiptTitle => 'Transaction Receipt';

  @override
  String qrTicketOfCount(int index, int count) {
    return 'Ticket $index of $count';
  }

  @override
  String get weeklyMenuTitle => 'This Week\'s Menu';

  @override
  String get weeklyMenuOpen => 'Weekly menu';

  @override
  String get weeklyMenuEmptyTitle => 'No menu published yet';

  @override
  String get weeklyMenuEmptyBody =>
      'The canteen hasn\'t published a menu for this week. Check back soon.';

  @override
  String get weeklyMenuErrorTitle => 'Couldn\'t load the weekly menu';

  @override
  String get weeklyMenuNothingToday => 'Nothing scheduled for this day';

  @override
  String get weeklyMenuAllWeekNote =>
      'Every dish on this menu is served all week, so each day shows the same list.';

  @override
  String get weeklyMenuToday => 'Today';

  @override
  String get slotBreakfast => 'Breakfast';

  @override
  String get slotLunch => 'Lunch';

  @override
  String get slotDinner => 'Dinner';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get menuEmptyTitle => 'No items found';

  @override
  String get menuEmptyBody => 'Try adjusting your filters or search';

  @override
  String get menuFoodType => 'Food Type';

  @override
  String get menuPrice => 'Price';

  @override
  String get menuNutritionInfo => 'Nutrition Info';

  @override
  String get menuAllergenInfo => 'Allergen Info';

  @override
  String get menuAllergenBody => 'May contain peanuts, shellfish, dairy';

  @override
  String get menuErrorTitle => 'Couldn\'t load the menu';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyBody => 'Add items from the menu to get started';

  @override
  String get cartYourOrder => 'Your Order';

  @override
  String get cartMealSession => 'Meal Session';

  @override
  String get cartProceedToPayment => 'Proceed to Payment';

  @override
  String cartItemsInCart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items in cart',
      one: '1 item in cart',
    );
    return '$_temp0';
  }

  @override
  String get cartSubtotal => 'Subtotal';

  @override
  String get cartScholarDiscount => 'Scholar Discount';

  @override
  String get cartServiceFee => 'Service Fee';

  @override
  String get cartTotal => 'Total';

  @override
  String get couponExpiredTitle => 'Coupon Expired';

  @override
  String get couponExpiredBody =>
      'Your QR ticket has expired. Please purchase a new coupon to continue.';

  @override
  String get couponExpiredAction => 'Get New Coupon';

  @override
  String get alertsTitle => 'Notifications';

  @override
  String get alertsMarkAllRead => 'Mark all read';

  @override
  String get alertsEmpty => 'No notifications';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageKhmer => 'ភាសាខ្មែរ';

  @override
  String get settingsChangePhoto => 'Change Profile Photo';

  @override
  String get settingsLogOut => 'Log Out';

  @override
  String get settingsLogOutConfirm =>
      'Are you sure you want to log out of your account?';

  @override
  String get settingsMyProfile => 'My Profile';

  @override
  String get authRememberMe => 'Remember me';

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authCompleteProfileTitle => 'Complete your profile';

  @override
  String get authCompleteProfileBody =>
      'Add a few details to finish setting up your account.';

  @override
  String get authSchool => 'School';

  @override
  String get authLoadingSchools => 'Loading schools…';

  @override
  String get authSelectSchool => 'Select your school';

  @override
  String get authPasswordReset =>
      'Password reset — sign in with your new password';

  @override
  String get authResendCode => 'Didn\'t get it? Send another code';
}
