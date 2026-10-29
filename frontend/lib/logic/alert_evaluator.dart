enum CalorieAlertLevel {
  normal,
  warning,
  over,
}

class AlertEvaluation {
  final CalorieAlertLevel level;
  final String? bannerMessage;
  final double percentage;

  const AlertEvaluation({
    required this.level,
    this.bannerMessage,
    required this.percentage,
  });
}

class AlertEvaluator {
  static AlertEvaluation evaluate({
    required double eatenKcal,
    required int targetKcal,
    double? fatEatenG,
    int? fatTargetG,
  }) {
    if (targetKcal <= 0) {
      return const AlertEvaluation(
        level: CalorieAlertLevel.normal,
        bannerMessage: null,
        percentage: 0,
      );
    }

    final ratio = eatenKcal / targetKcal;
    final percentage = (ratio * 100).round();

    // Specific highlight if fat is already high as shown in mockup:
    // "Fat is at 83%. Keep dinner light: dal, roti and a salad."
    if (fatEatenG != null && fatTargetG != null && fatTargetG > 0) {
      final fatPercent = ((fatEatenG / fatTargetG) * 100).round();
      if (fatPercent >= 80 && fatPercent <= 100 && eatenKcal <= targetKcal) {
        return AlertEvaluation(
          level: CalorieAlertLevel.warning,
          bannerMessage:
              'Fat is at $fatPercent%. Keep dinner light: dal, roti and a salad.',
          percentage: ratio * 100,
        );
      }
    }

    if (eatenKcal > targetKcal) {
      final overKcal = (eatenKcal - targetKcal).round();
      return AlertEvaluation(
        level: CalorieAlertLevel.over,
        bannerMessage: 'You are $overKcal kcal over today\'s target.',
        percentage: ratio * 100,
      );
    } else if (ratio >= 0.80) {
      return AlertEvaluation(
        level: CalorieAlertLevel.warning,
        bannerMessage:
            'You have used $percentage% of today\'s calories. Keep the next meal light.',
        percentage: ratio * 100,
      );
    } else {
      return AlertEvaluation(
        level: CalorieAlertLevel.normal,
        bannerMessage: null,
        percentage: ratio * 100,
      );
    }
  }
}

