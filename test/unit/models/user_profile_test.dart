import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/models/user_profile.dart';

void main() {
  group('UserProfile 모델 테스트', () {
    late DateTime testDate;
    late UserProfile testProfile;

    setUp(() {
      testDate = DateTime(2024, 1, 1, 12, 0, 0);
      testProfile = UserProfile(
        id: 1,
        level: UserLevel.rookie,
        initialMaxReps: 5,
        startDate: testDate,
        chadLevel: 2,
        reminderEnabled: true,
        reminderTime: '18:30',
        workoutDays: [true, false, true, false, true, false, false],
      );
    });

    group('생성자 테스트', () {
      test('기본 생성자로 UserProfile 생성', () {
        final profile = UserProfile(
          level: UserLevel.rising,
          initialMaxReps: 8,
          startDate: testDate,
        );

        expect(profile.level, UserLevel.rising);
        expect(profile.initialMaxReps, 8);
        expect(profile.startDate, testDate);
        expect(profile.id, isNull);
        expect(profile.chadLevel, 0);
        expect(profile.reminderEnabled, false);
        expect(profile.reminderTime, isNull);
        expect(profile.workoutDays, isNull);
      });

      test('모든 속성을 포함한 UserProfile 생성', () {
        expect(testProfile.id, 1);
        expect(testProfile.level, UserLevel.rookie);
        expect(testProfile.initialMaxReps, 5);
        expect(testProfile.startDate, testDate);
        expect(testProfile.chadLevel, 2);
        expect(testProfile.reminderEnabled, true);
        expect(testProfile.reminderTime, '18:30');
        expect(testProfile.workoutDays, [true, false, true, false, true, false, false]);
      });
    });

    group('toMap() 변환 테스트', () {
      test('모든 속성이 올바르게 Map으로 변환', () {
        final map = testProfile.toMap();

        expect(map['id'], 1);
        expect(map['level'], 'UserLevel.rookie');
        expect(map['initial_max_reps'], 5);
        expect(map['start_date'], testDate.toIso8601String());
        expect(map['chad_level'], 2);
        expect(map['reminder_enabled'], 1);
        expect(map['reminder_time'], '18:30');
        expect(map['workout_days'], 'true,false,true,false,true,false,false');
      });

      test('null 값들이 올바르게 처리', () {
        final profile = UserProfile(
          level: UserLevel.alpha,
          initialMaxReps: 15,
          startDate: testDate,
        );
        final map = profile.toMap();

        expect(map['id'], isNull);
        expect(map['reminder_time'], isNull);
        expect(map['workout_days'], isNull);
        expect(map['reminder_enabled'], 0);
      });
    });

    group('fromMap() 변환 테스트', () {
      test('Map에서 UserProfile 생성', () {
        final map = {
          'id': 2,
          'level': 'UserLevel.alpha',
          'initial_max_reps': 15,
          'start_date': testDate.toIso8601String(),
          'chad_level': 3,
          'reminder_enabled': 1,
          'reminder_time': '07:00',
          'workout_days': 'true,true,false,true,true,false,true',
        };

        final profile = UserProfile.fromMap(map);

        expect(profile.id, 2);
        expect(profile.level, UserLevel.alpha);
        expect(profile.initialMaxReps, 15);
        expect(profile.startDate, testDate);
        expect(profile.chadLevel, 3);
        expect(profile.reminderEnabled, true);
        expect(profile.reminderTime, '07:00');
        expect(profile.workoutDays, [true, true, false, true, true, false, true]);
      });

      test('필수 속성만 있는 Map에서 생성', () {
        final map = {
          'level': 'UserLevel.giga',
          'initial_max_reps': 25,
          'start_date': testDate.toIso8601String(),
          'reminder_enabled': 0,
        };

        final profile = UserProfile.fromMap(map);

        expect(profile.level, UserLevel.giga);
        expect(profile.initialMaxReps, 25);
        expect(profile.startDate, testDate);
        expect(profile.id, isNull);
        expect(profile.chadLevel, 0);
        expect(profile.reminderEnabled, false);
        expect(profile.reminderTime, isNull);
        expect(profile.workoutDays, isNull);
      });

      test('잘못된 level은 기본값으로 처리', () {
        final map = {
          'level': 'InvalidLevel',
          'initial_max_reps': 10,
          'start_date': testDate.toIso8601String(),
          'reminder_enabled': 0,
        };

        final profile = UserProfile.fromMap(map);
        expect(profile.level, UserLevel.rookie);
      });
    });

    group('workoutDays 파싱 테스트', () {
      test('정상적인 workout_days 문자열 파싱', () {
        final map = {
          'level': 'UserLevel.rookie',
          'initial_max_reps': 5,
          'start_date': testDate.toIso8601String(),
          'reminder_enabled': 0,
          'workout_days': 'true,false,true,true,false,true,false',
        };

        final profile = UserProfile.fromMap(map);
        expect(profile.workoutDays, [true, false, true, true, false, true, false]);
      });

      test('빈 문자열은 null로 처리', () {
        final map = {
          'level': 'UserLevel.rookie',
          'initial_max_reps': 5,
          'start_date': testDate.toIso8601String(),
          'reminder_enabled': 0,
          'workout_days': '',
        };

        final profile = UserProfile.fromMap(map);
        expect(profile.workoutDays, isNull);
      });

      test('null 값은 null로 처리', () {
        final map = {
          'level': 'UserLevel.rookie',
          'initial_max_reps': 5,
          'start_date': testDate.toIso8601String(),
          'reminder_enabled': 0,
          'workout_days': null,
        };

        final profile = UserProfile.fromMap(map);
        expect(profile.workoutDays, isNull);
      });
    });

    group('copyWith() 메소드 테스트', () {
      test('일부 속성만 변경', () {
        final newProfile = testProfile.copyWith(
          chadLevel: 5,
          reminderEnabled: false,
        );

        expect(newProfile.id, testProfile.id);
        expect(newProfile.level, testProfile.level);
        expect(newProfile.initialMaxReps, testProfile.initialMaxReps);
        expect(newProfile.startDate, testProfile.startDate);
        expect(newProfile.chadLevel, 5); // 변경됨
        expect(newProfile.reminderEnabled, false); // 변경됨
        expect(newProfile.reminderTime, testProfile.reminderTime);
        expect(newProfile.workoutDays, testProfile.workoutDays);
      });

      test('TimeOfDay로 reminderTime 설정', () {
        const timeOfDay = TimeOfDay(hour: 9, minute: 15);
        final newProfile = testProfile.copyWith(
          reminderTimeOfDay: timeOfDay,
        );

        expect(newProfile.reminderTime, '09:15');
      });

      test('모든 속성 변경', () {
        final newDate = DateTime(2024, 6, 15);
        final newWorkoutDays = [false, true, false, true, false, true, true];
        
        final newProfile = testProfile.copyWith(
          id: 10,
          level: UserLevel.giga,
          initialMaxReps: 30,
          startDate: newDate,
          chadLevel: 7,
          reminderEnabled: false,
          reminderTime: '06:00',
          workoutDays: newWorkoutDays,
        );

        expect(newProfile.id, 10);
        expect(newProfile.level, UserLevel.giga);
        expect(newProfile.initialMaxReps, 30);
        expect(newProfile.startDate, newDate);
        expect(newProfile.chadLevel, 7);
        expect(newProfile.reminderEnabled, false);
        expect(newProfile.reminderTime, '06:00');
        expect(newProfile.workoutDays, newWorkoutDays);
      });
    });

    group('reminderTimeOfDay getter 테스트', () {
      test('정상적인 시간 문자열을 TimeOfDay로 변환', () {
        final profile = testProfile.copyWith(reminderTime: '14:30');
        final timeOfDay = profile.reminderTimeOfDay;

        expect(timeOfDay, isNotNull);
        expect(timeOfDay!.hour, 14);
        expect(timeOfDay.minute, 30);
      });

      test('null reminderTime은 null TimeOfDay 반환', () {
        final profile = UserProfile(
          level: UserLevel.rookie,
          initialMaxReps: 5,
          startDate: testDate,
          reminderTime: null,
        );
        expect(profile.reminderTimeOfDay, isNull);
      });

      test('잘못된 형식의 시간 문자열은 null 반환', () {
        final profile = UserProfile(
          level: UserLevel.rookie,
          initialMaxReps: 5,
          startDate: testDate,
          reminderTime: 'invalid',
        );
        expect(profile.reminderTimeOfDay, isNull);
      });

      test('부분적으로 잘못된 시간 문자열도 파싱됨 (TimeOfDay 생성자 특성)', () {
        final profile = UserProfile(
          level: UserLevel.rookie,
          initialMaxReps: 5,
          startDate: testDate,
          reminderTime: '25:70',
        );
        // TimeOfDay 생성자는 범위 검증을 하지 않으므로 생성됨
        expect(profile.reminderTimeOfDay, isNotNull);
        expect(profile.reminderTimeOfDay!.hour, 25);
        expect(profile.reminderTimeOfDay!.minute, 70);
      });
    });
  });

  group('UserLevel enum 테스트', () {
    group('displayName getter 테스트', () {
      test('모든 UserLevel의 displayName 확인', () {
        expect(UserLevel.rookie.displayName, 'Rookie Chad');
        expect(UserLevel.rising.displayName, 'Rising Chad');
        expect(UserLevel.alpha.displayName, 'Alpha Chad');
        expect(UserLevel.giga.displayName, 'Giga Chad');
      });
    });

    group('levelValue getter 테스트', () {
      test('모든 UserLevel의 levelValue 확인', () {
        expect(UserLevel.rookie.levelValue, 1);
        expect(UserLevel.rising.levelValue, 25);
        expect(UserLevel.alpha.levelValue, 50);
        expect(UserLevel.giga.levelValue, 75);
      });
    });

    group('fromMaxReps() 메소드 테스트', () {
      test('푸쉬업 개수에 따른 적절한 레벨 반환', () {
        expect(UserLevelExtension.fromMaxReps(0), UserLevel.rookie);
        expect(UserLevelExtension.fromMaxReps(3), UserLevel.rookie);
        expect(UserLevelExtension.fromMaxReps(5), UserLevel.rookie);
        
        expect(UserLevelExtension.fromMaxReps(6), UserLevel.rising);
        expect(UserLevelExtension.fromMaxReps(8), UserLevel.rising);
        expect(UserLevelExtension.fromMaxReps(10), UserLevel.rising);
        
        expect(UserLevelExtension.fromMaxReps(11), UserLevel.alpha);
        expect(UserLevelExtension.fromMaxReps(15), UserLevel.alpha);
        expect(UserLevelExtension.fromMaxReps(20), UserLevel.alpha);
        
        expect(UserLevelExtension.fromMaxReps(21), UserLevel.giga);
        expect(UserLevelExtension.fromMaxReps(50), UserLevel.giga);
        expect(UserLevelExtension.fromMaxReps(100), UserLevel.giga);
      });
    });

    group('getDescription() 메소드 테스트', () {
      testWidgets('한국어 설명 확인', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ko', 'KR'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ko', 'KR'),
              Locale('en', 'US'),
            ],
            home: Builder(
              builder: (context) {
                expect(UserLevel.rookie.getDescription(context), '5개 이하 → 100개 달성');
                expect(UserLevel.rising.getDescription(context), '6-10개 → 100개 달성');
                expect(UserLevel.alpha.getDescription(context), '11-20개 → 100개 달성');
                expect(UserLevel.giga.getDescription(context), '21개 이상 → 100개+ 달성');
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('영어 설명 확인', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en', 'US'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ko', 'KR'),
              Locale('en', 'US'),
            ],
            home: Builder(
              builder: (context) {
                expect(UserLevel.rookie.getDescription(context), '≤5 reps → Achieve 100');
                expect(UserLevel.rising.getDescription(context), '6-10 reps → Achieve 100');
                expect(UserLevel.alpha.getDescription(context), '11-20 reps → Achieve 100');
                expect(UserLevel.giga.getDescription(context), '21+ reps → Achieve 100+');
                return Container();
              },
            ),
          ),
        );
      });
    });
  });
} 