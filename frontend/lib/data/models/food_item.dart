import 'package:uuid/uuid.dart';

class FoodItem {
  final String id;
  final String name;
  final String? portionLabel;
  final double grams;
  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double? aiKcal;

  FoodItem({
    String? id,
    required this.name,
    this.portionLabel,
    required this.grams,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.aiKcal,
  }) : id = id ?? const Uuid().v4();

  FoodItem copyWith({
    String? id,
    String? name,
    String? portionLabel,
    double? grams,
    double? kcal,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? aiKcal,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      portionLabel: portionLabel ?? this.portionLabel,
      grams: grams ?? this.grams,
      kcal: kcal ?? this.kcal,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      aiKcal: aiKcal ?? this.aiKcal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (portionLabel != null) 'portionLabel': portionLabel,
      'grams': grams,
      'kcal': kcal,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      if (aiKcal != null) 'aiKcal': aiKcal,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String?,
      name: json['name'] as String,
      portionLabel: json['portionLabel'] as String?,
      grams: (json['grams'] as num).toDouble(),
      kcal: (json['kcal'] as num).toDouble(),
      proteinG: (json['proteinG'] ?? json['protein_g'] as num).toDouble(),
      carbsG: (json['carbsG'] ?? json['carbs_g'] as num).toDouble(),
      fatG: (json['fatG'] ?? json['fat_g'] as num).toDouble(),
      aiKcal: json['aiKcal'] != null ? (json['aiKcal'] as num).toDouble() : null,
    );
  }
}

