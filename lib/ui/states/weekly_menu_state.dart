import 'package:flutter/foundation.dart';

import '../../data/dtos/menu_dto.dart';
import '../../data/exceptions/api_exception.dart';
import '../../data/repositories/menu/menu_repository.dart';
import '../utils/async_value.dart';

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
class WeeklyMenuState extends ChangeNotifier {
  WeeklyMenuState(this._menuRepository);

  final MenuRepository _menuRepository;

  AsyncValue<WeeklyMenuDto?> _menu = const AsyncLoading();
  AsyncValue<WeeklyMenuDto?> get menu => _menu;

  bool get isLoading => _menu is AsyncLoading;

  /// Why the last load failed, or null. Kept separate from [menu] so the UI can
  /// surface the backend's own message instead of a blank screen.
  String? get error =>
      _menu is AsyncError ? _describe((_menu as AsyncError).error) : null;

  WeeklyMenuDto? get data =>
      _menu is AsyncData<WeeklyMenuDto?> ? (_menu as AsyncData).data : null;

  static String _describe(Object e) => e is ApiException
      ? e.message
      : "Couldn't load the weekly menu. Please try again.";

  Future<void> load({String? schoolId}) async {
    _menu = const AsyncLoading();
    notifyListeners();
    try {
      _menu = AsyncData(
        await _menuRepository.getCurrentWeeklyMenu(schoolId: schoolId),
      );
    } catch (e, s) {
      _menu = AsyncError(e, s);
    }
    notifyListeners();
  }

  /// Which category counts as which meal. Anything uncategorised falls to
  /// lunch, matching `categoryNameToSession` on the dashboard.
  static MealSlot slotOf(MenuItemDto item) =>
      switch ((item.categoryName ?? '').toLowerCase()) {
        'breakfast' => MealSlot.breakfast,
        'dinner' => MealSlot.dinner,
        _ => MealSlot.lunch,
      };

  /// Dishes served on [day] (0 = Monday), split by meal slot.
  Map<MealSlot, List<MenuEntryDto>> entriesForDay(int day) {
    final result = {for (final s in MealSlot.values) s: <MenuEntryDto>[]};
    final weekly = data;
    if (weekly == null) return result;

    // Dishes explicitly scheduled on this day, keyed by slot + item, so an
    // "every day" entry for the same dish doesn't add a duplicate alongside it.
    final pinned = <String>{};
    for (final e in weekly.entries) {
      if (e.dayOfWeek != null) {
        pinned.add('${e.dayOfWeek}|${slotOf(e.menuItem).key}|${e.menuItem.id}');
      }
    }

    for (final e in weekly.entries) {
      final slot = slotOf(e.menuItem);
      if (e.dayOfWeek == null) {
        if (!pinned.contains('$day|${slot.key}|${e.menuItem.id}')) {
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
