import 'package:uuid/uuid.dart';
import 'food_item.dart';

class Meal {
  final String id;
  final String entryDate; // YYYY-MM-DD
  final DateTime loggedAt;
  final String mealType; // 'breakfast', 'lunch', 'snack', 'dinner'
  final String source; // 'ai' or 'manual'
  final String? provider;
  final String? promptVersion;
  final String? confidence;
  final List<FoodItem> items;

  Meal({
    String? id,
    required this.entryDate,
    required this.loggedAt,
    required this.mealType,
    required this.source,
    this.provider,
    this.promptVersion,
    this.confidence,
    required this.items,
  }) : id = id ?? const Uuid().v4();

  double get totalKcal => items.fold(0.0, (sum, i) => sum + i.kcal);
  double get totalProtein => items.fold(0.0, (sum, i) => sum + i.proteinG);
  double get totalCarbs => items.fold(0.0, (sum, i) => sum + i.carbsG);
  double get totalFat => items.fold(0.0, (sum, i) => sum + i.fatG);

  String get summaryTitle {
    if (items.isEmpty) return 'Meal';
    if (items.length == 1) return items.first.name;
    return items.map((i) => i.name).join(' + ');
  }

  Meal copyWith({
    String? id,
    String? entryDate,
    DateTime? loggedAt,
    String? mealType,
    String? source,
    String? provider,
    String? promptVersion,
    String? confidence,
    List<FoodItem>? items,
  }) {
    return Meal(
      id: id ?? this.id,
      entryDate: entryDate ?? this.entryDate,
      loggedAt: loggedAt ?? this.loggedAt,
      mealType: mealType ?? this.mealType,
      source: source ?? this.source,
      provider: provider ?? this.provider,
      promptVersion: promptVersion ?? this.promptVersion,
      confidence: confidence ?? this.confidence,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entryDate': entryDate,
      'loggedAt': loggedAt.toIso8601String(),
      'mealType': mealType,
      'source': source,
      'provider': provider,
      'promptVersion': promptVersion,
      'confidence': confidence,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String?,
      entryDate: json['entryDate'] as String,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      mealType: json['mealType'] as String,
      source: json['source'] as String,
      provider: json['provider'] as String?,
      promptVersion: json['promptVersion'] as String?,
      confidence: json['confidence'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

