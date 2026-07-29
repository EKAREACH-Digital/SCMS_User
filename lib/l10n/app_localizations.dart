import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Canteen'**
  String get appTitle;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Scan Eat Enjoy — The Smart Way'**
  String get splashTagline;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get commonViewAll;

  /// No description provided for @commonActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get commonActive;

  /// No description provided for @commonSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get commonSortBy;

  /// No description provided for @commonPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment'**
  String get commonPleaseWait;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get commonTopUp;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @navQrPay.
  ///
  /// In en, this message translates to:
  /// **'QR Pay'**
  String get navQrPay;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get historyTitle;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your transactions & top-ups'**
  String get historySubtitle;

  /// No description provided for @historyTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get historyTotalSpent;

  /// No description provided for @historyTopUps.
  ///
  /// In en, this message translates to:
  /// **'Top-ups'**
  String get historyTopUps;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your orders and top-ups will appear here'**
  String get historyEmptyBody;

  /// No description provided for @historyErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load history'**
  String get historyErrorTitle;

  /// No description provided for @historyRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get historyRetry;

  /// No description provided for @historyRetrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying…'**
  String get historyRetrying;

  /// No description provided for @historySortNewest.
  ///
  /// In en, this message translates to:
  /// **'Most recent'**
  String get historySortNewest;

  /// No description provided for @historySortAmountHigh.
  ///
  /// In en, this message translates to:
  /// **'Amount: high to low'**
  String get historySortAmountHigh;

  /// No description provided for @historySortAmountLow.
  ///
  /// In en, this message translates to:
  /// **'Amount: low to high'**
  String get historySortAmountLow;

  /// No description provided for @historyOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get historyOrderDetails;

  /// No description provided for @historyTopUpDetails.
  ///
  /// In en, this message translates to:
  /// **'Top-up Details'**
  String get historyTopUpDetails;

  /// No description provided for @historyTopUpSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Top-Up Successful'**
  String get historyTopUpSuccessful;

  /// No description provided for @historyItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get historyItems;

  /// No description provided for @historyTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get historyTotalAmount;

  /// No description provided for @historyInKhr.
  ///
  /// In en, this message translates to:
  /// **'In KHR'**
  String get historyInKhr;

  /// No description provided for @historyPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get historyPaymentMethod;

  /// No description provided for @historyStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get historyStatus;

  /// No description provided for @historyAmountAdded.
  ///
  /// In en, this message translates to:
  /// **'Amount Added'**
  String get historyAmountAdded;

  /// No description provided for @historyTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get historyTransactionId;

  /// No description provided for @historyMethodWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get historyMethodWallet;

  /// No description provided for @historyMethodBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get historyMethodBankTransfer;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusRedeemed.
  ///
  /// In en, this message translates to:
  /// **'Redeemed'**
  String get statusRedeemed;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @walletMyWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get walletMyWallet;

  /// No description provided for @walletTopUpBalance.
  ///
  /// In en, this message translates to:
  /// **'Top Up Balance'**
  String get walletTopUpBalance;

  /// No description provided for @walletTopUpPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select an amount to add to your wallet'**
  String get walletTopUpPrompt;

  /// No description provided for @walletEnterCustomAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Custom Amount'**
  String get walletEnterCustomAmount;

  /// No description provided for @walletChoosePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose Payment Method'**
  String get walletChoosePaymentMethod;

  /// No description provided for @walletChoosePaymentPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select how you want to top up your wallet'**
  String get walletChoosePaymentPrompt;

  /// No description provided for @walletTopUpAmount.
  ///
  /// In en, this message translates to:
  /// **'Top-up Amount'**
  String get walletTopUpAmount;

  /// No description provided for @walletTopUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Top-up failed. Please try again.'**
  String get walletTopUpFailed;

  /// No description provided for @walletLowBalance.
  ///
  /// In en, this message translates to:
  /// **'Low balance — top up to keep ordering'**
  String get walletLowBalance;

  /// No description provided for @walletTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get walletTotalAmount;

  /// No description provided for @walletPaymentPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred payment option below'**
  String get walletPaymentPrompt;

  /// No description provided for @walletPayWithBank.
  ///
  /// In en, this message translates to:
  /// **'or pay with bank'**
  String get walletPayWithBank;

  /// No description provided for @homeScholarBadge.
  ///
  /// In en, this message translates to:
  /// **'CADT Scholar'**
  String get homeScholarBadge;

  /// No description provided for @homePromoExclusive.
  ///
  /// In en, this message translates to:
  /// **'EXCLUSIVE'**
  String get homePromoExclusive;

  /// No description provided for @homePromoTitle.
  ///
  /// In en, this message translates to:
  /// **'Fresh Daily Campus Food'**
  String get homePromoTitle;

  /// No description provided for @homePromoBody.
  ///
  /// In en, this message translates to:
  /// **'20% off for CADT Scholars this week only'**
  String get homePromoBody;

  /// No description provided for @homeCouponApplied.
  ///
  /// In en, this message translates to:
  /// **'Discount coupon applied!'**
  String get homeCouponApplied;

  /// No description provided for @homeClaimNow.
  ///
  /// In en, this message translates to:
  /// **'Claim Now'**
  String get homeClaimNow;

  /// No description provided for @homeProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing {amount}…'**
  String homeProcessing(String amount);

  /// No description provided for @topupTitle.
  ///
  /// In en, this message translates to:
  /// **'Top up wallet'**
  String get topupTitle;

  /// No description provided for @topupAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (USD)'**
  String get topupAmountLabel;

  /// No description provided for @topupPayWithAba.
  ///
  /// In en, this message translates to:
  /// **'Pay with ABA'**
  String get topupPayWithAba;

  /// No description provided for @topupScanHint.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR with any banking app, or tap below to open ABA Mobile on this phone.'**
  String get topupScanHint;

  /// No description provided for @topupOpenAba.
  ///
  /// In en, this message translates to:
  /// **'Open ABA Mobile'**
  String get topupOpenAba;

  /// No description provided for @topupPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your payment…'**
  String get topupPreparing;

  /// No description provided for @topupWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment…'**
  String get topupWaiting;

  /// No description provided for @topupCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel payment'**
  String get topupCancel;

  /// No description provided for @topupInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get topupInvalidAmount;

  /// No description provided for @topupStartError.
  ///
  /// In en, this message translates to:
  /// **'Could not start the top-up. Please try again.'**
  String get topupStartError;

  /// No description provided for @topupAbaNotFound.
  ///
  /// In en, this message translates to:
  /// **'ABA Mobile isn\'t installed on this device. Scan the QR with another phone instead.'**
  String get topupAbaNotFound;

  /// No description provided for @topupFailed.
  ///
  /// In en, this message translates to:
  /// **'The payment failed or was cancelled.'**
  String get topupFailed;

  /// No description provided for @topupExpired.
  ///
  /// In en, this message translates to:
  /// **'This QR has expired. Please start again.'**
  String get topupExpired;

  /// No description provided for @topupNotCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment not completed'**
  String get topupNotCompletedTitle;

  /// No description provided for @topupCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'You cancelled the payment. Nothing was charged.'**
  String get topupCancelledBody;

  /// No description provided for @topupTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get topupTryAgain;

  /// No description provided for @topupBackToWallet.
  ///
  /// In en, this message translates to:
  /// **'Back to wallet'**
  String get topupBackToWallet;

  /// No description provided for @topupSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Top-up successful'**
  String get topupSuccessTitle;

  /// No description provided for @topupSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} has been added to your wallet.'**
  String topupSuccessBody(String amount);

  /// No description provided for @topupDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get topupDone;

  /// No description provided for @qrTitle.
  ///
  /// In en, this message translates to:
  /// **'My Meal Ticket'**
  String get qrTitle;

  /// No description provided for @qrRefreshed.
  ///
  /// In en, this message translates to:
  /// **'QR code refreshed'**
  String get qrRefreshed;

  /// No description provided for @qrViewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get qrViewReceipt;

  /// No description provided for @qrHint.
  ///
  /// In en, this message translates to:
  /// **'Show this code at the canteen counter\nto collect your meal'**
  String get qrHint;

  /// No description provided for @qrOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get qrOrderSummary;

  /// No description provided for @qrTotalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get qrTotalPaid;

  /// No description provided for @qrEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get qrEmptyTitle;

  /// No description provided for @qrEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Place an order from the menu\nto generate your ticket'**
  String get qrEmptyBody;

  /// No description provided for @qrReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Receipt'**
  String get qrReceiptTitle;

  /// No description provided for @qrTicketOfCount.
  ///
  /// In en, this message translates to:
  /// **'Ticket {index} of {count}'**
  String qrTicketOfCount(int index, int count);

  /// No description provided for @menuEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get menuEmptyTitle;

  /// No description provided for @menuEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search'**
  String get menuEmptyBody;

  /// No description provided for @menuFoodType.
  ///
  /// In en, this message translates to:
  /// **'Food Type'**
  String get menuFoodType;

  /// No description provided for @menuPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get menuPrice;

  /// No description provided for @menuNutritionInfo.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Info'**
  String get menuNutritionInfo;

  /// No description provided for @menuAllergenInfo.
  ///
  /// In en, this message translates to:
  /// **'Allergen Info'**
  String get menuAllergenInfo;

  /// No description provided for @menuAllergenBody.
  ///
  /// In en, this message translates to:
  /// **'May contain peanuts, shellfish, dairy'**
  String get menuAllergenBody;

  /// No description provided for @menuErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the menu'**
  String get menuErrorTitle;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add items from the menu to get started'**
  String get cartEmptyBody;

  /// No description provided for @cartYourOrder.
  ///
  /// In en, this message translates to:
  /// **'Your Order'**
  String get cartYourOrder;

  /// No description provided for @cartMealSession.
  ///
  /// In en, this message translates to:
  /// **'Meal Session'**
  String get cartMealSession;

  /// No description provided for @cartProceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get cartProceedToPayment;

  /// No description provided for @cartItemsInCart.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item in cart} other{{count} items in cart}}'**
  String cartItemsInCart(int count);

  /// No description provided for @cartSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartSubtotal;

  /// No description provided for @cartScholarDiscount.
  ///
  /// In en, this message translates to:
  /// **'Scholar Discount'**
  String get cartScholarDiscount;

  /// No description provided for @cartServiceFee.
  ///
  /// In en, this message translates to:
  /// **'Service Fee'**
  String get cartServiceFee;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartTotal;

  /// No description provided for @couponExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Coupon Expired'**
  String get couponExpiredTitle;

  /// No description provided for @couponExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'Your QR ticket has expired. Please purchase a new coupon to continue.'**
  String get couponExpiredBody;

  /// No description provided for @couponExpiredAction.
  ///
  /// In en, this message translates to:
  /// **'Get New Coupon'**
  String get couponExpiredAction;

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get alertsTitle;

  /// No description provided for @alertsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get alertsMarkAllRead;

  /// No description provided for @alertsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get alertsEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageKhmer.
  ///
  /// In en, this message translates to:
  /// **'ភាសាខ្មែរ'**
  String get settingsLanguageKhmer;

  /// No description provided for @settingsChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get settingsChangePhoto;

  /// No description provided for @settingsLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get settingsLogOut;

  /// No description provided for @settingsLogOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get settingsLogOutConfirm;

  /// No description provided for @settingsMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get settingsMyProfile;

  /// No description provided for @authRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get authRememberMe;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// No description provided for @authCompleteProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get authCompleteProfileTitle;

  /// No description provided for @authCompleteProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Add a few details to finish setting up your account.'**
  String get authCompleteProfileBody;

  /// No description provided for @authSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get authSchool;

  /// No description provided for @authLoadingSchools.
  ///
  /// In en, this message translates to:
  /// **'Loading schools…'**
  String get authLoadingSchools;

  /// No description provided for @authSelectSchool.
  ///
  /// In en, this message translates to:
  /// **'Select your school'**
  String get authSelectSchool;

  /// No description provided for @authPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Password reset — sign in with your new password'**
  String get authPasswordReset;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it? Send another code'**
  String get authResendCode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
