import '../api/api_client.dart';
import '../api/api_routes.dart';
import '../data/models/scan_result.dart';

abstract class NutritionEstimator {
  Future<ScanResult> estimate({
    required String imageBase64,
    required String mealType,
  });
}

class CloudNutritionEstimator implements NutritionEstimator {
  final ApiClient apiClient;

  CloudNutritionEstimator({required this.apiClient});

  @override
  Future<ScanResult> estimate({
    required String imageBase64,
    required String mealType,
  }) async {
    final request = AnalyzeMealRequest(
      imageBase64: imageBase64,
      mealType: mealType,
    );
    return await apiClient.analyzeMeal(request);
  }
}

