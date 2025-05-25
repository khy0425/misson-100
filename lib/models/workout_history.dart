class WorkoutHistory {
  final String id;
  final DateTime date;
  final String workoutTitle;
  final List<int> targetReps;
  final List<int> completedReps;
  final int totalReps;
  final double completionRate;
  final String level;

  WorkoutHistory({
    required this.id,
    required this.date,
    required this.workoutTitle,
    required this.targetReps,
    required this.completedReps,
    required this.totalReps,
    required this.completionRate,
    required this.level,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'workoutTitle': workoutTitle,
      'targetReps': targetReps.join(','),
      'completedReps': completedReps.join(','),
      'totalReps': totalReps,
      'completionRate': completionRate,
      'level': level,
    };
  }

  factory WorkoutHistory.fromMap(Map<String, dynamic> map) {
    return WorkoutHistory(
      id: map['id'],
      date: DateTime.parse(map['date']),
      workoutTitle: map['workoutTitle'],
      targetReps: map['targetReps']
          .split(',')
          .map<int>((e) => int.parse(e))
          .toList(),
      completedReps: map['completedReps']
          .split(',')
          .map<int>((e) => int.parse(e))
          .toList(),
      totalReps: map['totalReps'],
      completionRate: map['completionRate'],
      level: map['level'],
    );
  }

  // 성취도에 따른 색상 반환
  String getPerformanceLevel() {
    if (completionRate >= 1.0) return 'perfect';
    if (completionRate >= 0.8) return 'good';
    if (completionRate >= 0.5) return 'okay';
    return 'poor';
  }
}
