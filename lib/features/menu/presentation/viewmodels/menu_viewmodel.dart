import 'package:flutter/foundation.dart';

import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/daily_menu.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/repositories/menu_repository.dart';

/// Loads today's active menu for the user's home branch and shares it between
/// the home and menu screens (and the cart). Uses `GET /menus/active?branch_id=`
/// so only dishes scheduled for today are shown.
class MenuViewModel extends ChangeNotifier {
  MenuViewModel(this._menuRepository);

  final MenuRepository _menuRepository;

  ViewState _state = ViewState.idle;
  DailyMenu? _dailyMenu;
  String? _errorMessage;

  ViewState get state => _state;

  /// Every dish across all canteens for today; empty until the first load
  /// succeeds. A forced reload keeps the previous items until the new ones arrive.
  List<FoodItem> get items => _dailyMenu?.items ?? const [];

  /// The last successfully loaded daily menu; null until the first load succeeds.
  DailyMenu? get dailyMenu => _dailyMenu;

  /// Why the last load failed; null unless [state] is [ViewState.error].
  String? get errorMessage => _errorMessage;

  /// `GET /menus/active` — today's orderable dishes for [branchId] (the user's
  /// `home_branch_id`). No-ops once loaded unless [force] is set. When
  /// [branchId] is null the call is skipped and the error state is shown.
  Future<void> load({String? branchId, bool force = false}) async {
    if (_state == ViewState.success && !force) return;

    if (branchId == null) {
      _errorMessage = 'No branch selected. Please complete your profile.';
      _setState(ViewState.error);
      return;
    }

    _setState(ViewState.loading);
    try {
      // GET /menus/active — today's menu for the student's home branch.
      _dailyMenu = await _menuRepository.getActiveMenu(branchId: branchId);
      _setState(ViewState.success);
    } catch (e, s) {
      AppLogger.e('Loading the active menu failed', e, s);
      _errorMessage = e is ApiException
          ? e.message
          : "Couldn't load the menu. Please try again.";
      _setState(ViewState.error);
    }
  }

  /// The only place listeners are notified. Leaving the error state clears
  /// the error message.
  void _setState(ViewState newState) {
    _state = newState;
    if (newState != ViewState.error) _errorMessage = null;
    notifyListeners();
  }
}
