import 'package:flutter/foundation.dart';
import '../models/progress.dart';
import '../models/workout_session.dart';
import 'database_service.dart';

/// 통합된 진행 상황 추적 서비스 (미션 전환 문제 해결)
class ProgressTrackerService {
  static final ProgressTrackerService _instance = ProgressTrackerService._internal();
  factory ProgressTrackerService() => _instance;
  ProgressTrackerService._internal();

  final DatabaseService _databaseService = DatabaseService();

  /// 완전한 진행 상황 계산 (모든 주차 상태 확인)
  Future<Progress> calculateCompleteProgress() async {
    try {
      debugPrint('📊 완전한 진행 상황 계산 시작...');
      
      // 모든 워크아웃 세션 가져오기
      final allSessions = await _databaseService.getAllWorkoutSessions();
      debugPrint('💾 총 ${allSessions.length}개 세션 발견');
      
      // 주차별 진행 상황 계산
      final weeklyProgress = <WeeklyProgress>[];
      int currentWeek = 1;
      int currentDay = 1;
      int totalWorkouts = 0;
      int totalPushups = 0;
      
      for (int week = 1; week <= 6; week++) {
        final weekSessions = allSessions
            .where((session) => session.week == week)
            .toList();
        
        final completedSessions = weekSessions
            .where((session) => session.isCompleted)
            .toList();
        
        // 일일 진행 상황 생성
        final dailyProgress = <DayProgress>[];
        for (int day = 1; day <= 3; day++) {
          final daySession = weekSessions
              .where((session) => session.day == day)
              .firstOrNull;
          
          if (daySession != null) {
            dailyProgress.add(DayProgress(
              day: day,
              isCompleted: daySession.isCompleted,
              targetReps: daySession.targetReps.fold(0, (sum, reps) => sum + reps),
              completedReps: daySession.completedReps?.fold<int>(0, (sum, reps) => sum + reps) ?? 0,
              completionRate: daySession.isCompleted ? 1.0 : 0.0,
              completedDate: daySession.isCompleted ? daySession.date : null,
            ));
            
            if (daySession.isCompleted) {
              totalWorkouts++;
              totalPushups += daySession.totalReps;
            }
          } else {
            dailyProgress.add(DayProgress(day: day));
          }
        }
        
        // 주차 진행 상황 생성
        final weekProgress = WeeklyProgress(
          week: week,
          completedDays: completedSessions.length,
          totalPushups: completedSessions.fold(0, (sum, session) => sum + session.totalReps),
          averageCompletionRate: completedSessions.isEmpty 
              ? 0.0 
              : completedSessions.length / 3.0,
          dailyProgress: dailyProgress,
        );
        
        weeklyProgress.add(weekProgress);
        
        // 현재 주차/일차 업데이트
        if (!weekProgress.isWeekCompleted) {
          currentWeek = week;
          currentDay = weekProgress.actualCompletedDays + 1;
          if (currentDay > 3) {
            currentDay = 3;
          }
        } else if (week == 6 && weekProgress.isWeekCompleted) {
          // 마지막 주차까지 완료된 경우
          currentWeek = 7; // 프로그램 완료
          currentDay = 1;
        }
        
        debugPrint('✅ ${week}주차 상태: ${weekProgress.actualCompletedDays}/3일 완료 (완료: ${weekProgress.isWeekCompleted})');
      }
      
      // 연속 운동일 계산
      final consecutiveDays = await _calculateConsecutiveDays(allSessions);
      
      // 전체 완료율 계산
      final totalPossibleWorkouts = 18; // 6주 * 3일
      final completionRate = totalWorkouts / totalPossibleWorkouts;
      
      final progress = Progress(
        totalWorkouts: totalWorkouts,
        consecutiveDays: consecutiveDays,
        totalPushups: totalPushups,
        currentWeek: currentWeek,
        currentDay: currentDay,
        completionRate: completionRate,
        weeklyProgress: weeklyProgress,
      );
      
      debugPrint('📈 진행 상황 계산 완료: ${currentWeek}주차 ${currentDay}일차 (${(completionRate * 100).toInt()}% 완료)');
      return progress;
      
    } catch (e) {
      debugPrint('❌ 진행 상황 계산 오류: $e');
      rethrow;
    }
  }

  /// 주차 완료 상태 강제 업데이트 (디버깅/수정용)
  Future<void> forceUpdateWeekStatus(int week) async {
    try {
      debugPrint('🔧 ${week}주차 상태 강제 업데이트 시작...');
      
      final weekSessions = await _databaseService.getWorkoutSessionsByWeek(week);
      final completedSessions = weekSessions
          .where((session) => session.isCompleted)
          .toList();
      
      debugPrint('📊 ${week}주차: ${completedSessions.length}/3개 세션 완료');
      
      if (completedSessions.length >= 3) {
        debugPrint('✅ ${week}주차가 완료되었습니다!');
      } else {
        debugPrint('⏸️ ${week}주차가 아직 미완료입니다 (${completedSessions.length}/3)');
      }
      
    } catch (e) {
      debugPrint('❌ 주차 상태 업데이트 오류: $e');
    }
  }

  /// 연속 운동일 계산
  Future<int> _calculateConsecutiveDays(List<WorkoutSession> allSessions) async {
    if (allSessions.isEmpty) return 0;
    
    // 완료된 세션만 필터링하고 날짜순 정렬
    final completedSessions = allSessions
        .where((session) => session.isCompleted)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // 최근 날짜부터
    
    if (completedSessions.isEmpty) return 0;
    
    int consecutiveDays = 0;
    DateTime? lastDate;
    
    for (final session in completedSessions) {
      final sessionDate = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      
      if (lastDate == null) {
        // 첫 번째 세션
        consecutiveDays = 1;
        lastDate = sessionDate;
      } else {
        final daysDifference = lastDate.difference(sessionDate).inDays;
        
        if (daysDifference == 1) {
          // 연속된 날짜
          consecutiveDays++;
          lastDate = sessionDate;
        } else {
          // 연속성이 끊어짐
          break;
        }
      }
    }
    
    debugPrint('🔥 연속 운동일: ${consecutiveDays}일');
    return consecutiveDays;
  }

  /// 특정 주차의 상세 정보 가져오기
  Future<Map<String, dynamic>> getWeekDetails(int week) async {
    try {
      if (week < 1 || week > 6) {
        throw ArgumentError('유효하지 않은 주차: $week (1-6 범위)');
      }
      
      final weekSessions = await _databaseService.getWorkoutSessionsByWeek(week);
      final completedSessions = weekSessions
          .where((session) => session.isCompleted)
          .toList();
      
      final details = {
        'week': week,
        'totalSessions': 3,
        'completedSessions': completedSessions.length,
        'remainingSessions': 3 - completedSessions.length,
        'isCompleted': completedSessions.length >= 3,
        'completionRate': completedSessions.length / 3.0,
        'totalReps': completedSessions.fold(0, (sum, session) => sum + session.totalReps),
        'sessions': weekSessions.map((session) => {
          'day': session.day,
          'isCompleted': session.isCompleted,
          'totalReps': session.totalReps,
          'date': session.date.toIso8601String(),
        }).toList(),
      };
      
      debugPrint('📋 ${week}주차 상세 정보: ${completedSessions.length}/3 완료');
      return details;
      
    } catch (e) {
      debugPrint('❌ 주차 상세 정보 가져오기 오류: $e');
      rethrow;
    }
  }

  /// 진행 상황 진단 (문제 탐지)
  Future<Map<String, dynamic>> diagnoseProblem() async {
    try {
      debugPrint('🔍 진행 상황 진단 시작...');
      
      final progress = await calculateCompleteProgress();
      final issues = <String>[];
      final recommendations = <String>[];
      
      // 주차별 문제 확인
      for (int week = 1; week <= 6; week++) {
        final weekProgress = progress.weeklyProgress
            .where((wp) => wp.week == week)
            .firstOrNull;
        
        if (weekProgress != null) {
          if (weekProgress.completedDays != weekProgress.actualCompletedDays) {
            issues.add('${week}주차: completedDays(${weekProgress.completedDays})와 actualCompletedDays(${weekProgress.actualCompletedDays}) 불일치');
            recommendations.add('${week}주차 데이터 재계산 필요');
          }
          
          if (weekProgress.dailyProgress.length != 3) {
            issues.add('${week}주차: 일일 진행 상황 개수가 3개가 아님 (${weekProgress.dailyProgress.length}개)');
            recommendations.add('${week}주차 일일 진행 상황 재생성 필요');
          }
        } else {
          issues.add('${week}주차: 주차 진행 상황 데이터 없음');
          recommendations.add('${week}주차 데이터 생성 필요');
        }
      }
      
      final diagnosis = {
        'hasIssues': issues.isNotEmpty,
        'issueCount': issues.length,
        'issues': issues,
        'recommendations': recommendations,
        'currentWeek': progress.currentWeek,
        'currentDay': progress.currentDay,
        'totalCompletedWeeks': progress.weeklyProgress
            .where((wp) => wp.isWeekCompleted)
            .length,
        'summary': issues.isEmpty 
            ? '진행 상황 데이터가 정상입니다' 
            : '${issues.length}개의 문제가 발견되었습니다',
      };
      
      debugPrint('📋 진단 완료: ${diagnosis['summary']}');
      return diagnosis;
      
    } catch (e) {
      debugPrint('❌ 진행 상황 진단 오류: $e');
      rethrow;
    }
  }
} 