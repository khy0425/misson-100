import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/services/database_service.dart';
import 'package:mission100/models/user_profile.dart';
import 'package:mission100/models/workout_session.dart';
import '../../test_helper.dart';

void main() {
  group('DatabaseService Tests', () {
    late DatabaseService service;

    setUpAll(() async {
      await TestHelper.setupTestEnvironment();
    });

    setUp(() {
      service = DatabaseService();
    });

    tearDown(() async {
      // 각 테스트 후 데이터 정리
      await service.clearAllData();
    });

    group('서비스 초기화 테스트', () {
      test('DatabaseService 싱글톤 인스턴스 생성', () {
        final service1 = DatabaseService();
        final service2 = DatabaseService();
        
        expect(service1, equals(service2)); // 싱글톤 패턴 확인
      });

      test('데이터베이스 연결 테스트', () async {
        final db = await service.database;
        expect(db, isNotNull);
      });

      test('데이터베이스 상태 확인', () async {
        final status = await service.getDatabaseStatus();
        expect(status['databaseExists'], isTrue);
        expect(status['userProfiles'], isA<int>());
        expect(status['workoutSessions'], isA<int>());
      });
    });

    group('UserProfile CRUD 테스트', () {
      test('UserProfile 삽입 및 조회', () async {
        final profile = TestHelper.createTestUserProfile();
        
        // 삽입
        final id = await service.insertUserProfile(profile);
        expect(id, greaterThan(0));
        
        // 조회
        final retrievedProfile = await service.getUserProfile();
        expect(retrievedProfile, isNotNull);
        expect(retrievedProfile!.level, equals(profile.level));
        expect(retrievedProfile.initialMaxReps, equals(profile.initialMaxReps));
      });

      test('UserProfile 업데이트', () async {
        final profile = TestHelper.createTestUserProfile();
        final id = await service.insertUserProfile(profile);
        
        // 업데이트할 프로필 생성
        final updatedProfile = profile.copyWith(
          id: id,
          level: UserLevel.alpha,
          chadLevel: 2,
        );
        
        final updateResult = await service.updateUserProfile(updatedProfile);
        expect(updateResult, equals(1)); // 한 개 행이 업데이트됨
        
        // 업데이트 확인
        final retrievedProfile = await service.getUserProfile();
        expect(retrievedProfile!.level, equals(UserLevel.alpha));
        expect(retrievedProfile.chadLevel, equals(2));
      });

      test('UserProfile 삭제', () async {
        final profile = TestHelper.createTestUserProfile();
        final id = await service.insertUserProfile(profile);
        
        // 삭제
        final deleteResult = await service.deleteUserProfile(id);
        expect(deleteResult, equals(1)); // 한 개 행이 삭제됨
        
        // 삭제 확인
        final retrievedProfile = await service.getUserProfile();
        expect(retrievedProfile, isNull);
      });
    });

    group('WorkoutSession CRUD 테스트', () {
      test('WorkoutSession 삽입 및 조회', () async {
        final session = TestHelper.createTestWorkoutSession();
        
        // 삽입
        final id = await service.insertWorkoutSession(session);
        expect(id, greaterThan(0));
        
        // 조회
        final sessions = await service.getAllWorkoutSessions();
        expect(sessions, isNotEmpty);
        expect(sessions.first.week, equals(session.week));
        expect(sessions.first.day, equals(session.day));
      });

      test('주차별 WorkoutSession 조회', () async {
        // 여러 주차의 세션 생성
        final session1 = TestHelper.createTestWorkoutSession(week: 1, day: 1);
        final session2 = TestHelper.createTestWorkoutSession(week: 1, day: 2);
        final session3 = TestHelper.createTestWorkoutSession(week: 2, day: 1);
        
        await service.insertWorkoutSession(session1);
        await service.insertWorkoutSession(session2);
        await service.insertWorkoutSession(session3);
        
        // 1주차 세션 조회
        final week1Sessions = await service.getWorkoutSessionsByWeek(1);
        expect(week1Sessions.length, equals(2));
        
        // 2주차 세션 조회
        final week2Sessions = await service.getWorkoutSessionsByWeek(2);
        expect(week2Sessions.length, equals(1));
      });

      test('특정 주차/일차 WorkoutSession 조회', () async {
        final session = TestHelper.createTestWorkoutSession(week: 3, day: 2);
        await service.insertWorkoutSession(session);
        
        final retrievedSession = await service.getWorkoutSession(3, 2);
        expect(retrievedSession, isNotNull);
        expect(retrievedSession!.week, equals(3));
        expect(retrievedSession.day, equals(2));
        
        // 존재하지 않는 세션 조회
        final nonExistentSession = await service.getWorkoutSession(5, 5);
        expect(nonExistentSession, isNull);
      });

      test('오늘의 WorkoutSession 조회', () async {
        final today = DateTime.now();
        final session = TestHelper.createTestWorkoutSession(date: today);
        
        await service.insertWorkoutSession(session);
        
        final todaySession = await service.getTodayWorkoutSession();
        expect(todaySession, isNotNull);
        expect(todaySession!.date.day, equals(today.day));
      });

      test('WorkoutSession 업데이트', () async {
        final session = TestHelper.createTestWorkoutSession();
        final id = await service.insertWorkoutSession(session);
        
        // 업데이트할 세션 생성
        final updatedSession = session.copyWith(
          id: id,
          isCompleted: true,
          totalReps: 100,
          completedReps: [10, 10, 10, 10, 10],
        );
        
        final updateResult = await service.updateWorkoutSession(updatedSession);
        expect(updateResult, equals(1));
        
        // 업데이트 확인
        final retrievedSession = await service.getWorkoutSession(session.week, session.day);
        expect(retrievedSession!.isCompleted, isTrue);
        expect(retrievedSession.totalReps, equals(100));
      });

      test('WorkoutSession 삭제', () async {
        final session = TestHelper.createTestWorkoutSession();
        final id = await service.insertWorkoutSession(session);
        
        // 삭제
        final deleteResult = await service.deleteWorkoutSession(id);
        expect(deleteResult, equals(1));
        
        // 삭제 확인
        final sessions = await service.getAllWorkoutSessions();
        expect(sessions.any((s) => s.id == id), isFalse);
      });

      test('최근 운동 세션 조회', () async {
        // 여러 세션 생성
        for (int i = 1; i <= 5; i++) {
          final session = TestHelper.createTestWorkoutSession(
            date: DateTime.now().subtract(Duration(days: i)),
            week: i,
            day: 1,
          );
          await service.insertWorkoutSession(session);
        }
        
        final recentSessions = await service.getRecentWorkouts(limit: 3);
        expect(recentSessions.length, equals(3));
        
        // 날짜 순으로 정렬되어 있는지 확인
        expect(recentSessions[0].date.isAfter(recentSessions[1].date), isTrue);
      });
    });

    group('통계 메서드 테스트', () {
      test('총 푸쉬업 개수 계산', () async {
        // 완료된 세션들 생성
        final session1 = TestHelper.createTestWorkoutSession(week: 1).copyWith(
          isCompleted: true,
          totalReps: 50,
        );
        final session2 = TestHelper.createTestWorkoutSession(week: 2).copyWith(
          isCompleted: true,
          totalReps: 75,
        );
        final session3 = TestHelper.createTestWorkoutSession(week: 3).copyWith(
          isCompleted: false, // 미완료 세션
          totalReps: 30,
        );
        
        await service.insertWorkoutSession(session1);
        await service.insertWorkoutSession(session2);
        await service.insertWorkoutSession(session3);
        
        final totalPushups = await service.getTotalPushups();
        expect(totalPushups, equals(125)); // 완료된 세션만 카운트 (50 + 75)
      });

      test('완료된 운동 세션 수 계산', () async {
        // 여러 세션 생성 (일부 완료, 일부 미완료)
        final sessions = [
          TestHelper.createTestWorkoutSession(week: 1, day: 1).copyWith(isCompleted: true),
          TestHelper.createTestWorkoutSession(week: 1, day: 2).copyWith(isCompleted: true),
          TestHelper.createTestWorkoutSession(week: 1, day: 3).copyWith(isCompleted: false),
          TestHelper.createTestWorkoutSession(week: 2, day: 1).copyWith(isCompleted: true),
        ];
        
        for (final session in sessions) {
          await service.insertWorkoutSession(session);
        }
        
        final completedCount = await service.getCompletedWorkouts();
        expect(completedCount, equals(3)); // 완료된 세션 3개
      });

      test('연속 운동일 계산', () async {
        final now = DateTime.now();
        
        // 연속 3일간 운동한 세션 생성
        for (int i = 0; i < 3; i++) {
          final session = TestHelper.createTestWorkoutSession(
            date: now.subtract(Duration(days: i)),
            week: i + 1,
            day: 1,
          ).copyWith(isCompleted: true);
          
          await service.insertWorkoutSession(session);
        }
        
        final consecutiveDays = await service.getConsecutiveDays();
        expect(consecutiveDays, equals(3));
      });
    });

    group('에러 처리 테스트', () {
      test('존재하지 않는 UserProfile 업데이트 시도', () async {
        final profile = TestHelper.createTestUserProfile().copyWith(id: 999);
        
        final updateResult = await service.updateUserProfile(profile);
        expect(updateResult, equals(0)); // 업데이트된 행이 없음
      });

      test('존재하지 않는 WorkoutSession 삭제 시도', () async {
        final deleteResult = await service.deleteWorkoutSession(999);
        expect(deleteResult, equals(0)); // 삭제된 행이 없음
      });

      test('잘못된 주차 번호로 세션 조회', () async {
        final sessions = await service.getWorkoutSessionsByWeek(-1);
        expect(sessions, isEmpty); // 빈 리스트 반환
      });
    });

    group('성능 테스트', () {
      test('대량 데이터 삽입 성능', () async {
        final sessions = List.generate(50, (index) => 
          TestHelper.createTestWorkoutSession(
            week: (index % 6) + 1, 
            day: (index % 3) + 1,
            date: DateTime.now().subtract(Duration(days: index)),
          )
        );
        
        final stopwatch = Stopwatch()..start();
        
        for (final session in sessions) {
          await service.insertWorkoutSession(session);
        }
        
        stopwatch.stop();
        
        // 50개 세션 삽입이 5초 이내에 완료되어야 함
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
        
        // 모든 세션이 삽입되었는지 확인
        final allSessions = await service.getAllWorkoutSessions();
        expect(allSessions.length, greaterThanOrEqualTo(50));
      });

      test('복잡한 쿼리 성능', () async {
        // 테스트 데이터 준비
        for (int i = 1; i <= 6; i++) {
          for (int j = 1; j <= 3; j++) {
            final session = TestHelper.createTestWorkoutSession(
              week: i,
              day: j,
              date: DateTime.now().subtract(Duration(days: i * 3 + j)),
            ).copyWith(
              isCompleted: i % 2 == 0, // 짝수 주차만 완료
              totalReps: i * 10 + j,
            );
            await service.insertWorkoutSession(session);
          }
        }
        
        final stopwatch = Stopwatch()..start();
        
        // 여러 쿼리 동시 실행
        final results = await Future.wait([
          service.getTotalPushups(),
          service.getCompletedWorkouts(),
          service.getAllWorkoutSessions(),
          service.getWorkoutSessionsByWeek(3),
          service.getConsecutiveDays(),
        ]);
        
        stopwatch.stop();
        
        // 복잡한 쿼리들이 3초 이내에 완료되어야 함
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
        expect(results, hasLength(5));
      });
    });
  });
} 