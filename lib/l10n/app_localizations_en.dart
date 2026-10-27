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
  String get navCart => 'Cart';

  @override
  String get navQrPay => 'QR Pay';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get historyTitle => 'Order History';

  @override
  String get historySubtitle => 'Everything you\'ve ordered';

  @override
  String get historyEmptyTitle => 'No orders yet';

  @override
  String get historyEmptyBody => 'Your orders will appear here';

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
  String get historyItems => 'Items';

  @override
  String get historyTotalAmount => 'Total Amount';

  @override
  String get historyInKhr => 'In KHR';

  @override
  String get historyStatus => 'Status';

  @override
  String get historyOrderedOn => 'Ordered on';

  @override
  String get historyMealSession => 'Meal session';

  @override
  String historyItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

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
      'Select how you want to Top Up your wallet';

  @override
  String get walletTopUpAmount => 'Top Up Amount';

  @override
  String get walletTopUpFailed => 'Top Up failed. Please try again.';

  @override
  String get walletLowBalance => 'Low balance — Top Up to keep ordering';

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
  String get topupTitle => 'Top Up wallet';

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
  String get topupStartError => 'Could not start the top up. Please try again.';

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
  String get topupSuccessTitle => 'Top Up successful';

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
  String get menuTabAll => 'All';

  @override
  String get menuTabSnacks => 'Snacks';

  @override
  String get menuTabDrinks => 'Drinks';

  @override
  String get menuTabDesserts => 'Desserts';

  @override
  String menuViewCart(int count) {
    return 'View Cart ($count)';
  }

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
  String get cartTitle => 'Cart';

  @override
  String get cartItemSection => 'Item';

  @override
  String get cartPaymentSummary => 'Payment Summary';

  @override
  String get cartDiscount => 'Discount';

  @override
  String get cartApplyCoupon => 'Apply coupon';

  @override
  String get cartSelectPaymentMethod => 'Select Payment Method';

  @override
  String get cartCheckout => 'Checkout';

  @override
  String get cartBrowseMenu => 'Browse Menu';

  @override
  String get cartPaymentComingSoon => 'Payment flow will be connected here.';

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
      'Password reset — log in with your new password';

  @override
  String get authResendCode => 'Didn\'t get it? Send another code';

  @override
  String get authRegisterTitle => 'Register';

  @override
  String get authRegisterFirstName => 'First Name';

  @override
  String get authRegisterFirstNameHint => 'firstname';

  @override
  String get authRegisterLastName => 'Last Name';

  @override
  String get authRegisterLastNameHint => 'lastname';

  @override
  String get authRegisterEmailLabel => 'E-mail';

  @override
  String get authRegisterEmailHint => 'Enter your email';

  @override
  String get authRegisterPasswordLabel => 'Password';

  @override
  String get authRegisterPasswordRequirement => 'must contain 8 char.';

  @override
  String get authRegisterConfirmPasswordLabel => 'Confirm Password';

  @override
  String get authRegisterNext => 'Next';

  @override
  String get authRegisterCreating => 'Creating account…';

  @override
  String get authRegisterChooseSchool => 'Choose your school';

  @override
  String get authRegisterSelectBranch => 'Select branch';

  @override
  String get authRegisterCreateAccount => 'Create Account';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get authSignInLink => 'Sign In';

  @override
  String get authRegisterErrorName => 'Please enter your first and last name.';

  @override
  String get authRegisterErrorEmail => 'Please enter a valid email address.';

  @override
  String get authRegisterErrorPasswordMatch => 'Passwords do not match.';

  @override
  String get authRegisterFailed => 'Registration failed.';

  @override
  String get authRegisterErrorSchool => 'Please select your school.';

  @override
  String get authRegisterErrorBranch => 'Please select your branch.';

  @override
  String get authRegisterSaveFailed =>
      'Could not save your details. Please try again.';

  @override
  String get authSignInTitle => 'Sign In';

  @override
  String get authSignInButton => 'Log In';

  @override
  String get authSignInLoading => 'Signing in…';

  @override
  String get authSignInEmailLabel => 'Email Address';

  @override
  String get authSignInEmailHint => 'Enter your email';

  @override
  String get authSignInPasswordLabel => 'Password';

  @override
  String get authSignInPasswordHint => 'Enter your password';

  @override
  String get authOrContinueWith => 'OR CONTINUE WITH';

  @override
  String get authDontHaveAccount => 'Don\'t have an account? ';

  @override
  String get authSignUpLink => 'Sign Up';

  @override
  String get authSignInErrorEmpty => 'Please fill in all fields.';

  @override
  String get authSignInFailed => 'Sign in failed.';

  @override
  String get authVerifyEmailTitle => 'Verify your email';

  @override
  String authVerifyEmailBody(String email) {
    return 'We sent a 6-digit code to $email. Enter it below to activate your account.';
  }

  @override
  String get authVerifyCodeLabel => 'Verification code';

  @override
  String get authVerifyCodeHint => 'Enter the 6-digit code';

  @override
  String get authVerifyButton => 'Verify';

  @override
  String get authVerifying => 'Verifying…';

  @override
  String get authVerifyErrorCode => 'Enter the complete 6-digit code.';

  @override
  String get authVerifyFailed => 'Could not verify your email.';

  @override
  String authResendIn(int seconds) {
    return 'Send another code in ${seconds}s';
  }

  @override
  String get authCodeResent => 'A new code is on its way.';

  @override
  String get authRegisterPhoneLabel => 'Phone number';

  @override
  String get authRegisterPhoneHint => '+855 12 345 678';

  @override
  String get authRegisterErrorPhone => 'Please enter your phone number.';

  @override
  String get authRegisterSelectBranchHint => 'Select your branch';

  @override
  String get authRegisterLoadFailed =>
      'Could not load the list. Please try again.';

  @override
  String get authForgotPasswordPageTitle => 'Reset Password';

  @override
  String get authForgotPasswordEmailBody =>
      'Enter the email address linked to your account. We\'ll send you a reset code.';

  @override
  String get authForgotPasswordEmailLabel => 'Email Address';

  @override
  String get authForgotPasswordEmailHint => 'Enter your email';

  @override
  String get authForgotPasswordSendCode => 'Send Code';

  @override
  String get authForgotPasswordSending => 'Sending…';

  @override
  String get authForgotPasswordErrorEmail =>
      'Please enter a valid email address.';

  @override
  String authForgotPasswordCodeSentBody(String email) {
    return 'We sent a 6-digit reset code to $email. Enter it below.';
  }

  @override
  String get authForgotPasswordVerifyButton => 'Verify Code';

  @override
  String get authForgotPasswordVerifyFailed =>
      'That code is invalid or has expired.';

  @override
  String get authForgotPasswordNewPasswordTitle => 'Set new password';

  @override
  String get authForgotPasswordNewPasswordBody =>
      'Choose a password you haven\'t used before.';

  @override
  String get authForgotPasswordNewPasswordLabel => 'New Password';

  @override
  String get authForgotPasswordNewPasswordHint => 'Enter new password';

  @override
  String get authForgotPasswordConfirmLabel => 'Confirm Password';

  @override
  String get authForgotPasswordConfirmHint => 'Re-enter new password';

  @override
  String get authForgotPasswordResetButton => 'Reset Password';

  @override
  String get authForgotPasswordResetting => 'Resetting…';

  @override
  String get authForgotPasswordResetFailed =>
      'Could not reset your password. Please try again.';

  @override
  String get authForgotPasswordErrorPasswordMatch => 'Passwords do not match.';

  @override
  String get dialogOkButton => 'OK';

  @override
  String get paymentQuitTitle => 'Quit payment?';

  @override
  String get paymentQuitBody =>
      'Your order has not been paid. Are you sure you want to leave?';

  @override
  String get paymentQuitConfirm => 'Yes, quit';
}
