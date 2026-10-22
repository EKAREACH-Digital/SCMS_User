import 'package:flutter/foundation.dart';

import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/repositories/menu_repository.dart';

/// Loads the backend menu once and shares it between the home and menu
/// screens (and the cart). The backend has no ratings, so cards fall back to
/// gradient + icon placeholders for anything it doesn't provide.
class MenuViewModel extends ChangeNotifier {
  MenuViewModel(this._menuRepository);

  final MenuRepository _menuRepository;

  ViewState _state = ViewState.idle;
  List<FoodItem> _items = const [];
  String? _errorMessage;

  ViewState get state => _state;

  /// The loaded dishes; empty until [state] is [ViewState.success].
  List<FoodItem> get items => _items;

  /// Why the last load failed; null unless [state] is [ViewState.error].
  String? get errorMessage => _errorMessage;

  /// The school the loaded menu belongs to — used to scope a placed order to
  /// the correct tenant. Captured from the fetched items.
  String? _schoolId;
  String? get schoolId => _schoolId;

  /// Loads the menu. No-ops once loaded unless [force] is set.
  Future<void> load({String? schoolId, bool force = false}) async {
    if (_state == ViewState.success && !force) return;

    _setState(ViewState.loading);
    try {
      final foods = await _menuRepository.getMenuItems(schoolId: schoolId);
      _schoolId = foods.isNotEmpty ? foods.first.schoolId : null;
      _items = foods;
      _setState(ViewState.success);
    } catch (e, s) {
      AppLogger.e('Loading the menu failed', e, s);
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
