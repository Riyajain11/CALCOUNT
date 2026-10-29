import 'package:ai_food_and_macro_tracker/data/models/food_item.dart';
import 'package:ai_food_and_macro_tracker/data/models/user_profile.dart';
import 'package:ai_food_and_macro_tracker/logic/alert_evaluator.dart';
import 'package:ai_food_and_macro_tracker/logic/portion_scaler.dart';
import 'package:ai_food_and_macro_tracker/logic/retention_cleaner.dart';
import 'package:ai_food_and_macro_tracker/logic/target_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TargetCalculator Tests', () {
    test('TC-01: Male 21, 175 cm, 70 kg, moderate, maintain', () {
      const profile = UserProfile(
        name: 'Alex',
        goal: 'maintain',
        age: 21,
        sex: 'male',
        heightCm: 175.0,
        weightKg: 70.0,
        activity: 'moderate',
      );

      final targets = TargetCalculator.calculateTargets(profile);

      // BMR = 10*70 + 6.25*175 - 5*21 + 5 = 700 + 1093.75 - 105 + 5 = 1693.75
      // Calories = round(1693.75 * 1.55 * 1.0) = 2625
      // Protein = round(1.8 * 70) = 126
      // Fat = round(0.25 * 2625 / 9) = 73
      // Carbs = round((2625 - 4*126 - 9*73) / 4) = 366
      expect(targets.calories, equals(2625));
      expect(targets.proteinG, equals(126));
      expect(targets.fatG, equals(73));
      expect(targets.carbsG, equals(366));
    });
  });

  group('PortionScaler Tests', () {
    test('TC-05: Change an item from 180 g to 90 g halves every value', () {
      final item = FoodItem(
        name: 'Dal',
        grams: 180.0,
        kcal: 200.0,
        proteinG: 12.0,
        carbsG: 28.0,
        fatG: 4.0,
      );

      final scaled = PortionScaler.scaleItem(item, 90.0);

      expect(scaled.grams, equals(90.0));
      expect(scaled.kcal, equals(100.0));
      expect(scaled.proteinG, equals(6.0));
      expect(scaled.carbsG, equals(14.0));
      expect(scaled.fatG, equals(2.0));
    });
  });

  group('AlertEvaluator Tests', () {
    test('TC-10: Target 2,000, eaten 1,600 triggers Warning state at 80%', () {
      final eval = AlertEvaluator.evaluate(
        eatenKcal: 1600.0,
        targetKcal: 2000,
      );

      expect(eval.level, equals(CalorieAlertLevel.warning));
      expect(eval.bannerMessage, contains('80%'));
    });

    test('TC-11: Push total to 2,001 triggers Over-limit state', () {
      final eval = AlertEvaluator.evaluate(
        eatenKcal: 2001.0,
        targetKcal: 2000,
      );

      expect(eval.level, equals(CalorieAlertLevel.over));
      expect(eval.bannerMessage, contains('1 kcal over'));
    });

    test('Eaten under 80% is Normal level', () {
      final eval = AlertEvaluator.evaluate(
        eatenKcal: 1400.0,
        targetKcal: 2000,
      );

      expect(eval.level, equals(CalorieAlertLevel.normal));
      expect(eval.bannerMessage, isNull);
    });
  });

  group('RetentionCleaner Tests', () {
    test('TC-14: Retention cutoff calculation', () {
      final today = DateTime(2026, 10, 28);
      final cutoff1m = RetentionCleaner.getCutoffDate(today, 1);
      final cutoff3m = RetentionCleaner.getCutoffDate(today, 3);

      expect(cutoff1m, equals(DateTime(2026, 9, 28)));
      expect(cutoff3m, equals(DateTime(2026, 7, 28)));
    });
  });
}

