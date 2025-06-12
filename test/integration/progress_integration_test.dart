import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/models/progress.dart';
import 'package:mission100/services/progress_tracker_service.dart';
import '../test_helper.dart';

void main() {
  group('Progress Integration Tests', () {
    late ProgressTrackerService service;

    setUpAll(() async {
      await TestHelper.setupTestEnvironment();
    });

    setUp(() {
      service = ProgressTrackerService();
    });

    group('Progress 모델과 ProgressTrackerService 통합', () {
      test('서비스에서 반환된 Progress 모델이 올바른 구조를 가짐', () async {
        final progress = await service.calculateCompleteProgress();
        
        // Progress 모델의 기본 구조 검증
        expect(progress, isA<Progress>());
        expect(progress.totalWorkouts, isA<int>());
        expect(progress.consecutiveDays, isA<int>());
        expect(progress.totalPushups, isA<int>());
        expect(progress.currentWeek, isA<int>());
        expect(progress.currentDay, isA<int>());
        expect(progress.completionRate, isA<double>());
        expect(progress.weeklyProgress, isA<List<WeeklyProgress>>());
        
        // 계산된 속성들이 올바르게 작동하는지 확인
        expect(progress.currentWeekProgress, isA<double>());
        expect(progress.overallProgress, isA<double>());
        expect(progress.averagePushupsPerWorkout, isA<double>());
        expect(progress.isProgramCompleted, isA<bool>());
      });

      test('WeeklyProgress 모델이 올바른 구조를 가짐', () async {
        final progress = await service.calculateCompleteProgress();
        
        for (final weeklyProgress in progress.weeklyProgress) {
          expect(weeklyProgress, isA<WeeklyProgress>());
          expect(weeklyProgress.week, isA<int>());
          expect(weeklyProgress.completedDays, isA<int>());
          expect(weeklyProgress.totalPushups, isA<int>());
          expect(weeklyProgress.averageCompletionRate, isA<double>());
          expect(weeklyProgress.dailyProgress, isA<List<DayProgress>>());
          
          // 계산된 속성들 확인
          expect(weeklyProgress.isWeekCompleted, isA<bool>());
          expect(weeklyProgress.weekCompletionRate, isA<double>());
          expect(weeklyProgress.actualCompletedDays, isA<int>());
        }
      });

      test('DayProgress 모델이 올바른 구조를 가짐', () async {
        final progress = await service.calculateCompleteProgress();
        
        for (final weeklyProgress in progress.weeklyProgress) {
          for (final dayProgress in weeklyProgress.dailyProgress) {
            expect(dayProgress, isA<DayProgress>());
            expect(dayProgress.day, isA<int>());
            expect(dayProgress.isCompleted, isA<bool>());
            expect(dayProgress.targetReps, isA<int>());
            expect(dayProgress.completedReps, isA<int>());
            expect(dayProgress.completionRate, isA<double>());
            expect(dayProgress.completedDate, isA<DateTime?>());
          }
        }
      });

      test('서비스의 주차별 상세 정보와 Progress 모델의 일관성', () async {
        final progress = await service.calculateCompleteProgress();
        
        for (int week = 1; week <= 6; week++) {
          final weekDetails = await service.getWeekDetails(week);
          
          // 주차별 정보 일관성 확인
          expect(weekDetails['week'], equals(week));
          expect(weekDetails['totalSessions'], equals(3)); // 각 주차는 3개 세션
          expect(weekDetails['isCompleted'], isA<bool>());
        }
      });

      test('Progress 모델의 계산된 속성들이 실제 데이터와 일치', () async {
        final progress = await service.calculateCompleteProgress();
        
        // currentWeekProgress 계산 검증
        final expectedCurrentWeekProgress = (progress.currentDay - 1) / 3.0;
        expect(progress.currentWeekProgress, closeTo(expectedCurrentWeekProgress, 0.01));
        
        // overallProgress 계산 검증
        final expectedOverallProgress = (progress.currentWeek - 1) / 6.0 + 
                                      (progress.currentDay - 1) / 18.0;
        expect(progress.overallProgress, closeTo(expectedOverallProgress, 0.01));
        
        // averagePushupsPerWorkout 계산 검증
        final expectedAverage = progress.totalWorkouts > 0 
            ? progress.totalPushups / progress.totalWorkouts 
            : 0.0;
        expect(progress.averagePushupsPerWorkout, closeTo(expectedAverage, 0.01));
      });

      test('빈 데이터베이스에서의 기본값 일관성', () async {
        final progress = await service.calculateCompleteProgress();
        
        // 빈 DB에서의 기본값들 확인
        expect(progress.totalWorkouts, equals(0));
        expect(progress.consecutiveDays, equals(0));
        expect(progress.totalPushups, equals(0));
        expect(progress.currentWeek, equals(6)); // 빈 DB에서는 6주차로 설정
        expect(progress.currentDay, equals(1));
        expect(progress.completionRate, equals(0.0));
        expect(progress.isProgramCompleted, isFalse);
        
        // 모든 주차가 미완료 상태인지 확인
        for (final weeklyProgress in progress.weeklyProgress) {
          expect(weeklyProgress.isWeekCompleted, isFalse);
          expect(weeklyProgress.completedDays, equals(0));
          expect(weeklyProgress.totalPushups, equals(0));
          expect(weeklyProgress.averageCompletionRate, equals(0.0));
        }
      });

      test('Progress 모델의 copyWith 메서드가 서비스와 호환됨', () async {
        final originalProgress = await service.calculateCompleteProgress();
        
        // copyWith로 새로운 Progress 생성
        final modifiedProgress = originalProgress.copyWith(
          totalWorkouts: 10,
          totalPushups: 500,
          currentWeek: 3,
          currentDay: 2,
        );
        
        // 변경된 값들 확인
        expect(modifiedProgress.totalWorkouts, equals(10));
        expect(modifiedProgress.totalPushups, equals(500));
        expect(modifiedProgress.currentWeek, equals(3));
        expect(modifiedProgress.currentDay, equals(2));
        
        // 변경되지 않은 값들 확인
        expect(modifiedProgress.consecutiveDays, equals(originalProgress.consecutiveDays));
        expect(modifiedProgress.completionRate, equals(originalProgress.completionRate));
        expect(modifiedProgress.weeklyProgress, equals(originalProgress.weeklyProgress));
        
        // 계산된 속성들이 새로운 값으로 업데이트되는지 확인
        expect(modifiedProgress.currentWeekProgress, isNot(equals(originalProgress.currentWeekProgress)));
        expect(modifiedProgress.overallProgress, isNot(equals(originalProgress.overallProgress)));
        expect(modifiedProgress.averagePushupsPerWorkout, isNot(equals(originalProgress.averagePushupsPerWorkout)));
      });
    });

    group('성능 및 안정성 테스트', () {
      test('반복적인 서비스 호출이 일관된 결과를 반환', () async {
        final results = <Progress>[];
        
        // 여러 번 호출하여 일관성 확인
        for (int i = 0; i < 3; i++) {
          final progress = await service.calculateCompleteProgress();
          results.add(progress);
        }
        
        // 모든 결과가 동일한지 확인
        for (int i = 1; i < results.length; i++) {
          expect(results[i].totalWorkouts, equals(results[0].totalWorkouts));
          expect(results[i].currentWeek, equals(results[0].currentWeek));
          expect(results[i].currentDay, equals(results[0].currentDay));
          expect(results[i].weeklyProgress.length, equals(results[0].weeklyProgress.length));
        }
      });

      test('대용량 데이터 처리 시뮬레이션', () async {
        // 기본 Progress 생성
        final baseProgress = await service.calculateCompleteProgress();
        
        // 대용량 weeklyProgress 시뮬레이션
        final largeWeeklyProgress = List.generate(100, (index) => 
          WeeklyProgress(
            week: index + 1,
            completedDays: index % 4,
            totalPushups: index * 50,
            averageCompletionRate: (index % 10) / 10.0,
            dailyProgress: List.generate(3, (dayIndex) =>
              DayProgress(
                day: dayIndex + 1,
                isCompleted: dayIndex < (index % 4),
                targetReps: 50,
                completedReps: dayIndex < (index % 4) ? 50 : 0,
                completionRate: dayIndex < (index % 4) ? 1.0 : 0.0,
                completedDate: dayIndex < (index % 4) ? DateTime.now() : null,
              ),
            ),
          ),
        );
        
        final largeProgress = baseProgress.copyWith(
          weeklyProgress: largeWeeklyProgress,
        );
        
        // 계산된 속성들이 여전히 올바르게 작동하는지 확인
        expect(largeProgress.weeklyProgress.length, equals(100));
        expect(largeProgress.currentWeekProgress, isA<double>());
        expect(largeProgress.overallProgress, isA<double>());
        expect(largeProgress.averagePushupsPerWorkout, isA<double>());
      });
    });
  });
} 