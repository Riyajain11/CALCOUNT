import 'dart:math';
import '../data/models/targets.dart';
import '../data/models/user_profile.dart';

class TargetCalculator {
  /// Basal Metabolic Rate using Mifflin-St Jeor formula
  static double calculateBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required String sex,
  }) {
    final s = sex.toLowerCase() == 'male' ? 5.0 : -161.0;
    return (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age) + s;
  }

  /// Activity factor
  static double activityFactor(String activity) {
    switch (activity.toLowerCase()) {
      case 'sedentary':
        return 1.2;
      case 'light':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'active':
        return 1.725;
      case 'very_active':
        return 1.9;
      default:
        return 1.2;
    }
  }

  /// Goal factor
  static double goalFactor(String goal) {
    switch (goal.toLowerCase()) {
      case 'cut':
        return 0.85;
      case 'maintain':
        return 1.0;
      case 'bulk':
        return 1.10;
      default:
        return 1.0;
    }
  }

  /// Calculate calorie and macro targets from user profile
  static Targets calculateTargets(UserProfile profile) {
    final bmr = calculateBmr(
      weightKg: profile.weightKg,
      heightCm: profile.heightCm,
      age: profile.age,
      sex: profile.sex,
    );

    final aFactor = activityFactor(profile.activity);
    final gFactor = goalFactor(profile.goal);

    double rawCalories = bmr * aFactor * gFactor;

    // Safety floor: never below 1200 kcal (female) or 1500 kcal (male)
    final minCalories = profile.sex.toLowerCase() == 'male' ? 1500.0 : 1200.0;
    rawCalories = max(rawCalories, minCalories);

    final calories = rawCalories.round();
    final proteinG = (1.8 * profile.weightKg).round();
    final fatG = (0.25 * calories / 9.0).round();
    final remainingCaloriesForCarbs = calories - (4 * proteinG) - (9 * fatG);
    final carbsG = max(0, (remainingCaloriesForCarbs / 4.0).round());

    return Targets(
      id: 1,
      calories: calories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      isCustom: false,
    );
  }

  /// Checks if custom macro sum (4P + 4C + 9F) differs from calorie target by > 10%
  static bool differsFromMacroCalories(int calories, int p, int c, int f) {
    final macroCalories = (4 * p) + (4 * c) + (9 * f);
    final diff = (macroCalories - calories).abs();
    return diff > (calories * 0.10);
  }
}

