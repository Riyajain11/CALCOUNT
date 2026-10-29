import 'food_item.dart';

class ScanResult {
  final List<FoodItem> items;
  final int scansRemaining;
  final String confidence; // 'low', 'medium', 'high'
  final String provider; // 'gemini', 'xai', etc.
  final String promptVersion; // 'p1'

  const ScanResult({
    required this.items,
    required this.scansRemaining,
    required this.confidence,
    required this.provider,
    required this.promptVersion,
  });

  double get totalKcal => items.fold(0.0, (sum, i) => sum + i.kcal);
  double get totalProtein => items.fold(0.0, (sum, i) => sum + i.proteinG);
  double get totalCarbs => items.fold(0.0, (sum, i) => sum + i.carbsG);
  double get totalFat => items.fold(0.0, (sum, i) => sum + i.fatG);

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return ScanResult(
      items: rawItems
          .map((item) => FoodItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      scansRemaining: json['scansRemaining'] as int? ?? 0,
      confidence: json['confidence'] as String? ?? 'medium',
      provider: json['provider'] as String? ?? 'gemini',
      promptVersion: json['promptVersion'] as String? ?? 'p1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scansRemaining': scansRemaining,
      'confidence': confidence,
      'provider': provider,
      'promptVersion': promptVersion,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

