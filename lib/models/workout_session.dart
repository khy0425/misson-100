class WorkoutSession {
  final int? id;
  final DateTime date;
  final int week;
  final int day; // 1, 2, 3 (주 3회)
  final List<int> targetReps; // 세트별 목표 횟수
  final List<int> completedReps; // 세트별 실제 완료 횟수
  final bool isCompleted;
  final int totalReps;
  final Duration totalTime;

  WorkoutSession({
    this.id,
    required this.date,
    required this.week,
    required this.day,
    required this.targetReps,
    this.completedReps = const [],
    this.isCompleted = false,
    this.totalReps = 0,
    this.totalTime = Duration.zero,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'week': week,
      'day': day,
      'target_reps': targetReps.join(','),
      'completed_reps': completedReps.join(','),
      'is_completed': isCompleted ? 1 : 0,
      'total_reps': totalReps,
      'total_time': totalTime.inSeconds,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'],
      date: DateTime.parse(map['date']),
      week: map['week'],
      day: map['day'],
      targetReps: map['target_reps'].toString().isEmpty
          ? []
          : map['target_reps']
                .toString()
                .split(',')
                .map<int>((e) => int.parse(e.trim()))
                .toList(),
      completedReps: map['completed_reps'].toString().isEmpty
          ? []
          : map['completed_reps']
                .toString()
                .split(',')
                .map<int>((e) => int.parse(e.trim()))
                .toList(),
      isCompleted: map['is_completed'] == 1,
      totalReps: map['total_reps'] ?? 0,
      totalTime: Duration(seconds: map['total_time'] ?? 0),
    );
  }

  WorkoutSession copyWith({
    int? id,
    DateTime? date,
    int? week,
    int? day,
    List<int>? targetReps,
    List<int>? completedReps,
    bool? isCompleted,
    int? totalReps,
    Duration? totalTime,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      date: date ?? this.date,
      week: week ?? this.week,
      day: day ?? this.day,
      targetReps: targetReps ?? this.targetReps,
      completedReps: completedReps ?? this.completedReps,
      isCompleted: isCompleted ?? this.isCompleted,
      totalReps: totalReps ?? this.totalReps,
      totalTime: totalTime ?? this.totalTime,
    );
  }

  // 완료율 계산
  double get completionRate {
    if (targetReps.isEmpty || completedReps.isEmpty) return 0.0;

    int totalTarget = targetReps.reduce((a, b) => a + b);
    int totalCompleted = completedReps.reduce((a, b) => a + b);

    return totalTarget > 0
        ? (totalCompleted / totalTarget).clamp(0.0, 1.0)
        : 0.0;
  }

  // 세트 완료 개수
  int get completedSets {
    return completedReps.length;
  }

  // 총 세트 개수
  int get totalSets {
    return targetReps.length;
  }

  // 운동 키 (주-일 조합)
  String get workoutKey {
    return 'W${week}D$day';
  }
}
