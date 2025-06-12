import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/models/chad_evolution.dart';

void main() {
  group('ChadEvolution Model Tests', () {
    late ChadEvolution testChadEvolution;
    late DateTime testUnlockedAt;

    setUp(() {
      testUnlockedAt = DateTime(2024, 1, 15, 10, 30);
      testChadEvolution = const ChadEvolution(
        stage: ChadEvolutionStage.basicChad,
        name: 'Basic Chad',
        description: 'First evolution completed Chad',
        imagePath: 'assets/images/basic_chad.jpg',
        requiredWeek: 1,
        isUnlocked: true,
        unlockMessage: 'Congratulations! You evolved to Basic Chad!',
      );
    });

    group('Constructor Tests', () {
      test('Basic ChadEvolution creation', () {
        const chad = ChadEvolution(
          stage: ChadEvolutionStage.sleepCapChad,
          name: 'Sleep Cap Chad',
          description: 'Starting Chad',
          imagePath: 'assets/images/sleep_cap_chad.jpg',
          requiredWeek: 0,
          isUnlocked: true,
          unlockMessage: 'Welcome to Mission 100!',
        );

        expect(chad.stage, ChadEvolutionStage.sleepCapChad);
        expect(chad.name, 'Sleep Cap Chad');
        expect(chad.description, 'Starting Chad');
        expect(chad.imagePath, 'assets/images/sleep_cap_chad.jpg');
        expect(chad.requiredWeek, 0);
        expect(chad.isUnlocked, true);
        expect(chad.unlockedAt, isNull);
        expect(chad.unlockMessage, 'Welcome to Mission 100!');
      });

      test('ChadEvolution with unlockedAt', () {
        final chad = ChadEvolution(
          stage: ChadEvolutionStage.coffeeChad,
          name: 'Coffee Chad',
          description: 'Energetic Chad',
          imagePath: 'assets/images/coffee_chad.jpg',
          requiredWeek: 2,
          isUnlocked: true,
          unlockedAt: testUnlockedAt,
          unlockMessage: 'Great! You evolved to Coffee Chad!',
        );

        expect(chad.unlockedAt, testUnlockedAt);
        expect(chad.stage, ChadEvolutionStage.coffeeChad);
        expect(chad.requiredWeek, 2);
      });
    });

    group('Default Stages Tests', () {
      test('Default stages count and order', () {
        expect(ChadEvolution.defaultStages.length, 7);
        expect(ChadEvolution.defaultStages[0].stage, ChadEvolutionStage.sleepCapChad);
        expect(ChadEvolution.defaultStages[1].stage, ChadEvolutionStage.basicChad);
        expect(ChadEvolution.defaultStages[2].stage, ChadEvolutionStage.coffeeChad);
        expect(ChadEvolution.defaultStages[3].stage, ChadEvolutionStage.frontFacingChad);
        expect(ChadEvolution.defaultStages[4].stage, ChadEvolutionStage.sunglassesChad);
        expect(ChadEvolution.defaultStages[5].stage, ChadEvolutionStage.glowingEyesChad);
        expect(ChadEvolution.defaultStages[6].stage, ChadEvolutionStage.doubleChad);
      });

      test('Default stages required weeks', () {
        expect(ChadEvolution.defaultStages[0].requiredWeek, 0);
        expect(ChadEvolution.defaultStages[1].requiredWeek, 1);
        expect(ChadEvolution.defaultStages[2].requiredWeek, 2);
        expect(ChadEvolution.defaultStages[3].requiredWeek, 3);
        expect(ChadEvolution.defaultStages[4].requiredWeek, 4);
        expect(ChadEvolution.defaultStages[5].requiredWeek, 5);
        expect(ChadEvolution.defaultStages[6].requiredWeek, 6);
      });

      test('Default stages unlock status', () {
        expect(ChadEvolution.defaultStages[0].isUnlocked, true); // sleepCapChad starts unlocked
        for (int i = 1; i < ChadEvolution.defaultStages.length; i++) {
          expect(ChadEvolution.defaultStages[i].isUnlocked, false);
        }
      });
    });

    group('Theme Color Tests', () {
      test('Each stage has unique theme color', () {
        const expectedColors = {
          ChadEvolutionStage.sleepCapChad: Color(0xFF9C88FF),
          ChadEvolutionStage.basicChad: Color(0xFF4DABF7),
          ChadEvolutionStage.coffeeChad: Color(0xFF8B4513),
          ChadEvolutionStage.frontFacingChad: Color(0xFF51CF66),
          ChadEvolutionStage.sunglassesChad: Color(0xFF000000),
          ChadEvolutionStage.glowingEyesChad: Color(0xFFFF6B6B),
          ChadEvolutionStage.doubleChad: Color(0xFFFFD43B),
        };

        for (final stage in ChadEvolutionStage.values) {
          final chad = ChadEvolution(
            stage: stage,
            name: 'Test',
            description: 'Test',
            imagePath: 'test.jpg',
            requiredWeek: 0,
            isUnlocked: false,
            unlockMessage: 'Test',
          );
          expect(chad.themeColor, expectedColors[stage]);
        }
      });
    });

    group('Stage Properties Tests', () {
      test('Stage number calculation', () {
        expect(testChadEvolution.stageNumber, 1); // basicChad is index 1
        
        const sleepCapChad = ChadEvolution(
          stage: ChadEvolutionStage.sleepCapChad,
          name: 'Sleep Cap Chad',
          description: 'Starting Chad',
          imagePath: 'test.jpg',
          requiredWeek: 0,
          isUnlocked: true,
          unlockMessage: 'Welcome!',
        );
        expect(sleepCapChad.stageNumber, 0);

        const doubleChad = ChadEvolution(
          stage: ChadEvolutionStage.doubleChad,
          name: 'Double Chad',
          description: 'Final Chad',
          imagePath: 'test.jpg',
          requiredWeek: 6,
          isUnlocked: false,
          unlockMessage: 'Legendary!',
        );
        expect(doubleChad.stageNumber, 6);
      });

      test('Has next stage check', () {
        expect(testChadEvolution.hasNextStage, true); // basicChad has next stages
        
        const doubleChad = ChadEvolution(
          stage: ChadEvolutionStage.doubleChad,
          name: 'Double Chad',
          description: 'Final Chad',
          imagePath: 'test.jpg',
          requiredWeek: 6,
          isUnlocked: false,
          unlockMessage: 'Legendary!',
        );
        expect(doubleChad.hasNextStage, false); // doubleChad is final
      });

      test('Is final stage check', () {
        expect(testChadEvolution.isFinalStage, false); // basicChad is not final
        
        const doubleChad = ChadEvolution(
          stage: ChadEvolutionStage.doubleChad,
          name: 'Double Chad',
          description: 'Final Chad',
          imagePath: 'test.jpg',
          requiredWeek: 6,
          isUnlocked: false,
          unlockMessage: 'Legendary!',
        );
        expect(doubleChad.isFinalStage, true); // doubleChad is final
      });
    });

    group('JSON Serialization Tests', () {
      test('toJson() method', () {
        final chad = ChadEvolution(
          stage: ChadEvolutionStage.coffeeChad,
          name: 'Coffee Chad',
          description: 'Energetic Chad',
          imagePath: 'assets/images/coffee_chad.jpg',
          requiredWeek: 2,
          isUnlocked: true,
          unlockedAt: testUnlockedAt,
          unlockMessage: 'Great evolution!',
        );

        final json = chad.toJson();

        expect(json['stage'], 'coffeeChad');
        expect(json['name'], 'Coffee Chad');
        expect(json['description'], 'Energetic Chad');
        expect(json['imagePath'], 'assets/images/coffee_chad.jpg');
        expect(json['requiredWeek'], 2);
        expect(json['isUnlocked'], true);
        expect(json['unlockedAt'], testUnlockedAt.toIso8601String());
        expect(json['unlockMessage'], 'Great evolution!');
      });

      test('fromJson() method', () {
        final json = {
          'stage': 'sunglassesChad',
          'name': 'Sunglasses Chad',
          'description': 'Cool Chad',
          'imagePath': 'assets/images/sunglasses_chad.jpg',
          'requiredWeek': 4,
          'isUnlocked': false,
          'unlockedAt': null,
          'unlockMessage': 'Cool evolution!',
        };

        final chad = ChadEvolution.fromJson(json);

        expect(chad.stage, ChadEvolutionStage.sunglassesChad);
        expect(chad.name, 'Sunglasses Chad');
        expect(chad.description, 'Cool Chad');
        expect(chad.imagePath, 'assets/images/sunglasses_chad.jpg');
        expect(chad.requiredWeek, 4);
        expect(chad.isUnlocked, false);
        expect(chad.unlockedAt, isNull);
        expect(chad.unlockMessage, 'Cool evolution!');
      });

      test('fromJson() with unlockedAt', () {
        final json = {
          'stage': 'basicChad',
          'name': 'Basic Chad',
          'description': 'First evolution',
          'imagePath': 'assets/images/basic_chad.jpg',
          'requiredWeek': 1,
          'isUnlocked': true,
          'unlockedAt': testUnlockedAt.toIso8601String(),
          'unlockMessage': 'First evolution!',
        };

        final chad = ChadEvolution.fromJson(json);

        expect(chad.unlockedAt, testUnlockedAt);
        expect(chad.isUnlocked, true);
      });

      test('fromJson() with empty/invalid data', () {
        final chad = ChadEvolution.fromJson({});

        expect(chad.stage, ChadEvolutionStage.sleepCapChad); // default fallback
        expect(chad.name, '');
        expect(chad.description, '');
        expect(chad.imagePath, '');
        expect(chad.requiredWeek, 0);
        expect(chad.isUnlocked, false);
        expect(chad.unlockedAt, isNull);
        expect(chad.unlockMessage, '');
      });

      test('fromJson() with invalid stage falls back to sleepCapChad', () {
        final json = {
          'stage': 'invalidStage',
          'name': 'Test Chad',
          'description': 'Test',
          'imagePath': 'test.jpg',
          'requiredWeek': 1,
          'isUnlocked': false,
          'unlockMessage': 'Test',
        };

        final chad = ChadEvolution.fromJson(json);
        expect(chad.stage, ChadEvolutionStage.sleepCapChad);
      });
    });

    group('copyWith Method Tests', () {
      test('Partial property changes', () {
        final updatedChad = testChadEvolution.copyWith(
          isUnlocked: false,
          unlockedAt: testUnlockedAt,
        );

        expect(updatedChad.isUnlocked, false);
        expect(updatedChad.unlockedAt, testUnlockedAt);
        expect(updatedChad.stage, testChadEvolution.stage); // unchanged
        expect(updatedChad.name, testChadEvolution.name); // unchanged
      });

      test('All property changes', () {
        final updatedChad = testChadEvolution.copyWith(
          stage: ChadEvolutionStage.doubleChad,
          name: 'Updated Chad',
          description: 'Updated description',
          imagePath: 'updated/path.jpg',
          requiredWeek: 10,
          isUnlocked: false,
          unlockedAt: testUnlockedAt,
          unlockMessage: 'Updated message',
        );

        expect(updatedChad.stage, ChadEvolutionStage.doubleChad);
        expect(updatedChad.name, 'Updated Chad');
        expect(updatedChad.description, 'Updated description');
        expect(updatedChad.imagePath, 'updated/path.jpg');
        expect(updatedChad.requiredWeek, 10);
        expect(updatedChad.isUnlocked, false);
        expect(updatedChad.unlockedAt, testUnlockedAt);
        expect(updatedChad.unlockMessage, 'Updated message');
      });
    });

    group('Equality and hashCode Tests', () {
      test('Same properties are equal', () {
        const chad1 = ChadEvolution(
          stage: ChadEvolutionStage.basicChad,
          name: 'Basic Chad',
          description: 'First evolution',
          imagePath: 'assets/images/basic_chad.jpg',
          requiredWeek: 1,
          isUnlocked: true,
          unlockMessage: 'Great!',
        );

        const chad2 = ChadEvolution(
          stage: ChadEvolutionStage.basicChad,
          name: 'Basic Chad',
          description: 'First evolution',
          imagePath: 'assets/images/basic_chad.jpg',
          requiredWeek: 1,
          isUnlocked: true,
          unlockMessage: 'Great!',
        );

        expect(chad1, equals(chad2));
        expect(chad1.hashCode, equals(chad2.hashCode));
      });

      test('Different properties are not equal', () {
        const chad1 = ChadEvolution(
          stage: ChadEvolutionStage.basicChad,
          name: 'Basic Chad',
          description: 'First evolution',
          imagePath: 'assets/images/basic_chad.jpg',
          requiredWeek: 1,
          isUnlocked: true,
          unlockMessage: 'Great!',
        );

        const chad2 = ChadEvolution(
          stage: ChadEvolutionStage.coffeeChad,
          name: 'Coffee Chad',
          description: 'Second evolution',
          imagePath: 'assets/images/coffee_chad.jpg',
          requiredWeek: 2,
          isUnlocked: false,
          unlockMessage: 'Awesome!',
        );

        expect(chad1, isNot(equals(chad2)));
        expect(chad1.hashCode, isNot(equals(chad2.hashCode)));
      });
    });

    group('toString Method Tests', () {
      test('toString format check', () {
        final result = testChadEvolution.toString();
        expect(result, contains('ChadEvolution('));
        expect(result, contains('stage: ChadEvolutionStage.basicChad'));
        expect(result, contains('name: Basic Chad'));
        expect(result, contains('isUnlocked: true'));
      });
    });
  });

  group('ChadEvolutionState Model Tests', () {
    late ChadEvolutionState testState;
    late DateTime testLastEvolution;
    late List<ChadEvolution> testUnlockedStages;

    setUp(() {
      testLastEvolution = DateTime(2024, 1, 15, 10, 30);
      testUnlockedStages = [
        ChadEvolution.defaultStages[0], // sleepCapChad
        ChadEvolution.defaultStages[1], // basicChad
      ];
      
      testState = ChadEvolutionState(
        currentStage: ChadEvolutionStage.basicChad,
        unlockedStages: testUnlockedStages,
        lastEvolutionAt: testLastEvolution,
        totalEvolutions: 1,
      );
    });

    group('Constructor Tests', () {
      test('Basic ChadEvolutionState creation', () {
        const state = ChadEvolutionState(
          currentStage: ChadEvolutionStage.sleepCapChad,
          unlockedStages: [],
          totalEvolutions: 0,
        );

        expect(state.currentStage, ChadEvolutionStage.sleepCapChad);
        expect(state.unlockedStages, isEmpty);
        expect(state.lastEvolutionAt, isNull);
        expect(state.totalEvolutions, 0);
      });

      test('Full ChadEvolutionState creation', () {
        expect(testState.currentStage, ChadEvolutionStage.basicChad);
        expect(testState.unlockedStages, testUnlockedStages);
        expect(testState.lastEvolutionAt, testLastEvolution);
        expect(testState.totalEvolutions, 1);
      });
    });

    group('Current Chad Tests', () {
      test('Current chad retrieval', () {
        final currentChad = testState.currentChad;
        expect(currentChad.stage, ChadEvolutionStage.basicChad);
        expect(currentChad.name, '기본 Chad');
      });

      test('Current chad fallback for invalid stage', () {
        // This shouldn't happen in practice, but tests the fallback
        const state = ChadEvolutionState(
          currentStage: ChadEvolutionStage.sleepCapChad,
          unlockedStages: [],
          totalEvolutions: 0,
        );
        
        final currentChad = state.currentChad;
        expect(currentChad.stage, ChadEvolutionStage.sleepCapChad);
      });
    });

    group('Next Chad Tests', () {
      test('Next chad retrieval', () {
        final nextChad = testState.nextChad;
        expect(nextChad, isNotNull);
        expect(nextChad!.stage, ChadEvolutionStage.coffeeChad);
        expect(nextChad.name, '커피 Chad');
      });

      test('Next chad is null for final stage', () {
        const finalState = ChadEvolutionState(
          currentStage: ChadEvolutionStage.doubleChad,
          unlockedStages: [],
          totalEvolutions: 6,
        );
        
        expect(finalState.nextChad, isNull);
      });
    });

    group('Evolution Progress Tests', () {
      test('Evolution progress calculation', () {
        expect(testState.evolutionProgress, closeTo(0.286, 0.001)); // 2/7 ≈ 0.286
      });

      test('Evolution progress for first stage', () {
        const firstState = ChadEvolutionState(
          currentStage: ChadEvolutionStage.sleepCapChad,
          unlockedStages: [],
          totalEvolutions: 0,
        );
        
        expect(firstState.evolutionProgress, closeTo(0.143, 0.001)); // 1/7 ≈ 0.143
      });

      test('Evolution progress for final stage', () {
        const finalState = ChadEvolutionState(
          currentStage: ChadEvolutionStage.doubleChad,
          unlockedStages: [],
          totalEvolutions: 6,
        );
        
        expect(finalState.evolutionProgress, 1.0); // 7/7 = 1.0
      });
    });

    group('Max Evolution Tests', () {
      test('Is max evolution check', () {
        expect(testState.isMaxEvolution, false); // basicChad is not max
        
        const maxState = ChadEvolutionState(
          currentStage: ChadEvolutionStage.doubleChad,
          unlockedStages: [],
          totalEvolutions: 6,
        );
        expect(maxState.isMaxEvolution, true); // doubleChad is max
      });
    });

    group('JSON Serialization Tests', () {
      test('toJson() method', () {
        final json = testState.toJson();

        expect(json['currentStage'], 'basicChad');
        expect(json['unlockedStages'], isA<List>());
        expect(json['unlockedStages'].length, 2);
        expect(json['lastEvolutionAt'], testLastEvolution.toIso8601String());
        expect(json['totalEvolutions'], 1);
      });

      test('fromJson() method', () {
        final json = {
          'currentStage': 'coffeeChad',
          'unlockedStages': [
            {
              'stage': 'sleepCapChad',
              'name': 'Sleep Cap Chad',
              'description': 'Starting Chad',
              'imagePath': 'assets/images/sleep_cap_chad.jpg',
              'requiredWeek': 0,
              'isUnlocked': true,
              'unlockMessage': 'Welcome!',
            },
          ],
          'lastEvolutionAt': testLastEvolution.toIso8601String(),
          'totalEvolutions': 2,
        };

        final state = ChadEvolutionState.fromJson(json);

        expect(state.currentStage, ChadEvolutionStage.coffeeChad);
        expect(state.unlockedStages.length, 1);
        expect(state.unlockedStages[0].stage, ChadEvolutionStage.sleepCapChad);
        expect(state.lastEvolutionAt, testLastEvolution);
        expect(state.totalEvolutions, 2);
      });

      test('fromJson() with empty/invalid data', () {
        final state = ChadEvolutionState.fromJson({});

        expect(state.currentStage, ChadEvolutionStage.sleepCapChad); // default fallback
        expect(state.unlockedStages, isEmpty);
        expect(state.lastEvolutionAt, isNull);
        expect(state.totalEvolutions, 0);
      });
    });

    group('copyWith Method Tests', () {
      test('Partial property changes', () {
        final updatedState = testState.copyWith(
          totalEvolutions: 2,
          lastEvolutionAt: DateTime(2024, 1, 20),
        );

        expect(updatedState.totalEvolutions, 2);
        expect(updatedState.lastEvolutionAt, DateTime(2024, 1, 20));
        expect(updatedState.currentStage, testState.currentStage); // unchanged
        expect(updatedState.unlockedStages, testState.unlockedStages); // unchanged
      });

      test('All property changes', () {
        final newUnlockedStages = [ChadEvolution.defaultStages[0]];
        final newLastEvolution = DateTime(2024, 2, 1);
        
        final updatedState = testState.copyWith(
          currentStage: ChadEvolutionStage.doubleChad,
          unlockedStages: newUnlockedStages,
          lastEvolutionAt: newLastEvolution,
          totalEvolutions: 6,
        );

        expect(updatedState.currentStage, ChadEvolutionStage.doubleChad);
        expect(updatedState.unlockedStages, newUnlockedStages);
        expect(updatedState.lastEvolutionAt, newLastEvolution);
        expect(updatedState.totalEvolutions, 6);
      });
    });

    group('Equality and hashCode Tests', () {
      test('Same properties are equal', () {
        final state1 = ChadEvolutionState(
          currentStage: ChadEvolutionStage.basicChad,
          unlockedStages: testUnlockedStages,
          lastEvolutionAt: testLastEvolution,
          totalEvolutions: 1,
        );

        final state2 = ChadEvolutionState(
          currentStage: ChadEvolutionStage.basicChad,
          unlockedStages: testUnlockedStages,
          lastEvolutionAt: testLastEvolution,
          totalEvolutions: 1,
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('Different properties are not equal', () {
        final state1 = testState;
        final state2 = testState.copyWith(totalEvolutions: 2);

        expect(state1, isNot(equals(state2)));
        expect(state1.hashCode, isNot(equals(state2.hashCode)));
      });
    });

    group('toString Method Tests', () {
      test('toString format check', () {
        final result = testState.toString();
        expect(result, contains('ChadEvolutionState('));
        expect(result, contains('currentStage: ChadEvolutionStage.basicChad'));
        expect(result, contains('totalEvolutions: 1'));
      });
    });
  });

  group('ChadEvolutionStage Enum Tests', () {
    test('Enum values count and order', () {
      expect(ChadEvolutionStage.values.length, 7);
      expect(ChadEvolutionStage.values[0], ChadEvolutionStage.sleepCapChad);
      expect(ChadEvolutionStage.values[1], ChadEvolutionStage.basicChad);
      expect(ChadEvolutionStage.values[2], ChadEvolutionStage.coffeeChad);
      expect(ChadEvolutionStage.values[3], ChadEvolutionStage.frontFacingChad);
      expect(ChadEvolutionStage.values[4], ChadEvolutionStage.sunglassesChad);
      expect(ChadEvolutionStage.values[5], ChadEvolutionStage.glowingEyesChad);
      expect(ChadEvolutionStage.values[6], ChadEvolutionStage.doubleChad);
    });

    test('Enum index values', () {
      expect(ChadEvolutionStage.sleepCapChad.index, 0);
      expect(ChadEvolutionStage.basicChad.index, 1);
      expect(ChadEvolutionStage.coffeeChad.index, 2);
      expect(ChadEvolutionStage.frontFacingChad.index, 3);
      expect(ChadEvolutionStage.sunglassesChad.index, 4);
      expect(ChadEvolutionStage.glowingEyesChad.index, 5);
      expect(ChadEvolutionStage.doubleChad.index, 6);
    });
  });
}
