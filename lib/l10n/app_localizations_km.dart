// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get appTitle => 'Smart Canteen';

  @override
  String get splashTagline => 'ស្កេន បរិភោគ រីករាយ — តាមរបៀបឆ្លាតវៃ';

  @override
  String get commonRetry => 'ព្យាយាមម្តងទៀត';

  @override
  String get commonAdd => 'បន្ថែម';

  @override
  String get commonViewAll => 'មើលទាំងអស់';

  @override
  String get commonActive => 'សកម្ម';

  @override
  String get commonSortBy => 'តម្រៀបតាម';

  @override
  String get commonPleaseWait => 'សូមរង់ចាំបន្តិច';

  @override
  String get commonCancel => 'បោះបង់';

  @override
  String get commonTopUp => 'បញ្ចូលទឹកប្រាក់';

  @override
  String get navHome => 'ទំព័រដើម';

  @override
  String get navMenu => 'ម៉ឺនុយ';

  @override
  String get navCart => 'រទេះ';

  @override
  String get navQrPay => 'បង់ប្រាក់ QR';

  @override
  String get navHistory => 'ប្រវត្តិ';

  @override
  String get navSettings => 'ការកំណត់';

  @override
  String get historyTitle => 'ប្រវត្តិការបញ្ជាទិញ';

  @override
  String get historySubtitle => 'អ្វីៗដែលអ្នកបានបញ្ជាទិញ';

  @override
  String get historyEmptyTitle => 'មិនទាន់មានការបញ្ជាទិញ';

  @override
  String get historyEmptyBody => 'ការបញ្ជាទិញរបស់អ្នកនឹងបង្ហាញនៅទីនេះ';

  @override
  String get historyErrorTitle => 'មិនអាចទាញយកប្រវត្តិបានទេ';

  @override
  String get historyRetry => 'ព្យាយាមម្តងទៀត';

  @override
  String get historyRetrying => 'កំពុងព្យាយាម…';

  @override
  String get historySortNewest => 'ថ្មីបំផុត';

  @override
  String get historySortAmountHigh => 'ចំនួន៖ ច្រើនទៅតិច';

  @override
  String get historySortAmountLow => 'ចំនួន៖ តិចទៅច្រើន';

  @override
  String get historyOrderDetails => 'ព័ត៌មានលម្អិតការបញ្ជាទិញ';

  @override
  String get historyItems => 'ទំនិញ';

  @override
  String get historyTotalAmount => 'ចំនួនសរុប';

  @override
  String get historyInKhr => 'ជាប្រាក់រៀល';

  @override
  String get historyStatus => 'ស្ថានភាព';

  @override
  String get historyOrderedOn => 'បញ្ជាទិញនៅ';

  @override
  String get historyMealSession => 'វេនអាហារ';

  @override
  String historyItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ទំនិញ $count',
      one: 'ទំនិញ 1',
    );
    return '$_temp0';
  }

  @override
  String get statusCompleted => 'បានបញ្ចប់';

  @override
  String get statusRedeemed => 'បានទទួល';

  @override
  String get statusPending => 'កំពុងរង់ចាំ';

  @override
  String get statusFailed => 'បរាជ័យ';

  @override
  String get walletMyWallet => 'កាបូបរបស់ខ្ញុំ';

  @override
  String get walletTopUpBalance => 'បញ្ចូលទឹកប្រាក់';

  @override
  String get walletTopUpPrompt =>
      'ជ្រើសរើសចំនួនទឹកប្រាក់ដើម្បីបញ្ចូលទៅកាបូបរបស់អ្នក';

  @override
  String get walletEnterCustomAmount => 'បញ្ចូលចំនួនផ្ទាល់ខ្លួន';

  @override
  String get walletChoosePaymentMethod => 'ជ្រើសរើសវិធីទូទាត់';

  @override
  String get walletChoosePaymentPrompt =>
      'ជ្រើសរើសរបៀបដែលអ្នកចង់បញ្ចូលទឹកប្រាក់';

  @override
  String get walletTopUpAmount => 'ចំនួនបញ្ចូលទឹកប្រាក់';

  @override
  String get walletTopUpFailed =>
      'ការបញ្ចូលទឹកប្រាក់បរាជ័យ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get walletLowBalance =>
      'សមតុល្យទាប — សូមបញ្ចូលទឹកប្រាក់ដើម្បីបន្តបញ្ជាទិញ';

  @override
  String get walletTotalAmount => 'ចំនួនសរុប';

  @override
  String get walletPaymentPrompt =>
      'ជ្រើសរើសជម្រើសទូទាត់ដែលអ្នកចូលចិត្តខាងក្រោម';

  @override
  String get walletPayWithBank => 'ឬបង់ប្រាក់តាមធនាគារ';

  @override
  String get homeScholarBadge => 'សិស្សអាហារូបករណ៍ CADT';

  @override
  String get homePromoExclusive => 'ពិសេស';

  @override
  String get homePromoTitle => 'អាហារស្រស់ៗប្រចាំថ្ងៃក្នុងបរិវេណសាលា';

  @override
  String get homePromoBody =>
      'បញ្ចុះតម្លៃ ២០% សម្រាប់សិស្សអាហារូបករណ៍ CADT សប្តាហ៍នេះតែប៉ុណ្ណោះ';

  @override
  String get homeCouponApplied => 'គូប៉ុងបញ្ចុះតម្លៃត្រូវបានប្រើ!';

  @override
  String get homeClaimNow => 'ទទួលយកឥឡូវ';

  @override
  String homeProcessing(String amount) {
    return 'កំពុងដំណើរការ $amount…';
  }

  @override
  String get topupTitle => 'បញ្ចូលទឹកប្រាក់';

  @override
  String get topupAmountLabel => 'ចំនួនទឹកប្រាក់ (ដុល្លារ)';

  @override
  String get topupPayWithAba => 'បង់ប្រាក់តាម ABA';

  @override
  String get topupScanHint =>
      'ស្កេន QR នេះដោយប្រើកម្មវិធីធនាគារណាមួយ ឬចុចខាងក្រោមដើម្បីបើក ABA Mobile នៅលើទូរស័ព្ទនេះ។';

  @override
  String get topupOpenAba => 'បើក ABA Mobile';

  @override
  String get topupPreparing => 'កំពុងរៀបចំការទូទាត់…';

  @override
  String get topupWaiting => 'កំពុងរង់ចាំការទូទាត់…';

  @override
  String get topupCancel => 'បោះបង់ការទូទាត់';

  @override
  String get topupInvalidAmount => 'សូមបញ្ចូលចំនួនទឹកប្រាក់ឱ្យបានត្រឹមត្រូវ';

  @override
  String get topupStartError =>
      'មិនអាចចាប់ផ្តើមការបញ្ចូលទឹកប្រាក់បានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get topupAbaNotFound =>
      'ABA Mobile មិនត្រូវបានដំឡើងនៅលើឧបករណ៍នេះទេ។ សូមស្កេន QR ដោយប្រើទូរស័ព្ទផ្សេង។';

  @override
  String get topupFailed => 'ការទូទាត់បរាជ័យ ឬត្រូវបានបោះបង់។';

  @override
  String get topupExpired => 'QR នេះបានផុតកំណត់។ សូមចាប់ផ្តើមឡើងវិញ។';

  @override
  String get topupNotCompletedTitle => 'ការទូទាត់មិនបានបញ្ចប់';

  @override
  String get topupCancelledBody =>
      'អ្នកបានបោះបង់ការទូទាត់។ គ្មានការកាត់ប្រាក់ឡើយ។';

  @override
  String get topupTryAgain => 'ព្យាយាមម្តងទៀត';

  @override
  String get topupBackToWallet => 'ត្រលប់ទៅកាបូប';

  @override
  String get topupSuccessTitle => 'ការបញ្ចូលទឹកប្រាក់ជោគជ័យ';

  @override
  String topupSuccessBody(String amount) {
    return '$amount ត្រូវបានបញ្ចូលទៅក្នុងកាបូបរបស់អ្នក។';
  }

  @override
  String get topupDone => 'រួចរាល់';

  @override
  String get qrTitle => 'សំបុត្រអាហាររបស់ខ្ញុំ';

  @override
  String get qrRefreshed => 'កូដ QR ត្រូវបានធ្វើឱ្យស្រស់';

  @override
  String get qrViewReceipt => 'មើលបង្កាន់ដៃ';

  @override
  String get qrHint => 'បង្ហាញកូដនេះនៅបញ្ជរអាហារដ្ឋាន\nដើម្បីទទួលអាហាររបស់អ្នក';

  @override
  String get qrOrderSummary => 'សេចក្តីសង្ខេបការបញ្ជាទិញ';

  @override
  String get qrTotalPaid => 'បានបង់សរុប';

  @override
  String get qrEmptyTitle => 'មិនទាន់មានការបញ្ជាទិញ';

  @override
  String get qrEmptyBody => 'សូមបញ្ជាទិញពីម៉ឺនុយ\nដើម្បីបង្កើតសំបុត្ររបស់អ្នក';

  @override
  String get qrReceiptTitle => 'បង្កាន់ដៃប្រតិបត្តិការ';

  @override
  String qrTicketOfCount(int index, int count) {
    return 'សំបុត្រទី $index ក្នុងចំណោម $count';
  }

  @override
  String get weeklyMenuTitle => 'ម៉ឺនុយប្រចាំសប្តាហ៍';

  @override
  String get weeklyMenuOpen => 'ម៉ឺនុយប្រចាំសប្តាហ៍';

  @override
  String get weeklyMenuEmptyTitle => 'មិនទាន់មានម៉ឺនុយត្រូវបានផ្សាយ';

  @override
  String get weeklyMenuEmptyBody =>
      'អាហារដ្ឋានមិនទាន់បានផ្សាយម៉ឺនុយសម្រាប់សប្តាហ៍នេះទេ។ សូមពិនិត្យមើលឡើងវិញនៅពេលក្រោយ។';

  @override
  String get weeklyMenuErrorTitle => 'មិនអាចទាញយកម៉ឺនុយប្រចាំសប្តាហ៍បានទេ';

  @override
  String get weeklyMenuNothingToday => 'មិនមានអាហារសម្រាប់ថ្ងៃនេះទេ';

  @override
  String get weeklyMenuAllWeekNote =>
      'មុខម្ហូបទាំងអស់ក្នុងម៉ឺនុយនេះមានលក់ពេញមួយសប្តាហ៍ ដូច្នេះរាល់ថ្ងៃបង្ហាញបញ្ជីដូចគ្នា។';

  @override
  String get weeklyMenuToday => 'ថ្ងៃនេះ';

  @override
  String get slotBreakfast => 'អាហារពេលព្រឹក';

  @override
  String get slotLunch => 'អាហារថ្ងៃត្រង់';

  @override
  String get slotDinner => 'អាហារពេលល្ងាច';

  @override
  String get dayMon => 'ច័ន្ទ';

  @override
  String get dayTue => 'អង្គារ';

  @override
  String get dayWed => 'ពុធ';

  @override
  String get dayThu => 'ព្រហ';

  @override
  String get dayFri => 'សុក្រ';

  @override
  String get daySat => 'សៅរ៍';

  @override
  String get daySun => 'អាទិត្យ';

  @override
  String get menuTabAll => 'ទាំងអស់';

  @override
  String get menuTabSnacks => 'អាហារសម្រន់';

  @override
  String get menuTabDrinks => 'ភេសជ្ជៈ';

  @override
  String get menuTabDesserts => 'បង្អែម';

  @override
  String menuViewCart(int count) {
    return 'មើលរទេះ ($count)';
  }

  @override
  String get menuEmptyTitle => 'រកមិនឃើញទំនិញ';

  @override
  String get menuEmptyBody => 'សូមកែតម្រូវតម្រង ឬការស្វែងរករបស់អ្នក';

  @override
  String get menuFoodType => 'ប្រភេទអាហារ';

  @override
  String get menuPrice => 'តម្លៃ';

  @override
  String get menuNutritionInfo => 'ព័ត៌មានអាហារូបត្ថម្ភ';

  @override
  String get menuAllergenInfo => 'ព័ត៌មានអាឡែហ្ស៊ី';

  @override
  String get menuAllergenBody => 'អាចមានសណ្តែកដី គ្រឿងសមុទ្រ និងផលិតផលទឹកដោះគោ';

  @override
  String get menuErrorTitle => 'មិនអាចទាញយកម៉ឺនុយបានទេ';

  @override
  String get cartEmptyTitle => 'រទេះទំនិញរបស់អ្នកទទេ';

  @override
  String get cartEmptyBody => 'បន្ថែមទំនិញពីម៉ឺនុយដើម្បីចាប់ផ្តើម';

  @override
  String get cartYourOrder => 'ការបញ្ជាទិញរបស់អ្នក';

  @override
  String get cartMealSession => 'វេនអាហារ';

  @override
  String get cartProceedToPayment => 'បន្តទៅការទូទាត់';

  @override
  String cartItemsInCart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ទំនិញ $count ក្នុងរទេះ',
    );
    return '$_temp0';
  }

  @override
  String get cartSubtotal => 'សរុបរង';

  @override
  String get cartScholarDiscount => 'ការបញ្ចុះតម្លៃសម្រាប់សិស្ស';

  @override
  String get cartServiceFee => 'ថ្លៃសេវា';

  @override
  String get cartTotal => 'សរុប';

  @override
  String get cartTitle => 'រទេះទំនិញ';

  @override
  String get cartItemSection => 'ទំនិញ';

  @override
  String get cartPaymentSummary => 'សេចក្តីសង្ខេបការទូទាត់';

  @override
  String get cartDiscount => 'បញ្ចុះតម្លៃ';

  @override
  String get cartApplyCoupon => 'ប្រើគូប៉ុង';

  @override
  String get cartSelectPaymentMethod => 'ជ្រើសរើសវិធីទូទាត់';

  @override
  String get cartCheckout => 'ទូទាត់';

  @override
  String get cartBrowseMenu => 'មើលម៉ឺនុយ';

  @override
  String get cartPaymentComingSoon => 'ការទូទាត់នឹងត្រូវភ្ជាប់នៅទីនេះ។';

  @override
  String get couponExpiredTitle => 'គូប៉ុងផុតកំណត់';

  @override
  String get couponExpiredBody =>
      'សំបុត្រ QR របស់អ្នកបានផុតកំណត់។ សូមទិញគូប៉ុងថ្មីដើម្បីបន្ត។';

  @override
  String get couponExpiredAction => 'យកគូប៉ុងថ្មី';

  @override
  String get alertsTitle => 'ការជូនដំណឹង';

  @override
  String get alertsMarkAllRead => 'សម្គាល់ថាបានអានទាំងអស់';

  @override
  String get alertsEmpty => 'មិនមានការជូនដំណឹង';

  @override
  String get settingsTitle => 'ការកំណត់';

  @override
  String get settingsDarkMode => 'របៀបងងឹត';

  @override
  String get settingsLanguage => 'ភាសា';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageKhmer => 'ភាសាខ្មែរ';

  @override
  String get settingsChangePhoto => 'ប្តូររូបភាពប្រវត្តិរូប';

  @override
  String get settingsLogOut => 'ចាកចេញ';

  @override
  String get settingsLogOutConfirm =>
      'តើអ្នកប្រាកដថាចង់ចាកចេញពីគណនីរបស់អ្នកមែនទេ?';

  @override
  String get settingsMyProfile => 'ប្រវត្តិរូបរបស់ខ្ញុំ';

  @override
  String get authRememberMe => 'ចងចាំខ្ញុំ';

  @override
  String get authForgotPassword => 'ភ្លេចពាក្យសម្ងាត់?';

  @override
  String get authCompleteProfileTitle => 'បំពេញប្រវត្តិរូបរបស់អ្នក';

  @override
  String get authCompleteProfileBody =>
      'បន្ថែមព័ត៌មានមួយចំនួនដើម្បីបញ្ចប់ការរៀបចំគណនីរបស់អ្នក។';

  @override
  String get authSchool => 'សាលា';

  @override
  String get authLoadingSchools => 'កំពុងទាញយកសាលា…';

  @override
  String get authSelectSchool => 'ជ្រើសរើសសាលារបស់អ្នក';

  @override
  String get authPasswordReset =>
      'ពាក្យសម្ងាត់ត្រូវបានកំណត់ឡើងវិញ — សូមចូលដោយប្រើពាក្យសម្ងាត់ថ្មី';

  @override
  String get authResendCode => 'មិនបានទទួល? ផ្ញើលេខកូដម្តងទៀត';

  @override
  String get authRegisterTitle => 'ចុះឈ្មោះ';

  @override
  String get authRegisterFirstName => 'នាមខ្លួន';

  @override
  String get authRegisterFirstNameHint => 'សុខា';

  @override
  String get authRegisterLastName => 'នាមត្រកូល';

  @override
  String get authRegisterLastNameHint => 'ចាន់';

  @override
  String get authRegisterEmailLabel => 'អ៊ីម៉ែល';

  @override
  String get authRegisterEmailHint => 'បញ្ចូលអ៊ីម៉ែលរបស់អ្នក';

  @override
  String get authRegisterPasswordLabel => 'ពាក្យសម្ងាត់';

  @override
  String get authRegisterPasswordRequirement => 'ត្រូវមានយ៉ាងហោចណាស់ ៨ តួអក្សរ';

  @override
  String get authRegisterConfirmPasswordLabel => 'បញ្ជាក់ពាក្យសម្ងាត់';

  @override
  String get authRegisterNext => 'បន្ទាប់';

  @override
  String get authRegisterCreating => 'កំពុងបង្កើតគណនី…';

  @override
  String get authRegisterChooseSchool => 'ជ្រើសរើសសាលារបស់អ្នក';

  @override
  String get authRegisterSelectBranch => 'ជ្រើសរើសសាខា';

  @override
  String get authRegisterCreateAccount => 'បង្កើតគណនី';

  @override
  String get authAlreadyHaveAccount => 'មានគណនីរួចហើយ? ';

  @override
  String get authSignInLink => 'ចូលគណនី';

  @override
  String get authRegisterErrorName => 'សូមបញ្ចូលនាមខ្លួន និងនាមត្រកូលរបស់អ្នក។';

  @override
  String get authRegisterErrorEmail => 'សូមបញ្ចូលអ៊ីម៉ែលឱ្យបានត្រឹមត្រូវ។';

  @override
  String get authRegisterErrorPasswordMatch => 'ពាក្យសម្ងាត់មិនត្រូវគ្នា។';

  @override
  String get authRegisterFailed => 'ការចុះឈ្មោះបរាជ័យ។';

  @override
  String get authRegisterErrorSchool => 'សូមជ្រើសរើសសាលារបស់អ្នក។';

  @override
  String get authRegisterErrorBranch => 'សូមជ្រើសរើសសាខារបស់អ្នក។';

  @override
  String get authRegisterSaveFailed =>
      'មិនអាចរក្សាទុកព័ត៌មានរបស់អ្នក។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get authSignInTitle => 'ចូលគណនី';

  @override
  String get authSignInButton => 'ចូល';

  @override
  String get authSignInLoading => 'កំពុងចូល…';

  @override
  String get authSignInEmailLabel => 'អ៊ីម៉ែល';

  @override
  String get authSignInEmailHint => 'បញ្ចូលអ៊ីម៉ែលរបស់អ្នក';

  @override
  String get authSignInPasswordLabel => 'ពាក្យសម្ងាត់';

  @override
  String get authSignInPasswordHint => 'បញ្ចូលពាក្យសម្ងាត់របស់អ្នក';

  @override
  String get authOrContinueWith => 'ឬបន្តជាមួយ';

  @override
  String get authDontHaveAccount => 'មិនទាន់មានគណនី? ';

  @override
  String get authSignUpLink => 'ចុះឈ្មោះ';

  @override
  String get authSignInErrorEmpty => 'សូមបំពេញព័ត៌មានទាំងអស់។';

  @override
  String get authSignInFailed => 'ការចូលគណនីបរាជ័យ។';

  @override
  String get authVerifyEmailTitle => 'ផ្ទៀងផ្ទាត់អ៊ីមែលរបស់អ្នក';

  @override
  String authVerifyEmailBody(String email) {
    return 'យើងបានផ្ញើលេខកូដ ៦ ខ្ទង់ទៅ $email។ សូមបញ្ចូលវានៅខាងក្រោម ដើម្បីបើកដំណើរការគណនីរបស់អ្នក។';
  }

  @override
  String get authVerifyCodeLabel => 'លេខកូដផ្ទៀងផ្ទាត់';

  @override
  String get authVerifyCodeHint => 'បញ្ចូលលេខកូដ ៦ ខ្ទង់';

  @override
  String get authVerifyButton => 'ផ្ទៀងផ្ទាត់';

  @override
  String get authVerifying => 'កំពុងផ្ទៀងផ្ទាត់…';

  @override
  String get authVerifyErrorCode => 'សូមបញ្ចូលលេខកូដ ៦ ខ្ទង់ឱ្យគ្រប់។';

  @override
  String get authVerifyFailed => 'មិនអាចផ្ទៀងផ្ទាត់អ៊ីមែលរបស់អ្នកបានទេ។';

  @override
  String authResendIn(int seconds) {
    return 'ផ្ញើលេខកូដម្តងទៀតក្នុង $seconds វិនាទី';
  }

  @override
  String get authCodeResent => 'លេខកូដថ្មីកំពុងត្រូវបានផ្ញើ។';

  @override
  String get authRegisterPhoneLabel => 'លេខទូរស័ព្ទ';

  @override
  String get authRegisterPhoneHint => '+855 12 345 678';

  @override
  String get authRegisterErrorPhone => 'សូមបញ្ចូលលេខទូរស័ព្ទរបស់អ្នក។';

  @override
  String get authRegisterSelectBranchHint => 'ជ្រើសរើសសាខារបស់អ្នក';

  @override
  String get authRegisterLoadFailed =>
      'មិនអាចទាញយកបញ្ជីបានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get authForgotPasswordPageTitle => 'កំណត់ពាក្យសម្ងាត់ឡើងវិញ';

  @override
  String get authForgotPasswordEmailBody =>
      'បញ្ចូលអ៊ីម៉ែលដែលភ្ជាប់ទៅគណនីរបស់អ្នក។ យើងនឹងផ្ញើលេខកូដបន្លំ។';

  @override
  String get authForgotPasswordEmailLabel => 'អ៊ីម៉ែល';

  @override
  String get authForgotPasswordEmailHint => 'បញ្ចូលអ៊ីម៉ែលរបស់អ្នក';

  @override
  String get authForgotPasswordSendCode => 'ផ្ញើលេខកូដ';

  @override
  String get authForgotPasswordSending => 'កំពុងផ្ញើ…';

  @override
  String get authForgotPasswordErrorEmail => 'សូមបញ្ចូលអ៊ីម៉ែលត្រឹមត្រូវ។';

  @override
  String authForgotPasswordCodeSentBody(String email) {
    return 'យើងបានផ្ញើលេខកូដ ៦ ខ្ទង់ទៅ $email។ សូមបញ្ចូលវានៅខាងក្រោម។';
  }

  @override
  String get authForgotPasswordVerifyButton => 'ផ្ទៀងផ្ទាត់លេខកូដ';

  @override
  String get authForgotPasswordVerifyFailed =>
      'លេខកូដនេះមិនត្រឹមត្រូវ ឬផុតកំណត់ហើយ។';

  @override
  String get authForgotPasswordNewPasswordTitle => 'កំណត់ពាក្យសម្ងាត់ថ្មី';

  @override
  String get authForgotPasswordNewPasswordBody =>
      'ជ្រើសពាក្យសម្ងាត់ដែលអ្នកមិនធ្លាប់ប្រើ។';

  @override
  String get authForgotPasswordNewPasswordLabel => 'ពាក្យសម្ងាត់ថ្មី';

  @override
  String get authForgotPasswordNewPasswordHint => 'បញ្ចូលពាក្យសម្ងាត់ថ្មី';

  @override
  String get authForgotPasswordConfirmLabel => 'បញ្ជាក់ពាក្យសម្ងាត់';

  @override
  String get authForgotPasswordConfirmHint => 'បញ្ចូលពាក្យសម្ងាត់ម្តងទៀត';

  @override
  String get authForgotPasswordResetButton => 'កំណត់ឡើងវិញ';

  @override
  String get authForgotPasswordResetting => 'កំពុងកំណត់ឡើងវិញ…';

  @override
  String get authForgotPasswordResetFailed =>
      'មិនអាចកំណត់ពាក្យសម្ងាត់ឡើងវិញបានទេ។ សូមព្យាយាមម្តងទៀត។';

  @override
  String get authForgotPasswordErrorPasswordMatch =>
      'ពាក្យសម្ងាត់មិនត្រូវគ្នា។';

  @override
  String get dialogOkButton => 'យល់ព្រម';

  @override
  String get paymentQuitTitle => 'ចាកចេញពីការទូទាត់?';

  @override
  String get paymentQuitBody =>
      'ការបញ្ជាទិញរបស់អ្នកមិនទាន់បានទូទាត់នៅឡើយ។ តើអ្នកប្រាកដថាចង់ចាកចេញ?';

  @override
  String get paymentQuitConfirm => 'បាទ/ចាស ចាកចេញ';
}
