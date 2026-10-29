class UserProfile {
  final int id;
  final String name;
  final String goal; // 'cut', 'maintain', 'bulk'
  final int age; // 16 to 90
  final String sex; // 'male', 'female'
  final double heightCm; // 100 to 230
  final double weightKg; // 30 to 250
  final String activity; // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  final int retentionMonths; // 1, 3 or 6 (default 3)
  final bool remindersOn; // default true
  final List<String> reminderTimes; // ['13:30', '20:30']

  const UserProfile({
    this.id = 1,
    required this.name,
    required this.goal,
    required this.age,
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.activity,
    this.retentionMonths = 3,
    this.remindersOn = true,
    this.reminderTimes = const ['13:30', '20:30'],
  });

  UserProfile copyWith({
    int? id,
    String? name,
    String? goal,
    int? age,
    String? sex,
    double? heightCm,
    double? weightKg,
    String? activity,
    int? retentionMonths,
    bool? remindersOn,
    List<String>? reminderTimes,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activity: activity ?? this.activity,
      retentionMonths: retentionMonths ?? this.retentionMonths,
      remindersOn: remindersOn ?? this.remindersOn,
      reminderTimes: reminderTimes ?? this.reminderTimes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'goal': goal,
      'age': age,
      'sex': sex,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'activity': activity,
      'retention_months': retentionMonths,
      'reminders_on': remindersOn ? 1 : 0,
      'reminder_times': reminderTimes.join(','),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int? ?? 1,
      name: map['name'] as String,
      goal: map['goal'] as String,
      age: map['age'] as int,
      sex: map['sex'] as String,
      heightCm: (map['height_cm'] as num).toDouble(),
      weightKg: (map['weight_kg'] as num).toDouble(),
      activity: map['activity'] as String,
      retentionMonths: map['retention_months'] as int? ?? 3,
      remindersOn: (map['reminders_on'] as int? ?? 1) == 1,
      reminderTimes: (map['reminder_times'] as String?)?.split(',') ?? ['13:30', '20:30'],
    );
  }
}

