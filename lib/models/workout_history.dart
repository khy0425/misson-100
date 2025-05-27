class WorkoutHistory {
  final String id;
  final DateTime date;
  final String workoutTitle;
  final List<int> targetReps;
  final List<int> completedReps;
  final int totalReps;
  final double completionRate;
  final String level;
  final Duration duration;
  final String pushupType;

  WorkoutHistory({
    required this.id,
    required this.date,
    required this.workoutTitle,
    required this.targetReps,
    required this.completedReps,
    required this.totalReps,
    required this.completionRate,
    required this.level,
    this.duration = const Duration(minutes: 10), // 기본값 설정
    this.pushupType = 'Push-up', // 기본값 설정
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
      'duration': duration.inMinutes,
      'pushupType': pushupType,
    };
  }

  factory WorkoutHistory.fromMap(Map<String, dynamic> map) {
    return WorkoutHistory(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      workoutTitle: map['workoutTitle'] as String,
      targetReps: (map['targetReps'] as String)
          .split(',')
          .map<int>((String e) => int.parse(e))
          .toList(),
      completedReps: (map['completedReps'] as String)
          .split(',')
          .map<int>((String e) => int.parse(e))
          .toList(),
      totalReps: map['totalReps'] as int,
      completionRate: map['completionRate'] as double,
      level: map['level'] as String,
      duration: Duration(minutes: map['duration'] as int? ?? 10),
      pushupType: map['pushupType'] as String? ?? 'Push-up',
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
