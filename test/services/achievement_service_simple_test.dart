import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:mission100/models/achievement.dart';

void main() {
  group('AchievementService Simple Tests', () {
    test('PredefinedAchievements의 기본 업적 목록이 존재하는지 테스트', () {
      // Given: PredefinedAchievements의 기본 업적들
      final achievements = PredefinedAchievements.all;

      // Then: 업적 목록이 비어있지 않아야 함
      expect(achievements, isNotEmpty);
      expect(achievements.length, greaterThan(0));

      // 각 업적이 올바른 구조를 가지는지 확인
      for (final achievement in achievements) {
        expect(achievement.id, isNotNull);
        expect(achievement.titleKey, isNotNull);
        expect(achievement.descriptionKey, isNotNull);
        expect(achievement.xpReward, greaterThan(0));
      }
    });

    test('업적 타입별 분류가 올바른지 테스트', () {
      // Given: 기본 업적들
      final achievements = PredefinedAchievements.all;

      // When: 타입별로 분류
      final firstAchievements = achievements
          .where((a) => a.type == AchievementType.first)
          .toList();
      final streakAchievements = achievements
          .where((a) => a.type == AchievementType.streak)
          .toList();
      final volumeAchievements = achievements
          .where((a) => a.type == AchievementType.volume)
          .toList();

      // Then: 각 타입별로 업적이 존재해야 함
      expect(firstAchievements, isNotEmpty);
      expect(streakAchievements, isNotEmpty);
      expect(volumeAchievements, isNotEmpty);
    });

    test('업적 레어도별 분류가 올바른지 테스트', () {
      // Given: 기본 업적들
      final achievements = PredefinedAchievements.all;

      // When: 레어도별로 분류
      final commonAchievements = achievements
          .where((a) => a.rarity == AchievementRarity.common)
          .toList();
      final rareAchievements = achievements
          .where((a) => a.rarity == AchievementRarity.rare)
          .toList();
      final epicAchievements = achievements
          .where((a) => a.rarity == AchievementRarity.epic)
          .toList();
      final legendaryAchievements = achievements
          .where((a) => a.rarity == AchievementRarity.legendary)
          .toList();

      // Then: 각 레어도별로 업적이 존재해야 함
      expect(commonAchievements, isNotEmpty);
      expect(rareAchievements, isNotEmpty);
      expect(epicAchievements, isNotEmpty);
      expect(legendaryAchievements, isNotEmpty);
    });

    test('업적의 XP 보상이 양수인지 테스트', () {
      // Given: 기본 업적들
      final achievements = PredefinedAchievements.all;

      // Then: 모든 업적의 XP 보상이 양수여야 함
      for (final achievement in achievements) {
        expect(achievement.xpReward, greaterThan(0));

        // 디버그: 실제 값들 출력
        debugPrint('${achievement.rarity.name}: ${achievement.xpReward} XP');
      }
    });

    test('특정 업적 ID로 업적을 찾을 수 있는지 테스트', () {
      // Given: 기본 업적들
      final achievements = PredefinedAchievements.all;

      // When: 첫 번째 업적의 ID로 검색
      final firstAchievement = achievements.first;
      final foundAchievement = achievements
          .where((a) => a.id == firstAchievement.id)
          .firstOrNull;

      // Then: 업적을 찾을 수 있어야 함
      expect(foundAchievement, isNotNull);
      expect(foundAchievement!.id, equals(firstAchievement.id));
      expect(foundAchievement.titleKey, equals(firstAchievement.titleKey));
    });

    test('업적 진행률 계산이 올바른지 테스트', () {
      // Given: targetValue가 10인 업적 하나 찾기
      final achievements = PredefinedAchievements.all;
      final testAchievement = achievements
          .where((a) => a.targetValue >= 10)
          .first;

      // When: 정확한 진행률 계산
      final achievement0 = testAchievement.copyWith(currentValue: 0);
      final achievement50 = testAchievement.copyWith(
        currentValue: (testAchievement.targetValue / 2).round(),
      );
      final achievement100 = testAchievement.copyWith(
        currentValue: testAchievement.targetValue,
      );

      // Then: 진행률이 올바르게 계산되어야 함
      expect(achievement0.progress, equals(0.0));
      expect(achievement50.progress, greaterThanOrEqualTo(0.4));
      expect(achievement50.progress, lessThanOrEqualTo(0.6));
      expect(achievement100.progress, equals(1.0));
    });
  });
}
