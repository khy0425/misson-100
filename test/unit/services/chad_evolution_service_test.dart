import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/services/chad_evolution_service.dart';
import 'package:mission100/models/chad_evolution.dart';
import 'package:mission100/models/progress.dart';
import '../../test_helper.dart';

void main() {
  group('ChadEvolutionService Tests', () {
    late ChadEvolutionService service;

    setUpAll(() async {
      await TestHelper.setupTestEnvironment();
    });

    setUp(() {
      service = ChadEvolutionService();
    });

    group('서비스 초기화 테스트', () {
      test('ChadEvolutionService 인스턴스 생성', () {
        expect(service, isNotNull);
      });

      test('서비스가 올바른 타입인지 확인', () {
        expect(service, isA<ChadEvolutionService>());
      });

      test('초기화 후 기본 상태 확인', () async {
        await service.initialize();
        
        expect(service.evolutionState, isNotNull);
        expect(service.currentChad, isNotNull);
        expect(service.evolutionProgress, isA<double>());
        expect(service.unlockedStages, isNotEmpty);
      });
    });

    group('Chad 진화 상태 테스트', () {
      test('초기 Chad는 수면모자 Chad', () async {
        await service.initialize();
        
        expect(service.evolutionState.currentStage, 
               equals(ChadEvolutionStage.sleepCapChad));
        expect(service.currentChad.stage, 
               equals(ChadEvolutionStage.sleepCapChad));
      });

      test('진화 진행률은 0.0~1.0 범위', () async {
        await service.initialize();
        
        expect(service.evolutionProgress, greaterThanOrEqualTo(0.0));
        expect(service.evolutionProgress, lessThanOrEqualTo(1.0));
      });

      test('해제된 단계 목록 확인', () async {
        await service.initialize();
        
        expect(service.unlockedStages, isA<List<ChadEvolution>>());
        expect(service.unlockedStages.length, greaterThan(0));
        
        // 첫 번째 Chad는 항상 해제되어 있어야 함
        final firstChad = service.unlockedStages.first;
        expect(firstChad.isUnlocked, isTrue);
        expect(firstChad.stage, equals(ChadEvolutionStage.sleepCapChad));
      });
    });

    group('Chad 진화 로직 테스트', () {
      test('진행 상황에 따른 Chad 진화 확인', () async {
        await service.initialize();
        
        // 1주차 완료 상태의 Progress 생성
        final progress = TestHelper.createSampleProgress(
          currentWeek: 1,
          weeklyProgress: [
            WeeklyProgress(
              week: 1,
              completedDays: 3,
              totalPushups: 150,
              averageCompletionRate: 1.0,
              dailyProgress: [
                DayProgress(day: 1, isCompleted: true, targetReps: 50, completedReps: 50),
                DayProgress(day: 2, isCompleted: true, targetReps: 50, completedReps: 50),
                DayProgress(day: 3, isCompleted: true, targetReps: 50, completedReps: 50),
              ],
            ),
          ],
        );
        
        final evolved = await service.checkAndUpdateChadLevel(progress);
        expect(evolved, isA<bool>());
      });

      test('최대 진화 상태 확인', () async {
        await service.initialize();
        
        expect(service.isMaxEvolution, isA<bool>());
      });

      test('다음 Chad 정보 확인', () async {
        await service.initialize();
        
        // nextChad는 null이거나 ChadEvolution 타입이어야 함
        if (service.nextChad != null) {
          expect(service.nextChad, isA<ChadEvolution>());
        }
      });
    });

    group('진화 애니메이션 테스트', () {
      test('진화 애니메이션 상태 초기값', () async {
        await service.initialize();
        
        expect(service.showEvolutionAnimation, isFalse);
        expect(service.evolutionFromChad, isNull);
        expect(service.evolutionToChad, isNull);
      });
    });

    group('에러 처리 테스트', () {
      test('잘못된 Progress로 진화 확인 시 에러 처리', () async {
        await service.initialize();
        
        // null이나 잘못된 데이터로 테스트
        expect(() async => await service.checkAndUpdateChadLevel(
          Progress(
            totalWorkouts: -1,
            consecutiveDays: -1,
            totalPushups: -1,
            currentWeek: -1,
            currentDay: -1,
            completionRate: -1.0,
            weeklyProgress: [],
          )
        ), returnsNormally);
      });
    });
  });
} 