import 'package:ai_food_and_macro_tracker/api/api_client.dart';
import 'package:ai_food_and_macro_tracker/api/api_routes.dart';
import 'package:ai_food_and_macro_tracker/data/models/scan_quota.dart';
import 'package:ai_food_and_macro_tracker/data/models/scan_result.dart';

abstract class ScanRepository {
  Future<ScanQuota> getQuota();
  Future<ScanResult> analyze({
    required String imageBase64,
    required String mealType,
  });
}

class ScanRepositoryImpl implements ScanRepository {
  final ApiClient apiClient;

  ScanRepositoryImpl({required this.apiClient});

  @override
  Future<ScanQuota> getQuota() async {
    return await apiClient.getScanQuota();
  }

  @override
  Future<ScanResult> analyze({
    required String imageBase64,
    required String mealType,
  }) async {
    return await apiClient.analyzeMeal(
      AnalyzeMealRequest(
        imageBase64: imageBase64,
        mealType: mealType,
      ),
    );
  }
}
