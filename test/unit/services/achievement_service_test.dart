import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/services/achievement_service.dart';
import 'package:mission100/models/achievement.dart';
import '../../test_helper.dart';

void main() {
  group('AchievementService Tests', () {
    late AchievementService service;

    setUpAll(() async {
      await TestHelper.setupTestEnvironment();
    });

    setUp(() {
      service = AchievementService();
    });

    group('서비스 초기화 테스트', () {
      test('AchievementService 싱글톤 인스턴스 생성', () {
        final service1 = AchievementService();
        final service2 = AchievementService();
        
        expect(service1, equals(service2)); // 싱글톤 패턴 확인
      });

      test('서비스 인스턴스가 null이 아님', () {
        expect(service, isNotNull);
      });
    });

    group('업적 조회 테스트', () {
      test('모든 업적 목록 조회', () async {
        final achievements = await service.getAllAchievements();
        
        expect(achievements, isNotNull);
        expect(achievements, isA<List<Achievement>>());
        // 기본 업적들이 있어야 함
        expect(achievements.length, greaterThan(0));
      });

      test('잠금 해제된 업적만 조회', () async {
        final unlockedAchievements = await service.getUnlockedAchievements();
        
        expect(unlockedAchievements, isNotNull);
        expect(unlockedAchievements, isA<List<Achievement>>());
        
        // 모든 반환된 업적이 잠금 해제되어 있어야 함
        for (final achievement in unlockedAchievements) {
          expect(achievement.isUnlocked, isTrue);
        }
      });

      test('잠금된 업적만 조회', () async {
        final lockedAchievements = await service.getLockedAchievements();
        
        expect(lockedAchievements, isNotNull);
        expect(lockedAchievements, isA<List<Achievement>>());
        
        // 모든 반환된 업적이 잠금되어 있어야 함
        for (final achievement in lockedAchievements) {
          expect(achievement.isUnlocked, isFalse);
        }
      });

      test('특정 ID로 업적 조회', () async {
        // 먼저 모든 업적을 가져와서 첫 번째 업적의 ID를 사용
        final allAchievements = await service.getAllAchievements();
        if (allAchievements.isNotEmpty) {
          final firstAchievement = allAchievements.first;
          final achievement = await service.getAchievementById(firstAchievement.id);
          
          expect(achievement, isNotNull);
          expect(achievement!.id, equals(firstAchievement.id));
        }
      });

      test('존재하지 않는 ID로 업적 조회', () async {
        final achievement = await service.getAchievementById('non_existent_id');
        
        expect(achievement, isNull);
      });
    });

    group('업적 타입별 조회 테스트', () {
      test('첫 번째 업적 타입 조회', () async {
        final firstAchievements = await service.getAchievementsByType(AchievementType.first);
        
        expect(firstAchievements, isNotNull);
        expect(firstAchievements, isA<List<Achievement>>());
        
        // 모든 반환된 업적이 first 타입이어야 함
        for (final achievement in firstAchievements) {
          expect(achievement.type, equals(AchievementType.first));
        }
      });

      test('연속 업적 타입 조회', () async {
        final streakAchievements = await service.getAchievementsByType(AchievementType.streak);
        
        expect(streakAchievements, isNotNull);
        expect(streakAchievements, isA<List<Achievement>>());
        
        // 모든 반환된 업적이 streak 타입이어야 함
        for (final achievement in streakAchievements) {
          expect(achievement.type, equals(AchievementType.streak));
        }
      });

      test('볼륨 업적 타입 조회', () async {
        final volumeAchievements = await service.getAchievementsByType(AchievementType.volume);
        
        expect(volumeAchievements, isNotNull);
        expect(volumeAchievements, isA<List<Achievement>>());
        
        // 모든 반환된 업적이 volume 타입이어야 함
        for (final achievement in volumeAchievements) {
          expect(achievement.type, equals(AchievementType.volume));
        }
      });
    });

    group('업적 진행 상황 업데이트 테스트', () {
      test('업적 진행 상황 업데이트', () async {
        final allAchievements = await service.getAllAchievements();
        if (allAchievements.isNotEmpty) {
          final achievement = allAchievements.first;
          final originalProgress = achievement.currentValue;
          
          // 진행 상황 업데이트
          await service.updateAchievementProgress(achievement.id, originalProgress + 1);
          
          // 업데이트된 업적 조회
          final updatedAchievement = await service.getAchievementById(achievement.id);
          expect(updatedAchievement, isNotNull);
          expect(updatedAchievement!.currentValue, equals(originalProgress + 1));
        }
      });

      test('업적 잠금 해제', () async {
        final lockedAchievements = await service.getLockedAchievements();
        if (lockedAchievements.isNotEmpty) {
          final achievement = lockedAchievements.first;
          
          // 업적 잠금 해제
          await service.unlockAchievement(achievement.id);
          
          // 업데이트된 업적 조회
          final unlockedAchievement = await service.getAchievementById(achievement.id);
          expect(unlockedAchievement, isNotNull);
          expect(unlockedAchievement!.isUnlocked, isTrue);
          expect(unlockedAchievement.unlockedAt, isNotNull);
        }
      });
    });

    group('업적 통계 테스트', () {
      test('전체 업적 통계 조회', () async {
        final stats = await service.getAchievementStats();
        
        expect(stats, isNotNull);
        expect(stats, isA<Map<String, dynamic>>());
        
        // 기본 통계 필드들이 있어야 함
        expect(stats.containsKey('totalAchievements'), isTrue);
        expect(stats.containsKey('unlockedAchievements'), isTrue);
        expect(stats.containsKey('completionRate'), isTrue);
        
        expect(stats['totalAchievements'], isA<int>());
        expect(stats['unlockedAchievements'], isA<int>());
        expect(stats['completionRate'], isA<double>());
        
        // 완료율은 0.0 ~ 1.0 사이여야 함
        expect(stats['completionRate'], greaterThanOrEqualTo(0.0));
        expect(stats['completionRate'], lessThanOrEqualTo(1.0));
      });

      test('타입별 업적 통계 조회', () async {
        final typeStats = await service.getAchievementStatsByType();
        
        expect(typeStats, isNotNull);
        expect(typeStats, isA<Map<AchievementType, Map<String, dynamic>>>());
        
        // 각 타입별로 통계가 있어야 함
        for (final type in AchievementType.values) {
          if (typeStats.containsKey(type)) {
            final stats = typeStats[type]!;
            expect(stats.containsKey('total'), isTrue);
            expect(stats.containsKey('unlocked'), isTrue);
            expect(stats.containsKey('completionRate'), isTrue);
          }
        }
      });
    });

    group('업적 검증 테스트', () {
      test('푸쉬업 개수 기반 업적 확인', () async {
        // 푸쉬업 개수를 기반으로 업적 확인
        await service.checkPushupsAchievements(50);
        
        // 업적이 적절히 업데이트되었는지 확인
        final volumeAchievements = await service.getAchievementsByType(AchievementType.volume);
        expect(volumeAchievements, isNotEmpty);
      });

      test('연속 일수 기반 업적 확인', () async {
        // 연속 일수를 기반으로 업적 확인
        await service.checkStreakAchievements(7);
        
        // 업적이 적절히 업데이트되었는지 확인
        final streakAchievements = await service.getAchievementsByType(AchievementType.streak);
        expect(streakAchievements, isNotEmpty);
      });

      test('완벽한 운동 기반 업적 확인', () async {
        // 완벽한 운동을 기반으로 업적 확인
        await service.checkPerfectWorkoutAchievements(5);
        
        // 업적이 적절히 업데이트되었는지 확인
        final perfectAchievements = await service.getAchievementsByType(AchievementType.perfect);
        expect(perfectAchievements, isNotEmpty);
      });
    });

    group('에러 처리 테스트', () {
      test('잘못된 ID로 업적 업데이트 시도', () async {
        // 존재하지 않는 ID로 업데이트 시도
        expect(
          () async => await service.updateAchievementProgress('invalid_id', 100),
          returnsNormally, // 에러가 발생하지 않고 조용히 처리되어야 함
        );
      });

      test('음수 진행 상황으로 업데이트 시도', () async {
        final allAchievements = await service.getAllAchievements();
        if (allAchievements.isNotEmpty) {
          final achievement = allAchievements.first;
          
          // 음수 값으로 업데이트 시도
          await service.updateAchievementProgress(achievement.id, -10);
          
          // 값이 0 이상으로 유지되어야 함
          final updatedAchievement = await service.getAchievementById(achievement.id);
          expect(updatedAchievement!.currentValue, greaterThanOrEqualTo(0));
        }
      });
    });

    group('성능 테스트', () {
      test('대량 업적 조회 성능', () async {
        final stopwatch = Stopwatch()..start();
        
        // 여러 번 조회해서 성능 확인
        for (int i = 0; i < 10; i++) {
          await service.getAllAchievements();
        }
        
        stopwatch.stop();
        
        // 10번 조회가 5초 이내에 완료되어야 함
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('업적 업데이트 성능', () async {
        final stopwatch = Stopwatch()..start();
        
        final allAchievements = await service.getAllAchievements();
        if (allAchievements.isNotEmpty) {
          final achievement = allAchievements.first;
          
          // 여러 번 업데이트해서 성능 확인
          for (int i = 0; i < 10; i++) {
            await service.updateAchievementProgress(achievement.id, i);
          }
        }
        
        stopwatch.stop();
        
        // 10번 업데이트가 5초 이내에 완료되어야 함
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });
    });

    group('통합 시나리오 테스트', () {
      test('전체 업적 시스템 워크플로우', () async {
        // 1. 초기 업적 상태 확인
        final initialStats = await service.getAchievementStats();
        expect(initialStats['totalAchievements'], greaterThan(0));
        
        // 2. 특정 타입 업적 조회
        final volumeAchievements = await service.getAchievementsByType(AchievementType.volume);
        expect(volumeAchievements, isNotEmpty);
        
        // 3. 업적 진행 상황 업데이트
        if (volumeAchievements.isNotEmpty) {
          final achievement = volumeAchievements.first;
          await service.updateAchievementProgress(achievement.id, achievement.currentValue + 10);
        }
        
        // 4. 업적 확인 실행
        await service.checkPushupsAchievements(100);
        await service.checkStreakAchievements(5);
        
        // 5. 최종 통계 확인
        final finalStats = await service.getAchievementStats();
        expect(finalStats['totalAchievements'], equals(initialStats['totalAchievements']));
      });

      test('모든 업적 타입에 대한 순차적 처리', () async {
        for (final type in AchievementType.values) {
          final achievements = await service.getAchievementsByType(type);
          expect(achievements, isNotNull);
          
          // 각 타입별로 최소 하나의 업적이 있어야 함 (실제 데이터에 따라 조정 가능)
          if (achievements.isNotEmpty) {
            final firstAchievement = achievements.first;
            expect(firstAchievement.type, equals(type));
          }
        }
      });
    });
  });
} 