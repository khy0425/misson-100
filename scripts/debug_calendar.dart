import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../lib/models/workout_history.dart';
import '../lib/services/workout_history_service.dart';

void main() async {
  // FFI 초기화 (Flutter 이외 환경에서 sqflite 사용을 위해)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  print('🚀 캘린더 디버깅 스크립트 시작');
  print('======================================');
  
  try {
    // 데이터베이스 스키마 수정 (필요시)
    print('\n📋 1단계: 데이터베이스 스키마 확인');
    await WorkoutHistoryService.fixSchemaIfNeeded();
    
    // 모든 운동 기록 조회
    print('\n📊 2단계: 운동 기록 데이터 조회');
    final allWorkouts = await WorkoutHistoryService.getAllWorkouts();
    print('총 운동 기록 수: ${allWorkouts.length}개');
    
    if (allWorkouts.isEmpty) {
      print('⚠️ 운동 기록이 없습니다. 실제 운동을 완료한 후 다시 확인하세요.');
      return;
    }
    
    // 데이터 상세 분석
    print('\n🔍 3단계: 데이터 상세 분석');
    print('최근 운동 기록들:');
    for (int i = 0; i < allWorkouts.length && i < 10; i++) {
      final workout = allWorkouts[i];
      print('${i + 1}. ${workout.date} - ${workout.workoutTitle}');
      print('   목표: ${workout.targetReps} | 완료: ${workout.completedReps}');
      print('   총 완료: ${workout.totalReps}회 (${(workout.completionRate * 100).toStringAsFixed(1)}%)');
      print('   레벨: ${workout.level} | 타입: ${workout.pushupType}');
      print('');
    }
    
    // 날짜별 그룹화 테스트 (캘린더 로직과 동일)
    print('\n📅 4단계: 캘린더 날짜별 그룹화 테스트');
    final Map<DateTime, List<WorkoutHistory>> workoutEvents = {};
    
    for (final workout in allWorkouts) {
      final date = DateTime(
        workout.date.year,
        workout.date.month,
        workout.date.day,
      );
      
      if (workoutEvents[date] != null) {
        workoutEvents[date]!.add(workout);
      } else {
        workoutEvents[date] = [workout];
      }
    }
    
    print('그룹화된 날짜 수: ${workoutEvents.keys.length}개');
    print('그룹화된 날짜들:');
    
    final sortedDates = workoutEvents.keys.toList()..sort((a, b) => b.compareTo(a));
    for (int i = 0; i < sortedDates.length && i < 15; i++) {
      final date = sortedDates[i];
      final events = workoutEvents[date]!;
      print('${i + 1}. $date - ${events.length}개 운동');
      
      for (final event in events) {
        final completionRate = (event.completionRate * 100).toStringAsFixed(1);
        print('   - ${event.workoutTitle} ($completionRate%)');
      }
    }
    
    // 색상 계산 테스트
    print('\n🎨 5단계: 색상 계산 테스트');
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    
    // 오늘부터 과거 7일간 확인
    for (int i = 0; i < 7; i++) {
      final checkDate = todayNormalized.subtract(Duration(days: i));
      final events = workoutEvents[checkDate] ?? [];
      
      String colorResult = '투명 (운동 없음)';
      if (events.isNotEmpty) {
        double totalCompletionRate = 0.0;
        
        for (final event in events) {
          // 개별 세트들이 모두 목표를 달성했는지 확인
          bool allSetsCompleted = true;
          if (event.completedReps.isNotEmpty && event.targetReps.isNotEmpty) {
            for (int j = 0; j < event.completedReps.length; j++) {
              final targetRep = j < event.targetReps.length ? event.targetReps[j] : 0;
              final completedRep = event.completedReps[j];
              if (completedRep < targetRep) {
                allSetsCompleted = false;
                break;
              }
            }
          }
          
          if (allSetsCompleted) {
            final totalTarget = event.targetReps.fold(0, (sum, reps) => sum + reps);
            final totalCompleted = event.completedReps.fold(0, (sum, reps) => sum + reps);
            totalCompletionRate += totalTarget > 0 ? totalCompleted / totalTarget : 1.0;
          } else {
            totalCompletionRate += event.completionRate;
          }
        }
        
        final avgCompletionRate = totalCompletionRate / events.length;
        
        if (avgCompletionRate >= 1.0) {
          colorResult = '초록색 (완벽: ${(avgCompletionRate * 100).toStringAsFixed(1)}%)';
        } else if (avgCompletionRate >= 0.8) {
          colorResult = '파란색 (좋음: ${(avgCompletionRate * 100).toStringAsFixed(1)}%)';
        } else if (avgCompletionRate >= 0.5) {
          colorResult = '주황색 (보통: ${(avgCompletionRate * 100).toStringAsFixed(1)}%)';
        } else {
          colorResult = '빨간색 (부족: ${(avgCompletionRate * 100).toStringAsFixed(1)}%)';
        }
      }
      
      print('$checkDate: $colorResult (${events.length}개 운동)');
    }
    
    // 통계 정보
    print('\n📈 6단계: 통계 정보');
    final stats = await WorkoutHistoryService.getStatistics();
    print('총 운동 횟수: ${stats['totalWorkouts']}');
    print('평균 완료율: ${(stats['averageCompletion'] * 100).toStringAsFixed(1)}%');
    print('총 푸쉬업 횟수: ${stats['totalReps']}');
    print('최고 완료율: ${(stats['bestCompletion'] * 100).toStringAsFixed(1)}%');
    
    // 연속 운동일 계산
    final currentStreak = await WorkoutHistoryService.getCurrentStreak();
    print('현재 연속 운동일: ${currentStreak}일');
    
    print('\n✅ 캘린더 디버깅 완료!');
    print('======================================');
    
  } catch (e, stackTrace) {
    print('❌ 오류 발생: $e');
    print('스택 트레이스: $stackTrace');
  }
} 