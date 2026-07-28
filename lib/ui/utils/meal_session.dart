/// The canteen meal sessions and the time windows they're available for
/// ordering. Ordering is only allowed while a session's window is active, so a
/// user at lunchtime can only order lunch (not breakfast or dinner).
enum MealSession {
  breakfast('breakfast', 'Breakfast', 7, 9),
  lunch('lunch', 'Lunch', 11, 13),
  dinner('dinner', 'Dinner', 15, 17);

  const MealSession(this.key, this.label, this.startHour, this.endHour);

  /// Backend value: 'breakfast' | 'lunch' | 'dinner'.
  final String key;

  /// Display label.
  final String label;

  /// Window start hour (inclusive) and end hour (exclusive), 24h.
  final int startHour;
  final int endHour;

  /// e.g. "7:00 – 9:00 AM".
  String get timeRange {
    String hh(int h) => (h % 12 == 0 ? 12 : h % 12).toString();
    final startPeriod = startHour < 12 ? 'AM' : 'PM';
    final endPeriod = endHour < 12 ? 'AM' : 'PM';
    return startPeriod == endPeriod
        ? '${hh(startHour)}:00 – ${hh(endHour)}:00 $endPeriod'
        : '${hh(startHour)}:00 $startPeriod – ${hh(endHour)}:00 $endPeriod';
  }

  bool isActiveAt(DateTime now) {
    final minutes = now.hour * 60 + now.minute;
    return minutes >= startHour * 60 && minutes < endHour * 60;
  }

  /// The session currently open for ordering, or null if between windows.
  static MealSession? activeAt(DateTime now) {
    for (final s in MealSession.values) {
      if (s.isActiveAt(now)) return s;
    }
    return null;
  }

  static MealSession? fromKey(String? key) {
    for (final s in MealSession.values) {
      if (s.key == key) return s;
    }
    return null;
  }

  /// Menu categories sold outside the meal windows. Drinks aren't tied to a
  /// sitting, so requiring a user to wait for lunch to buy a bottle of water
  /// made no sense. Add a category here to make it available all day.
  static const anytimeCategories = {'drinks'};

  static bool isAnytimeCategory(String category) =>
      anytimeCategories.contains(category.toLowerCase());

  /// The session to file an order under.
  ///
  /// Orders always carry a session — the backend enum is breakfast/lunch/dinner
  /// with no "anytime" member — so an all-day purchase made between windows is
  /// attributed to the nearest session on the same day. That keeps the coupon
  /// in a bucket the QR screen can find rather than inventing a fourth value
  /// that the schema and the staff dashboard don't understand.
  static MealSession nearestTo(DateTime now) {
    final active = activeAt(now);
    if (active != null) return active;

    final minutes = now.hour * 60 + now.minute;
    MealSession best = MealSession.values.first;
    int bestDistance = -1;

    for (final s in MealSession.values) {
      final start = s.startHour * 60;
      final end = s.endHour * 60;
      // Distance to the window, zero when inside it.
      final distance = minutes < start
          ? start - minutes
          : minutes >= end
              ? minutes - end
              : 0;
      if (bestDistance < 0 || distance < bestDistance) {
        bestDistance = distance;
        best = s;
      }
    }
    return best;
  }
}
