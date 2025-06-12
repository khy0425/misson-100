import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/models/progress.dart';
import '../../test_helper.dart';

void main() {
  group('Progress Model Tests', () {
    group('Progress 기본 생성자 테스트', () {
      test('기본값으로 Progress 생성', () {
        final progress = Progress();
        
        expect(progress.totalWorkouts, equals(0));
        expect(progress.consecutiveDays, equals(0));
        expect(progress.totalPushups, equals(0));
        expect(progress.currentWeek, equals(1));
        expect(progress.currentDay, equals(1));
        expect(progress.completionRate, equals(0.0));
        expect(progress.weeklyProgress, isEmpty);
      });

      test('커스텀 값으로 Progress 생성', () {
        final weeklyProgress = [TestHelper.createTestWeeklyProgress()];
        final progress = Progress(
          totalWorkouts: 15,
          consecutiveDays: 10,
          totalPushups: 750,
          currentWeek: 3,
          currentDay: 2,
          completionRate: 0.75,
          weeklyProgress: weeklyProgress,
        );
        
        expect(progress.totalWorkouts, equals(15));
        expect(progress.consecutiveDays, equals(10));
        expect(progress.totalPushups, equals(750));
        expect(progress.currentWeek, equals(3));
        expect(progress.currentDay, equals(2));
        expect(progress.completionRate, equals(0.75));
        expect(progress.weeklyProgress, equals(weeklyProgress));
      });
    });

    group('Progress copyWith 메서드 테스트', () {
      test('일부 필드만 변경하여 복사', () {
        final original = TestHelper.createTestProgress();
        final copied = original.copyWith(
          totalWorkouts: 20,
          currentWeek: 5,
        );
        
        expect(copied.totalWorkouts, equals(20));
        expect(copied.currentWeek, equals(5));
        expect(copied.consecutiveDays, equals(original.consecutiveDays));
        expect(copied.totalPushups, equals(original.totalPushups));
        expect(copied.currentDay, equals(original.currentDay));
        expect(copied.completionRate, equals(original.completionRate));
      });

      test('모든 필드 변경하여 복사', () {
        final original = TestHelper.createTestProgress();
        final newWeeklyProgress = [TestHelper.createTestWeeklyProgress()];
        
        final copied = original.copyWith(
          totalWorkouts: 25,
          consecutiveDays: 15,
          totalPushups: 1000,
          currentWeek: 6,
          currentDay: 3,
          completionRate: 1.0,
          weeklyProgress: newWeeklyProgress,
        );
        
        expect(copied.totalWorkouts, equals(25));
        expect(copied.consecutiveDays, equals(15));
        expect(copied.totalPushups, equals(1000));
        expect(copied.currentWeek, equals(6));
        expect(copied.currentDay, equals(3));
        expect(copied.completionRate, equals(1.0));
        expect(copied.weeklyProgress, equals(newWeeklyProgress));
      });
    });

    group('Progress 계산된 속성 테스트', () {
      test('isProgramCompleted - 6주 이하일 때 false', () {
        final progress = Progress(currentWeek: 6);
        expect(progress.isProgramCompleted, isFalse);
      });

      test('isProgramCompleted - 6주 초과일 때 true', () {
        final progress = Progress(currentWeek: 7);
        expect(progress.isProgramCompleted, isTrue);
      });

      test('currentWeekProgress - 주차별 진행률 계산', () {
        final progress1 = Progress(currentWeek: 3, currentDay: 1);
        expect(progress1.currentWeekProgress, equals(0.0)); // (1-1)/3 = 0

        final progress2 = Progress(currentWeek: 3, currentDay: 2);
        expect(progress2.currentWeekProgress, closeTo(0.333, 0.01)); // (2-1)/3 = 0.333

        final progress3 = Progress(currentWeek: 3, currentDay: 3);
        expect(progress3.currentWeekProgress, closeTo(0.667, 0.01)); // (3-1)/3 = 0.667
      });

      test('currentWeekProgress - 프로그램 완료 시 1.0', () {
        final progress = Progress(currentWeek: 7);
        expect(progress.currentWeekProgress, equals(1.0));
      });

      test('overallProgress - 전체 진행률 계산', () {
        final progress1 = Progress(currentWeek: 1, currentDay: 1);
        expect(progress1.overallProgress, equals(0.0));

        final progress2 = Progress(currentWeek: 3, currentDay: 2);
        final expectedWeekProgress = (3 - 1) / 6.0; // 2/6 = 0.333
        final expectedDayProgress = (2 - 1) / 18.0; // 1/18 = 0.056
        final expectedTotal = expectedWeekProgress + expectedDayProgress;
        expect(progress2.overallProgress, closeTo(expectedTotal, 0.01));

        final progress3 = Progress(currentWeek: 7);
        expect(progress3.overallProgress, equals(1.0));
      });

      test('averagePushupsPerWorkout - 평균 푸쉬업 계산', () {
        final progress1 = Progress(totalWorkouts: 0, totalPushups: 100);
        expect(progress1.averagePushupsPerWorkout, equals(0.0));

        final progress2 = Progress(totalWorkouts: 10, totalPushups: 500);
        expect(progress2.averagePushupsPerWorkout, equals(50.0));

        final progress3 = Progress(totalWorkouts: 8, totalPushups: 320);
        expect(progress3.averagePushupsPerWorkout, equals(40.0));
      });
    });

    group('WeeklyProgress 기본 생성자 테스트', () {
      test('기본값으로 WeeklyProgress 생성', () {
        final weeklyProgress = WeeklyProgress(week: 1);
        
        expect(weeklyProgress.week, equals(1));
        expect(weeklyProgress.completedDays, equals(0));
        expect(weeklyProgress.totalPushups, equals(0));
        expect(weeklyProgress.averageCompletionRate, equals(0.0));
        expect(weeklyProgress.dailyProgress, isEmpty);
      });

      test('커스텀 값으로 WeeklyProgress 생성', () {
        final dailyProgress = [TestHelper.createTestDayProgress()];
        final weeklyProgress = WeeklyProgress(
          week: 3,
          completedDays: 2,
          totalPushups: 150,
          averageCompletionRate: 0.8,
          dailyProgress: dailyProgress,
        );
        
        expect(weeklyProgress.week, equals(3));
        expect(weeklyProgress.completedDays, equals(2));
        expect(weeklyProgress.totalPushups, equals(150));
        expect(weeklyProgress.averageCompletionRate, equals(0.8));
        expect(weeklyProgress.dailyProgress, equals(dailyProgress));
      });
    });

    group('WeeklyProgress copyWith 메서드 테스트', () {
      test('일부 필드만 변경하여 복사', () {
        final original = TestHelper.createTestWeeklyProgress();
        final copied = original.copyWith(
          completedDays: 3,
          totalPushups: 200,
        );
        
        expect(copied.completedDays, equals(3));
        expect(copied.totalPushups, equals(200));
        expect(copied.week, equals(original.week));
        expect(copied.averageCompletionRate, equals(original.averageCompletionRate));
        expect(copied.dailyProgress, equals(original.dailyProgress));
      });
    });

    group('WeeklyProgress 계산된 속성 테스트', () {
      test('isWeekCompleted - 3일 미만 완료 시 false', () {
        final weeklyProgress = WeeklyProgress(week: 1, completedDays: 2);
        expect(weeklyProgress.isWeekCompleted, isFalse);
      });

      test('isWeekCompleted - 3일 이상 완료 시 true (dailyProgress 없음)', () {
        final weeklyProgress = WeeklyProgress(week: 1, completedDays: 3);
        expect(weeklyProgress.isWeekCompleted, isTrue);
      });

      test('isWeekCompleted - dailyProgress로 실제 완료일 검증', () {
        final dailyProgress = [
          TestHelper.createTestDayProgress(day: 1, isCompleted: true),
          TestHelper.createTestDayProgress(day: 2, isCompleted: true),
          TestHelper.createTestDayProgress(day: 3, isCompleted: false),
        ];
        
        final weeklyProgress = WeeklyProgress(
          week: 1,
          completedDays: 3, // 보고된 완료일은 3일
          dailyProgress: dailyProgress, // 실제로는 2일만 완료
        );
        
        expect(weeklyProgress.isWeekCompleted, isFalse); // 실제 완료일이 3일 미만
      });

      test('isWeekCompleted - dailyProgress로 실제 완료일 검증 (완료)', () {
        final dailyProgress = [
          TestHelper.createTestDayProgress(day: 1, isCompleted: true),
          TestHelper.createTestDayProgress(day: 2, isCompleted: true),
          TestHelper.createTestDayProgress(day: 3, isCompleted: true),
        ];
        
        final weeklyProgress = WeeklyProgress(
          week: 1,
          completedDays: 3,
          dailyProgress: dailyProgress,
        );
        
        expect(weeklyProgress.isWeekCompleted, isTrue);
      });

      test('weekCompletionRate - dailyProgress 없을 때', () {
        final weeklyProgress = WeeklyProgress(week: 1, completedDays: 2);
        expect(weeklyProgress.weekCompletionRate, closeTo(0.667, 0.01)); // 2/3
      });

      test('weekCompletionRate - dailyProgress 있을 때', () {
        final dailyProgress = [
          TestHelper.createTestDayProgress(day: 1, isCompleted: true),
          TestHelper.createTestDayProgress(day: 2, isCompleted: false),
          TestHelper.createTestDayProgress(day: 3, isCompleted: true),
        ];
        
        final weeklyProgress = WeeklyProgress(
          week: 1,
          completedDays: 3, // 보고된 완료일
          dailyProgress: dailyProgress, // 실제로는 2일 완료
        );
        
        expect(weeklyProgress.weekCompletionRate, closeTo(0.667, 0.01)); // 2/3
      });

      test('actualCompletedDays - dailyProgress 없을 때', () {
        final weeklyProgress = WeeklyProgress(week: 1, completedDays: 2);
        expect(weeklyProgress.actualCompletedDays, equals(2));
      });

      test('actualCompletedDays - dailyProgress 있을 때', () {
        final dailyProgress = [
          TestHelper.createTestDayProgress(day: 1, isCompleted: true),
          TestHelper.createTestDayProgress(day: 2, isCompleted: false),
          TestHelper.createTestDayProgress(day: 3, isCompleted: true),
        ];
        
        final weeklyProgress = WeeklyProgress(
          week: 1,
          completedDays: 3,
          dailyProgress: dailyProgress,
        );
        
        expect(weeklyProgress.actualCompletedDays, equals(2)); // 실제 완료일
      });
    });

    group('DayProgress 기본 생성자 테스트', () {
      test('기본값으로 DayProgress 생성', () {
        final dayProgress = DayProgress(day: 1);
        
        expect(dayProgress.day, equals(1));
        expect(dayProgress.isCompleted, isFalse);
        expect(dayProgress.targetReps, equals(0));
        expect(dayProgress.completedReps, equals(0));
        expect(dayProgress.completionRate, equals(0.0));
        expect(dayProgress.completedDate, isNull);
      });

      test('커스텀 값으로 DayProgress 생성', () {
        final completedDate = DateTime.now();
        final dayProgress = DayProgress(
          day: 2,
          isCompleted: true,
          targetReps: 50,
          completedReps: 55,
          completionRate: 1.1,
          completedDate: completedDate,
        );
        
        expect(dayProgress.day, equals(2));
        expect(dayProgress.isCompleted, isTrue);
        expect(dayProgress.targetReps, equals(50));
        expect(dayProgress.completedReps, equals(55));
        expect(dayProgress.completionRate, equals(1.1));
        expect(dayProgress.completedDate, equals(completedDate));
      });
    });

    group('DayProgress copyWith 메서드 테스트', () {
      test('일부 필드만 변경하여 복사', () {
        final original = TestHelper.createTestDayProgress();
        final newDate = DateTime.now();
        final copied = original.copyWith(
          isCompleted: true,
          completedDate: newDate,
        );
        
        expect(copied.isCompleted, isTrue);
        expect(copied.completedDate, equals(newDate));
        expect(copied.day, equals(original.day));
        expect(copied.targetReps, equals(original.targetReps));
        expect(copied.completedReps, equals(original.completedReps));
        expect(copied.completionRate, equals(original.completionRate));
      });
    });

    group('통합 시나리오 테스트', () {
      test('완료된 프로그램 시나리오', () {
        final completedProgress = TestHelper.createCompletedProgramProgress();
        
        expect(completedProgress.isProgramCompleted, isTrue);
        expect(completedProgress.overallProgress, equals(1.0));
        expect(completedProgress.totalWorkouts, equals(18));
        expect(completedProgress.weeklyProgress.length, equals(6));
        
        // 모든 주차가 완료되었는지 확인
        for (final week in completedProgress.weeklyProgress) {
          expect(week.isWeekCompleted, isTrue);
          expect(week.actualCompletedDays, equals(3));
        }
      });

      test('진행 중인 프로그램 시나리오', () {
        final weeklyProgress = TestHelper.createSampleWeeklyProgress();
        final progress = Progress(
          totalWorkouts: 6,
          consecutiveDays: 6,
          totalPushups: 300,
          currentWeek: 3,
          currentDay: 1,
          completionRate: 0.4,
          weeklyProgress: weeklyProgress,
        );
        
        expect(progress.isProgramCompleted, isFalse);
        expect(progress.overallProgress, lessThan(1.0));
        expect(progress.averagePushupsPerWorkout, equals(50.0));
        expect(weeklyProgress.last.isWeekCompleted, isFalse); // 마지막 주는 진행 중
      });

      test('빈 프로그램 시나리오', () {
        final progress = Progress();
        
        expect(progress.isProgramCompleted, isFalse);
        expect(progress.overallProgress, equals(0.0));
        expect(progress.currentWeekProgress, equals(0.0));
        expect(progress.averagePushupsPerWorkout, equals(0.0));
      });
    });

    group('엣지 케이스 테스트', () {
      test('경계값 테스트 - 정확히 6주차', () {
        final progress = Progress(currentWeek: 6, currentDay: 3);
        expect(progress.isProgramCompleted, isFalse);
        expect(progress.overallProgress, lessThan(1.0));
      });

      test('경계값 테스트 - 7주차 시작', () {
        final progress = Progress(currentWeek: 7, currentDay: 1);
        expect(progress.isProgramCompleted, isTrue);
        expect(progress.overallProgress, equals(1.0));
      });

      test('음수 값 처리', () {
        final progress = Progress(
          totalWorkouts: -5,
          consecutiveDays: -3,
          totalPushups: -100,
        );
        
        // 음수 값도 그대로 저장되지만, totalWorkouts <= 0이면 0.0 반환
        expect(progress.averagePushupsPerWorkout, equals(0.0)); // totalWorkouts <= 0이므로 0.0
      });

      test('매우 큰 값 처리', () {
        final progress = Progress(
          totalWorkouts: 1000000,
          totalPushups: 50000000,
        );
        
        expect(progress.averagePushupsPerWorkout, equals(50.0));
      });
    });
  });
} 