class Progress {
  final int totalWorkouts;
  final int consecutiveDays;
  final int totalPushups;
  final int currentWeek;
  final int currentDay;
  final double completionRate;
  final List<WeeklyProgress> weeklyProgress;

  Progress({
    this.totalWorkouts = 0,
    this.consecutiveDays = 0,
    this.totalPushups = 0,
    this.currentWeek = 1,
    this.currentDay = 1,
    this.completionRate = 0.0,
    this.weeklyProgress = const [],
  });

  Progress copyWith({
    int? totalWorkouts,
    int? consecutiveDays,
    int? totalPushups,
    int? currentWeek,
    int? currentDay,
    double? completionRate,
    List<WeeklyProgress>? weeklyProgress,
  }) {
    return Progress(
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      totalPushups: totalPushups ?? this.totalPushups,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      completionRate: completionRate ?? this.completionRate,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
    );
  }

  // 6주 프로그램 완료 여부
  bool get isProgramCompleted {
    return currentWeek > 6;
  }

  // 현재 주차 진행률
  double get currentWeekProgress {
    if (currentWeek > 6) return 1.0;
    return (currentDay - 1) / 3.0; // 주 3일 기준
  }

  // 전체 프로그램 진행률
  double get overallProgress {
    if (currentWeek > 6) return 1.0;
    final double weekProgress = (currentWeek - 1) / 6.0;
    final double dayProgress = (currentDay - 1) / 18.0; // 총 18일 (6주 * 3일)
    return (weekProgress + dayProgress).clamp(0.0, 1.0);
  }

  // 일평균 푸쉬업 개수
  double get averagePushupsPerWorkout {
    return totalWorkouts > 0 ? totalPushups / totalWorkouts : 0.0;
  }
}

class WeeklyProgress {
  final int week;
  final int completedDays;
  final int totalPushups;
  final double averageCompletionRate;
  final List<DayProgress> dailyProgress;

  WeeklyProgress({
    required this.week,
    this.completedDays = 0,
    this.totalPushups = 0,
    this.averageCompletionRate = 0.0,
    this.dailyProgress = const [],
  });

  WeeklyProgress copyWith({
    int? week,
    int? completedDays,
    int? totalPushups,
    double? averageCompletionRate,
    List<DayProgress>? dailyProgress,
  }) {
    return WeeklyProgress(
      week: week ?? this.week,
      completedDays: completedDays ?? this.completedDays,
      totalPushups: totalPushups ?? this.totalPushups,
      averageCompletionRate:
          averageCompletionRate ?? this.averageCompletionRate,
      dailyProgress: dailyProgress ?? this.dailyProgress,
    );
  }

  // 주차 완료 여부
  bool get isWeekCompleted {
    return completedDays >= 3;
  }

  // 주차 진행률
  double get weekCompletionRate {
    return completedDays / 3.0;
  }
}

class DayProgress {
  final int day;
  final bool isCompleted;
  final int targetReps;
  final int completedReps;
  final double completionRate;
  final DateTime? completedDate;

  DayProgress({
    required this.day,
    this.isCompleted = false,
    this.targetReps = 0,
    this.completedReps = 0,
    this.completionRate = 0.0,
    this.completedDate,
  });

  DayProgress copyWith({
    int? day,
    bool? isCompleted,
    int? targetReps,
    int? completedReps,
    double? completionRate,
    DateTime? completedDate,
  }) {
    return DayProgress(
      day: day ?? this.day,
      isCompleted: isCompleted ?? this.isCompleted,
      targetReps: targetReps ?? this.targetReps,
      completedReps: completedReps ?? this.completedReps,
      completionRate: completionRate ?? this.completionRate,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}
