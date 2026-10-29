import 'package:intl/intl.dart';

class DateHelpers {
  static final DateFormat _isoDayFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayFormat = DateFormat('EEEE, d MMM');
  static final DateFormat _shortDisplayFormat = DateFormat('d MMM');

  /// Formats date to YYYY-MM-DD in phone's local timezone
  static String toLocalDayString(DateTime dateTime) {
    return _isoDayFormat.format(dateTime.toLocal());
  }

  /// Formats date to YYYY-MM-DD in India Standard Time (UTC+5:30)
  static String toIstDayString(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final ist = utc.add(const Duration(hours: 5, minutes: 30));
    return _isoDayFormat.format(ist);
  }

  /// Formats date for display like "Thursday, 22 Oct"
  static String toDisplayDate(DateTime dateTime) {
    return _displayFormat.format(dateTime.toLocal());
  }

  /// Formats date for display like "22 Oct"
  static String toShortDisplayDate(DateTime dateTime) {
    return _shortDisplayFormat.format(dateTime.toLocal());
  }

  /// Parses YYYY-MM-DD
  static DateTime parseDayString(String dateStr) {
    return _isoDayFormat.parse(dateStr);
  }

  /// Check if two dates represent the same local day
  static bool isSameDay(DateTime a, DateTime b) {
    return toLocalDayString(a) == toLocalDayString(b);
  }

  /// Determines default meal type from current local hour
  /// < 11:00 -> breakfast
  /// 11:00 - 15:59 -> lunch
  /// 16:00 - 18:59 -> snack
  /// >= 19:00 -> dinner
  static String defaultMealType(DateTime dateTime) {
    final hour = dateTime.toLocal().hour;
    if (hour < 11) {
      return 'breakfast';
    } else if (hour < 16) {
      return 'lunch';
    } else if (hour < 19) {
      return 'snack';
    } else {
      return 'dinner';
    }
  }

  /// Capitalize meal type for display
  static String formatMealType(String mealType) {
    if (mealType.isEmpty) return '';
    return mealType[0].toUpperCase() + mealType.substring(1).toLowerCase();
  }
}

