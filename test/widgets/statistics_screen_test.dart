import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mission100_chad_pushup/screens/statistics_screen.dart';
import 'package:mission100_chad_pushup/services/workout_history_service.dart';
import 'package:mission100_chad_pushup/models/workout_history.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';

void main() {
  // FFI 초기화 (테스트 환경용)
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('StatisticsScreen Widget Tests', () {
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

    testWidgets('StatisticsScreen이 데이터 없이 렌더링되는지 테스트', (
      WidgetTester tester,
    ) async {
      // Given: 빈 데이터베이스
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const StatisticsScreen())),
      );

      // When: 위젯이 렌더링됨
      await tester.pumpAndSettle();

      // Then: 통계 화면이 오류 없이 렌더링되어야 함
      expect(find.byType(StatisticsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('운동 데이터가 있을 때 통계가 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 샘플 운동 데이터
      final sampleWorkout = WorkoutHistory(
        id: 'test_1',
        date: DateTime.now(),
        workoutTitle: '테스트 운동',
        targetReps: [10, 8, 6],
        completedReps: [10, 8, 6],
        totalReps: 24,
        completionRate: 1.0,
        level: 'beginner',
      );

      await WorkoutHistoryService.saveWorkoutHistory(sampleWorkout);

      // When: StatisticsScreen 렌더링
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const StatisticsScreen())),
      );
      await tester.pumpAndSettle();

      // Then: 통계 정보가 표시되어야 함
      expect(find.byType(StatisticsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('StatisticsScreen 스크롤 동작 테스트', (WidgetTester tester) async {
      // Given: 여러 운동 데이터
      for (int i = 0; i < 5; i++) {
        final workout = WorkoutHistory(
          id: 'test_$i',
          date: DateTime.now().subtract(Duration(days: i)),
          workoutTitle: '운동 $i',
          targetReps: [10, 8, 6],
          completedReps: [10, 8, 6],
          totalReps: 24,
          completionRate: 1.0,
          level: 'intermediate',
        );
        await WorkoutHistoryService.saveWorkoutHistory(workout);
      }

      // When: StatisticsScreen 렌더링
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const StatisticsScreen())),
      );
      await tester.pumpAndSettle();

      // Then: 스크롤 가능한 화면이어야 함
      expect(find.byType(StatisticsScreen), findsOneWidget);

      // 스크롤 동작 테스트
      await tester.drag(find.byType(StatisticsScreen), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
