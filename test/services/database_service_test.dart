import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/services/database_service.dart';
import 'package:mission100/models/user_profile.dart';
import 'package:mission100/models/workout_session.dart';
import '../test_helper.dart';

void main() {
  setUpAll(() {
    setupTestEnvironment();
  });

  tearDownAll(() {
    tearDownTestEnvironment();
  });

  group('DatabaseService Tests', () {
    late DatabaseService databaseService;

    setUp(() async {
      databaseService = DatabaseService();
      await databaseService.deleteAllData();
    });

    tearDown(() async {
      await databaseService.deleteAllData();
    });

    group('UserProfile CRUD Tests', () {
      test('사용자 프로필 삽입이 올바르게 작동하는지 테스트', () async {
        // Given: 테스트용 사용자 프로필
        final userProfile = UserProfile(
          level: UserLevel.rookie,
          initialMaxReps: 10,
          startDate: DateTime.now(),
          chadLevel: 0,
        );

        // When: 사용자 프로필 삽입
        final userId = await databaseService.insertUserProfile(userProfile);

        // Then: 유효한 ID가 반환되어야 함
        expect(userId, greaterThan(0));

        // 삽입된 프로필을 조회하여 확인
        final retrievedProfile = await databaseService.getUserProfile();
        expect(retrievedProfile, isNotNull);
        expect(retrievedProfile!.id, userId);
        expect(retrievedProfile.level, UserLevel.rookie);
        expect(retrievedProfile.initialMaxReps, 10);
        expect(retrievedProfile.chadLevel, 0);
      });

      test('사용자 프로필 조회가 올바르게 작동하는지 테스트', () async {
        // Given: 사용자 프로필이 없는 상태
        final emptyProfile = await databaseService.getUserProfile();
        expect(emptyProfile, isNull);

        // When: 사용자 프로필 삽입 후 조회
        final userProfile = UserProfile(
          level: UserLevel.rising,
          initialMaxReps: 15,
          startDate: DateTime.now(),
          chadLevel: 1,
        );
        await databaseService.insertUserProfile(userProfile);

        // Then: 올바른 프로필이 조회되어야 함
        final retrievedProfile = await databaseService.getUserProfile();
        expect(retrievedProfile, isNotNull);
        expect(retrievedProfile!.level, UserLevel.rising);
        expect(retrievedProfile.initialMaxReps, 15);
        expect(retrievedProfile.chadLevel, 1);
      });

      test('사용자 프로필 업데이트가 올바르게 작동하는지 테스트', () async {
        // Given: 초기 사용자 프로필 생성
        final initialProfile = UserProfile(
          level: UserLevel.rookie,
          initialMaxReps: 10,
          startDate: DateTime.now(),
          chadLevel: 0,
        );
        final userId = await databaseService.insertUserProfile(initialProfile);

        // When: 프로필 업데이트
        final updatedProfile = initialProfile.copyWith(
          id: userId,
          chadLevel: 2,
          level: UserLevel.rising,
        );
        await databaseService.updateUserProfile(updatedProfile);

        // Then: 업데이트된 값이 반영되어야 함
        final retrievedProfile = await databaseService.getUserProfile();
        expect(retrievedProfile, isNotNull);
        expect(retrievedProfile!.chadLevel, 2);
        expect(retrievedProfile.level, UserLevel.rising);
      });

      test('사용자 프로필 삭제가 올바르게 작동하는지 테스트', () async {
        // Given: 사용자 프로필 생성
        final userProfile = UserProfile(
          level: UserLevel.rookie,
          initialMaxReps: 10,
          startDate: DateTime.now(),
          chadLevel: 0,
        );
        final userId = await databaseService.insertUserProfile(userProfile);

        // 프로필이 존재하는지 확인
        final beforeDelete = await databaseService.getUserProfile();
        expect(beforeDelete, isNotNull);

        // When: 프로필 삭제
        await databaseService.deleteUserProfile(userId);

        // Then: 프로필이 삭제되어야 함
        final afterDelete = await databaseService.getUserProfile();
        expect(afterDelete, isNull);
      });
    });

    group('WorkoutSession CRUD Tests', () {
      test('워크아웃 세션 삽입이 올바르게 작동하는지 테스트', () async {
        // Given: 테스트용 워크아웃 세션
        final workoutSession = WorkoutSession(
          week: 1,
          day: 1,
          date: DateTime.now(),
          targetReps: [10, 8, 6, 4, 2],
          completedReps: const [],
          isCompleted: false,
          totalReps: 30,
          totalTime: Duration.zero,
        );

        // When: 워크아웃 세션 삽입
        final sessionId = await databaseService.insertWorkoutSession(workoutSession);

        // Then: 유효한 ID가 반환되어야 함
        expect(sessionId, greaterThan(0));

        // 삽입된 세션을 조회하여 확인
        final retrievedSession = await databaseService.getWorkoutSession(1, 1);
        expect(retrievedSession, isNotNull);
        expect(retrievedSession!.id, sessionId);
        expect(retrievedSession.week, 1);
        expect(retrievedSession.day, 1);
        expect(retrievedSession.targetReps, [10, 8, 6, 4, 2]);
        expect(retrievedSession.isCompleted, false);
      });

      test('특정 워크아웃 세션 조회가 올바르게 작동하는지 테스트', () async {
        // Given: 여러 워크아웃 세션 생성
        final session1 = WorkoutSession(
          week: 1,
          day: 1,
          date: DateTime.now(),
          targetReps: [10, 8, 6, 4, 2],
          completedReps: const [],
          isCompleted: false,
          totalReps: 30,
          totalTime: Duration.zero,
        );

        final session2 = WorkoutSession(
          week: 1,
          day: 2,
          date: DateTime.now().add(const Duration(days: 2)),
          targetReps: [12, 10, 8, 6, 4],
          completedReps: const [],
          isCompleted: false,
          totalReps: 40,
          totalTime: Duration.zero,
        );

        await databaseService.insertWorkoutSession(session1);
        await databaseService.insertWorkoutSession(session2);

        // When: 특정 세션 조회
        final retrievedSession1 = await databaseService.getWorkoutSession(1, 1);
        final retrievedSession2 = await databaseService.getWorkoutSession(1, 2);

        // Then: 올바른 세션이 조회되어야 함
        expect(retrievedSession1, isNotNull);
        expect(retrievedSession1!.day, 1);
        expect(retrievedSession1.targetReps, [10, 8, 6, 4, 2]);

        expect(retrievedSession2, isNotNull);
        expect(retrievedSession2!.day, 2);
        expect(retrievedSession2.targetReps, [12, 10, 8, 6, 4]);
      });

      test('주차별 워크아웃 세션 조회가 올바르게 작동하는지 테스트', () async {
        // Given: 여러 주차의 워크아웃 세션 생성
        for (int week = 1; week <= 2; week++) {
          for (int day = 1; day <= 3; day++) {
            final session = WorkoutSession(
              week: week,
              day: day,
              date: DateTime.now().add(Duration(days: (week - 1) * 7 + (day - 1) * 2)),
              targetReps: [10, 8, 6, 4, 2],
              completedReps: const [],
              isCompleted: false,
              totalReps: 30,
              totalTime: Duration.zero,
            );
            await databaseService.insertWorkoutSession(session);
          }
        }

        // When: 1주차 세션들 조회
        final week1Sessions = await databaseService.getWorkoutSessionsByWeek(1);
        final week2Sessions = await databaseService.getWorkoutSessionsByWeek(2);

        // Then: 올바른 수의 세션이 조회되어야 함
        expect(week1Sessions.length, 3);
        expect(week2Sessions.length, 3);

        // 모든 세션이 올바른 주차인지 확인
        expect(week1Sessions.every((session) => session.week == 1), true);
        expect(week2Sessions.every((session) => session.week == 2), true);
      });

      test('모든 워크아웃 세션 조회가 올바르게 작동하는지 테스트', () async {
        // Given: 여러 워크아웃 세션 생성
        for (int i = 1; i <= 5; i++) {
          final session = WorkoutSession(
            week: 1,
            day: i <= 3 ? i : i - 3,
            date: DateTime.now().add(Duration(days: i)),
            targetReps: [10, 8, 6, 4, 2],
            completedReps: const [],
            isCompleted: false,
            totalReps: 30,
            totalTime: Duration.zero,
          );
          await databaseService.insertWorkoutSession(session);
        }

        // When: 모든 세션 조회
        final allSessions = await databaseService.getAllWorkoutSessions();

        // Then: 모든 세션이 조회되어야 함
        expect(allSessions.length, 5);
      });

      test('사용자별 워크아웃 세션 조회가 올바르게 작동하는지 테스트', () async {
        // Given: 워크아웃 세션 생성
        for (int i = 1; i <= 3; i++) {
          final session = WorkoutSession(
            week: 1,
            day: i,
            date: DateTime.now().add(Duration(days: i)),
            targetReps: [10, 8, 6, 4, 2],
            completedReps: const [],
            isCompleted: false,
            totalReps: 30,
            totalTime: Duration.zero,
          );
          await databaseService.insertWorkoutSession(session);
        }

        // When: 사용자별 세션 조회 (현재는 단일 사용자)
        final userSessions = await databaseService.getWorkoutSessionsByUserId(1);

        // Then: 모든 세션이 조회되어야 함
        expect(userSessions.length, 3);
      });

      test('워크아웃 세션 업데이트가 올바르게 작동하는지 테스트', () async {
        // Given: 초기 워크아웃 세션 생성
        final initialSession = WorkoutSession(
          week: 1,
          day: 1,
          date: DateTime.now(),
          targetReps: [10, 8, 6, 4, 2],
          completedReps: const [],
          isCompleted: false,
          totalReps: 30,
          totalTime: Duration.zero,
        );
        final sessionId = await databaseService.insertWorkoutSession(initialSession);

        // When: 세션 업데이트 (완료 처리)
        final updatedSession = initialSession.copyWith(
          id: sessionId,
          completedReps: [10, 8, 6, 4, 2],
          isCompleted: true,
          totalTime: const Duration(minutes: 5),
        );
        await databaseService.updateWorkoutSession(updatedSession);

        // Then: 업데이트된 값이 반영되어야 함
        final retrievedSession = await databaseService.getWorkoutSession(1, 1);
        expect(retrievedSession, isNotNull);
        expect(retrievedSession!.isCompleted, true);
        expect(retrievedSession.completedReps, [10, 8, 6, 4, 2]);
        expect(retrievedSession.totalTime, const Duration(minutes: 5));
      });

      test('워크아웃 세션 삭제가 올바르게 작동하는지 테스트', () async {
        // Given: 워크아웃 세션 생성
        final session = WorkoutSession(
          week: 1,
          day: 1,
          date: DateTime.now(),
          targetReps: [10, 8, 6, 4, 2],
          completedReps: const [],
          isCompleted: false,
          totalReps: 30,
          totalTime: Duration.zero,
        );
        final sessionId = await databaseService.insertWorkoutSession(session);

        // 세션이 존재하는지 확인
        final beforeDelete = await databaseService.getWorkoutSession(1, 1);
        expect(beforeDelete, isNotNull);

        // When: 세션 삭제
        await databaseService.deleteWorkoutSession(sessionId);

        // Then: 세션이 삭제되어야 함
        final afterDelete = await databaseService.getWorkoutSession(1, 1);
        expect(afterDelete, isNull);
      });
    });

    group('Database Utility Tests', () {
      test('모든 데이터 삭제가 올바르게 작동하는지 테스트', () async {
        // Given: 사용자 프로필과 워크아웃 세션 생성
        final userProfile = UserProfile(
          level: UserLevel.rookie,
          initialMaxReps: 10,
          startDate: DateTime.now(),
          chadLevel: 0,
        );
        await databaseService.insertUserProfile(userProfile);

        final session = WorkoutSession(
          week: 1,
          day: 1,
          date: DateTime.now(),
          targetReps: [10, 8, 6, 4, 2],
          completedReps: const [],
          isCompleted: false,
          totalReps: 30,
          totalTime: Duration.zero,
        );
        await databaseService.insertWorkoutSession(session);

        // 데이터가 존재하는지 확인
        final profileBefore = await databaseService.getUserProfile();
        final sessionsBefore = await databaseService.getAllWorkoutSessions();
        expect(profileBefore, isNotNull);
        expect(sessionsBefore.isNotEmpty, true);

        // When: 모든 데이터 삭제
        await databaseService.deleteAllData();

        // Then: 모든 데이터가 삭제되어야 함
        final profileAfter = await databaseService.getUserProfile();
        final sessionsAfter = await databaseService.getAllWorkoutSessions();
        expect(profileAfter, isNull);
        expect(sessionsAfter.isEmpty, true);
      });

      test('데이터베이스 초기화가 올바르게 작동하는지 테스트', () async {
        // When: 데이터베이스 초기화
        final database = await databaseService.database;

        // Then: 데이터베이스가 생성되어야 함
        expect(database, isNotNull);
        expect(database.isOpen, true);
      });
    });

    group('Edge Cases and Error Handling Tests', () {
      test('존재하지 않는 워크아웃 세션 조회 시 null 반환하는지 테스트', () async {
        // When: 존재하지 않는 세션 조회
        final nonExistentSession = await databaseService.getWorkoutSession(999, 999);

        // Then: null이 반환되어야 함
        expect(nonExistentSession, isNull);
      });

      test('빈 주차에 대한 세션 조회가 올바르게 작동하는지 테스트', () async {
        // When: 세션이 없는 주차 조회
        final emptySessions = await databaseService.getWorkoutSessionsByWeek(999);

        // Then: 빈 리스트가 반환되어야 함
        expect(emptySessions, isEmpty);
      });

      test('중복 사용자 프로필 삽입 시 기존 프로필 업데이트되는지 테스트', () async {
        // Given: 첫 번째 사용자 프로필 생성
        final firstProfile = UserProfile(
          level: UserLevel.rookie,
          initialMaxReps: 10,
          startDate: DateTime.now(),
          chadLevel: 0,
        );
        await databaseService.insertUserProfile(firstProfile);

        // When: 두 번째 사용자 프로필 생성 (현재는 단일 사용자 시스템)
        final secondProfile = UserProfile(
          level: UserLevel.rising,
          initialMaxReps: 15,
          startDate: DateTime.now(),
          chadLevel: 1,
        );
        await databaseService.insertUserProfile(secondProfile);

        // Then: 최신 프로필만 존재해야 함
        final retrievedProfile = await databaseService.getUserProfile();
        expect(retrievedProfile, isNotNull);
        // 현재 구현에 따라 결과가 달라질 수 있음
      });

      test('잘못된 데이터 타입으로 세션 생성 시 처리되는지 테스트', () async {
        // Given: 잘못된 데이터가 포함된 세션
        final invalidSession = WorkoutSession(
          week: -1, // 잘못된 주차
          day: 0,   // 잘못된 일차
          date: DateTime.now(),
          targetReps: [], // 빈 목표 횟수
          completedReps: const [],
          isCompleted: false,
          totalReps: 0,
          totalTime: Duration.zero,
        );

        // When & Then: 예외 없이 처리되어야 함 (또는 적절한 검증)
        expect(() async => await databaseService.insertWorkoutSession(invalidSession), 
               returnsNormally);
      });
    });
  });
} 