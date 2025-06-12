import 'package:flutter_test/flutter_test.dart';
import '../../../lib/models/challenge.dart';

void main() {
  group('Challenge Model Tests', () {
    late Challenge testChallenge;
    late DateTime testStartDate;
    late DateTime testEndDate;
    late List<ChallengeReward> testRewards;

    setUp(() {
      testStartDate = DateTime(2024, 1, 15);
      testEndDate = DateTime(2024, 1, 22);
      testRewards = [
        const ChallengeReward(
          type: 'badge',
          value: 'first_week_badge',
          description: 'First week badge',
        ),
        const ChallengeReward(
          type: 'points',
          value: '100',
          description: '100 points',
        ),
      ];

      testChallenge = Challenge(
        id: 'challenge_1',
        titleKey: 'challenge_first_week_title',
        descriptionKey: 'challenge_first_week_desc',
        difficultyKey: 'medium',
        duration: 7,
        targetCount: 21,
        milestones: ['milestone_1', 'milestone_2', 'milestone_3'],
        rewardKey: 'first_week_reward',
        isActive: true,
        startDate: testStartDate,
        endDate: null,
        currentProgress: 15,
        title: 'First Week Challenge',
        description: 'Complete the first week',
        detailedDescription: 'Complete daily workouts for 7 days.',
        type: ChallengeType.consecutiveDays,
        difficulty: ChallengeDifficulty.medium,
        targetValue: 21,
        targetUnit: 'pushups',
        prerequisites: ['onboarding_complete'],
        estimatedDuration: 7,
        rewards: testRewards,
        iconPath: 'assets/icons/first_week.png',
        status: ChallengeStatus.active,
        completionDate: null,
        lastUpdatedAt: testStartDate,
      );
    });

    group('Constructor Tests', () {
      test('Basic Challenge creation', () {
        final challenge = Challenge(
          id: 'test_challenge',
          titleKey: 'test_title',
          descriptionKey: 'test_desc',
          difficultyKey: 'easy',
          duration: 5,
          targetCount: 10,
          milestones: ['test_milestone'],
          rewardKey: 'test_reward',
          isActive: false,
          currentProgress: 0,
        );

        expect(challenge.id, 'test_challenge');
        expect(challenge.titleKey, 'test_title');
        expect(challenge.descriptionKey, 'test_desc');
        expect(challenge.difficultyKey, 'easy');
        expect(challenge.duration, 5);
        expect(challenge.targetCount, 10);
        expect(challenge.milestones, ['test_milestone']);
        expect(challenge.rewardKey, 'test_reward');
        expect(challenge.isActive, false);
        expect(challenge.currentProgress, 0);
        expect(challenge.startDate, isNull);
        expect(challenge.endDate, isNull);
      });

      test('Full Challenge creation', () {
        expect(testChallenge.id, 'challenge_1');
        expect(testChallenge.title, 'First Week Challenge');
        expect(testChallenge.type, ChallengeType.consecutiveDays);
        expect(testChallenge.difficulty, ChallengeDifficulty.medium);
        expect(testChallenge.status, ChallengeStatus.active);
        expect(testChallenge.rewards, testRewards);
        expect(testChallenge.prerequisites, ['onboarding_complete']);
      });
    });

    group('Progress Calculation Tests', () {
      test('Normal progress calculation', () {
        expect(testChallenge.progressPercentage, closeTo(0.714, 0.001));
      });

      test('Zero target returns 0 progress', () {
        final challenge = testChallenge.copyWith(targetCount: 0);
        expect(challenge.progressPercentage, 0.0);
      });

      test('Progress does not exceed 100%', () {
        final challenge = testChallenge.copyWith(currentProgress: 30);
        expect(challenge.progressPercentage, 1.0);
      });

      test('Negative progress is treated as 0', () {
        final challenge = testChallenge.copyWith(currentProgress: -5);
        expect(challenge.progressPercentage, 0.0);
      });
    });

    group('Status Check Methods', () {
      test('Completion status check', () {
        expect(testChallenge.isCompleted, false);
        
        final completedChallenge = testChallenge.copyWith(endDate: testEndDate);
        expect(completedChallenge.isCompleted, true);
      });

      test('Available status check', () {
        expect(testChallenge.isAvailable, false); // has startDate so false
        
        final availableChallenge = Challenge(
          id: 'available_challenge',
          titleKey: 'available_title',
          descriptionKey: 'available_desc',
          difficultyKey: 'easy',
          duration: 5,
          targetCount: 10,
          milestones: ['milestone'],
          rewardKey: 'reward',
          isActive: true,
          currentProgress: 0,
          startDate: null, // explicitly null
        );
        expect(availableChallenge.isAvailable, true); // no startDate so true
      });

      test('Locked status check', () {
        expect(testChallenge.isLocked, false);
        
        final lockedChallenge = testChallenge.copyWith(isActive: false);
        expect(lockedChallenge.isLocked, true);
      });

      test('Failed status check', () {
        expect(testChallenge.isFailed, false);
      });

      test('Started at getter', () {
        expect(testChallenge.startedAt, testStartDate);
      });
    });

    group('Progress Amount Tests', () {
      test('Remaining progress calculation', () {
        expect(testChallenge.remainingProgress, 6);
      });

      test('Remaining progress does not go negative', () {
        final challenge = testChallenge.copyWith(currentProgress: 25);
        expect(challenge.remainingProgress, 0);
      });

      test('Days since start calculation', () {
        final now = DateTime.now();
        final daysDiff = now.difference(testStartDate).inDays;
        expect(testChallenge.daysSinceStart, daysDiff);
      });

      test('Unstarted challenge has 0 days elapsed', () {
        final challenge = Challenge(
          id: 'test_challenge',
          titleKey: 'test_title',
          descriptionKey: 'test_desc',
          difficultyKey: 'easy',
          duration: 5,
          targetCount: 10,
          milestones: ['test_milestone'],
          rewardKey: 'test_reward',
          isActive: false,
          currentProgress: 0,
          startDate: null, // explicitly null
        );
        expect(challenge.daysSinceStart, 0);
      });

      test('Estimated days remaining calculation', () {
        final now = DateTime.now();
        final elapsed = now.difference(testStartDate).inDays;
        final remaining = (7 - elapsed).clamp(0, 7);
        expect(testChallenge.estimatedDaysRemaining, remaining);
      });
    });

    group('copyWith Method Tests', () {
      test('Partial property changes', () {
        final updatedChallenge = testChallenge.copyWith(
          currentProgress: 20,
          isActive: false,
        );

        expect(updatedChallenge.currentProgress, 20);
        expect(updatedChallenge.isActive, false);
        expect(updatedChallenge.id, testChallenge.id);
        expect(updatedChallenge.titleKey, testChallenge.titleKey);
      });

      test('All property changes', () {
        final newRewards = [
          const ChallengeReward(
            type: 'achievement',
            value: 'new_achievement',
            description: 'New achievement',
          ),
        ];

        final updatedChallenge = testChallenge.copyWith(
          id: 'new_id',
          titleKey: 'new_title',
          currentProgress: 25,
          type: ChallengeType.singleSession,
          difficulty: ChallengeDifficulty.hard,
          status: ChallengeStatus.completed,
          rewards: newRewards,
        );

        expect(updatedChallenge.id, 'new_id');
        expect(updatedChallenge.titleKey, 'new_title');
        expect(updatedChallenge.currentProgress, 25);
        expect(updatedChallenge.type, ChallengeType.singleSession);
        expect(updatedChallenge.difficulty, ChallengeDifficulty.hard);
        expect(updatedChallenge.status, ChallengeStatus.completed);
        expect(updatedChallenge.rewards, newRewards);
      });
    });

    group('JSON Serialization Tests', () {
      test('toJson() method', () {
        final json = testChallenge.toJson();

        expect(json['id'], 'challenge_1');
        expect(json['titleKey'], 'challenge_first_week_title');
        expect(json['duration'], 7);
        expect(json['targetCount'], 21);
        expect(json['currentProgress'], 15);
        expect(json['isActive'], true);
        expect(json['startDate'], testStartDate.toIso8601String());
        expect(json['endDate'], isNull);
        expect(json['type'], 'consecutiveDays');
        expect(json['difficulty'], 'medium');
        expect(json['status'], 'active');
        expect(json['milestones'], ['milestone_1', 'milestone_2', 'milestone_3']);
        expect(json['prerequisites'], ['onboarding_complete']);
        expect(json['rewards'], isA<List>());
        expect(json['rewards'].length, 2);
      });

      test('fromJson() method', () {
        final json = {
          'id': 'test_challenge',
          'titleKey': 'test_title',
          'descriptionKey': 'test_desc',
          'difficultyKey': 'hard',
          'duration': 14,
          'targetCount': 50,
          'milestones': ['test_milestone_1', 'test_milestone_2'],
          'rewardKey': 'test_reward',
          'isActive': true,
          'startDate': '2024-01-20T10:00:00.000Z',
          'endDate': null,
          'currentProgress': 25,
          'title': 'Test Challenge',
          'type': 'cumulative',
          'difficulty': 'hard',
          'status': 'active',
          'targetValue': 50,
          'targetUnit': 'reps',
          'prerequisites': ['prerequisite_1'],
          'estimatedDuration': 14,
          'rewards': [
            {
              'type': 'badge',
              'value': 'test_badge',
              'description': 'Test badge'
            }
          ],
          'iconPath': 'assets/test_icon.png',
        };

        final challenge = Challenge.fromJson(json);

        expect(challenge.id, 'test_challenge');
        expect(challenge.titleKey, 'test_title');
        expect(challenge.duration, 14);
        expect(challenge.targetCount, 50);
        expect(challenge.currentProgress, 25);
        expect(challenge.type, ChallengeType.cumulative);
        expect(challenge.difficulty, ChallengeDifficulty.hard);
        expect(challenge.status, ChallengeStatus.active);
        expect(challenge.startDate, DateTime.parse('2024-01-20T10:00:00.000Z'));
        expect(challenge.endDate, isNull);
        expect(challenge.rewards?.length, 1);
        expect(challenge.rewards?.first.type, 'badge');
      });

      test('Empty JSON default handling', () {
        final challenge = Challenge.fromJson({});

        expect(challenge.id, '');
        expect(challenge.titleKey, '');
        expect(challenge.duration, 0);
        expect(challenge.targetCount, 0);
        expect(challenge.currentProgress, 0);
        expect(challenge.isActive, false);
        expect(challenge.milestones, isEmpty);
        expect(challenge.type, isNull);
        expect(challenge.difficulty, isNull);
        expect(challenge.status, isNull);
      });
    });

    group('Equality and hashCode Tests', () {
      test('Same ID Challenges are equal', () {
        final challenge1 = Challenge(
          id: 'same_id',
          titleKey: 'title1',
          descriptionKey: 'desc1',
          difficultyKey: 'easy',
          duration: 5,
          targetCount: 10,
          milestones: [],
          rewardKey: 'reward1',
          isActive: true,
          currentProgress: 5,
        );

        final challenge2 = Challenge(
          id: 'same_id',
          titleKey: 'title2',
          descriptionKey: 'desc2',
          difficultyKey: 'hard',
          duration: 10,
          targetCount: 20,
          milestones: [],
          rewardKey: 'reward2',
          isActive: false,
          currentProgress: 15,
        );

        expect(challenge1, equals(challenge2));
        expect(challenge1.hashCode, equals(challenge2.hashCode));
      });

      test('Different ID Challenges are not equal', () {
        final challenge1 = testChallenge;
        final challenge2 = testChallenge.copyWith(id: 'different_id');

        expect(challenge1, isNot(equals(challenge2)));
        expect(challenge1.hashCode, isNot(equals(challenge2.hashCode)));
      });
    });

    group('toString Method Tests', () {
      test('toString format check', () {
        final result = testChallenge.toString();
        expect(result, contains('Challenge('));
        expect(result, contains('id: challenge_1'));
        expect(result, contains('title: challenge_first_week_title'));
        expect(result, contains('status: Active'));
        expect(result, contains('progress: 15/21'));
      });
    });
  });

  group('ChallengeReward Tests', () {
    test('ChallengeReward creation and properties', () {
      const reward = ChallengeReward(
        type: 'badge',
        value: 'first_badge',
        description: 'First badge',
      );

      expect(reward.type, 'badge');
      expect(reward.value, 'first_badge');
      expect(reward.description, 'First badge');
    });

    test('ChallengeReward JSON serialization', () {
      const reward = ChallengeReward(
        type: 'points',
        value: '500',
        description: '500 points reward',
      );

      final json = reward.toJson();
      expect(json['type'], 'points');
      expect(json['value'], '500');
      expect(json['description'], '500 points reward');

      final fromJson = ChallengeReward.fromJson(json);
      expect(fromJson.type, reward.type);
      expect(fromJson.value, reward.value);
      expect(fromJson.description, reward.description);
    });

    test('ChallengeReward empty JSON handling', () {
      final reward = ChallengeReward.fromJson({});
      expect(reward.type, '');
      expect(reward.value, '');
      expect(reward.description, '');
    });
  });

  group('Enum Tests', () {
    group('ChallengeType Tests', () {
      test('ChallengeType enum values', () {
        expect(ChallengeType.values.length, 3);
        expect(ChallengeType.values, contains(ChallengeType.consecutiveDays));
        expect(ChallengeType.values, contains(ChallengeType.singleSession));
        expect(ChallengeType.values, contains(ChallengeType.cumulative));
      });
    });

    group('ChallengeDifficulty Tests', () {
      test('ChallengeDifficulty emoji check', () {
        expect(ChallengeDifficulty.easy.emoji, '😊');
        expect(ChallengeDifficulty.medium.emoji, '💪');
        expect(ChallengeDifficulty.hard.emoji, '🔥');
        expect(ChallengeDifficulty.extreme.emoji, '💀');
      });

      test('ChallengeDifficulty displayName check', () {
        expect(ChallengeDifficulty.easy.displayName, '쉬움');
        expect(ChallengeDifficulty.medium.displayName, '보통');
        expect(ChallengeDifficulty.hard.displayName, '어려움');
        expect(ChallengeDifficulty.extreme.displayName, '극한');
      });
    });

    group('ChallengeStatus Tests', () {
      test('ChallengeStatus emoji check', () {
        expect(ChallengeStatus.available.emoji, '⭐');
        expect(ChallengeStatus.active.emoji, '⚡');
        expect(ChallengeStatus.completed.emoji, '✅');
        expect(ChallengeStatus.failed.emoji, '❌');
        expect(ChallengeStatus.locked.emoji, '🔒');
      });

      test('ChallengeStatus displayName check', () {
        expect(ChallengeStatus.available.displayName, '참여 가능');
        expect(ChallengeStatus.active.displayName, '진행 중');
        expect(ChallengeStatus.completed.displayName, '완료');
        expect(ChallengeStatus.failed.displayName, '실패');
        expect(ChallengeStatus.locked.displayName, '잠김');
      });
    });
  });

  group('Extension Method Tests', () {
    group('ChallengeDifficultyExtension Tests', () {
      test('String displayName check', () {
        expect('easy'.displayName, '쉬움');
        expect('medium'.displayName, '보통');
        expect('hard'.displayName, '어려움');
        expect('extreme'.displayName, '극한');
      });

      test('String emoji check', () {
        expect('easy'.emoji, '🟢');
        expect('medium'.emoji, '🟡');
        expect('hard'.emoji, '🟠');
        expect('extreme'.emoji, '🔴');
      });

      test('Unknown difficulty throws exception', () {
        expect(() => 'unknown'.displayName, throwsException);
        expect(() => 'unknown'.emoji, throwsException);
      });
    });

    group('ChallengeStatusExtension Tests', () {
      test('Bool displayName check', () {
        expect(true.displayName, 'Active');
        expect(false.displayName, 'Inactive');
      });

      test('Bool emoji check', () {
        expect(true.emoji, '🔥');
        expect(false.emoji, '🔒');
      });
    });
  });
}
