import 'package:flutter_test/flutter_test.dart';
import 'package:mission100_chad_pushup/models/workout_history.dart';

void main() {
  group('WorkoutHistory Model Tests', () {
    test('WorkoutHistory 생성 테스트', () {
      // Given: 운동 기록 데이터
      final history = WorkoutHistory(
        id: 'test1',
        date: DateTime(2024, 1, 15),
        workoutTitle: '테스트 운동',
        targetReps: [10, 8, 6, 4, 2],
        completedReps: [10, 8, 6, 4, 2],
        totalReps: 30,
        completionRate: 1.0,
        level: 'intermediate',
      );

      // Then: 객체가 올바르게 생성되어야 함
      expect(history.id, 'test1');
      expect(history.workoutTitle, '테스트 운동');
      expect(history.totalReps, 30);
      expect(history.completionRate, 1.0);
      expect(history.level, 'intermediate');
    });

    test('WorkoutHistory toMap 변환 테스트', () {
      // Given: WorkoutHistory 객체
      final history = WorkoutHistory(
        id: 'test1',
        date: DateTime(2024, 1, 15),
        workoutTitle: '테스트 운동',
        targetReps: [10, 8, 6],
        completedReps: [10, 7, 5],
        totalReps: 22,
        completionRate: 0.8,
        level: 'beginner',
      );

      // When: Map으로 변환
      final map = history.toMap();

      // Then: 올바른 Map 구조여야 함
      expect(map['id'], 'test1');
      expect(map['workoutTitle'], '테스트 운동');
      expect(map['targetReps'], '10,8,6');
      expect(map['completedReps'], '10,7,5');
      expect(map['totalReps'], 22);
      expect(map['completionRate'], 0.8);
      expect(map['level'], 'beginner');
    });

    test('WorkoutHistory fromMap 생성 테스트', () {
      // Given: Map 데이터
      final map = {
        'id': 'test2',
        'date': '2024-01-15T10:30:00.000Z',
        'workoutTitle': '고급 운동',
        'targetReps': '15,12,10,8,5',
        'completedReps': '15,12,8,6,4',
        'totalReps': 45,
        'completionRate': 0.85,
        'level': 'advanced',
      };

      // When: Map에서 WorkoutHistory 생성
      final history = WorkoutHistory.fromMap(map);

      // Then: 올바른 객체가 생성되어야 함
      expect(history.id, 'test2');
      expect(history.workoutTitle, '고급 운동');
      expect(history.targetReps, [15, 12, 10, 8, 5]);
      expect(history.completedReps, [15, 12, 8, 6, 4]);
      expect(history.totalReps, 45);
      expect(history.completionRate, 0.85);
      expect(history.level, 'advanced');
    });

    test('성취도 레벨 계산 테스트', () {
      // Given: 다양한 완성도의 운동 기록들
      final perfectHistory = WorkoutHistory(
        id: 'perfect',
        date: DateTime.now(),
        workoutTitle: '완벽한 운동',
        targetReps: [10],
        completedReps: [10],
        totalReps: 10,
        completionRate: 1.0,
        level: 'beginner',
      );

      final goodHistory = WorkoutHistory(
        id: 'good',
        date: DateTime.now(),
        workoutTitle: '좋은 운동',
        targetReps: [10],
        completedReps: [9],
        totalReps: 9,
        completionRate: 0.9,
        level: 'beginner',
      );

      final okayHistory = WorkoutHistory(
        id: 'okay',
        date: DateTime.now(),
        workoutTitle: '보통 운동',
        targetReps: [10],
        completedReps: [6],
        totalReps: 6,
        completionRate: 0.6,
        level: 'beginner',
      );

      final poorHistory = WorkoutHistory(
        id: 'poor',
        date: DateTime.now(),
        workoutTitle: '아쉬운 운동',
        targetReps: [10],
        completedReps: [3],
        totalReps: 3,
        completionRate: 0.3,
        level: 'beginner',
      );

      // Then: 성취도 레벨이 올바르게 계산되어야 함
      expect(perfectHistory.getPerformanceLevel(), 'perfect');
      expect(goodHistory.getPerformanceLevel(), 'good');
      expect(okayHistory.getPerformanceLevel(), 'okay');
      expect(poorHistory.getPerformanceLevel(), 'poor');
    });

    test('Map 변환 라운드트립 테스트', () {
      // Given: 원본 WorkoutHistory 객체
      final original = WorkoutHistory(
        id: 'roundtrip',
        date: DateTime(2024, 1, 15, 14, 30),
        workoutTitle: '라운드트립 테스트',
        targetReps: [20, 15, 10, 5],
        completedReps: [18, 15, 9, 5],
        totalReps: 47,
        completionRate: 0.94,
        level: 'intermediate',
      );

      // When: Map으로 변환 후 다시 객체로 변환
      final map = original.toMap();
      final restored = WorkoutHistory.fromMap(map);

      // Then: 원본과 동일해야 함
      expect(restored.id, original.id);
      expect(restored.workoutTitle, original.workoutTitle);
      expect(restored.targetReps, original.targetReps);
      expect(restored.completedReps, original.completedReps);
      expect(restored.totalReps, original.totalReps);
      expect(restored.completionRate, original.completionRate);
      expect(restored.level, original.level);
      // 날짜는 정밀도 차이로 인해 별도 검증
      expect(
        restored.date.millisecondsSinceEpoch,
        original.date.millisecondsSinceEpoch,
      );
    });
  });
}
