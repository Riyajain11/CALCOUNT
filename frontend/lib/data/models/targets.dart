class Targets {
  final int id;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final bool isCustom;

  const Targets({
    this.id = 1,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.isCustom = false,
  });

  Targets copyWith({
    int? id,
    int? calories,
    int? proteinG,
    int? carbsG,
    int? fatG,
    bool? isCustom,
  }) {
    return Targets(
      id: id ?? this.id,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'calories': calories,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
      'is_custom': isCustom ? 1 : 0,
    };
  }

  factory Targets.fromMap(Map<String, dynamic> map) {
    return Targets(
      id: map['id'] as int? ?? 1,
      calories: map['calories'] as int,
      proteinG: map['protein_g'] as int,
      carbsG: map['carbs_g'] as int,
      fatG: map['fat_g'] as int,
      isCustom: (map['is_custom'] as int? ?? 0) == 1,
    );
  }
}

