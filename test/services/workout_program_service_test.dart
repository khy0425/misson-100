import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/services/workout_program_service.dart';
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

  group('WorkoutProgramService Tests', () {
    late WorkoutProgramService workoutProgramService;
    late DatabaseService databaseService;
    late UserProfile testUserProfile;

    setUp(() async {
      workoutProgramService = WorkoutProgramService();
      databaseService = DatabaseService();
      
      // 테스트용 데이터베이스 초기화
      await databaseService.deleteAllData();
      
      // 테스트용 사용자 프로필 생성
      testUserProfile = UserProfile(
        level: UserLevel.rookie,
        initialMaxReps: 10,
        startDate: DateTime.now(),
        chadLevel: 0,
      );
      
      final userId = await databaseService.insertUserProfile(testUserProfile);
      testUserProfile = testUserProfile.copyWith(id: userId);
    });

    tearDown(() async {
      await databaseService.deleteAllData();
    });

    test('프로그램 생성이 올바르게 작동하는지 테스트', () {
      // When: 프로그램 생성
      final program = workoutProgramService.generateProgram(UserLevel.rookie);

      // Then: 6주간의 프로그램이 생성되어야 함
      expect(program.length, 6);
      
      // 각 주차마다 3일의 워크아웃이 있어야 함
      for (int week = 1; week <= 6; week++) {
        expect(program[week], isNotNull);
        expect(program[week]!.length, 3);
        
        for (int day = 1; day <= 3; day++) {
          expect(program[week]![day], isNotNull);
          expect(program[week]![day]!, isNotEmpty);
        }
      }
    });

    test('특정 일차 워크아웃 가져오기가 올바르게 작동하는지 테스트', () {
      // When: 특정 일차 워크아웃 가져오기
      final workout = workoutProgramService.getWorkoutForDay(UserLevel.rookie, 1, 1);

      // Then: 워크아웃이 반환되어야 함
      expect(workout, isNotNull);
      expect(workout!, isNotEmpty);
      expect(workout.every((reps) => reps > 0), true);
    });

    test('잘못된 주차/일차에 대한 예외 처리가 올바른지 테스트', () {
      // When & Then: 잘못된 주차/일차에 대해 예외가 발생해야 함
      expect(() => workoutProgramService.getWorkoutForDay(UserLevel.rookie, 0, 1), 
             throwsArgumentError);
      expect(() => workoutProgramService.getWorkoutForDay(UserLevel.rookie, 7, 1), 
             throwsArgumentError);
      expect(() => workoutProgramService.getWorkoutForDay(UserLevel.rookie, 1, 0), 
             throwsArgumentError);
      expect(() => workoutProgramService.getWorkoutForDay(UserLevel.rookie, 1, 4), 
             throwsArgumentError);
    });

    test('총 횟수 계산이 올바르게 작동하는지 테스트', () {
      // Given: 테스트 워크아웃
      final workout = [10, 8, 6, 4, 2];

      // When: 총 횟수 계산
      final totalReps = workoutProgramService.getTotalRepsForWorkout(workout);

      // Then: 올바른 총 횟수가 계산되어야 함
      expect(totalReps, 30);
    });

    test('주차별 총 운동량 계산이 올바르게 작동하는지 테스트', () {
      // When: 주차별 총 운동량 계산
      final weeklyTotal = workoutProgramService.getTotalRepsForWeek(UserLevel.rookie, 1);

      // Then: 양수 값이 반환되어야 함
      expect(weeklyTotal, greaterThan(0));
    });

    test('전체 프로그램 총 운동량 계산이 올바르게 작동하는지 테스트', () {
      // When: 전체 프로그램 총 운동량 계산
      final programTotal = workoutProgramService.getTotalRepsForProgram(UserLevel.rookie);

      // Then: 양수 값이 반환되어야 함
      expect(programTotal, greaterThan(0));
      
      // 전체 총합은 각 주차 총합의 합과 같아야 함
      int weeklySum = 0;
      for (int week = 1; week <= 6; week++) {
        weeklySum += workoutProgramService.getTotalRepsForWeek(UserLevel.rookie, week);
      }
      expect(programTotal, weeklySum);
    });

    test('사용자 프로그램 초기화가 올바르게 작동하는지 테스트', () async {
      // When: 사용자 프로그램 초기화
      final createdSessions = await workoutProgramService.initializeUserProgram(testUserProfile);

      // Then: 18개의 세션이 생성되어야 함 (6주 * 3일)
      expect(createdSessions, 18);
      
      // 데이터베이스에서 세션들 확인
      final allSessions = await databaseService.getAllWorkoutSessions();
      expect(allSessions.length, 18);
      
      // 첫 번째 주의 세션들이 있는지 확인
      final week1Sessions = await databaseService.getWorkoutSessionsByWeek(1);
      expect(week1Sessions.length, 3);
    });

    test('프로그램 초기화 상태 확인이 올바르게 작동하는지 테스트', () async {
      // Given: 초기 상태에서는 프로그램이 초기화되지 않음
      bool isInitialized = await workoutProgramService.isProgramInitialized(testUserProfile.id!);
      expect(isInitialized, false);

      // When: 프로그램 초기화
      await workoutProgramService.initializeUserProgram(testUserProfile);

      // Then: 프로그램이 초기화됨
      isInitialized = await workoutProgramService.isProgramInitialized(testUserProfile.id!);
      expect(isInitialized, true);
    });

    test('오늘의 워크아웃 가져오기가 올바르게 작동하는지 테스트', () async {
      // Given: 프로그램 초기화
      await workoutProgramService.initializeUserProgram(testUserProfile);

      // When: 오늘의 워크아웃 가져오기
      final todayWorkout = await workoutProgramService.getTodayWorkout(testUserProfile);

      // Then: 오늘의 워크아웃이 반환되어야 함 (운동일인 경우)
      // 휴식일일 수도 있으므로 null 체크
      if (todayWorkout != null) {
        expect(todayWorkout.week, greaterThan(0));
        expect(todayWorkout.day, greaterThan(0));
        expect(todayWorkout.workout, isNotEmpty);
        expect(todayWorkout.totalReps, greaterThan(0));
        expect(todayWorkout.setCount, greaterThan(0));
        expect(todayWorkout.restTimeSeconds, greaterThan(0));
      }
    });

    test('주간 진행 상황 계산이 올바르게 작동하는지 테스트', () async {
      // Given: 프로그램 초기화
      await workoutProgramService.initializeUserProgram(testUserProfile);

      // When: 주간 진행 상황 가져오기
      final weeklyProgress = await workoutProgramService.getWeeklyProgress(testUserProfile);

      // Then: 주간 진행 상황이 올바르게 계산되어야 함
      expect(weeklyProgress.currentWeek, greaterThan(0));
      expect(weeklyProgress.currentWeek, lessThanOrEqualTo(6));
      expect(weeklyProgress.completedWeeks, greaterThanOrEqualTo(0));
      expect(weeklyProgress.totalDaysThisWeek, 3);
      expect(weeklyProgress.completedDaysThisWeek, greaterThanOrEqualTo(0));
      expect(weeklyProgress.weeklyCompletionRate, greaterThanOrEqualTo(0.0));
      expect(weeklyProgress.weeklyCompletionRate, lessThanOrEqualTo(1.0));
      expect(weeklyProgress.weeklyTarget, greaterThan(0));
    });

    test('프로그램 진행 상황 계산이 올바르게 작동하는지 테스트', () async {
      // Given: 프로그램 초기화
      await workoutProgramService.initializeUserProgram(testUserProfile);

      // When: 프로그램 진행 상황 가져오기
      final progress = await workoutProgramService.getProgramProgress(testUserProfile);

      // Then: 진행 상황이 올바르게 계산되어야 함
      expect(progress.progressPercentage, greaterThanOrEqualTo(0.0));
      expect(progress.progressPercentage, lessThanOrEqualTo(1.0));
      expect(progress.totalSessions, 18);
      expect(progress.completedSessions, greaterThanOrEqualTo(0));
      expect(progress.weeklyProgress, isNotNull);
      expect(progress.programTarget, greaterThan(0));
      expect(progress.totalCompletedReps, greaterThanOrEqualTo(0));
      expect(progress.remainingSessions, greaterThanOrEqualTo(0));
      expect(progress.remainingReps, greaterThanOrEqualTo(0));
    });

    test('다음 워크아웃 가져오기가 올바르게 작동하는지 테스트', () async {
      // Given: 프로그램 초기화
      await workoutProgramService.initializeUserProgram(testUserProfile);

      // When: 다음 워크아웃 가져오기
      final nextWorkout = await workoutProgramService.getNextWorkout(testUserProfile);

      // Then: 다음 워크아웃이 반환되어야 함
      expect(nextWorkout, isNotNull);
      expect(nextWorkout!.week, 1);
      expect(nextWorkout.day, 1);
      expect(nextWorkout.workout, isNotEmpty);
      expect(nextWorkout.totalReps, greaterThan(0));
      expect(nextWorkout.setCount, greaterThan(0));
    });

    test('프로그램 재초기화가 올바르게 작동하는지 테스트', () async {
      // Given: 초기 프로그램 생성
      await workoutProgramService.initializeUserProgram(testUserProfile);
      final initialSessions = await databaseService.getAllWorkoutSessions();
      expect(initialSessions.length, 18);

      // When: 프로그램 재초기화
      final newUserProfile = testUserProfile.copyWith(level: UserLevel.rising);
      final createdSessions = await workoutProgramService.reinitializeUserProgram(
        newUserProfile,
        clearExisting: true,
      );

      // Then: 새로운 세션들이 생성되어야 함
      expect(createdSessions, 18);
      final newSessions = await databaseService.getAllWorkoutSessions();
      expect(newSessions.length, 18);
    });

    test('TodayWorkout 클래스의 getter들이 올바르게 작동하는지 테스트', () {
      // Given: TodayWorkout 인스턴스
      final todayWorkout = TodayWorkout(
        week: 1,
        day: 1,
        workout: [10, 8, 6, 4, 2],
        totalReps: 30,
        restTimeSeconds: 60,
      );

      // Then: getter들이 올바른 값을 반환해야 함
      expect(todayWorkout.setCount, 5);
      expect(todayWorkout.averageRepsPerSet, 6.0);
      expect(todayWorkout.title, '1주차 - 1일차');
      expect(todayWorkout.description, '5세트, 총 30회');
    });

    test('WeeklyProgress 클래스의 getter들이 올바르게 작동하는지 테스트', () {
      // Given: WeeklyProgress 인스턴스
      final weeklyProgress = WeeklyProgress(
        currentWeek: 2,
        completedWeeks: 1,
        completedDaysThisWeek: 2,
        totalDaysThisWeek: 3,
        weeklyTarget: 100,
      );

      // Then: getter들이 올바른 값을 반환해야 함
      expect(weeklyProgress.weeklyCompletionRate, closeTo(0.67, 0.01));
      expect(weeklyProgress.remainingDaysThisWeek, 1);
    });

    test('ProgramProgress 클래스의 getter들이 올바르게 작동하는지 테스트', () {
      // Given: ProgramProgress 인스턴스
      final weeklyProgress = WeeklyProgress(
        currentWeek: 2,
        completedWeeks: 1,
        completedDaysThisWeek: 2,
        totalDaysThisWeek: 3,
        weeklyTarget: 100,
      );
      
      final programProgress = ProgramProgress(
        weeklyProgress: weeklyProgress,
        completedSessions: 5,
        totalSessions: 18,
        totalCompletedReps: 150,
        programTarget: 500,
        progressPercentage: 0.3,
        isCompleted: false,
      );

      // Then: getter들이 올바른 값을 반환해야 함
      expect(programProgress.remainingSessions, 13);
      expect(programProgress.remainingReps, 350);
    });
  });

  group('WorkoutProgramService Error Handling Tests', () {
    late WorkoutProgramService workoutProgramService;
    late DatabaseService databaseService;

    setUp(() async {
      workoutProgramService = WorkoutProgramService();
      databaseService = DatabaseService();
      await databaseService.deleteAllData();
    });

    tearDown(() async {
      await databaseService.deleteAllData();
    });

    test('존재하지 않는 사용자에 대한 처리가 올바른지 테스트', () async {
      // Given: 존재하지 않는 사용자 프로필
      final nonExistentProfile = UserProfile(
        id: 999,
        level: UserLevel.rookie,
        initialMaxReps: 10,
        startDate: DateTime.now(),
        chadLevel: 0,
      );

      // When & Then: 오류 없이 처리되어야 함
      expect(() async => await workoutProgramService.getTodayWorkout(nonExistentProfile), 
             returnsNormally);
      expect(() async => await workoutProgramService.getProgramProgress(nonExistentProfile), 
             returnsNormally);
    });

    test('잘못된 주차에 대한 예외 처리가 올바른지 테스트', () {
      // When & Then: 잘못된 주차에 대해 예외가 발생해야 함
      expect(() => workoutProgramService.getTotalRepsForWeek(UserLevel.rookie, 0), 
             throwsArgumentError);
      expect(() => workoutProgramService.getTotalRepsForWeek(UserLevel.rookie, 7), 
             throwsArgumentError);
    });

    test('빈 워크아웃에 대한 처리가 올바른지 테스트', () {
      // Given: 빈 워크아웃
      final emptyWorkout = <int>[];

      // When: 총 횟수 계산
      final totalReps = workoutProgramService.getTotalRepsForWorkout(emptyWorkout);

      // Then: 0이 반환되어야 함
      expect(totalReps, 0);
    });
  });
} 