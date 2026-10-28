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

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

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
  /// **'Everything you\'ve ordered'**
  String get historySubtitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here'**
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

  /// No description provided for @historyStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get historyStatus;

  /// No description provided for @historyOrderedOn.
  ///
  /// In en, this message translates to:
  /// **'Ordered on'**
  String get historyOrderedOn;

  /// No description provided for @historyMealSession.
  ///
  /// In en, this message translates to:
  /// **'Meal session'**
  String get historyMealSession;

  /// No description provided for @historyItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String historyItemCount(int count);

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

  /// No description provided for @statusPendingPayment.
  ///
  /// In en, this message translates to:
  /// **'Pending Payment'**
  String get statusPendingPayment;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @historyTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historyTabAll;

  /// No description provided for @historyViewOrder.
  ///
  /// In en, this message translates to:
  /// **'View Order'**
  String get historyViewOrder;

  /// No description provided for @historyTotalItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Total 1 item} other{Total {count} items}}'**
  String historyTotalItems(int count);

  /// No description provided for @orderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Detail'**
  String get orderDetailTitle;

  /// No description provided for @orderDetailScanCaption.
  ///
  /// In en, this message translates to:
  /// **'Scan and enjoy the meals'**
  String get orderDetailScanCaption;

  /// No description provided for @orderDetailDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get orderDetailDownload;

  /// No description provided for @orderDetailSaved.
  ///
  /// In en, this message translates to:
  /// **'QR code saved to your photos'**
  String get orderDetailSaved;

  /// No description provided for @orderDetailSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the QR code'**
  String get orderDetailSaveFailed;

  /// No description provided for @orderDetailQrPending.
  ///
  /// In en, this message translates to:
  /// **'Your pickup QR appears once the order is paid'**
  String get orderDetailQrPending;

  /// No description provided for @orderDetailQrCancelled.
  ///
  /// In en, this message translates to:
  /// **'This order was cancelled'**
  String get orderDetailQrCancelled;

  /// No description provided for @orderDetailQrPreparing.
  ///
  /// In en, this message translates to:
  /// **'QR ticket is in processing (CODE: QR_TOKEN_NOT_FOUND)'**
  String get orderDetailQrPreparing;

  /// No description provided for @orderDetailQrPickedUp.
  ///
  /// In en, this message translates to:
  /// **'You have already picked up your food. QR not available.'**
  String get orderDetailQrPickedUp;

  /// No description provided for @orderDetailErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this order'**
  String get orderDetailErrorTitle;

  /// No description provided for @orderDetailSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderDetailSummary;

  /// No description provided for @orderDetailDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get orderDetailDate;

  /// No description provided for @orderDetailSubTotal.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get orderDetailSubTotal;

  /// No description provided for @orderDetailDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get orderDetailDiscount;

  /// No description provided for @orderDetailTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderDetailTotal;

  /// No description provided for @historyTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String historyTotal(String amount);

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
  /// **'Select how you want to Top Up your wallet'**
  String get walletChoosePaymentPrompt;

  /// No description provided for @walletTopUpAmount.
  ///
  /// In en, this message translates to:
  /// **'Top Up Amount'**
  String get walletTopUpAmount;

  /// No description provided for @walletTopUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Top Up failed. Please try again.'**
  String get walletTopUpFailed;

  /// No description provided for @walletLowBalance.
  ///
  /// In en, this message translates to:
  /// **'Low balance — Top Up to keep ordering'**
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
  /// **'Top Up wallet'**
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
  /// **'Could not start the top up. Please try again.'**
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
  /// **'Top Up successful'**
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

  /// No description provided for @weeklyMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Menu'**
  String get weeklyMenuTitle;

  /// No description provided for @weeklyMenuOpen.
  ///
  /// In en, this message translates to:
  /// **'Weekly menu'**
  String get weeklyMenuOpen;

  /// No description provided for @weeklyMenuEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No menu published yet'**
  String get weeklyMenuEmptyTitle;

  /// No description provided for @weeklyMenuEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'The canteen hasn\'t published a menu for this week. Check back soon.'**
  String get weeklyMenuEmptyBody;

  /// No description provided for @weeklyMenuErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the weekly menu'**
  String get weeklyMenuErrorTitle;

  /// No description provided for @weeklyMenuNothingToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled for this day'**
  String get weeklyMenuNothingToday;

  /// No description provided for @weeklyMenuAllWeekNote.
  ///
  /// In en, this message translates to:
  /// **'Every dish on this menu is served all week, so each day shows the same list.'**
  String get weeklyMenuAllWeekNote;

  /// No description provided for @weeklyMenuToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get weeklyMenuToday;

  /// No description provided for @slotBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get slotBreakfast;

  /// No description provided for @slotLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get slotLunch;

  /// No description provided for @slotDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get slotDinner;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @menuTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get menuTabAll;

  /// No description provided for @menuTabSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get menuTabSnacks;

  /// No description provided for @menuTabDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get menuTabDrinks;

  /// No description provided for @menuTabDesserts.
  ///
  /// In en, this message translates to:
  /// **'Desserts'**
  String get menuTabDesserts;

  /// No description provided for @menuViewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart ({count})'**
  String menuViewCart(int count);

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

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @cartItemSection.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get cartItemSection;

  /// No description provided for @cartPaymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get cartPaymentSummary;

  /// No description provided for @cartDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get cartDiscount;

  /// No description provided for @cartApplyCoupon.
  ///
  /// In en, this message translates to:
  /// **'Apply coupon'**
  String get cartApplyCoupon;

  /// No description provided for @cartSelectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get cartSelectPaymentMethod;

  /// No description provided for @cartCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get cartCheckout;

  /// No description provided for @cartBrowseMenu.
  ///
  /// In en, this message translates to:
  /// **'Browse Menu'**
  String get cartBrowseMenu;

  /// No description provided for @cartPaymentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Payment flow will be connected here.'**
  String get cartPaymentComingSoon;

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
  /// **'Password reset — log in with your new password'**
  String get authPasswordReset;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it? Send another code'**
  String get authResendCode;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get authRegisterFirstName;

  /// No description provided for @authRegisterFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'firstname'**
  String get authRegisterFirstNameHint;

  /// No description provided for @authRegisterLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get authRegisterLastName;

  /// No description provided for @authRegisterLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'lastname'**
  String get authRegisterLastNameHint;

  /// No description provided for @authRegisterEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get authRegisterEmailLabel;

  /// No description provided for @authRegisterEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authRegisterEmailHint;

  /// No description provided for @authRegisterPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authRegisterPasswordLabel;

  /// No description provided for @authRegisterPasswordRequirement.
  ///
  /// In en, this message translates to:
  /// **'must contain 8 char.'**
  String get authRegisterPasswordRequirement;

  /// No description provided for @authRegisterConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authRegisterConfirmPasswordLabel;

  /// No description provided for @authRegisterNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get authRegisterNext;

  /// No description provided for @authRegisterCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating account…'**
  String get authRegisterCreating;

  /// No description provided for @authRegisterChooseSchool.
  ///
  /// In en, this message translates to:
  /// **'Choose your school'**
  String get authRegisterChooseSchool;

  /// No description provided for @authRegisterSelectBranch.
  ///
  /// In en, this message translates to:
  /// **'Select branch'**
  String get authRegisterSelectBranch;

  /// No description provided for @authRegisterCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authRegisterCreateAccount;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authAlreadyHaveAccount;

  /// No description provided for @authSignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignInLink;

  /// No description provided for @authRegisterErrorName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first and last name.'**
  String get authRegisterErrorName;

  /// No description provided for @authRegisterErrorEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authRegisterErrorEmail;

  /// No description provided for @authRegisterErrorPasswordMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authRegisterErrorPasswordMatch;

  /// No description provided for @authRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed.'**
  String get authRegisterFailed;

  /// No description provided for @authRegisterErrorSchool.
  ///
  /// In en, this message translates to:
  /// **'Please select your school.'**
  String get authRegisterErrorSchool;

  /// No description provided for @authRegisterErrorBranch.
  ///
  /// In en, this message translates to:
  /// **'Please select your branch.'**
  String get authRegisterErrorBranch;

  /// No description provided for @authRegisterSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your details. Please try again.'**
  String get authRegisterSaveFailed;

  /// No description provided for @authSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignInTitle;

  /// No description provided for @authSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get authSignInButton;

  /// No description provided for @authSignInLoading.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get authSignInLoading;

  /// No description provided for @authSignInEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authSignInEmailLabel;

  /// No description provided for @authSignInEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authSignInEmailHint;

  /// No description provided for @authSignInPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authSignInPasswordLabel;

  /// No description provided for @authSignInPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authSignInPasswordHint;

  /// No description provided for @authOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'OR CONTINUE WITH'**
  String get authOrContinueWith;

  /// No description provided for @authDontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get authDontHaveAccount;

  /// No description provided for @authSignUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUpLink;

  /// No description provided for @authSignInErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get authSignInErrorEmpty;

  /// No description provided for @authSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed.'**
  String get authSignInFailed;

  /// No description provided for @authVerifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get authVerifyEmailTitle;

  /// No description provided for @authVerifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}. Enter it below to activate your account.'**
  String authVerifyEmailBody(String email);

  /// No description provided for @authVerifyCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get authVerifyCodeLabel;

  /// No description provided for @authVerifyCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get authVerifyCodeHint;

  /// No description provided for @authVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerifyButton;

  /// No description provided for @authVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying…'**
  String get authVerifying;

  /// No description provided for @authVerifyErrorCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the complete 6-digit code.'**
  String get authVerifyErrorCode;

  /// No description provided for @authVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify your email.'**
  String get authVerifyFailed;

  /// No description provided for @authResendIn.
  ///
  /// In en, this message translates to:
  /// **'Send another code in {seconds}s'**
  String authResendIn(int seconds);

  /// No description provided for @authCodeResent.
  ///
  /// In en, this message translates to:
  /// **'A new code is on its way.'**
  String get authCodeResent;

  /// No description provided for @authRegisterPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authRegisterPhoneLabel;

  /// No description provided for @authRegisterPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+855 12 345 678'**
  String get authRegisterPhoneHint;

  /// No description provided for @authRegisterErrorPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number.'**
  String get authRegisterErrorPhone;

  /// No description provided for @authRegisterSelectBranchHint.
  ///
  /// In en, this message translates to:
  /// **'Select your branch'**
  String get authRegisterSelectBranchHint;

  /// No description provided for @authRegisterLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the list. Please try again.'**
  String get authRegisterLoadFailed;

  /// No description provided for @authForgotPasswordPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authForgotPasswordPageTitle;

  /// No description provided for @authForgotPasswordEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address linked to your account. We\'ll send you a reset code.'**
  String get authForgotPasswordEmailBody;

  /// No description provided for @authForgotPasswordEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authForgotPasswordEmailLabel;

  /// No description provided for @authForgotPasswordEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authForgotPasswordEmailHint;

  /// No description provided for @authForgotPasswordSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get authForgotPasswordSendCode;

  /// No description provided for @authForgotPasswordSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get authForgotPasswordSending;

  /// No description provided for @authForgotPasswordErrorEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authForgotPasswordErrorEmail;

  /// No description provided for @authForgotPasswordCodeSentBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit reset code to {email}. Enter it below.'**
  String authForgotPasswordCodeSentBody(String email);

  /// No description provided for @authForgotPasswordVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get authForgotPasswordVerifyButton;

  /// No description provided for @authForgotPasswordVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'That code is invalid or has expired.'**
  String get authForgotPasswordVerifyFailed;

  /// No description provided for @authForgotPasswordNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get authForgotPasswordNewPasswordTitle;

  /// No description provided for @authForgotPasswordNewPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a password you haven\'t used before.'**
  String get authForgotPasswordNewPasswordBody;

  /// No description provided for @authForgotPasswordNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get authForgotPasswordNewPasswordLabel;

  /// No description provided for @authForgotPasswordNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get authForgotPasswordNewPasswordHint;

  /// No description provided for @authForgotPasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authForgotPasswordConfirmLabel;

  /// No description provided for @authForgotPasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get authForgotPasswordConfirmHint;

  /// No description provided for @authForgotPasswordResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authForgotPasswordResetButton;

  /// No description provided for @authForgotPasswordResetting.
  ///
  /// In en, this message translates to:
  /// **'Resetting…'**
  String get authForgotPasswordResetting;

  /// No description provided for @authForgotPasswordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not reset your password. Please try again.'**
  String get authForgotPasswordResetFailed;

  /// No description provided for @authForgotPasswordErrorPasswordMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authForgotPasswordErrorPasswordMatch;

  /// No description provided for @dialogOkButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialogOkButton;

  /// No description provided for @paymentQuitTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit payment?'**
  String get paymentQuitTitle;

  /// No description provided for @paymentQuitBody.
  ///
  /// In en, this message translates to:
  /// **'Your order has not been paid. Are you sure you want to leave?'**
  String get paymentQuitBody;

  /// No description provided for @paymentQuitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, quit'**
  String get paymentQuitConfirm;

  /// No description provided for @pickupScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get pickupScanTitle;

  /// No description provided for @pickupScanInstruction.
  ///
  /// In en, this message translates to:
  /// **'Point at the counter QR code'**
  String get pickupScanInstruction;

  /// No description provided for @pickupScanReady.
  ///
  /// In en, this message translates to:
  /// **'Go to the counter'**
  String get pickupScanReady;

  /// No description provided for @pickupScanPreparing.
  ///
  /// In en, this message translates to:
  /// **'Still preparing'**
  String get pickupScanPreparing;

  /// No description provided for @pickupScanManualHint.
  ///
  /// In en, this message translates to:
  /// **'Enter stand code'**
  String get pickupScanManualHint;

  /// No description provided for @pickupScanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get pickupScanAgain;

  /// No description provided for @pickupScanCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in at {counter}'**
  String pickupScanCheckedIn(String counter);

  /// No description provided for @pickupScanErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown pickup counter QR'**
  String get pickupScanErrorUnknown;

  /// No description provided for @pickupScanErrorNoOrder.
  ///
  /// In en, this message translates to:
  /// **'You have no order to collect at this counter today'**
  String get pickupScanErrorNoOrder;

  /// No description provided for @pickupScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Canteen | Scan and enjoy the meals'**
  String get pickupScanSubtitle;

  /// No description provided for @pickupEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get pickupEnterCode;

  /// No description provided for @pickupEnterCodeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get pickupEnterCodeConfirm;

  /// No description provided for @pickupFlash.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get pickupFlash;

  /// No description provided for @pickupResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick Up Items'**
  String get pickupResultTitle;
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
