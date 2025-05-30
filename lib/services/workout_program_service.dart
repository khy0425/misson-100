import '../models/user_profile.dart';
import '../models/workout_session.dart';
import '../utils/workout_data.dart';
import 'database_service.dart';
import 'package:flutter/foundation.dart';

/// 사용자 레벨에 따른 6주 워크아웃 프로그램 생성 및 관리 서비스
class WorkoutProgramService {
  final DatabaseService _databaseService = DatabaseService();

  /// 사용자 레벨에 따른 완전한 6주 워크아웃 프로그램 생성
  ///
  /// [level] - 사용자의 현재 레벨 (Rookie, Rising, Alpha, Giga)
  /// Returns: 주차 -> 일차 -> 세트별 횟수 맵
  Map<int, Map<int, List<int>>> generateProgram(UserLevel level) {
    final program = WorkoutData.workoutPrograms[level];
    if (program == null) {
      throw ArgumentError('Invalid user level: $level');
    }
    return Map<int, Map<int, List<int>>>.from(program);
  }

  /// 특정 주차, 일차의 워크아웃 가져오기
  ///
  /// [level] - 사용자 레벨
  /// [week] - 주차 (1-6)
  /// [day] - 일차 (1-3)
  /// Returns: 세트별 횟수 리스트 또는 null
  List<int>? getWorkoutForDay(UserLevel level, int week, int day) {
    if (week < 1 || week > 6 || day < 1 || day > 3) {
      throw ArgumentError('Invalid week ($week) or day ($day)');
    }
    return WorkoutData.getWorkout(level, week, day);
  }

  /// 특정 워크아웃의 총 횟수 계산
  int getTotalRepsForWorkout(List<int> workout) {
    return WorkoutData.getTotalReps(workout);
  }

  /// 주차별 총 운동량 계산
  int getTotalRepsForWeek(UserLevel level, int week) {
    if (week < 1 || week > 6) {
      throw ArgumentError('Invalid week: $week');
    }
    return WorkoutData.getWeeklyTotal(level, week);
  }

  /// 전체 6주 프로그램의 총 운동량 계산
  int getTotalRepsForProgram(UserLevel level) {
    return WorkoutData.getProgramTotal(level);
  }

  /// 현재 날짜를 기준으로 오늘의 워크아웃 가져오기
  ///
  /// [userProfile] - 사용자 프로필 (시작 날짜 포함)
  /// Returns: 오늘의 워크아웃 정보 또는 null (프로그램 완료/휴식일)
  Future<TodayWorkout?> getTodayWorkout(UserProfile userProfile) async {
    final startDate = userProfile.startDate;
    final today = DateTime.now();
    final daysSinceStart = today.difference(startDate).inDays;

    debugPrint('🏃 getTodayWorkout 시작');
    debugPrint('📅 시작일: $startDate');
    debugPrint('📅 오늘: $today');
    debugPrint('📅 시작한지 $daysSinceStart일 경과');

    // 프로그램 완료 확인 (18일 = 6주 * 3일)
    if (daysSinceStart >= 18) {
      debugPrint('✅ 프로그램 완료 (18일 초과)');
      return null; // 프로그램 완료
    }

    // 주차와 일차 계산
    final weekIndex = daysSinceStart ~/ 7; // 0-based week index
    final dayInWeek = daysSinceStart % 7;

    debugPrint('📊 주차 인덱스: $weekIndex (${weekIndex + 1}주차)');
    debugPrint('📊 주 내 일차: $dayInWeek');

    // 운동일 확인 (월, 수, 금 = 0, 2, 4일차)
    final workoutDayMapping = {0: 1, 2: 2, 4: 3}; // 주 내 일차 -> 운동 일차
    final workoutDay = workoutDayMapping[dayInWeek];

    debugPrint('📊 운동일 매핑: $dayInWeek -> $workoutDay');

    if (workoutDay == null) {
      debugPrint('🛌 오늘은 휴식일 (화, 목, 토, 일)');
      return null; // 휴식일 (화, 목, 토, 일)
    }

    final week = weekIndex + 1; // 1-based week
    debugPrint('📊 최종 주차: $week, 운동일: $workoutDay');
    
    final workout = getWorkoutForDay(userProfile.level, week, workoutDay);

    if (workout == null) {
      debugPrint('❌ 워크아웃 데이터가 null (레벨: ${userProfile.level}, 주차: $week, 일차: $workoutDay)');
      return null;
    }

    debugPrint('✅ 오늘의 워크아웃 찾음: $week주차 $workoutDay일차 - $workout');

    return TodayWorkout(
      week: week,
      day: workoutDay,
      workout: workout,
      totalReps: getTotalRepsForWorkout(workout),
      restTimeSeconds: WorkoutData.restTimeSeconds[userProfile.level] ?? 60,
    );
  }

  /// 사용자의 주간 진행 상황 계산
  ///
  /// [userProfile] - 사용자 프로필
  /// Returns: 주간 진행 상황 정보
  Future<WeeklyProgress> getWeeklyProgress(UserProfile userProfile) async {
    final startDate = userProfile.startDate;
    final today = DateTime.now();
    final daysSinceStart = today.difference(startDate).inDays;

    final currentWeek = (daysSinceStart ~/ 7) + 1;
    final completedWeeks = currentWeek - 1;

    // 현재 주차의 완료된 워크아웃 세션 조회
    final sessions = await _databaseService.getWorkoutSessionsByWeek(
      currentWeek,
    );
    final completedDaysThisWeek = sessions.where((s) => s.isCompleted).length;

    return WeeklyProgress(
      currentWeek: currentWeek.clamp(1, 6),
      completedWeeks: completedWeeks.clamp(0, 6),
      completedDaysThisWeek: completedDaysThisWeek,
      totalDaysThisWeek: 3,
      weeklyTarget: getTotalRepsForWeek(
        userProfile.level,
        currentWeek.clamp(1, 6),
      ),
    );
  }

  /// 전체 프로그램 진행 상황 계산
  ///
  /// [userProfile] - 사용자 프로필
  /// Returns: 전체 프로그램 진행 상황 정보
  Future<ProgramProgress> getProgramProgress(UserProfile userProfile) async {
    final weeklyProgress = await getWeeklyProgress(userProfile);
    final allSessions = await _databaseService.getWorkoutSessionsByUserId(
      1,
    ); // 현재는 단일 사용자

    final completedSessions = allSessions.where((s) => s.isCompleted).length;
    final totalCompletedReps = allSessions
        .where((s) => s.isCompleted)
        .fold<int>(0, (sum, session) => sum + session.totalReps);

    final programTarget = getTotalRepsForProgram(userProfile.level);
    final progressPercentage = (totalCompletedReps / programTarget).clamp(
      0.0,
      1.0,
    );

    return ProgramProgress(
      weeklyProgress: weeklyProgress,
      completedSessions: completedSessions,
      totalSessions: 18,
      totalCompletedReps: totalCompletedReps,
      programTarget: programTarget,
      progressPercentage: progressPercentage,
      isCompleted: completedSessions >= 18,
    );
  }

  /// 다음 워크아웃 세션 예약
  ///
  /// [userProfile] - 사용자 프로필
  /// Returns: 다음 워크아웃 정보 또는 null (프로그램 완료)
  Future<TodayWorkout?> getNextWorkout(UserProfile userProfile) async {
    final allSessions = await _databaseService.getWorkoutSessionsByUserId(1);
    final completedSessions = allSessions.where((s) => s.isCompleted).length;

    if (completedSessions >= 18) {
      return null; // 프로그램 완료
    }

    // 다음 세션 계산
    final nextSessionIndex = completedSessions; // 0-based
    final week = (nextSessionIndex ~/ 3) + 1; // 1-based week
    final day = (nextSessionIndex % 3) + 1; // 1-based day

    final workout = getWorkoutForDay(userProfile.level, week, day);
    if (workout == null) {
      return null;
    }

    return TodayWorkout(
      week: week,
      day: day,
      workout: workout,
      totalReps: getTotalRepsForWorkout(workout),
      restTimeSeconds: WorkoutData.restTimeSeconds[userProfile.level] ?? 60,
    );
  }

  /// 새 사용자를 위한 완전한 워크아웃 프로그램을 데이터베이스에 초기화
  ///
  /// [userProfile] - 사용자 프로필 (레벨과 시작 날짜 포함)
  /// Returns: 생성된 워크아웃 세션 수
  Future<int> initializeUserProgram(UserProfile userProfile) async {
    final program = generateProgram(userProfile.level);
    int createdSessions = 0;

    for (int week = 1; week <= 6; week++) {
      final weekData = program[week];
      if (weekData == null) continue;

      for (int day = 1; day <= 3; day++) {
        final workout = weekData[day];
        if (workout == null) continue;

        // 워크아웃 날짜 계산 (월, 수, 금)
        final dayMapping = {1: 0, 2: 2, 3: 4}; // 운동 일차 -> 주 내 일차
        final weekOffset = (week - 1) * 7;
        final dayOffset = dayMapping[day] ?? 0;
        final workoutDate = userProfile.startDate.add(
          Duration(days: weekOffset + dayOffset),
        );

        // WorkoutSession 생성
        final session = WorkoutSession(
          id: null, // 자동 생성됨
          week: week,
          day: day,
          date: workoutDate,
          targetReps: workout,
          completedReps: const [],
          isCompleted: false,
          totalReps: getTotalRepsForWorkout(workout),
          totalTime: Duration.zero,
        );

        // 데이터베이스에 저장
        await _databaseService.insertWorkoutSession(session);
        createdSessions++;
      }
    }

    return createdSessions;
  }

  /// 사용자의 워크아웃 프로그램이 이미 초기화되었는지 확인
  ///
  /// [userId] - 사용자 ID
  /// Returns: 초기화 여부
  Future<bool> isProgramInitialized(int userId) async {
    final sessions = await _databaseService.getWorkoutSessionsByUserId(userId);
    return sessions.length >= 18; // 6주 * 3일 = 18세션
  }

  /// 사용자 프로그램 재초기화 (레벨 변경 시 사용)
  ///
  /// [userProfile] - 업데이트된 사용자 프로필
  /// [clearExisting] - 기존 세션 삭제 여부
  /// Returns: 생성된 워크아웃 세션 수
  Future<int> reinitializeUserProgram(
    UserProfile userProfile, {
    bool clearExisting = true,
  }) async {
    if (clearExisting) {
      // 기존 세션들 삭제
      final existingSessions = await _databaseService
          .getWorkoutSessionsByUserId(userProfile.id ?? 1);
      for (final session in existingSessions) {
        if (session.id != null) {
          await _databaseService.deleteWorkoutSession(session.id!);
        }
      }
    }

    // 새 프로그램 초기화
    return await initializeUserProgram(userProfile);
  }
}

/// 오늘의 워크아웃 정보를 담는 클래스
class TodayWorkout {
  final int week;
  final int day;
  final List<int> workout;
  final int totalReps;
  final int restTimeSeconds;

  const TodayWorkout({
    required this.week,
    required this.day,
    required this.workout,
    required this.totalReps,
    required this.restTimeSeconds,
  });

  /// 워크아웃 세트 수
  int get setCount => workout.length;

  /// 평균 세트당 횟수
  double get averageRepsPerSet => totalReps / setCount;

  /// 워크아웃 제목
  String get title => '$week주차 - $day일차';

  /// 워크아웃 설명
  String get description => '$setCount세트, 총 $totalReps회';

  @override
  String toString() {
    return 'TodayWorkout(week: $week, day: $day, sets: $setCount, totalReps: $totalReps)';
  }
}

/// 주간 진행 상황 정보를 담는 클래스
class WeeklyProgress {
  final int currentWeek;
  final int completedWeeks;
  final int completedDaysThisWeek;
  final int totalDaysThisWeek;
  final int weeklyTarget;

  const WeeklyProgress({
    required this.currentWeek,
    required this.completedWeeks,
    required this.completedDaysThisWeek,
    required this.totalDaysThisWeek,
    required this.weeklyTarget,
  });

  /// 이번 주 완료율 (0.0 - 1.0)
  double get weeklyCompletionRate => completedDaysThisWeek / totalDaysThisWeek;

  /// 이번 주 남은 운동일
  int get remainingDaysThisWeek => totalDaysThisWeek - completedDaysThisWeek;

  @override
  String toString() {
    return 'WeeklyProgress(week: $currentWeek, completed: $completedDaysThisWeek/$totalDaysThisWeek)';
  }
}

/// 전체 프로그램 진행 상황 정보를 담는 클래스
class ProgramProgress {
  final WeeklyProgress weeklyProgress;
  final int completedSessions;
  final int totalSessions;
  final int totalCompletedReps;
  final int programTarget;
  final double progressPercentage;
  final bool isCompleted;

  const ProgramProgress({
    required this.weeklyProgress,
    required this.completedSessions,
    required this.totalSessions,
    required this.totalCompletedReps,
    required this.programTarget,
    required this.progressPercentage,
    required this.isCompleted,
  });

  /// 남은 세션 수
  int get remainingSessions => totalSessions - completedSessions;

  /// 남은 횟수
  int get remainingReps => programTarget - totalCompletedReps;

  @override
  String toString() {
    return 'ProgramProgress(sessions: $completedSessions/$totalSessions, reps: $totalCompletedReps/$programTarget, ${(progressPercentage * 100).toStringAsFixed(1)}%)';
  }
}
