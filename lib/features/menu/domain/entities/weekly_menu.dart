import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';

/// A published weekly menu — the schedule a manager publishes covering a date
/// range — with the dishes scheduled on it.
class WeeklyMenu {
  final String id;
  final String name;

  /// Inclusive date range the menu covers.
  final DateTime validFrom;
  final DateTime validTo;

  final List<MenuEntry> entries;

  const WeeklyMenu({
    required this.id,
    required this.name,
    required this.validFrom,
    required this.validTo,
    required this.entries,
  });

  bool coversDate(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(validFrom) && !d.isAfter(validTo);
  }

  WeeklyMenu copyWith({
    String? id,
    String? name,
    DateTime? validFrom,
    DateTime? validTo,
    List<MenuEntry>? entries,
  }) {
    return WeeklyMenu(
      id: id ?? this.id,
      name: name ?? this.name,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      entries: entries ?? this.entries,
    );
  }
}

/// One line of a weekly menu: a dish, the day it's served, and how much of it
/// was scheduled.
class MenuEntry {
  final String id;
  final FoodItem item;

  /// Day of the week the dish is served on, **0 = Monday … 6 = Sunday**, or
  /// null meaning "served every day of this menu". This matches the manager
  /// dashboard's convention exactly — see `groupByDayAndSession` there.
  final int? dayOfWeek;

  final int quantityAvailable;

  const MenuEntry({
    required this.id,
    required this.item,
    required this.dayOfWeek,
    required this.quantityAvailable,
  });

  MenuEntry copyWith({
    String? id,
    FoodItem? item,
    int? dayOfWeek,
    int? quantityAvailable,
  }) {
    return MenuEntry(
      id: id ?? this.id,
      item: item ?? this.item,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
    );
  }
}
