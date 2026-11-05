import '../data/models/food_item.dart';

class PortionScaler {
  /// Scales an item's nutrition proportionally when grams change from g0 to g1
  static FoodItem scaleItem(FoodItem item, double newGrams) {
    if (item.grams <= 0 || newGrams <= 0) return item;
    final ratio = newGrams / item.grams;

    return item.copyWith(
      grams: double.parse(newGrams.toStringAsFixed(1)),
      kcal: double.parse((item.kcal * ratio).toStringAsFixed(1)),
      proteinG: double.parse((item.proteinG * ratio).toStringAsFixed(1)),
      carbsG: double.parse((item.carbsG * ratio).toStringAsFixed(1)),
      fatG: double.parse((item.fatG * ratio).toStringAsFixed(1)),
    );
  }

  /// Scales all items in a list by a percentage (e.g. 100% -> 110%)
  static List<FoodItem> scaleByPercentage(
    List<FoodItem> items,
    List<FoodItem> baseItems,
    double percentage,
  ) {
    final ratio = percentage / 100.0;
    return List.generate(items.length, (index) {
      final base = baseItems[index];
      return scaleItem(base, base.grams * ratio);
    });
  }
}

