import 'package:flutter/widgets.dart';

enum AppBranch { cadt, itc, mptc }

/// The languages the app ships translations for. Mirrors the `.arb` files in
/// `lib/l10n` and [AppLocalizations.supportedLocales].
enum AppLanguage {
  english(Locale('en')),
  khmer(Locale('km'));

  const AppLanguage(this.locale);

  final Locale locale;

  /// The name of the language written in that language, so a user who can't
  /// read the current one can still find their own.
  String get nativeLabel => switch (this) {
        AppLanguage.english => 'English',
        AppLanguage.khmer => 'ភាសាខ្មែរ',
      };
}

class AppSettingsViewModel extends ChangeNotifier {
  bool _isDarkMode = false;
  AppBranch _branch = AppBranch.cadt;
  AppLanguage _language = AppLanguage.english;

  bool get isDarkMode => _isDarkMode;
  AppBranch get branch => _branch;
  AppLanguage get language => _language;

  /// Fed to `MaterialApp.locale`.
  Locale get locale => _language.locale;

  String get branchLabel => switch (_branch) {
        AppBranch.cadt => 'CADT',
        AppBranch.itc => 'ITC',
        AppBranch.mptc => 'MPTC',
      };

  void toggleDarkMode() => _setState(() => _isDarkMode = !_isDarkMode);

  void setBranch(AppBranch branch) {
    if (_branch == branch) return;
    _setState(() => _branch = branch);
  }

  void setLanguage(AppLanguage language) {
    if (_language == language) return;
    _setState(() => _language = language);
  }

  /// The only place listeners are notified: applies [update], then rebuilds
  /// listeners. This view model has no async work, so it has no `ViewState`.
  void _setState(VoidCallback update) {
    update();
    notifyListeners();
  }
}
