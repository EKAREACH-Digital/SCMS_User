import 'package:flutter/foundation.dart';

import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/weekly_menu.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/repositories/menu_repository.dart';

/// Meal sessions a dish can belong to. Derived from its category name, the
/// same way the manager dashboard does it.
enum MealSlot { breakfast, lunch, dinner }

extension MealSlotX on MealSlot {
  String get key => name;
}

/// The published weekly menu, grouped for display.
///
/// Grouping deliberately mirrors `groupByDayAndSession` in the manager
/// dashboard so both surfaces show the same thing:
///  * `day_of_week` is 0 = Monday … 6 = Sunday.
///  * A **null** day means the dish runs every day of the menu — except on
///    days where a day-specific entry for that same dish and slot already
///    exists, which would otherwise duplicate it.
class WeeklyMenuViewModel extends ChangeNotifier {
  WeeklyMenuViewModel(this._menuRepository);

  final MenuRepository _menuRepository;

  // Starts as loading: the page shows a spinner until its first load lands.
  ViewState _state = ViewState.loading;
  WeeklyMenu? _data;
  String? _errorMessage;

  ViewState get state => _state;
  bool get isLoading => _state == ViewState.loading;

  /// Why the last load failed, or null. Lets the UI surface the backend's own
  /// message instead of a blank screen.
  String? get error => _errorMessage;

  /// The published menu covering today; null when there is none (or before
  /// it loads).
  WeeklyMenu? get data => _data;

  Future<void> load({String? schoolId}) async {
    _setState(ViewState.loading);
    try {
      _data = await _menuRepository.getCurrentWeeklyMenu(schoolId: schoolId);
      _setState(ViewState.success);
    } catch (e, s) {
      AppLogger.e('Loading the weekly menu failed', e, s);
      _data = null;
      _errorMessage = e is ApiException
          ? e.message
          : "Couldn't load the weekly menu. Please try again.";
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

  /// Which category counts as which meal. Anything uncategorised falls to
  /// lunch, matching `categoryNameToSession` on the dashboard.
  static MealSlot slotOf(FoodItem item) => switch (item.category) {
    'breakfast' => MealSlot.breakfast,
    'dinner' => MealSlot.dinner,
    _ => MealSlot.lunch,
  };

  /// Dishes served on [day] (0 = Monday), split by meal slot.
  Map<MealSlot, List<MenuEntry>> entriesForDay(int day) {
    final result = {for (final s in MealSlot.values) s: <MenuEntry>[]};
    final weekly = data;
    if (weekly == null) return result;

    // Dishes explicitly scheduled on this day, keyed by slot + item, so an
    // "every day" entry for the same dish doesn't add a duplicate alongside it.
    final pinned = <String>{};
    for (final e in weekly.entries) {
      if (e.dayOfWeek != null) {
        pinned.add('${e.dayOfWeek}|${slotOf(e.item).key}|${e.item.id}');
      }
    }

    for (final e in weekly.entries) {
      final slot = slotOf(e.item);
      if (e.dayOfWeek == null) {
        if (!pinned.contains('$day|${slot.key}|${e.item.id}')) {
          result[slot]!.add(e);
        }
      } else if (e.dayOfWeek == day) {
        result[slot]!.add(e);
      }
    }
    return result;
  }

  /// True when the menu has no day-specific scheduling at all — every dish is
  /// simply available all week. Lets the UI explain why each day looks alike
  /// instead of implying a schedule that doesn't exist.
  bool get hasNoDaySchedule {
    final weekly = data;
    if (weekly == null) return false;
    return weekly.entries.isNotEmpty &&
        weekly.entries.every((e) => e.dayOfWeek == null);
  }

  /// Index (0 = Monday) of today, clamped into the week.
  static int todayIndex() => DateTime.now().weekday - 1;
}
