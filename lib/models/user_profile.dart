import 'package:flutter/material.dart';

class UserProfile {
  final int? id;
  final UserLevel level;
  final int initialMaxReps;
  final DateTime startDate;
  final int chadLevel;
  final bool reminderEnabled;
  final String? reminderTime;
  final List<bool>? workoutDays; // 월~일 (7개 요소)

  UserProfile({
    this.id,
    required this.level,
    required this.initialMaxReps,
    required this.startDate,
    this.chadLevel = 0,
    this.reminderEnabled = false,
    this.reminderTime,
    this.workoutDays,
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
      'workout_days': workoutDays?.join(','), // 1,0,1,0,1,0,0 형태로 저장
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
      workoutDays: _parseWorkoutDays(map['workout_days'] as String?),
    );
  }

  static List<bool>? _parseWorkoutDays(String? workoutDaysStr) {
    if (workoutDaysStr == null || workoutDaysStr.isEmpty) return null;
    try {
      return workoutDaysStr.split(',').map((e) => e.trim() == 'true').toList();
    } catch (e) {
      return null;
    }
  }

  UserProfile copyWith({
    int? id,
    UserLevel? level,
    int? initialMaxReps,
    DateTime? startDate,
    int? chadLevel,
    bool? reminderEnabled,
    String? reminderTime,
    TimeOfDay? reminderTimeOfDay,
    List<bool>? workoutDays,
  }) {
    return UserProfile(
      id: id ?? this.id,
      level: level ?? this.level,
      initialMaxReps: initialMaxReps ?? this.initialMaxReps,
      startDate: startDate ?? this.startDate,
      chadLevel: chadLevel ?? this.chadLevel,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTimeOfDay != null 
        ? '${reminderTimeOfDay.hour.toString().padLeft(2, '0')}:${reminderTimeOfDay.minute.toString().padLeft(2, '0')}'
        : (reminderTime ?? this.reminderTime),
      workoutDays: workoutDays ?? this.workoutDays,
    );
  }

  /// reminderTime 문자열을 TimeOfDay로 변환
  TimeOfDay? get reminderTimeOfDay {
    if (reminderTime == null) return null;
    try {
      final parts = reminderTime!.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      debugPrint('reminderTime 파싱 오류: $e');
    }
    return null;
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

  String getDescription(BuildContext context) {
    final isKorean = Localizations.localeOf(context).languageCode == 'ko';
    switch (this) {
      case UserLevel.rookie:
        return isKorean ? '5개 이하 → 100개 달성' : '≤5 reps → Achieve 100';
      case UserLevel.rising:
        return isKorean ? '6-10개 → 100개 달성' : '6-10 reps → Achieve 100';
      case UserLevel.alpha:
        return isKorean ? '11-20개 → 100개 달성' : '11-20 reps → Achieve 100';
      case UserLevel.giga:
        return isKorean ? '21개 이상 → 100개+ 달성' : '21+ reps → Achieve 100+';
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
