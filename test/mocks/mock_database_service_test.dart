import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/models/user_profile.dart';
import 'package:mission100/models/workout_session.dart';
import 'mock_database_service.dart';
import '../test_helper.dart';

void main() {
  setUpAll(() {
    setupTestEnvironment();
  });

  tearDownAll(() {
    tearDownTestEnvironment();
  });

  group('MockDatabaseService Tests', () {
    late MockDatabaseService mockDb;

    setUp(() {
      mockDb = MockDatabaseService();
      mockDb.initialize();
    });

    tearDown(() {
      mockDb.clearMockData();
    });

    group('초기화 및 기본 상태 테스트', () {
      test('초기화 상태가 올바르게 설정되는지 테스트', () {
        expect(mockDb.isInitialized, isTrue);
        expect(mockDb.hasUserProfile, isFalse);
        expect(mockDb.workoutSessionCount, equals(0));
      });

      test('초기화되지 않은 상태에서 메서드 호출 시 예외 발생 테스트', () async {
        final uninitializedDb = MockDatabaseService();
        
        expect(
          () => uninitializedDb.getUserProfile(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('UserProfile CRUD 테스트', () {
      test('사용자 프로필 삽입 테스트', () async {
        // Given: 새로운 사용자 프로필
        final profile = UserProfile(
          id: 1,
          level: UserLevel.rookie,
          initialMaxReps: 10,
          startDate: DateTime.now(),
        );

        // When: 프로필을 삽입
        final result = await mockDb.insertUserProfile(profile);

        // Then: 성공적으로 삽입되어야 함
        expect(result, equals(1));
        expect(mockDb.hasUserProfile, isTrue);
        
        final savedProfile = await mockDb.getUserProfile();
        expect(savedProfile, isNotNull);
        expect(savedProfile!.level, equals(UserLevel.rookie));
      });

      test('사용자 프로필 업데이트 테스트', () async {
        // Given: 기존 사용자 프로필
        final originalProfile = UserProfile(
          id: 1,
          level: UserLevel.rookie,
          initialMaxReps: 10,
          startDate: DateTime.now(),
        );
        await mockDb.insertUserProfile(originalProfile);

        // When: 프로필을 업데이트
        final updatedProfile = originalProfile.copyWith(level: UserLevel.rising);
        final result = await mockDb.updateUserProfile(updatedProfile);

        // Then: 성공적으로 업데이트되어야 함
        expect(result, equals(1));
        
        final savedProfile = await mockDb.getUserProfile();
        expect(savedProfile!.level, equals(UserLevel.rising));
      });

      test('사용자 프로필 삭제 테스트', () async {
        // Given: 기존 사용자 프로필
        final profile = UserProfile(
          id: 1,
          level: UserLevel.rookie,
          initialMaxReps: 10,
          startDate: DateTime.now(),
        );
        await mockDb.insertUserProfile(profile);

        // When: 프로필을 삭제
        final result = await mockDb.deleteUserProfile(1);

        // Then: 성공적으로 삭제되어야 함
        expect(result, equals(1));
        expect(mockDb.hasUserProfile, isFalse);
        
        final savedProfile = await mockDb.getUserProfile();
        expect(savedProfile, isNull);
      });

      test('존재하지 않는 프로필 삭제 시 0 반환 테스트', () async {
        // When: 존재하지 않는 프로필을 삭제
        final result = await mockDb.deleteUserProfile(999);

        // Then: 0이 반환되어야 함
        expect(result, equals(0));
      });
    });

    group('WorkoutSession CRUD 테스트', () {
      test('운동 세션 삽입 테스트', () async {
        // Given: 새로운 운동 세션
        final session = WorkoutSession(
          id: 1,
          date: DateTime.now(),
          week: 1,
          day: 1,
          targetReps: [10, 8, 6],
          completedReps: [10, 8, 6],
          isCompleted: true,
          totalReps: 24,
        );

        // When: 세션을 삽입
        final result = await mockDb.insertWorkoutSession(session);

        // Then: 성공적으로 삽입되어야 함
        expect(result, equals(1));
        expect(mockDb.workoutSessionCount, equals(1));
      });

      test('모든 운동 세션 조회 테스트', () async {
        // Given: 여러 운동 세션
        final sessions = [
          WorkoutSession(
            id: 1,
            date: DateTime.now(),
            week: 1,
            day: 1,
            targetReps: [10],
            totalReps: 10,
          ),
          WorkoutSession(
            id: 2,
            date: DateTime.now().add(const Duration(days: 1)),
            week: 1,
            day: 2,
            targetReps: [12],
            totalReps: 12,
          ),
        ];

        for (final session in sessions) {
          await mockDb.insertWorkoutSession(session);
        }

        // When: 모든 세션을 조회
        final result = await mockDb.getAllWorkoutSessions();

        // Then: 모든 세션이 반환되어야 함
        expect(result.length, equals(2));
        expect(result[0].week, equals(1));
        expect(result[1].week, equals(1));
      });

      test('주별 운동 세션 조회 테스트', () async {
        // Given: 다른 주의 운동 세션들
        final sessions = [
          WorkoutSession(
            id: 1,
            date: DateTime.now(),
            week: 1,
            day: 1,
            targetReps: [10],
          ),
          WorkoutSession(
            id: 2,
            date: DateTime.now(),
            week: 2,
            day: 1,
            targetReps: [12],
          ),
        ];

        for (final session in sessions) {
          await mockDb.insertWorkoutSession(session);
        }

        // When: 1주차 세션만 조회
        final result = await mockDb.getWorkoutSessionsByWeek(1);

        // Then: 1주차 세션만 반환되어야 함
        expect(result.length, equals(1));
        expect(result[0].week, equals(1));
      });

      test('특정 주-일 운동 세션 조회 테스트', () async {
        // Given: 운동 세션
        final session = WorkoutSession(
          id: 1,
          date: DateTime.now(),
          week: 1,
          day: 2,
          targetReps: [10],
        );
        await mockDb.insertWorkoutSession(session);

        // When: 특정 주-일 세션을 조회
        final result = await mockDb.getWorkoutSession(1, 2);

        // Then: 해당 세션이 반환되어야 함
        expect(result, isNotNull);
        expect(result!.week, equals(1));
        expect(result.day, equals(2));
      });

      test('존재하지 않는 운동 세션 조회 시 null 반환 테스트', () async {
        // When: 존재하지 않는 세션을 조회
        final result = await mockDb.getWorkoutSession(999, 999);

        // Then: null이 반환되어야 함
        expect(result, isNull);
      });

      test('오늘의 운동 세션 조회 테스트', () async {
        // Given: 오늘 날짜의 운동 세션
        final today = DateTime.now();
        final session = WorkoutSession(
          id: 1,
          date: today,
          week: 1,
          day: 1,
          targetReps: [10],
        );
        await mockDb.insertWorkoutSession(session);

        // When: 오늘의 세션을 조회
        final result = await mockDb.getTodayWorkoutSession();

        // Then: 오늘의 세션이 반환되어야 함
        expect(result, isNotNull);
        expect(result!.date.day, equals(today.day));
      });

      test('운동 세션 업데이트 테스트', () async {
        // Given: 기존 운동 세션
        final originalSession = WorkoutSession(
          id: 1,
          date: DateTime.now(),
          week: 1,
          day: 1,
          targetReps: [10],
          isCompleted: false,
        );
        await mockDb.insertWorkoutSession(originalSession);

        // When: 세션을 업데이트
        final updatedSession = originalSession.copyWith(isCompleted: true);
        final result = await mockDb.updateWorkoutSession(updatedSession);

        // Then: 성공적으로 업데이트되어야 함
        expect(result, equals(1));
      });

      test('운동 세션 삭제 테스트', () async {
        // Given: 기존 운동 세션
        final session = WorkoutSession(
          id: 1,
          date: DateTime.now(),
          week: 1,
          day: 1,
          targetReps: [10],
        );
        await mockDb.insertWorkoutSession(session);

        // When: 세션을 삭제
        final result = await mockDb.deleteWorkoutSession(1);

        // Then: 성공적으로 삭제되어야 함
        expect(result, equals(1));
        expect(mockDb.workoutSessionCount, equals(0));
      });
    });

    group('통계 메서드 테스트', () {
      test('총 푸시업 개수 계산 테스트', () async {
        // Given: 완료된 운동 세션들
        final sessions = [
          WorkoutSession(
            id: 1,
            date: DateTime.now(),
            week: 1,
            day: 1,
            targetReps: [10],
            isCompleted: true,
            totalReps: 10,
          ),
          WorkoutSession(
            id: 2,
            date: DateTime.now(),
            week: 1,
            day: 2,
            targetReps: [12],
            isCompleted: true,
            totalReps: 12,
          ),
          WorkoutSession(
            id: 3,
            date: DateTime.now(),
            week: 1,
            day: 3,
            targetReps: [8],
            isCompleted: false, // 완료되지 않음
            totalReps: 8,
          ),
        ];

        for (final session in sessions) {
          await mockDb.insertWorkoutSession(session);
        }

        // When: 총 푸시업 개수를 계산
        final result = await mockDb.getTotalPushups();

        // Then: 완료된 세션의 푸시업만 합산되어야 함
        expect(result, equals(22)); // 10 + 12
      });

      test('완료된 운동 개수 계산 테스트', () async {
        // Given: 운동 세션들 (일부만 완료)
        final sessions = [
          WorkoutSession(
            id: 1,
            date: DateTime.now(),
            week: 1,
            day: 1,
            targetReps: [10],
            isCompleted: true,
          ),
          WorkoutSession(
            id: 2,
            date: DateTime.now(),
            week: 1,
            day: 2,
            targetReps: [12],
            isCompleted: false,
          ),
          WorkoutSession(
            id: 3,
            date: DateTime.now(),
            week: 1,
            day: 3,
            targetReps: [8],
            isCompleted: true,
          ),
        ];

        for (final session in sessions) {
          await mockDb.insertWorkoutSession(session);
        }

        // When: 완료된 운동 개수를 계산
        final result = await mockDb.getCompletedWorkouts();

        // Then: 완료된 운동만 카운트되어야 함
        expect(result, equals(2));
      });

      test('최근 운동 조회 테스트', () async {
        // Given: 다양한 날짜의 운동 세션들
        final now = DateTime.now();
        final sessions = [
          WorkoutSession(
            id: 1,
            date: now.subtract(const Duration(days: 3)),
            week: 1,
            day: 1,
            targetReps: [10],
          ),
          WorkoutSession(
            id: 2,
            date: now.subtract(const Duration(days: 1)),
            week: 1,
            day: 2,
            targetReps: [12],
          ),
          WorkoutSession(
            id: 3,
            date: now,
            week: 1,
            day: 3,
            targetReps: [8],
          ),
        ];

        for (final session in sessions) {
          await mockDb.insertWorkoutSession(session);
        }

        // When: 최근 2개 운동을 조회
        final result = await mockDb.getRecentWorkouts(limit: 2);

        // Then: 최신 순으로 2개가 반환되어야 함
        expect(result.length, equals(2));
        expect(result[0].id, equals(3)); // 가장 최근
        expect(result[1].id, equals(2)); // 두 번째 최근
      });

      test('연속 운동일 계산 테스트', () async {
        // Given: 연속된 날짜의 완료된 운동들
        final now = DateTime.now();
        final sessions = [
          WorkoutSession(
            id: 1,
            date: now.subtract(const Duration(days: 2)),
            week: 1,
            day: 1,
            targetReps: [10],
            isCompleted: true,
          ),
          WorkoutSession(
            id: 2,
            date: now.subtract(const Duration(days: 1)),
            week: 1,
            day: 2,
            targetReps: [12],
            isCompleted: true,
          ),
          WorkoutSession(
            id: 3,
            date: now,
            week: 1,
            day: 3,
            targetReps: [8],
            isCompleted: true,
          ),
        ];

        for (final session in sessions) {
          await mockDb.insertWorkoutSession(session);
        }

        // When: 연속 운동일을 계산
        final result = await mockDb.getConsecutiveDays();

        // Then: 3일 연속이어야 함
        expect(result, equals(3));
      });

      test('연속 운동일 계산 - 중간에 빠진 날이 있는 경우 테스트', () async {
        // Given: 중간에 빠진 날이 있는 운동들
        final now = DateTime.now();
        final sessions = [
          WorkoutSession(
            id: 1,
            date: now.subtract(const Duration(days: 3)),
            week: 1,
            day: 1,
            targetReps: [10],
            isCompleted: true,
          ),
          // 2일 전은 빠짐
          WorkoutSession(
            id: 2,
            date: now.subtract(const Duration(days: 1)),
            week: 1,
            day: 2,
            targetReps: [12],
            isCompleted: true,
          ),
          WorkoutSession(
            id: 3,
            date: now,
            week: 1,
            day: 3,
            targetReps: [8],
            isCompleted: true,
          ),
        ];

        for (final session in sessions) {
          await mockDb.insertWorkoutSession(session);
        }

        // When: 연속 운동일을 계산
        final result = await mockDb.getConsecutiveDays();

        // Then: 2일 연속이어야 함 (최근부터 계산)
        expect(result, equals(2));
      });
    });

    group('데이터 관리 테스트', () {
      test('모든 데이터 삭제 테스트', () async {
        // Given: 사용자 프로필과 운동 세션이 있는 상태
        final profile = UserProfile(
          id: 1,
          level: UserLevel.rookie,
          initialMaxReps: 10,
          startDate: DateTime.now(),
        );
        await mockDb.insertUserProfile(profile);

        final session = WorkoutSession(
          id: 1,
          date: DateTime.now(),
          week: 1,
          day: 1,
          targetReps: [10],
        );
        await mockDb.insertWorkoutSession(session);

        // When: 모든 데이터를 삭제
        await mockDb.deleteAllData();

        // Then: 모든 데이터가 삭제되어야 함
        expect(mockDb.hasUserProfile, isFalse);
        expect(mockDb.workoutSessionCount, equals(0));
      });

      test('데이터베이스 닫기 테스트', () async {
        // When: 데이터베이스를 닫음
        await mockDb.close();

        // Then: 초기화 상태가 false가 되어야 함
        expect(mockDb.isInitialized, isFalse);
      });
    });

    group('헬퍼 메서드 테스트', () {
      test('clearMockData 메서드 테스트', () async {
        // Given: 데이터가 있는 상태
        final profile = UserProfile(
          id: 1,
          level: UserLevel.rookie,
          initialMaxReps: 10,
          startDate: DateTime.now(),
        );
        await mockDb.insertUserProfile(profile);

        final session = WorkoutSession(
          id: 1,
          date: DateTime.now(),
          week: 1,
          day: 1,
          targetReps: [10],
        );
        await mockDb.insertWorkoutSession(session);

        // When: 모킹 데이터를 클리어
        mockDb.clearMockData();

        // Then: 모든 데이터가 클리어되어야 함
        expect(mockDb.hasUserProfile, isFalse);
        expect(mockDb.workoutSessionCount, equals(0));
        expect(mockDb.isInitialized, isFalse);
      });

      test('setMockUserProfile 메서드 테스트', () {
        // Given: 사용자 프로필
        final profile = UserProfile(
          id: 1,
          level: UserLevel.alpha,
          initialMaxReps: 20,
          startDate: DateTime.now(),
        );

        // When: 모킹 프로필을 설정
        mockDb.setMockUserProfile(profile);

        // Then: 프로필이 설정되어야 함
        expect(mockDb.hasUserProfile, isTrue);
      });

      test('addMockWorkoutSession 메서드 테스트', () {
        // Given: 운동 세션
        final session = WorkoutSession(
          id: 1,
          date: DateTime.now(),
          week: 1,
          day: 1,
          targetReps: [10],
        );

        // When: 모킹 세션을 추가
        mockDb.addMockWorkoutSession(session);

        // Then: 세션이 추가되어야 함
        expect(mockDb.workoutSessionCount, equals(1));
      });
    });
  });
} 