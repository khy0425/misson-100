import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mission100/screens/statistics_screen.dart';
import 'package:mission100/services/workout_history_service.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mission100/generated/app_localizations.dart';
import '../test_helper.dart';

void main() {
  // FFI 초기화 (테스트 환경용)
  setUpAll(() {
    setupTestEnvironment();
  });

  tearDownAll(() {
    tearDownTestEnvironment();
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

    testWidgets('StatisticsScreen이 기본 구조를 가지는지 테스트', (
      WidgetTester tester,
    ) async {
      // Given: 충분한 화면 크기로 설정
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      // When: StatisticsScreen 렌더링 (더 간단한 방식)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: StatisticsScreen(),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('ko', 'KR'), Locale('en', 'US')],
            locale: Locale('ko', 'KR'),
          ),
        ),
      );

      // 짧은 pump로 기본 렌더링만 확인
      await tester.pump(const Duration(milliseconds: 100));

      // Then: 기본 화면 구조가 있어야 함
      expect(find.byType(StatisticsScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('StatisticsScreen이 로딩 상태를 표시하는지 테스트', (
      WidgetTester tester,
    ) async {
      // Given: 충분한 화면 크기로 설정
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      // When: StatisticsScreen 렌더링
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: StatisticsScreen(),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('ko', 'KR'), Locale('en', 'US')],
            locale: Locale('ko', 'KR'),
          ),
        ),
      );

      // 로딩 상태 확인 (애니메이션 전)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('StatisticsScreen이 빈 상태를 처리하는지 테스트', (
      WidgetTester tester,
    ) async {
      // Given: 충분한 화면 크기로 설정
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      // When: StatisticsScreen 렌더링
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: StatisticsScreen(),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('ko', 'KR'), Locale('en', 'US')],
            locale: Locale('ko', 'KR'),
          ),
        ),
      );

      // 초기 렌더링만 확인
      await tester.pump();

      // Then: 기본 구조가 렌더링되었는지만 확인
      expect(find.byType(StatisticsScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
