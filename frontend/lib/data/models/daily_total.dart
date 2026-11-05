class DailyTotal {
  final String date; // YYYY-MM-DD
  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final int entryCount;

  const DailyTotal({
    required this.date,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.entryCount,
  });

  factory DailyTotal.zero(String date) {
    return DailyTotal(
      date: date,
      kcal: 0.0,
      proteinG: 0.0,
      carbsG: 0.0,
      fatG: 0.0,
      entryCount: 0,
    );
  }

  DailyTotal copyWith({
    String? date,
    double? kcal,
    double? proteinG,
    double? carbsG,
    double? fatG,
    int? entryCount,
  }) {
    return DailyTotal(
      date: date ?? this.date,
      kcal: kcal ?? this.kcal,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      entryCount: entryCount ?? this.entryCount,
    );
  }
}

