class ApiRoutes {
  static const String getScanQuota = 'getScanQuota';
  static const String analyzeMeal = 'analyzeMeal';
  static const String onUserDeleted = 'onUserDeleted';
}

class AnalyzeMealRequest {
  final String imageBase64;
  final String mealType;

  const AnalyzeMealRequest({
    required this.imageBase64,
    required this.mealType,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageBase64': imageBase64,
      'mealType': mealType,
    };
  }
}

