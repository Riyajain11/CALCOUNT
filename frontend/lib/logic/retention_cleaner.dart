import '../core/date_helpers.dart';
import '../data/models/meal.dart';

class RetentionCleaner {
  /// Computes cutoff date: today minus retentionMonths calendar months
  static DateTime getCutoffDate(DateTime today, int retentionMonths) {
    int year = today.year;
    int month = today.month - retentionMonths;
    int day = today.day;

    while (month <= 0) {
      year -= 1;
      month += 12;
    }

    // Handle month length overflow (e.g. 31 Mar - 1 month != 31 Feb)
    final daysInTargetMonth = DateTime(year, month + 1, 0).day;
    if (day > daysInTargetMonth) {
      day = daysInTargetMonth;
    }

    return DateTime(year, month, day);
  }

  /// Filters meals to retain only those on or after the cutoff date
  static List<Meal> cleanMeals(List<Meal> meals, DateTime today, int retentionMonths) {
    final cutoffDateStr = DateHelpers.toLocalDayString(getCutoffDate(today, retentionMonths));
    return meals.where((meal) => meal.entryDate.compareTo(cutoffDateStr) >= 0).toList();
  }

  /// Counts how many meals would be deleted if retention is reduced to [newRetentionMonths]
  static int countMealsToDelete(List<Meal> meals, DateTime today, int newRetentionMonths) {
    final cutoffDateStr = DateHelpers.toLocalDayString(getCutoffDate(today, newRetentionMonths));
    return meals.where((meal) => meal.entryDate.compareTo(cutoffDateStr) < 0).length;
  }
}

