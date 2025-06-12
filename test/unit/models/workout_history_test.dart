import 'package:flutter_test/flutter_test.dart';
import '../../../lib/models/workout_history.dart';

void main() {
  group('WorkoutHistory Model Tests', () {
    late WorkoutHistory testWorkoutHistory;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testWorkoutHistory = WorkoutHistory(
        id: 'workout_001',
        date: testDate,
        workoutTitle: 'Week 1 Day 1',
        targetReps: [5, 6, 5, 5, 7],
        completedReps: [5, 6, 4, 5, 6],
        totalReps: 26,
        completionRate: 0.93,
        level: 'Rookie Chad',
        duration: const Duration(minutes: 15),
        pushupType: 'Standard Push-up',
      );
    });

    group('Constructor Tests', () {
      test('Basic WorkoutHistory creation', () {
        final history = WorkoutHistory(
          id: 'test_001',
          date: testDate,
          workoutTitle: 'Test Workout',
          targetReps: [10, 15, 10],
          completedReps: [10, 12, 8],
          totalReps: 30,
          completionRate: 0.86,
          level: 'Alpha Chad',
        );

        expect(history.id, 'test_001');
        expect(history.date, testDate);
        expect(history.workoutTitle, 'Test Workout');
        expect(history.targetReps, [10, 15, 10]);
        expect(history.completedReps, [10, 12, 8]);
        expect(history.totalReps, 30);
        expect(history.completionRate, 0.86);
        expect(history.level, 'Alpha Chad');
        expect(history.duration, const Duration(minutes: 10)); // default value
        expect(history.pushupType, 'Push-up'); // default value
      });

      test('WorkoutHistory with custom duration and pushupType', () {
        final history = WorkoutHistory(
          id: 'test_002',
          date: testDate,
          workoutTitle: 'Custom Workout',
          targetReps: [20],
          completedReps: [18],
          totalReps: 18,
          completionRate: 0.9,
          level: 'Giga Chad',
          duration: const Duration(minutes: 25),
          pushupType: 'Diamond Push-up',
        );

        expect(history.duration, const Duration(minutes: 25));
        expect(history.pushupType, 'Diamond Push-up');
      });

      test('WorkoutHistory with all properties', () {
        expect(testWorkoutHistory.id, 'workout_001');
        expect(testWorkoutHistory.date, testDate);
        expect(testWorkoutHistory.workoutTitle, 'Week 1 Day 1');
        expect(testWorkoutHistory.targetReps, [5, 6, 5, 5, 7]);
        expect(testWorkoutHistory.completedReps, [5, 6, 4, 5, 6]);
        expect(testWorkoutHistory.totalReps, 26);
        expect(testWorkoutHistory.completionRate, 0.93);
        expect(testWorkoutHistory.level, 'Rookie Chad');
        expect(testWorkoutHistory.duration, const Duration(minutes: 15));
        expect(testWorkoutHistory.pushupType, 'Standard Push-up');
      });
    });

    group('toMap Method Tests', () {
      test('Convert WorkoutHistory to Map', () {
        final map = testWorkoutHistory.toMap();

        expect(map['id'], 'workout_001');
        expect(map['date'], testDate.toIso8601String());
        expect(map['workoutTitle'], 'Week 1 Day 1');
        expect(map['targetReps'], '5,6,5,5,7');
        expect(map['completedReps'], '5,6,4,5,6');
        expect(map['totalReps'], 26);
        expect(map['completionRate'], 0.93);
        expect(map['level'], 'Rookie Chad');
        expect(map['duration'], 15);
        expect(map['pushupType'], 'Standard Push-up');
      });

      test('Convert WorkoutHistory with default values to Map', () {
        final history = WorkoutHistory(
          id: 'test_default',
          date: testDate,
          workoutTitle: 'Default Test',
          targetReps: [10],
          completedReps: [8],
          totalReps: 8,
          completionRate: 0.8,
          level: 'Test Level',
        );

        final map = history.toMap();

        expect(map['duration'], 10); // default 10 minutes
        expect(map['pushupType'], 'Push-up'); // default pushup type
      });

      test('Convert WorkoutHistory with empty reps lists', () {
        final history = WorkoutHistory(
          id: 'empty_test',
          date: testDate,
          workoutTitle: 'Empty Test',
          targetReps: [],
          completedReps: [],
          totalReps: 0,
          completionRate: 0.0,
          level: 'Test Level',
        );

        final map = history.toMap();

        expect(map['targetReps'], '');
        expect(map['completedReps'], '');
        expect(map['totalReps'], 0);
        expect(map['completionRate'], 0.0);
      });
    });

    group('fromMap Method Tests', () {
      test('Create WorkoutHistory from Map', () {
        final map = {
          'id': 'from_map_001',
          'date': testDate.toIso8601String(),
          'workoutTitle': 'From Map Test',
          'targetReps': '8,10,8,8,12',
          'completedReps': '8,9,7,8,10',
          'totalReps': 42,
          'completionRate': 0.88,
          'level': 'Rising Chad',
          'duration': 20,
          'pushupType': 'Wide Push-up',
        };

        final history = WorkoutHistory.fromMap(map);

        expect(history.id, 'from_map_001');
        expect(history.date, testDate);
        expect(history.workoutTitle, 'From Map Test');
        expect(history.targetReps, [8, 10, 8, 8, 12]);
        expect(history.completedReps, [8, 9, 7, 8, 10]);
        expect(history.totalReps, 42);
        expect(history.completionRate, 0.88);
        expect(history.level, 'Rising Chad');
        expect(history.duration, const Duration(minutes: 20));
        expect(history.pushupType, 'Wide Push-up');
      });

      test('Create WorkoutHistory from Map with missing optional fields', () {
        final map = {
          'id': 'missing_fields',
          'date': testDate.toIso8601String(),
          'workoutTitle': 'Missing Fields Test',
          'targetReps': '5,5,5',
          'completedReps': '4,5,3',
          'totalReps': 12,
          'completionRate': 0.8,
          'level': 'Test Level',
          // duration and pushupType are missing
        };

        final history = WorkoutHistory.fromMap(map);

        expect(history.duration, const Duration(minutes: 10)); // default value
        expect(history.pushupType, 'Push-up'); // default value
        expect(history.id, 'missing_fields');
        expect(history.totalReps, 12);
      });

      test('Create WorkoutHistory from Map with null optional fields', () {
        final map = {
          'id': 'null_fields',
          'date': testDate.toIso8601String(),
          'workoutTitle': 'Null Fields Test',
          'targetReps': '10,10',
          'completedReps': '9,8',
          'totalReps': 17,
          'completionRate': 0.85,
          'level': 'Test Level',
          'duration': null,
          'pushupType': null,
        };

        final history = WorkoutHistory.fromMap(map);

        expect(history.duration, const Duration(minutes: 10)); // default value
        expect(history.pushupType, 'Push-up'); // default value
      });

      test('Create WorkoutHistory from Map with empty reps strings', () {
        final map = {
          'id': 'empty_reps',
          'date': testDate.toIso8601String(),
          'workoutTitle': 'Empty Reps Test',
          'targetReps': '',
          'completedReps': '',
          'totalReps': 0,
          'completionRate': 0.0,
          'level': 'Test Level',
          'duration': 5,
          'pushupType': 'Test Push-up',
        };

        final history = WorkoutHistory.fromMap(map);

        expect(history.targetReps, isEmpty);
        expect(history.completedReps, isEmpty);
        expect(history.totalReps, 0);
        expect(history.completionRate, 0.0);
      });

      test('Create WorkoutHistory from Map with single rep values', () {
        final map = {
          'id': 'single_rep',
          'date': testDate.toIso8601String(),
          'workoutTitle': 'Single Rep Test',
          'targetReps': '50',
          'completedReps': '45',
          'totalReps': 45,
          'completionRate': 0.9,
          'level': 'Test Level',
          'duration': 30,
          'pushupType': 'Single Set Push-up',
        };

        final history = WorkoutHistory.fromMap(map);

        expect(history.targetReps, [50]);
        expect(history.completedReps, [45]);
        expect(history.totalReps, 45);
        expect(history.completionRate, 0.9);
      });
    });

    group('Performance Level Tests', () {
      test('Perfect performance level (100% completion)', () {
        final perfectHistory = WorkoutHistory(
          id: 'perfect',
          date: testDate,
          workoutTitle: 'Perfect Workout',
          targetReps: [10, 10, 10],
          completedReps: [10, 10, 10],
          totalReps: 30,
          completionRate: 1.0,
          level: 'Test Level',
        );

        expect(perfectHistory.getPerformanceLevel(), 'perfect');
      });

      test('Perfect performance level (over 100% completion)', () {
        final overPerfectHistory = WorkoutHistory(
          id: 'over_perfect',
          date: testDate,
          workoutTitle: 'Over Perfect Workout',
          targetReps: [10, 10, 10],
          completedReps: [12, 11, 10],
          totalReps: 33,
          completionRate: 1.1,
          level: 'Test Level',
        );

        expect(overPerfectHistory.getPerformanceLevel(), 'perfect');
      });

      test('Good performance level (80-99% completion)', () {
        final goodHistory = WorkoutHistory(
          id: 'good',
          date: testDate,
          workoutTitle: 'Good Workout',
          targetReps: [10, 10, 10],
          completedReps: [9, 8, 10],
          totalReps: 27,
          completionRate: 0.9,
          level: 'Test Level',
        );

        expect(goodHistory.getPerformanceLevel(), 'good');

        final goodHistoryMin = WorkoutHistory(
          id: 'good_min',
          date: testDate,
          workoutTitle: 'Good Min Workout',
          targetReps: [10, 10, 10],
          completedReps: [8, 8, 8],
          totalReps: 24,
          completionRate: 0.8,
          level: 'Test Level',
        );

        expect(goodHistoryMin.getPerformanceLevel(), 'good');
      });

      test('Okay performance level (50-79% completion)', () {
        final okayHistory = WorkoutHistory(
          id: 'okay',
          date: testDate,
          workoutTitle: 'Okay Workout',
          targetReps: [10, 10, 10],
          completedReps: [7, 6, 8],
          totalReps: 21,
          completionRate: 0.7,
          level: 'Test Level',
        );

        expect(okayHistory.getPerformanceLevel(), 'okay');

        final okayHistoryMin = WorkoutHistory(
          id: 'okay_min',
          date: testDate,
          workoutTitle: 'Okay Min Workout',
          targetReps: [10, 10, 10],
          completedReps: [5, 5, 5],
          totalReps: 15,
          completionRate: 0.5,
          level: 'Test Level',
        );

        expect(okayHistoryMin.getPerformanceLevel(), 'okay');
      });

      test('Poor performance level (below 50% completion)', () {
        final poorHistory = WorkoutHistory(
          id: 'poor',
          date: testDate,
          workoutTitle: 'Poor Workout',
          targetReps: [10, 10, 10],
          completedReps: [3, 4, 5],
          totalReps: 12,
          completionRate: 0.4,
          level: 'Test Level',
        );

        expect(poorHistory.getPerformanceLevel(), 'poor');

        final veryPoorHistory = WorkoutHistory(
          id: 'very_poor',
          date: testDate,
          workoutTitle: 'Very Poor Workout',
          targetReps: [10, 10, 10],
          completedReps: [1, 2, 0],
          totalReps: 3,
          completionRate: 0.1,
          level: 'Test Level',
        );

        expect(veryPoorHistory.getPerformanceLevel(), 'poor');
      });

      test('Zero completion rate', () {
        final zeroHistory = WorkoutHistory(
          id: 'zero',
          date: testDate,
          workoutTitle: 'Zero Workout',
          targetReps: [10, 10, 10],
          completedReps: [0, 0, 0],
          totalReps: 0,
          completionRate: 0.0,
          level: 'Test Level',
        );

        expect(zeroHistory.getPerformanceLevel(), 'poor');
      });
    });

    group('Serialization Round-trip Tests', () {
      test('toMap and fromMap round-trip consistency', () {
        final originalHistory = testWorkoutHistory;
        final map = originalHistory.toMap();
        final reconstructedHistory = WorkoutHistory.fromMap(map);

        expect(reconstructedHistory.id, originalHistory.id);
        expect(reconstructedHistory.date, originalHistory.date);
        expect(reconstructedHistory.workoutTitle, originalHistory.workoutTitle);
        expect(reconstructedHistory.targetReps, originalHistory.targetReps);
        expect(reconstructedHistory.completedReps, originalHistory.completedReps);
        expect(reconstructedHistory.totalReps, originalHistory.totalReps);
        expect(reconstructedHistory.completionRate, originalHistory.completionRate);
        expect(reconstructedHistory.level, originalHistory.level);
        expect(reconstructedHistory.duration, originalHistory.duration);
        expect(reconstructedHistory.pushupType, originalHistory.pushupType);
      });

      test('Round-trip with default values', () {
        final originalHistory = WorkoutHistory(
          id: 'round_trip_default',
          date: testDate,
          workoutTitle: 'Round Trip Default',
          targetReps: [15, 20, 15],
          completedReps: [14, 18, 13],
          totalReps: 45,
          completionRate: 0.9,
          level: 'Test Level',
          // using default duration and pushupType
        );

        final map = originalHistory.toMap();
        final reconstructedHistory = WorkoutHistory.fromMap(map);

        expect(reconstructedHistory.duration, const Duration(minutes: 10));
        expect(reconstructedHistory.pushupType, 'Push-up');
        expect(reconstructedHistory.id, originalHistory.id);
        expect(reconstructedHistory.totalReps, originalHistory.totalReps);
      });

      test('Round-trip with empty reps lists', () {
        final originalHistory = WorkoutHistory(
          id: 'round_trip_empty',
          date: testDate,
          workoutTitle: 'Round Trip Empty',
          targetReps: [],
          completedReps: [],
          totalReps: 0,
          completionRate: 0.0,
          level: 'Test Level',
        );

        final map = originalHistory.toMap();
        final reconstructedHistory = WorkoutHistory.fromMap(map);

        expect(reconstructedHistory.targetReps, isEmpty);
        expect(reconstructedHistory.completedReps, isEmpty);
        expect(reconstructedHistory.totalReps, 0);
        expect(reconstructedHistory.completionRate, 0.0);
      });
    });

    group('Edge Cases Tests', () {
      test('Very large rep numbers', () {
        final largeHistory = WorkoutHistory(
          id: 'large_reps',
          date: testDate,
          workoutTitle: 'Large Reps Test',
          targetReps: [1000, 2000, 1500],
          completedReps: [950, 1800, 1400],
          totalReps: 4150,
          completionRate: 0.92,
          level: 'Legendary Chad',
          duration: const Duration(hours: 2),
          pushupType: 'Endurance Push-up',
        );

        final map = largeHistory.toMap();
        final reconstructed = WorkoutHistory.fromMap(map);

        expect(reconstructed.targetReps, [1000, 2000, 1500]);
        expect(reconstructed.completedReps, [950, 1800, 1400]);
        expect(reconstructed.totalReps, 4150);
        expect(reconstructed.duration, const Duration(hours: 2));
      });

      test('Very long workout title and level names', () {
        final longNameHistory = WorkoutHistory(
          id: 'long_names',
          date: testDate,
          workoutTitle: 'This is a very long workout title that contains many words and should still work properly',
          targetReps: [5],
          completedReps: [5],
          totalReps: 5,
          completionRate: 1.0,
          level: 'Ultra Mega Super Giga Chad Level with Very Long Name',
          pushupType: 'Super Advanced Diamond Wide Grip Push-up Variation',
        );

        final map = longNameHistory.toMap();
        final reconstructed = WorkoutHistory.fromMap(map);

        expect(reconstructed.workoutTitle, longNameHistory.workoutTitle);
        expect(reconstructed.level, longNameHistory.level);
        expect(reconstructed.pushupType, longNameHistory.pushupType);
      });

      test('Zero duration workout', () {
        final zeroDurationHistory = WorkoutHistory(
          id: 'zero_duration',
          date: testDate,
          workoutTitle: 'Zero Duration Test',
          targetReps: [1],
          completedReps: [1],
          totalReps: 1,
          completionRate: 1.0,
          level: 'Test Level',
          duration: Duration.zero,
        );

        final map = zeroDurationHistory.toMap();
        final reconstructed = WorkoutHistory.fromMap(map);

        expect(reconstructed.duration, Duration.zero);
      });
    });
  });
}
