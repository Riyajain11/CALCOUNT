import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/error_types.dart';
import '../data/models/food_item.dart';
import '../data/models/scan_quota.dart';
import '../data/models/scan_result.dart';
import 'api_routes.dart';

abstract class ApiClient {
  Future<ScanQuota> getScanQuota();
  Future<ScanResult> analyzeMeal(AnalyzeMealRequest request);
  Future<void> onUserDeleted(String uid);
}

/// Real HTTP API Client that sends data to the Firebase Cloud Functions backend
/// or custom REST backend server.
class HttpApiClient implements ApiClient {
  final String baseUrl;
  final Future<String?> Function()? getAuthToken;
  final http.Client _client;

  HttpApiClient({
    required this.baseUrl,
    this.getAuthToken,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (getAuthToken != null) {
      final token = await getAuthToken!();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  @override
  Future<ScanQuota> getScanQuota() async {
    final uri = Uri.parse('$baseUrl/${ApiRoutes.getScanQuota}');
    try {
      final response = await _client
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ScanQuota.fromJson(data);
      } else if (response.statusCode == 401) {
        throw ScanException(
          code: ScanErrorCode.unauthenticated,
          message: 'User authentication required',
        );
      } else {
        throw ScanException(
          code: ScanErrorCode.network,
          message: 'Failed to fetch scan quota (${response.statusCode})',
        );
      }
    } on SocketException {
      throw ScanException(
        code: ScanErrorCode.network,
        message: 'No internet connection',
      );
    } on TimeoutException {
      throw ScanException(
        code: ScanErrorCode.network,
        message: 'Request timed out',
      );
    }
  }

  @override
  Future<ScanResult> analyzeMeal(AnalyzeMealRequest request) async {
    final uri = Uri.parse('$baseUrl/${ApiRoutes.analyzeMeal}');
    try {
      final payload = jsonEncode(request.toJson());
      final response = await _client
          .post(uri, headers: await _headers(), body: payload)
          .timeout(const Duration(seconds: 25)); // 25s client timeout as in spec

      final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};

      if (response.statusCode == 200) {
        return ScanResult.fromJson(body);
      }

      final errorCodeStr = body['error']?['code'] as String? ?? '';

      switch (response.statusCode) {
        case 401:
          throw ScanException(
            code: ScanErrorCode.unauthenticated,
            message: 'Signed out or session expired',
          );
        case 400:
          throw ScanException(
            code: ScanErrorCode.badImage,
            message: 'Image was missing, invalid or too large (>1 MB)',
          );
        case 429:
          throw ScanException(
            code: ScanErrorCode.limitReached,
            message: 'Daily scan limit reached. Resets at midnight IST.',
          );
        case 412:
          if (errorCodeStr.contains('NO_FOOD')) {
            throw ScanException(
              code: ScanErrorCode.noFoodDetected,
              message: 'No food items detected in photo',
            );
          }
          break;
        case 503:
        case 504:
          throw ScanException(
            code: ScanErrorCode.aiUnavailable,
            message: 'AI provider timeout or unavailable',
          );
      }

      throw ScanException(
        code: ScanException.parseCode(errorCodeStr),
        message: body['error']?['message'] as String? ?? 'Analysis failed',
      );
    } on SocketException {
      throw ScanException(
        code: ScanErrorCode.network,
        message: 'No network connection. Please check your internet.',
      );
    } on TimeoutException {
      throw ScanException(
        code: ScanErrorCode.network,
        message: 'Server took too long to respond. Please retry.',
      );
    }
  }

  @override
  Future<void> onUserDeleted(String uid) async {
    final uri = Uri.parse('$baseUrl/${ApiRoutes.onUserDeleted}');
    try {
      await _client.post(
        uri,
        headers: await _headers(),
        body: jsonEncode({'uid': uid}),
      );
    } catch (_) {}
  }
}

/// High-fidelity mock API client for frontend development and offline testing.
/// Matches the exact sample screens and requirements from the V1 SDD and mockup PDFs.
class MockApiClient implements ApiClient {
  final int _dailyLimit = 7;
  int _usedScans = 0;
  bool simulateNetworkError = false;
  bool simulateNoFood = false;

  @override
  Future<ScanQuota> getScanQuota() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final remaining = (_dailyLimit - _usedScans).clamp(0, _dailyLimit);
    final now = DateTime.now();
    final resetsAt = DateTime(now.year, now.month, now.day + 1);

    return ScanQuota(
      limit: _dailyLimit,
      used: _usedScans,
      remaining: remaining,
      resetsAt: resetsAt,
    );
  }

  @override
  Future<ScanResult> analyzeMeal(AnalyzeMealRequest request) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    if (simulateNetworkError) {
      throw ScanException(
        code: ScanErrorCode.network,
        message: 'No internet connection',
      );
    }

    if (simulateNoFood) {
      throw ScanException(
        code: ScanErrorCode.noFoodDetected,
        message: 'No food items detected in the image',
      );
    }

    if (_usedScans >= _dailyLimit) {
      throw ScanException(
        code: ScanErrorCode.limitReached,
        message: 'Daily scan limit reached. Your quota resets at midnight IST.',
      );
    }

    _usedScans++;
    final remaining = (_dailyLimit - _usedScans).clamp(0, _dailyLimit);

    return ScanResult(
      scansRemaining: remaining,
      confidence: 'medium',
      provider: 'gemini',
      promptVersion: 'p1',
      items: [
        FoodItem(
          name: 'Roti x2',
          portionLabel: '2 roti',
          grams: 80.0,
          kcal: 240.0,
          proteinG: 6.0,
          carbsG: 48.0,
          fatG: 2.0,
          aiKcal: 240.0,
        ),
        FoodItem(
          name: 'Dal',
          portionLabel: '1 katori, 150 g',
          grams: 150.0,
          kcal: 180.0,
          proteinG: 11.0,
          carbsG: 26.0,
          fatG: 4.0,
          aiKcal: 180.0,
        ),
        FoodItem(
          name: 'Sabzi',
          portionLabel: '120 g',
          grams: 120.0,
          kcal: 150.0,
          proteinG: 5.0,
          carbsG: 14.0,
          fatG: 10.0,
          aiKcal: 150.0,
        ),
      ],
    );
  }

  @override
  Future<void> onUserDeleted(String uid) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _usedScans = 0;
  }

  void resetQuota() {
    _usedScans = 0;
  }
}
