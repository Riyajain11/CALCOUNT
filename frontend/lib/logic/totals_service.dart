import '../core/date_helpers.dart';
import '../data/models/daily_total.dart';
import '../data/models/meal.dart';

class TotalsService {
  /// Computes daily total for a specific date from a list of meals
  static DailyTotal computeDayTotal(String dateStr, List<Meal> meals) {
    final dayMeals = meals.where((m) => m.entryDate == dateStr).toList();
    double totalKcal = 0.0;
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;
    int entryCount = 0;

    for (final meal in dayMeals) {
      for (final item in meal.items) {
        totalKcal += item.kcal;
        totalProtein += item.proteinG;
        totalCarbs += item.carbsG;
        totalFat += item.fatG;
        entryCount++;
      }
    }

    return DailyTotal(
      date: dateStr,
      kcal: totalKcal,
      proteinG: totalProtein,
      carbsG: totalCarbs,
      fatG: totalFat,
      entryCount: entryCount,
    );
  }

  /// Generates a list of DailyTotal objects across a date range [fromDate, toDate]
  /// Missing days are filled with zero.
  static List<DailyTotal> computeRangeTotals({
    required DateTime fromDate,
    required DateTime toDate,
    required List<Meal> allMeals,
  }) {
    final List<DailyTotal> result = [];
    DateTime current = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final end = DateTime(toDate.year, toDate.month, toDate.day);

    while (!current.isAfter(end)) {
      final dateStr = DateHelpers.toLocalDayString(current);
      result.add(computeDayTotal(dateStr, allMeals));
      current = current.add(const Duration(days: 1));
    }

    return result;
  }
}

