import 'package:flutter_test/flutter_test.dart';
import '../../../lib/models/workout_session.dart';

void main() {
  group('WorkoutSession 모델 테스트', () {
    late DateTime testDate;
    late WorkoutSession testSession;

    setUp(() {
      testDate = DateTime(2024, 1, 15);
      testSession = WorkoutSession(
        id: 1,
        date: testDate,
        week: 2,
        day: 1,
        targetReps: [5, 6, 4, 4, 5],
        completedReps: [5, 6, 4, 4, 3],
        isCompleted: true,
        totalReps: 22,
        totalTime: const Duration(minutes: 15, seconds: 30),
      );
    });

    group('생성자 테스트', () {
      test('기본 생성자로 WorkoutSession 생성', () {
        final session = WorkoutSession(
          date: testDate,
          week: 1,
          day: 2,
          targetReps: [3, 4, 2, 3, 4],
        );

        expect(session.date, testDate);
        expect(session.week, 1);
        expect(session.day, 2);
        expect(session.targetReps, [3, 4, 2, 3, 4]);
        expect(session.id, isNull);
        expect(session.completedReps, isEmpty);
        expect(session.isCompleted, false);
        expect(session.totalReps, 0);
        expect(session.totalTime, Duration.zero);
      });

      test('모든 속성을 포함한 WorkoutSession 생성', () {
        expect(testSession.id, 1);
        expect(testSession.date, testDate);
        expect(testSession.week, 2);
        expect(testSession.day, 1);
        expect(testSession.targetReps, [5, 6, 4, 4, 5]);
        expect(testSession.completedReps, [5, 6, 4, 4, 3]);
        expect(testSession.isCompleted, true);
        expect(testSession.totalReps, 22);
        expect(testSession.totalTime, const Duration(minutes: 15, seconds: 30));
      });
    });

    group('toMap() 변환 테스트', () {
      test('모든 속성이 올바르게 Map으로 변환', () {
        final map = testSession.toMap();

        expect(map['id'], 1);
        expect(map['date'], '2024-01-15');
        expect(map['week'], 2);
        expect(map['day'], 1);
        expect(map['target_reps'], '5,6,4,4,5');
        expect(map['completed_reps'], '5,6,4,4,3');
        expect(map['is_completed'], 1);
        expect(map['total_reps'], 22);
        expect(map['total_time'], 930); // 15분 30초 = 930초
      });

      test('빈 completedReps가 올바르게 처리', () {
        final session = WorkoutSession(
          date: testDate,
          week: 1,
          day: 1,
          targetReps: [3, 4, 2],
        );
        final map = session.toMap();

        expect(map['completed_reps'], '');
        expect(map['is_completed'], 0);
        expect(map['total_reps'], 0);
        expect(map['total_time'], 0);
      });
    });

    group('fromMap() 변환 테스트', () {
      test('Map에서 WorkoutSession 생성', () {
        final map = {
          'id': 2,
          'date': '2024-02-20',
          'week': 3,
          'day': 2,
          'target_reps': '7,8,6,6,7',
          'completed_reps': '7,8,6,5,7',
          'is_completed': 1,
          'total_reps': 33,
          'total_time': 1200, // 20분
        };

        final session = WorkoutSession.fromMap(map);

        expect(session.id, 2);
        expect(session.date, DateTime(2024, 2, 20));
        expect(session.week, 3);
        expect(session.day, 2);
        expect(session.targetReps, [7, 8, 6, 6, 7]);
        expect(session.completedReps, [7, 8, 6, 5, 7]);
        expect(session.isCompleted, true);
        expect(session.totalReps, 33);
        expect(session.totalTime, const Duration(minutes: 20));
      });

      test('필수 속성만 있는 Map에서 생성', () {
        final map = {
          'date': '2024-01-01',
          'week': 1,
          'day': 1,
          'target_reps': '2,3,2',
          'completed_reps': '',
          'is_completed': 0,
        };

        final session = WorkoutSession.fromMap(map);

        expect(session.date, DateTime(2024, 1, 1));
        expect(session.week, 1);
        expect(session.day, 1);
        expect(session.targetReps, [2, 3, 2]);
        expect(session.completedReps, isEmpty);
        expect(session.isCompleted, false);
        expect(session.id, isNull);
        expect(session.totalReps, 0);
        expect(session.totalTime, Duration.zero);
      });

      test('빈 target_reps 문자열 처리', () {
        final map = {
          'date': '2024-01-01',
          'week': 1,
          'day': 1,
          'target_reps': '',
          'completed_reps': '',
          'is_completed': 0,
        };

        final session = WorkoutSession.fromMap(map);
        expect(session.targetReps, isEmpty);
        expect(session.completedReps, isEmpty);
      });
    });

    group('copyWith() 메소드 테스트', () {
      test('일부 속성만 변경', () {
        final newSession = testSession.copyWith(
          isCompleted: false,
          totalReps: 20,
        );

        expect(newSession.id, testSession.id);
        expect(newSession.date, testSession.date);
        expect(newSession.week, testSession.week);
        expect(newSession.day, testSession.day);
        expect(newSession.targetReps, testSession.targetReps);
        expect(newSession.completedReps, testSession.completedReps);
        expect(newSession.isCompleted, false); // 변경됨
        expect(newSession.totalReps, 20); // 변경됨
        expect(newSession.totalTime, testSession.totalTime);
      });

      test('completedReps 업데이트', () {
        final newCompletedReps = [5, 6, 4, 4, 5];
        final newSession = testSession.copyWith(
          completedReps: newCompletedReps,
          totalReps: 24,
          isCompleted: true,
        );

        expect(newSession.completedReps, newCompletedReps);
        expect(newSession.totalReps, 24);
        expect(newSession.isCompleted, true);
      });

      test('모든 속성 변경', () {
        final newDate = DateTime(2024, 3, 10);
        final newTargetReps = [10, 12, 8, 8, 10];
        final newCompletedReps = [10, 12, 8, 8, 9];
        final newTotalTime = const Duration(minutes: 25);

        final newSession = testSession.copyWith(
          id: 5,
          date: newDate,
          week: 4,
          day: 3,
          targetReps: newTargetReps,
          completedReps: newCompletedReps,
          isCompleted: false,
          totalReps: 47,
          totalTime: newTotalTime,
        );

        expect(newSession.id, 5);
        expect(newSession.date, newDate);
        expect(newSession.week, 4);
        expect(newSession.day, 3);
        expect(newSession.targetReps, newTargetReps);
        expect(newSession.completedReps, newCompletedReps);
        expect(newSession.isCompleted, false);
        expect(newSession.totalReps, 47);
        expect(newSession.totalTime, newTotalTime);
      });
    });

    group('계산된 속성 테스트', () {
      group('completionRate getter 테스트', () {
        test('정상적인 완료율 계산', () {
          // targetReps: [5, 6, 4, 4, 5] = 24
          // completedReps: [5, 6, 4, 4, 3] = 22
          // 완료율: 22/24 = 0.9166...
          expect(testSession.completionRate, closeTo(0.9167, 0.0001));
        });

        test('100% 완료율', () {
          final session = testSession.copyWith(
            completedReps: [5, 6, 4, 4, 5], // 목표와 동일
          );
          expect(session.completionRate, 1.0);
        });

        test('0% 완료율 (빈 completedReps)', () {
          final session = testSession.copyWith(
            completedReps: [],
          );
          expect(session.completionRate, 0.0);
        });

        test('빈 targetReps는 0% 완료율', () {
          final session = WorkoutSession(
            date: testDate,
            week: 1,
            day: 1,
            targetReps: [],
            completedReps: [1, 2, 3],
          );
          expect(session.completionRate, 0.0);
        });

        test('목표를 초과한 경우 100%로 제한', () {
          final session = testSession.copyWith(
            completedReps: [10, 12, 8, 8, 10], // 목표보다 많이 완료
          );
          expect(session.completionRate, 1.0);
        });
      });

      group('completedSets getter 테스트', () {
        test('완료된 세트 개수 확인', () {
          expect(testSession.completedSets, 5);
        });

        test('빈 completedReps는 0개 세트', () {
          final session = testSession.copyWith(completedReps: []);
          expect(session.completedSets, 0);
        });

        test('부분 완료된 세트 개수', () {
          final session = testSession.copyWith(completedReps: [5, 6, 4]);
          expect(session.completedSets, 3);
        });
      });

      group('totalSets getter 테스트', () {
        test('총 세트 개수 확인', () {
          expect(testSession.totalSets, 5);
        });

        test('빈 targetReps는 0개 세트', () {
          final session = WorkoutSession(
            date: testDate,
            week: 1,
            day: 1,
            targetReps: [],
          );
          expect(session.totalSets, 0);
        });
      });

      group('workoutKey getter 테스트', () {
        test('운동 키 형식 확인', () {
          expect(testSession.workoutKey, 'W2D1');
        });

        test('다양한 주차와 일차 조합', () {
          final session1 = testSession.copyWith(week: 1, day: 3);
          expect(session1.workoutKey, 'W1D3');

          final session2 = testSession.copyWith(week: 6, day: 2);
          expect(session2.workoutKey, 'W6D2');
        });
      });
    });

    group('엣지 케이스 테스트', () {
      test('매우 긴 운동 시간', () {
        final session = testSession.copyWith(
          totalTime: const Duration(hours: 2, minutes: 30),
        );
        final map = session.toMap();
        expect(map['total_time'], 9000); // 2.5시간 = 9000초

        final restored = WorkoutSession.fromMap(map);
        expect(restored.totalTime, const Duration(hours: 2, minutes: 30));
      });

      test('많은 세트 수', () {
        final manyReps = List.generate(20, (index) => index + 1);
        final session = WorkoutSession(
          date: testDate,
          week: 1,
          day: 1,
          targetReps: manyReps,
          completedReps: manyReps,
        );

        expect(session.totalSets, 20);
        expect(session.completedSets, 20);
        expect(session.completionRate, 1.0);
      });

      test('0개 목표 세트', () {
        final session = WorkoutSession(
          date: testDate,
          week: 1,
          day: 1,
          targetReps: [0, 0, 0],
          completedReps: [1, 2, 3],
        );

        expect(session.completionRate, 0.0); // 목표가 0이므로 완료율 0
      });
    });
  });
} 