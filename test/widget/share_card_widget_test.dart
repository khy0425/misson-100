import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/widgets/share_card_widget.dart';
import 'package:mission100/utils/constants.dart';
import 'package:mission100/models/user_profile.dart';
import '../test_helper.dart';

void main() {
  group('ShareCardWidget Tests', () {
    
    setUpAll(() async {
      await TestHelper.setupTestEnvironment();
    });

    group('기본 렌더링 테스트', () {
      testWidgets('ShareCardWidget이 올바르게 렌더링됨', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.dailyWorkout;
        final data = {
          'pushupCount': 50,
          'currentDay': 15,
          'level': UserLevel.rookie,
        };

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(ShareCardWidget), findsOneWidget);
        expect(find.byType(Container), findsAtLeastNWidgets(1));
        expect(find.byType(Column), findsAtLeastNWidgets(1));
      });

      testWidgets('헤더가 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.dailyWorkout;
        final data = {
          'pushupCount': 30,
          'currentDay': 10,
          'level': UserLevel.rookie,
        };

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        // Then
        expect(find.byIcon(Icons.fitness_center), findsOneWidget);
        expect(find.text('💀 ALPHA EMPEROR DOMAIN 💀'), findsOneWidget);
      });
    });

    group('데일리 워크아웃 카드 테스트', () {
      testWidgets('데일리 워크아웃 데이터가 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.dailyWorkout;
        final data = {
          'pushupCount': 75,
          'currentDay': 18,
          'level': UserLevel.rising,
        };

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        // Then
        expect(find.text('18'), findsOneWidget);
        expect(find.text('75 reps'), findsOneWidget);
      });

      testWidgets('다양한 푸시업 개수로 테스트', (WidgetTester tester) async {
        final testCases = [
          {'count': 10, 'day': 1},
          {'count': 50, 'day': 10},
          {'count': 100, 'day': 18},
        ];

        for (final testCase in testCases) {
          // Given
          const type = ShareCardType.dailyWorkout;
          final data = {
            'pushupCount': testCase['count'],
            'currentDay': testCase['day'],
            'level': UserLevel.rookie,
          };

          // When
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ShareCardWidget(
                  type: type,
                  data: data,
                ),
              ),
            ),
          );

          // Then
          expect(find.text('${testCase['count']} reps'), findsOneWidget);
          expect(find.text('${testCase['day']}'), findsOneWidget);

          await tester.binding.delayed(const Duration(milliseconds: 100));
        }
      });
    });

    group('레벨업 카드 테스트', () {
      testWidgets('레벨업 카드가 올바르게 렌더링됨', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.levelUp;
        final data = {
          'oldLevel': UserLevel.rookie,
          'newLevel': UserLevel.rising,
          'totalPushups': 500,
        };

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(ShareCardWidget), findsOneWidget);
        // 레벨업 관련 텍스트가 있는지 확인
        expect(find.textContaining('500'), findsAtLeastNWidgets(1));
      });
    });

    group('업적 카드 테스트', () {
      testWidgets('업적 카드가 올바르게 렌더링됨', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.achievement;
        final data = {
          'achievementTitle': 'Push-up Master',
          'achievementDescription': 'Completed 1000 push-ups',
          'icon': Icons.star,
        };

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(ShareCardWidget), findsOneWidget);
      });
    });

    group('미션100 카드 테스트', () {
      testWidgets('미션100 완료 카드가 올바르게 렌더링됨', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.mission100;
        final data = {
          'totalPushups': 1000,
          'completionDays': 42,
          'level': UserLevel.giga,
        };

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(ShareCardWidget), findsOneWidget);
        expect(find.textContaining('1000'), findsAtLeastNWidgets(1));
      });
    });

    group('주간 진행률 카드 테스트', () {
      testWidgets('주간 진행률 카드가 올바르게 렌더링됨', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.weeklyProgress;
        final data = {
          'week': 3,
          'completedDays': 2,
          'totalDays': 3,
          'weeklyPushups': 250,
        };

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(ShareCardWidget), findsOneWidget);
        expect(find.textContaining('3'), findsAtLeastNWidgets(1));
      });
    });

    group('스타일링 테스트', () {
      testWidgets('그라디언트 배경이 적용됨', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.dailyWorkout;
        final data = {
          'pushupCount': 50,
          'currentDay': 15,
          'level': UserLevel.rookie,
        };

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        // Then
        final containerFinder = find.byType(Container).first;
        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration?;
        
        expect(decoration?.gradient, isA<LinearGradient>());
        expect(decoration?.borderRadius, isNotNull);
        expect(decoration?.boxShadow, isNotNull);
      });

      testWidgets('올바른 크기와 패딩이 적용됨', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.dailyWorkout;
        final data = {
          'pushupCount': 50,
          'currentDay': 15,
          'level': UserLevel.rookie,
        };

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        // Then
        final containerFinder = find.byType(Container).first;
        final container = tester.widget<Container>(containerFinder);
        
        expect(container.constraints?.maxWidth, 350);
        expect(container.padding, const EdgeInsets.all(24));
      });
    });

    group('다크 모드 테스트', () {
      testWidgets('다크 모드에서 올바르게 렌더링됨', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.dailyWorkout;
        final data = {
          'pushupCount': 50,
          'currentDay': 15,
          'level': UserLevel.rookie,
        };

        // When
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(ShareCardWidget), findsOneWidget);
        
        final containerFinder = find.byType(Container).first;
        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration?;
        
        expect(decoration?.gradient, isA<LinearGradient>());
      });

      testWidgets('라이트 모드에서 올바르게 렌더링됨', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.dailyWorkout;
        final data = {
          'pushupCount': 50,
          'currentDay': 15,
          'level': UserLevel.rookie,
        };

        // When
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(ShareCardWidget), findsOneWidget);
      });
    });

    group('에지 케이스 테스트', () {
      testWidgets('빈 데이터로 테스트', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.dailyWorkout;
        final data = <String, dynamic>{};

        // When & Then - 오류 없이 렌더링되어야 함
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        expect(find.byType(ShareCardWidget), findsOneWidget);
      });

      testWidgets('최대값으로 테스트', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.dailyWorkout;
        final data = {
          'pushupCount': 999999,
          'currentDay': 365,
          'level': UserLevel.giga,
        };

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(ShareCardWidget), findsOneWidget);
        expect(find.text('365'), findsOneWidget);
        expect(find.text('999999 reps'), findsOneWidget);
      });

      testWidgets('0값으로 테스트', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.dailyWorkout;
        final data = {
          'pushupCount': 0,
          'currentDay': 0,
          'level': UserLevel.rookie,
        };

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(ShareCardWidget), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
        expect(find.text('0 reps'), findsOneWidget);
      });
    });

    group('접근성 테스트', () {
      testWidgets('접근성 라벨이 있음', (WidgetTester tester) async {
        // Given
        const type = ShareCardType.dailyWorkout;
        final data = {
          'pushupCount': 50,
          'currentDay': 15,
          'level': UserLevel.rookie,
        };

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ShareCardWidget(
                type: type,
                data: data,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(ShareCardWidget), findsOneWidget);
        
        // 텍스트 위젯들이 스크린 리더에 접근 가능한지 확인
        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        expect(textWidgets.isNotEmpty, isTrue);
      });
    });
  });
} 