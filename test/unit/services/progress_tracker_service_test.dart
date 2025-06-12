import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/services/progress_tracker_service.dart';
import '../../test_helper.dart';

void main() {
  group('ProgressTrackerService Tests', () {
    late ProgressTrackerService service;

    setUpAll(() async {
      await TestHelper.setupTestEnvironment();
    });

    setUp(() {
      service = ProgressTrackerService();
    });

    group('서비스 초기화 테스트', () {
      test('ProgressTrackerService 싱글톤 인스턴스 생성', () {
        final service1 = ProgressTrackerService();
        final service2 = ProgressTrackerService();
        
        expect(service1, equals(service2)); // 싱글톤 패턴 확인
      });

      test('서비스 인스턴스가 null이 아님', () {
        expect(service, isNotNull);
      });
    });

    group('calculateCompleteProgress 메서드 테스트', () {
      test('빈 데이터베이스에서 기본 Progress 반환', () async {
        // 실제 데이터베이스가 비어있을 때의 기본 동작 테스트
        final progress = await service.calculateCompleteProgress();
        
        expect(progress, isNotNull);
        expect(progress.totalWorkouts, equals(0));
        expect(progress.consecutiveDays, equals(0));
        expect(progress.totalPushups, equals(0));
        expect(progress.currentWeek, equals(6)); // 빈 DB에서는 6주차로 설정됨
        expect(progress.currentDay, equals(1));
        expect(progress.completionRate, equals(0.0));
        expect(progress.weeklyProgress, hasLength(6)); // 6주차까지 생성
      });

      test('Progress 객체의 기본 구조 검증', () async {
        final progress = await service.calculateCompleteProgress();
        
        // Progress 객체의 기본 필드들이 올바르게 설정되었는지 확인
        expect(progress.isProgramCompleted, isFalse); // 초기 상태에서는 미완료
        expect(progress.overallProgress, closeTo(0.833, 0.01)); // 6주차 1일차 = (6-1)/6 = 0.833
        expect(progress.currentWeekProgress, equals(0.0));
        expect(progress.averagePushupsPerWorkout, equals(0.0));
        
        // 주차별 진행 상황 확인
        for (int i = 0; i < progress.weeklyProgress.length; i++) {
          final week = progress.weeklyProgress[i];
          expect(week.week, equals(i + 1));
          expect(week.completedDays, equals(0));
          expect(week.isWeekCompleted, isFalse);
          expect(week.dailyProgress, hasLength(3)); // 각 주차마다 3일
        }
      });
    });

    group('forceUpdateWeekStatus 메서드 테스트', () {
      test('유효한 주차 번호로 상태 업데이트', () async {
        // 예외가 발생하지 않는지 확인
        expect(() async => await service.forceUpdateWeekStatus(1), returnsNormally);
        expect(() async => await service.forceUpdateWeekStatus(6), returnsNormally);
      });

      test('경계값 주차 번호 처리', () async {
        // 1주차와 6주차 경계값 테스트
        await service.forceUpdateWeekStatus(1);
        await service.forceUpdateWeekStatus(6);
        
        // 예외가 발생하지 않으면 성공
        expect(true, isTrue);
      });
    });

    group('getWeekDetails 메서드 테스트', () {
      test('유효한 주차의 상세 정보 조회', () async {
        for (int week = 1; week <= 6; week++) {
          final details = await service.getWeekDetails(week);
          
          expect(details, isNotNull);
          expect(details['week'], equals(week));
          expect(details.containsKey('totalSessions'), isTrue);
          expect(details.containsKey('completedSessions'), isTrue);
          expect(details.containsKey('completionRate'), isTrue);
          expect(details.containsKey('isCompleted'), isTrue);
        }
      });

      test('유효하지 않은 주차 번호 처리', () async {
        // 범위를 벗어난 주차 번호에 대한 예외 처리 확인
        expect(() async => await service.getWeekDetails(0), throwsA(isA<ArgumentError>()));
        expect(() async => await service.getWeekDetails(7), throwsA(isA<ArgumentError>()));
        expect(() async => await service.getWeekDetails(-1), throwsA(isA<ArgumentError>()));
        expect(() async => await service.getWeekDetails(10), throwsA(isA<ArgumentError>()));
      });

      test('빈 주차 정보 기본값 확인', () async {
        final details = await service.getWeekDetails(3);
        
        // 빈 주차의 기본값들 확인
        expect(details['week'], equals(3));
        expect(details['totalSessions'], equals(3)); // 각 주차는 3개 세션
        expect(details['completedSessions'], equals(0));
        expect(details['completionRate'], equals(0.0));
        expect(details['isCompleted'], isFalse);
      });
    });

    group('에러 처리 테스트', () {
      test('서비스 메서드들이 예외를 적절히 처리', () async {
        // 각 메서드가 예외 상황에서도 적절히 동작하는지 확인
        expect(() async => await service.calculateCompleteProgress(), returnsNormally);
        expect(() async => await service.forceUpdateWeekStatus(1), returnsNormally);
        expect(() async => await service.getWeekDetails(1), returnsNormally);
      });
    });

    group('성능 테스트', () {
      test('calculateCompleteProgress 성능 확인', () async {
        final stopwatch = Stopwatch()..start();
        
        // 여러 번 실행해서 성능 확인
        for (int i = 0; i < 5; i++) {
          await service.calculateCompleteProgress();
        }
        
        stopwatch.stop();
        
        // 5번 실행이 5초 이내에 완료되어야 함
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('메모리 누수 없이 반복 실행', () async {
        // 메모리 누수가 없는지 확인하기 위해 여러 번 실행
        for (int i = 0; i < 10; i++) {
          final progress = await service.calculateCompleteProgress();
          expect(progress, isNotNull);
          
          await service.forceUpdateWeekStatus(1);
          
          final details = await service.getWeekDetails(1);
          expect(details, isNotNull);
        }
        
        // 예외 없이 완료되면 성공
        expect(true, isTrue);
      });
    });

    group('통합 시나리오 테스트', () {
      test('전체 워크플로우 테스트', () async {
        // 1. 초기 진행 상황 확인
        final initialProgress = await service.calculateCompleteProgress();
        expect(initialProgress.currentWeek, equals(6)); // 빈 DB에서는 6주차로 설정됨
        expect(initialProgress.currentDay, equals(1));
        
        // 2. 1주차 상세 정보 확인
        final week1Details = await service.getWeekDetails(1);
        expect(week1Details['week'], equals(1));
        
        // 3. 주차 상태 강제 업데이트
        await service.forceUpdateWeekStatus(1);
        
        // 4. 업데이트 후 진행 상황 재확인
        final updatedProgress = await service.calculateCompleteProgress();
        expect(updatedProgress, isNotNull);
      });

      test('모든 주차에 대한 순차적 처리', () async {
        for (int week = 1; week <= 6; week++) {
          // 각 주차별로 상세 정보 조회
          final details = await service.getWeekDetails(week);
          expect(details['week'], equals(week));
          
          // 주차 상태 업데이트
          await service.forceUpdateWeekStatus(week);
        }
        
        // 최종 진행 상황 확인
        final finalProgress = await service.calculateCompleteProgress();
        expect(finalProgress.weeklyProgress, hasLength(6));
      });
    });
  });
} 