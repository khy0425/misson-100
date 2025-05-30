class UserProfile {
  final int? id;
  final UserLevel level;
  final int initialMaxReps;
  final DateTime startDate;
  final int chadLevel;
  final bool reminderEnabled;
  final String? reminderTime;

  UserProfile({
    this.id,
    required this.level,
    required this.initialMaxReps,
    required this.startDate,
    this.chadLevel = 0,
    this.reminderEnabled = false,
    this.reminderTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'level': level.toString(),
      'initial_max_reps': initialMaxReps,
      'start_date': startDate.toIso8601String(),
      'chad_level': chadLevel,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_time': reminderTime,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      level: UserLevel.values.firstWhere(
        (e) => e.toString() == map['level'] as String,
        orElse: () => UserLevel.rookie,
      ),
      initialMaxReps: map['initial_max_reps'] as int,
      startDate: DateTime.parse(map['start_date'] as String),
      chadLevel: map['chad_level'] as int? ?? 0,
      reminderEnabled: (map['reminder_enabled'] as int) == 1,
      reminderTime: map['reminder_time'] as String?,
    );
  }

  UserProfile copyWith({
    int? id,
    UserLevel? level,
    int? initialMaxReps,
    DateTime? startDate,
    int? chadLevel,
    bool? reminderEnabled,
    String? reminderTime,
  }) {
    return UserProfile(
      id: id ?? this.id,
      level: level ?? this.level,
      initialMaxReps: initialMaxReps ?? this.initialMaxReps,
      startDate: startDate ?? this.startDate,
      chadLevel: chadLevel ?? this.chadLevel,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

enum UserLevel {
  rookie, // 초급 (5개 이하)
  rising, // 중급 (6-10개)
  alpha, // 고급 (11-20개)
  giga, // 마스터 (21개 이상)
}

extension UserLevelExtension on UserLevel {
  String get displayName {
    switch (this) {
      case UserLevel.rookie:
        return 'Rookie Chad';
      case UserLevel.rising:
        return 'Rising Chad';
      case UserLevel.alpha:
        return 'Alpha Chad';
      case UserLevel.giga:
        return 'Giga Chad';
    }
  }

  String get description {
    switch (this) {
      case UserLevel.rookie:
        return '5개 이하 → 100개 달성';
      case UserLevel.rising:
        return '6-10개 → 100개 달성';
      case UserLevel.alpha:
        return '11-20개 → 100개 달성';
      case UserLevel.giga:
        return '21개 이상 → 100개+ 달성';
    }
  }

  /// UserLevel을 int 값으로 변환 (동기부여 메시지 레벨용)
  int get levelValue {
    switch (this) {
      case UserLevel.rookie:
        return 1;
      case UserLevel.rising:
        return 25;
      case UserLevel.alpha:
        return 50;
      case UserLevel.giga:
        return 75;
    }
  }

  static UserLevel fromMaxReps(int maxReps) {
    if (maxReps <= 5) return UserLevel.rookie;
    if (maxReps <= 10) return UserLevel.rising;
    if (maxReps <= 20) return UserLevel.alpha;
    return UserLevel.giga;
  }
}
