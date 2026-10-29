class ScanQuota {
  final int limit;
  final int used;
  final int remaining;
  final DateTime resetsAt;

  const ScanQuota({
    required this.limit,
    required this.used,
    required this.remaining,
    required this.resetsAt,
  });

  factory ScanQuota.fromJson(Map<String, dynamic> json) {
    return ScanQuota(
      limit: json['limit'] as int? ?? 5,
      used: json['used'] as int? ?? 0,
      remaining: json['remaining'] as int? ?? 5,
      resetsAt: json['resetsAt'] != null
          ? DateTime.parse(json['resetsAt'] as String)
          : DateTime.now().add(const Duration(days: 1)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'limit': limit,
      'used': used,
      'remaining': remaining,
      'resetsAt': resetsAt.toIso8601String(),
    };
  }

  ScanQuota copyWith({
    int? limit,
    int? used,
    int? remaining,
    DateTime? resetsAt,
  }) {
    return ScanQuota(
      limit: limit ?? this.limit,
      used: used ?? this.used,
      remaining: remaining ?? this.remaining,
      resetsAt: resetsAt ?? this.resetsAt,
    );
  }
}

