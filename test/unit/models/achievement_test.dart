import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/models/achievement.dart';

void main() {
  group('Achievement 모델 테스트', () {
    late Achievement testAchievement;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testAchievement = Achievement(
        id: 'test_achievement_1',
        titleKey: 'achievementFirst50Title',
        descriptionKey: 'achievementFirst50Desc',
        motivationKey: 'achievementFirst50Motivation',
        type: AchievementType.volume,
        rarity: AchievementRarity.rare,
        targetValue: 50,
        currentValue: 30,
        isUnlocked: false,
        unlockedAt: null,
        xpReward: 100,
        icon: Icons.fitness_center,
      );
    });

    group('생성자 테스트', () {
      test('기본 생성자로 Achievement 생성', () {
        final achievement = Achievement(
          id: 'basic_test',
          titleKey: 'testTitle',
          descriptionKey: 'testDesc',
          motivationKey: 'testMotivation',
          type: AchievementType.first,
          rarity: AchievementRarity.common,
          targetValue: 10,
          icon: Icons.star,
        );

        expect(achievement.id, 'basic_test');
        expect(achievement.titleKey, 'testTitle');
        expect(achievement.descriptionKey, 'testDesc');
        expect(achievement.motivationKey, 'testMotivation');
        expect(achievement.type, AchievementType.first);
        expect(achievement.rarity, AchievementRarity.common);
        expect(achievement.targetValue, 10);
        expect(achievement.currentValue, 0); // 기본값
        expect(achievement.isUnlocked, false); // 기본값
        expect(achievement.unlockedAt, isNull);
        expect(achievement.xpReward, 0); // 기본값
        expect(achievement.icon, Icons.star);
      });

      test('모든 속성을 포함한 Achievement 생성', () {
        final unlockedAchievement = Achievement(
          id: 'complete_test',
          titleKey: 'completeTitle',
          descriptionKey: 'completeDesc',
          motivationKey: 'completeMotivation',
          type: AchievementType.streak,
          rarity: AchievementRarity.legendary,
          targetValue: 100,
          currentValue: 100,
          isUnlocked: true,
          unlockedAt: testDate,
          xpReward: 500,
          icon: Icons.emoji_events,
        );

        expect(unlockedAchievement.currentValue, 100);
        expect(unlockedAchievement.isUnlocked, true);
        expect(unlockedAchievement.unlockedAt, testDate);
        expect(unlockedAchievement.xpReward, 500);
        expect(unlockedAchievement.rarity, AchievementRarity.legendary);
      });
    });

    group('계산된 속성 테스트', () {
      group('progress getter 테스트', () {
        test('정상적인 진행률 계산', () {
          // currentValue: 30, targetValue: 50
          // 진행률: 30/50 = 0.6
          expect(testAchievement.progress, 0.6);
        });

        test('0% 진행률', () {
          final achievement = testAchievement.copyWith(currentValue: 0);
          expect(achievement.progress, 0.0);
        });

        test('100% 진행률', () {
          final achievement = testAchievement.copyWith(currentValue: 50);
          expect(achievement.progress, 1.0);
        });

        test('목표 초과 진행률', () {
          final achievement = testAchievement.copyWith(currentValue: 75);
          expect(achievement.progress, 1.5);
        });
      });

      group('isCompleted getter 테스트', () {
        test('미완료 상태', () {
          expect(testAchievement.isCompleted, false);
        });

        test('완료 상태 (목표 달성)', () {
          final achievement = testAchievement.copyWith(currentValue: 50);
          expect(achievement.isCompleted, true);
        });

        test('완료 상태 (목표 초과)', () {
          final achievement = testAchievement.copyWith(currentValue: 75);
          expect(achievement.isCompleted, true);
        });
      });

      group('호환성 getter 테스트', () {
        test('이전 버전 호환성 확인', () {
          expect(testAchievement.title, testAchievement.titleKey);
          expect(testAchievement.description, testAchievement.descriptionKey);
          expect(testAchievement.motivationalMessage, testAchievement.motivationKey);
          expect(testAchievement.iconCode, testAchievement.icon.codePoint);
        });
      });
    });

    group('Rarity 관련 테스트', () {
      group('getRarityColor() 메소드 테스트', () {
        test('모든 희귀도별 색상 확인', () {
          final commonAchievement = testAchievement.copyWith(rarity: AchievementRarity.common);
          expect(commonAchievement.getRarityColor(), Colors.grey);

          final rareAchievement = testAchievement.copyWith(rarity: AchievementRarity.rare);
          expect(rareAchievement.getRarityColor(), Colors.blue);

          final epicAchievement = testAchievement.copyWith(rarity: AchievementRarity.epic);
          expect(epicAchievement.getRarityColor(), Colors.purple);

          final legendaryAchievement = testAchievement.copyWith(rarity: AchievementRarity.legendary);
          expect(legendaryAchievement.getRarityColor(), Colors.orange);
        });
      });
    });

    group('copyWith() 메소드 테스트', () {
      test('일부 속성만 변경', () {
        final newAchievement = testAchievement.copyWith(
          currentValue: 45,
          isUnlocked: true,
          unlockedAt: testDate,
        );

        expect(newAchievement.id, testAchievement.id);
        expect(newAchievement.titleKey, testAchievement.titleKey);
        expect(newAchievement.targetValue, testAchievement.targetValue);
        expect(newAchievement.currentValue, 45); // 변경됨
        expect(newAchievement.isUnlocked, true); // 변경됨
        expect(newAchievement.unlockedAt, testDate); // 변경됨
        expect(newAchievement.xpReward, testAchievement.xpReward);
      });

      test('진행률 업데이트', () {
        final progressAchievement = testAchievement.copyWith(currentValue: 25);
        expect(progressAchievement.currentValue, 25);
        expect(progressAchievement.progress, 0.5);
        expect(progressAchievement.isCompleted, false);
      });

      test('완료 상태로 변경', () {
        final completedAchievement = testAchievement.copyWith(
          currentValue: 50,
          isUnlocked: true,
          unlockedAt: testDate,
        );
        expect(completedAchievement.isCompleted, true);
        expect(completedAchievement.isUnlocked, true);
        expect(completedAchievement.progress, 1.0);
      });

      test('모든 속성 변경', () {
        final newIcon = Icons.emoji_events;
        final newDate = DateTime(2024, 2, 20);
        
        final newAchievement = testAchievement.copyWith(
          id: 'new_id',
          titleKey: 'newTitle',
          descriptionKey: 'newDesc',
          motivationKey: 'newMotivation',
          type: AchievementType.perfect,
          rarity: AchievementRarity.legendary,
          targetValue: 100,
          currentValue: 80,
          isUnlocked: true,
          unlockedAt: newDate,
          xpReward: 250,
          icon: newIcon,
        );

        expect(newAchievement.id, 'new_id');
        expect(newAchievement.titleKey, 'newTitle');
        expect(newAchievement.descriptionKey, 'newDesc');
        expect(newAchievement.motivationKey, 'newMotivation');
        expect(newAchievement.type, AchievementType.perfect);
        expect(newAchievement.rarity, AchievementRarity.legendary);
        expect(newAchievement.targetValue, 100);
        expect(newAchievement.currentValue, 80);
        expect(newAchievement.isUnlocked, true);
        expect(newAchievement.unlockedAt, newDate);
        expect(newAchievement.xpReward, 250);
        expect(newAchievement.icon, newIcon);
      });
    });

    group('toMap() 변환 테스트', () {
      test('모든 속성이 올바르게 Map으로 변환', () {
        final unlockedAchievement = testAchievement.copyWith(
          isUnlocked: true,
          unlockedAt: testDate,
        );
        final map = unlockedAchievement.toMap();

        expect(map['id'], 'test_achievement_1');
        expect(map['titleKey'], 'achievementFirst50Title');
        expect(map['descriptionKey'], 'achievementFirst50Desc');
        expect(map['motivationKey'], 'achievementFirst50Motivation');
        expect(map['type'], 'volume');
        expect(map['rarity'], 'rare');
        expect(map['targetValue'], 50);
        expect(map['currentValue'], 30);
        expect(map['isUnlocked'], 1);
        expect(map['unlockedAt'], testDate.toIso8601String());
        expect(map['xpReward'], 100);
        expect(map['icon'], Icons.fitness_center.codePoint);
        expect(map['version'], 1);
        expect(map['lastChecked'], isNotNull);
      });

      test('null unlockedAt 처리', () {
        final map = testAchievement.toMap();
        expect(map['isUnlocked'], 0);
        expect(map['unlockedAt'], isNull);
      });

      test('enum 값들이 문자열로 변환', () {
        final map = testAchievement.toMap();
        expect(map['type'], 'volume');
        expect(map['rarity'], 'rare');
      });
    });

    group('fromMap() 변환 테스트', () {
      test('Map에서 Achievement 생성', () {
        final map = {
          'id': 'map_test',
          'titleKey': 'mapTestTitle',
          'descriptionKey': 'mapTestDesc',
          'motivationKey': 'mapTestMotivation',
          'type': 'streak',
          'rarity': 'epic',
          'targetValue': 75,
          'currentValue': 25,
          'isUnlocked': 1,
          'unlockedAt': testDate.toIso8601String(),
          'xpReward': 150,
          'icon': Icons.star.codePoint,
        };

        final achievement = Achievement.fromMap(map);

        expect(achievement.id, 'map_test');
        expect(achievement.titleKey, 'mapTestTitle');
        expect(achievement.descriptionKey, 'mapTestDesc');
        expect(achievement.motivationKey, 'mapTestMotivation');
        expect(achievement.type, AchievementType.streak);
        expect(achievement.rarity, AchievementRarity.epic);
        expect(achievement.targetValue, 75);
        expect(achievement.currentValue, 25);
        expect(achievement.isUnlocked, true);
        expect(achievement.unlockedAt, testDate);
        expect(achievement.xpReward, 150);
        expect(achievement.icon.codePoint, Icons.star.codePoint);
      });

      test('필수 속성만 있는 Map에서 생성', () {
        final map = {
          'id': 'minimal_test',
          'titleKey': 'minimalTitle',
          'descriptionKey': 'minimalDesc',
          'type': 'first',
          'rarity': 'common',
          'targetValue': 10,
        };

        final achievement = Achievement.fromMap(map);

        expect(achievement.id, 'minimal_test');
        expect(achievement.titleKey, 'minimalTitle');
        expect(achievement.descriptionKey, 'minimalDesc');
        expect(achievement.motivationKey, ''); // 기본값
        expect(achievement.type, AchievementType.first);
        expect(achievement.rarity, AchievementRarity.common);
        expect(achievement.targetValue, 10);
        expect(achievement.currentValue, 0); // 기본값
        expect(achievement.isUnlocked, false); // 기본값
        expect(achievement.unlockedAt, isNull);
        expect(achievement.xpReward, 0); // 기본값
        expect(achievement.icon.codePoint, Icons.star.codePoint); // 기본값
      });

      test('잘못된 enum 값 처리', () {
        final map = {
          'id': 'invalid_enum_test',
          'titleKey': 'invalidTitle',
          'descriptionKey': 'invalidDesc',
          'type': 'invalid_type',
          'rarity': 'invalid_rarity',
          'targetValue': 5,
        };

        final achievement = Achievement.fromMap(map);
        
        // 잘못된 enum 값은 기본값으로 처리되어야 함
        expect(achievement.type, AchievementType.special); // 기본값
        expect(achievement.rarity, AchievementRarity.common); // 기본값
      });

      test('null unlockedAt 처리', () {
        final map = {
          'id': 'null_date_test',
          'titleKey': 'nullDateTitle',
          'descriptionKey': 'nullDateDesc',
          'type': 'volume',
          'rarity': 'rare',
          'targetValue': 20,
          'unlockedAt': null,
        };

        final achievement = Achievement.fromMap(map);
        expect(achievement.unlockedAt, isNull);
      });
    });

    group('AchievementType enum 테스트', () {
      test('모든 AchievementType 값 확인', () {
        expect(AchievementType.values.length, 7);
        expect(AchievementType.values, contains(AchievementType.first));
        expect(AchievementType.values, contains(AchievementType.streak));
        expect(AchievementType.values, contains(AchievementType.volume));
        expect(AchievementType.values, contains(AchievementType.perfect));
        expect(AchievementType.values, contains(AchievementType.special));
        expect(AchievementType.values, contains(AchievementType.challenge));
        expect(AchievementType.values, contains(AchievementType.statistics));
      });
    });

    group('AchievementRarity enum 테스트', () {
      test('모든 AchievementRarity 값 확인', () {
        expect(AchievementRarity.values.length, 4);
        expect(AchievementRarity.values, contains(AchievementRarity.common));
        expect(AchievementRarity.values, contains(AchievementRarity.rare));
        expect(AchievementRarity.values, contains(AchievementRarity.epic));
        expect(AchievementRarity.values, contains(AchievementRarity.legendary));
      });
    });

    group('엣지 케이스 테스트', () {
      test('매우 큰 목표값과 현재값', () {
        final bigAchievement = Achievement(
          id: 'big_test',
          titleKey: 'bigTitle',
          descriptionKey: 'bigDesc',
          motivationKey: 'bigMotivation',
          type: AchievementType.volume,
          rarity: AchievementRarity.legendary,
          targetValue: 1000000,
          currentValue: 500000,
          icon: Icons.star,
        );

        expect(bigAchievement.progress, 0.5);
        expect(bigAchievement.isCompleted, false);
      });

      test('0 목표값 처리', () {
        final zeroTargetAchievement = Achievement(
          id: 'zero_test',
          titleKey: 'zeroTitle',
          descriptionKey: 'zeroDesc',
          motivationKey: 'zeroMotivation',
          type: AchievementType.special,
          rarity: AchievementRarity.common,
          targetValue: 0,
          currentValue: 1,
          icon: Icons.star,
        );

        // 0으로 나누기 방지 확인
        expect(zeroTargetAchievement.progress, double.infinity);
        expect(zeroTargetAchievement.isCompleted, true);
      });

      test('음수 값 처리', () {
        final negativeAchievement = Achievement(
          id: 'negative_test',
          titleKey: 'negativeTitle',
          descriptionKey: 'negativeDesc',
          motivationKey: 'negativeMotivation',
          type: AchievementType.volume,
          rarity: AchievementRarity.common,
          targetValue: 10,
          currentValue: -5,
          icon: Icons.star,
        );

        expect(negativeAchievement.progress, -0.5);
        expect(negativeAchievement.isCompleted, false);
      });
    });
  });
} 