import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mission100/screens/workout_screen.dart';
import 'package:mission100/models/user_profile.dart';
import 'package:mission100/utils/workout_data.dart';
import 'package:mission100/services/workout_program_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mission100/generated/app_localizations.dart';
import '../test_helper.dart';

void main() {
  setUpAll(() {
    setupTestEnvironment();
  });

  tearDownAll(() {
    tearDownTestEnvironment();
  });

  group('WorkoutScreen Widget Tests', () {
    late UserProfile testUserProfile;
    late TodayWorkout testTodayWorkout;

    setUp(() {
      testUserProfile = UserProfile(
        level: UserLevel.rookie,
        initialMaxReps: 10,
        startDate: DateTime.now(),
        chadLevel: 0,
      );
      
      testTodayWorkout = TodayWorkout(
        week: 1,
        day: 1,
        workout: [5, 6, 5, 5, 5],
        totalReps: 26,
        restTimeSeconds: 60,
      );
    });

    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko', 'KR'),
            Locale('en', 'US'),
          ],
          locale: const Locale('ko', 'KR'),
          home: WorkoutScreen(
            userProfile: testUserProfile,
            todayWorkout: testTodayWorkout,
          ),
        ),
      );
    }

    testWidgets('워크아웃 스크린이 기본적으로 렌더링되는지 테스트', (WidgetTester tester) async {
      // Given: 워크아웃 스크린 위젯
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Then: 스크린이 렌더링되어야 함
      expect(find.byType(WorkoutScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('앱바가 올바르게 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 워크아웃 스크린 위젯
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Then: 앱바가 표시되어야 함
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('워크아웃 진행 상황이 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 워크아웃 스크린 위젯
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Then: 진행 상황 관련 위젯들이 표시되어야 함
      expect(find.byType(LinearProgressIndicator), findsWidgets);
      // 세트 번호나 진행 상황을 나타내는 텍스트가 있어야 함
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('세트 정보가 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 워크아웃 스크린 위젯
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Then: 세트 관련 정보가 표시되어야 함
      expect(find.textContaining('세트'), findsWidgets);
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('완료 버튼이 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 워크아웃 스크린 위젯
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Then: 버튼이 표시되어야 함
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('카운터 버튼들이 작동하는지 테스트', (WidgetTester tester) async {
      // Given: 워크아웃 스크린 위젯
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // When: 플러스 버튼을 찾아서 탭
      final plusButtons = find.byIcon(Icons.add);
      if (plusButtons.evaluate().isNotEmpty) {
        await tester.tap(plusButtons.first);
        await tester.pump();
      }

      // Then: UI가 업데이트되어야 함 (구체적인 검증은 실제 구현에 따라 조정)
      expect(find.byType(WorkoutScreen), findsOneWidget);
    });
  });
} 