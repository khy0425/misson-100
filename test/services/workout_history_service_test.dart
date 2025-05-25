import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mission100_chad_pushup/services/workout_history_service.dart';
import 'package:mission100_chad_pushup/models/workout_history.dart';

void main() {
  // FFI 초기화 (테스트 환경용)
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('WorkoutHistoryService Tests', () {
    late Database database;

    setUp(() async {
      // 테스트용 인메모리 데이터베이스 생성
      database = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          // 운동 기록 테이블 생성
          await db.execute('''
            CREATE TABLE workout_history (
              id TEXT PRIMARY KEY,
              date TEXT NOT NULL,
              workoutTitle TEXT NOT NULL,
              targetReps TEXT NOT NULL,
              completedReps TEXT NOT NULL,
              totalReps INTEGER NOT NULL,
              completionRate REAL NOT NULL,
              level TEXT NOT NULL
            )
          ''');
        },
      );

      // 테스트 데이터베이스 설정
      WorkoutHistoryService.setTestDatabase(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('운동 기록 추가 및 조회 테스트', () async {
      // Given: 새로운 운동 기록
      final workoutHistory = WorkoutHistory(
        id: 'test_workout_1',
        date: DateTime(2024, 1, 15),
        workoutTitle: '테스트 운동',
        targetReps: [10, 8, 6, 4, 2],
        completedReps: [10, 8, 6, 4, 2],
        totalReps: 30,
        completionRate: 1.0,
        level: 'intermediate',
      );

      // When: 운동 기록 추가
      await WorkoutHistoryService.saveWorkoutHistory(workoutHistory);

      // Then: 저장된 기록을 조회할 수 있어야 함
      final allWorkouts = await WorkoutHistoryService.getAllWorkouts();
      expect(allWorkouts, isNotEmpty);
      expect(allWorkouts.length, equals(1));
      expect(allWorkouts.first.id, equals('test_workout_1'));
      expect(allWorkouts.first.totalReps, equals(30));
    });

    test('여러 운동 기록 추가 후 통계 계산 테스트', () async {
      // Given: 여러 운동 기록들
      final workouts = [
        WorkoutHistory(
          id: 'workout_1',
          date: DateTime(2024, 1, 10),
          workoutTitle: '운동 1',
          targetReps: [10, 8, 6],
          completedReps: [10, 8, 6],
          totalReps: 24,
          completionRate: 1.0,
          level: 'beginner',
        ),
        WorkoutHistory(
          id: 'workout_2',
          date: DateTime(2024, 1, 11),
          workoutTitle: '운동 2',
          targetReps: [12, 10, 8],
          completedReps: [12, 10, 6],
          totalReps: 28,
          completionRate: 0.93,
          level: 'intermediate',
        ),
        WorkoutHistory(
          id: 'workout_3',
          date: DateTime(2024, 1, 12),
          workoutTitle: '운동 3',
          targetReps: [15, 12, 10],
          completedReps: [15, 12, 10],
          totalReps: 37,
          completionRate: 1.0,
          level: 'advanced',
        ),
      ];

      // When: 모든 운동 기록 저장
      for (final workout in workouts) {
        await WorkoutHistoryService.saveWorkoutHistory(workout);
      }

      // Then: 통계가 올바르게 계산되어야 함
      final statistics = await WorkoutHistoryService.getStatistics();
      expect(statistics['totalWorkouts'], equals(3));
      expect(statistics['totalReps'], equals(89)); // 24 + 28 + 37
      expect(statistics['averageCompletion'], greaterThan(0.9));
    });

    test('날짜별 운동 기록 조회 테스트', () async {
      // Given: 특정 날짜의 운동 기록
      final targetDate = DateTime(2024, 1, 15);
      final workoutHistory = WorkoutHistory(
        id: 'daily_workout',
        date: targetDate,
        workoutTitle: '일일 운동',
        targetReps: [20, 15, 10],
        completedReps: [20, 15, 10],
        totalReps: 45,
        completionRate: 1.0,
        level: 'advanced',
      );

      // When: 운동 기록 저장
      await WorkoutHistoryService.saveWorkoutHistory(workoutHistory);

      // Then: 특정 날짜의 기록을 조회할 수 있어야 함
      final dailyWorkout = await WorkoutHistoryService.getWorkoutByDate(
        targetDate,
      );
      expect(dailyWorkout, isNotNull);
      expect(dailyWorkout!.id, equals('daily_workout'));
      expect(dailyWorkout.totalReps, equals(45));
    });

    test('운동 완료율 계산 테스트', () async {
      // Given: 완료율이 다른 운동들
      final workouts = [
        WorkoutHistory(
          id: 'perfect_workout',
          date: DateTime(2024, 1, 1),
          workoutTitle: '완벽한 운동',
          targetReps: [10, 10, 10],
          completedReps: [10, 10, 10],
          totalReps: 30,
          completionRate: 1.0,
          level: 'intermediate',
        ),
        WorkoutHistory(
          id: 'partial_workout',
          date: DateTime(2024, 1, 2),
          workoutTitle: '부분 완료 운동',
          targetReps: [10, 10, 10],
          completedReps: [10, 8, 5],
          totalReps: 23,
          completionRate: 0.77,
          level: 'intermediate',
        ),
      ];

      // When: 운동 기록들 저장
      for (final workout in workouts) {
        await WorkoutHistoryService.saveWorkoutHistory(workout);
      }

      // Then: 평균 완료율이 올바르게 계산되어야 함
      final statistics = await WorkoutHistoryService.getStatistics();
      final avgCompletionRate = statistics['averageCompletion'] as double;
      expect(avgCompletionRate, greaterThan(0.8));
      expect(avgCompletionRate, lessThan(1.0));
    });
  });
}
