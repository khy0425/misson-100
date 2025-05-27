import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mission100_chad_pushup/models/achievement.dart';

void main() {
  group('Achievement Model Tests', () {
    test('Achievement 생성 테스트', () {
      // Given: 업적 데이터 (실제 필수 필드들 포함)
      final achievement = Achievement(
        id: 'first_pushup',
        titleKey: 'achievementFirstWorkoutTitle',
        descriptionKey: 'achievementFirstWorkoutDesc',
        motivationKey: 'achievementFirstWorkoutMotivation',
        type: AchievementType.first,
        rarity: AchievementRarity.common,
        targetValue: 1,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 50,
        icon: Icons.fitness_center,
      );

      // Then: 객체가 올바르게 생성되어야 함
      expect(achievement.id, 'first_pushup');
      expect(achievement.titleKey, 'achievementFirstWorkoutTitle');
      expect(achievement.xpReward, 50);
      expect(achievement.type, AchievementType.first);
      expect(achievement.rarity, AchievementRarity.common);
      expect(achievement.isUnlocked, false);
    });

    test('Achievement 진행률 계산 테스트', () {
      // Given: 진행 중인 업적
      final achievement = Achievement(
        id: 'workout_10',
        titleKey: 'achievementWorkout10Title',
        descriptionKey: 'achievementWorkout10Desc',
        motivationKey: 'achievementWorkout10Motivation',
        type: AchievementType.volume,
        rarity: AchievementRarity.rare,
        targetValue: 10,
        currentValue: 7,
        isUnlocked: false,
        xpReward: 100,
        icon: Icons.fitness_center,
      );

      // When: 진행률 계산
      final progress = achievement.progress;

      // Then: 올바른 진행률이 계산되어야 함
      expect(progress, 0.7);
    });

    test('Achievement 완료 상태 테스트', () {
      // Given: 완료된 업적
      final achievement = Achievement(
        id: 'streak_7',
        titleKey: 'achievementStreak7Title',
        descriptionKey: 'achievementStreak7Desc',
        motivationKey: 'achievementStreak7Motivation',
        type: AchievementType.streak,
        rarity: AchievementRarity.epic,
        targetValue: 7,
        currentValue: 7,
        isUnlocked: true,
        unlockedAt: DateTime(2024, 1, 15),
        xpReward: 200,
        icon: Icons.local_fire_department,
      );

      // Then: 완료 상태가 올바르게 표시되어야 함
      expect(achievement.isCompleted, true);
      expect(achievement.progress, 1.0);
      expect(achievement.isUnlocked, true);
      expect(achievement.unlockedAt, isNotNull);
    });

    test('Achievement toMap 변환 테스트', () {
      // Given: Achievement 객체
      final achievement = Achievement(
        id: 'pushup_500',
        titleKey: 'achievementPushup500Title',
        descriptionKey: 'achievementPushup500Desc',
        motivationKey: 'achievementPushup500Motivation',
        type: AchievementType.volume,
        rarity: AchievementRarity.legendary,
        targetValue: 500,
        currentValue: 350,
        isUnlocked: false,
        xpReward: 300,
        icon: Icons.sports_score,
      );

      // When: Map으로 변환
      final map = achievement.toMap();

      // Then: 올바른 Map 구조여야 함
      expect(map['id'], 'pushup_500');
      expect(map['titleKey'], 'achievementPushup500Title');
      expect(map['descriptionKey'], 'achievementPushup500Desc');
      expect(map['motivationKey'], 'achievementPushup500Motivation');
      expect(map['type'], 'volume');
      expect(map['rarity'], 'legendary');
      expect(map['xpReward'], 300);
      expect(map['targetValue'], 500);
      expect(map['currentValue'], 350);
      expect(map['isUnlocked'], 0); // SQLite boolean은 int로 저장
    });

    test('Achievement fromMap 생성 테스트', () {
      // Given: Map 데이터
      final map = {
        'id': 'perfect_week',
        'titleKey': 'achievementPerfectWeekTitle',
        'descriptionKey': 'achievementPerfectWeekDesc',
        'motivationKey': 'achievementPerfectWeekMotivation',
        'type': 'perfect',
        'rarity': 'epic',
        'targetValue': 7,
        'currentValue': 3,
        'isUnlocked': 1,
        'unlockedAt': '2024-01-15T10:30:00.000Z',
        'xpReward': 400,
        'iconCodePoint': Icons.emoji_events.codePoint,
      };

      // When: Map에서 Achievement 생성
      final achievement = Achievement.fromMap(map);

      // Then: 올바른 객체가 생성되어야 함
      expect(achievement.id, 'perfect_week');
      expect(achievement.titleKey, 'achievementPerfectWeekTitle');
      expect(achievement.descriptionKey, 'achievementPerfectWeekDesc');
      expect(achievement.motivationKey, 'achievementPerfectWeekMotivation');
      expect(achievement.type, AchievementType.perfect);
      expect(achievement.rarity, AchievementRarity.epic);
      expect(achievement.xpReward, 400);
      expect(achievement.isUnlocked, true);
      expect(achievement.unlockedAt, isNotNull);
    });

    test('Achievement 타입별 구분 테스트', () {
      // Given: 다양한 타입의 업적들
      final firstAchievement = Achievement(
        id: 'first',
        titleKey: 'achievementFirstTitle',
        descriptionKey: 'achievementFirstDesc',
        motivationKey: 'achievementFirstMotivation',
        type: AchievementType.first,
        rarity: AchievementRarity.common,
        targetValue: 1,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 50,
        icon: Icons.start,
      );

      final streakAchievement = Achievement(
        id: 'streak',
        titleKey: 'achievementStreakTitle',
        descriptionKey: 'achievementStreakDesc',
        motivationKey: 'achievementStreakMotivation',
        type: AchievementType.streak,
        rarity: AchievementRarity.rare,
        targetValue: 7,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 100,
        icon: Icons.local_fire_department,
      );

      final volumeAchievement = Achievement(
        id: 'volume',
        titleKey: 'achievementVolumeTitle',
        descriptionKey: 'achievementVolumeDesc',
        motivationKey: 'achievementVolumeMotivation',
        type: AchievementType.volume,
        rarity: AchievementRarity.epic,
        targetValue: 100,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 200,
        icon: Icons.bar_chart,
      );

      // Then: 타입이 올바르게 구분되어야 함
      expect(firstAchievement.type, AchievementType.first);
      expect(streakAchievement.type, AchievementType.streak);
      expect(volumeAchievement.type, AchievementType.volume);
    });

    test('Achievement 레어도별 색상 테스트', () {
      // Given: 다양한 레어도의 업적들
      final commonAchievement = Achievement(
        id: 'common',
        titleKey: 'achievementCommonTitle',
        descriptionKey: 'achievementCommonDesc',
        motivationKey: 'achievementCommonMotivation',
        type: AchievementType.first,
        rarity: AchievementRarity.common,
        targetValue: 1,
        xpReward: 50,
        icon: Icons.circle,
      );

      final legendaryAchievement = Achievement(
        id: 'legendary',
        titleKey: 'achievementLegendaryTitle',
        descriptionKey: 'achievementLegendaryDesc',
        motivationKey: 'achievementLegendaryMotivation',
        type: AchievementType.special,
        rarity: AchievementRarity.legendary,
        targetValue: 1,
        xpReward: 1000,
        icon: Icons.emoji_events,
      );

      // Then: 레어도에 따른 색상이 올바르게 반환되어야 함
      expect(commonAchievement.getRarityColor(), isA<Color>());
      expect(legendaryAchievement.getRarityColor(), isA<Color>());
    });

    test('Achievement Map 변환 라운드트립 테스트', () {
      // Given: 원본 Achievement 객체
      final original = Achievement(
        id: 'roundtrip_test',
        titleKey: 'achievementRoundtripTitle',
        descriptionKey: 'achievementRoundtripDesc',
        motivationKey: 'achievementRoundtripMotivation',
        type: AchievementType.volume,
        rarity: AchievementRarity.rare,
        targetValue: 1000,
        currentValue: 456,
        isUnlocked: true,
        unlockedAt: DateTime(2024, 1, 15, 14, 30),
        xpReward: 150,
        icon: Icons.refresh,
      );

      // When: Map으로 변환 후 다시 객체로 변환
      final map = original.toMap();
      final restored = Achievement.fromMap(map);

      // Then: 원본과 동일해야 함
      expect(restored.id, original.id);
      expect(restored.titleKey, original.titleKey);
      expect(restored.descriptionKey, original.descriptionKey);
      expect(restored.motivationKey, original.motivationKey);
      expect(restored.type, original.type);
      expect(restored.rarity, original.rarity);
      expect(restored.targetValue, original.targetValue);
      expect(restored.currentValue, original.currentValue);
      expect(restored.isUnlocked, original.isUnlocked);
      expect(restored.xpReward, original.xpReward);
      // 날짜 비교 (밀리초 단위로)
      expect(
        restored.unlockedAt?.millisecondsSinceEpoch,
        original.unlockedAt?.millisecondsSinceEpoch,
      );
    });
  });
}
