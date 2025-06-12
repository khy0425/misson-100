import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/widgets/achievement_progress_bar.dart';
import 'package:mission100/models/achievement.dart';
import '../test_helper.dart';

void main() {
  group('AchievementProgressBar Tests', () {
    
    setUpAll(() async {
      await TestHelper.setupTestEnvironment();
    });

    group('기본 렌더링 테스트', () {
      testWidgets('AchievementProgressBar가 올바르게 렌더링됨', (WidgetTester tester) async {
        // Given
        const progress = 0.5;
        const rarity = AchievementRarity.common;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressBar(
                progress: progress,
                rarity: rarity,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(AchievementProgressBar), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.byType(Container), findsAtLeastNWidgets(1));
      });

      testWidgets('SimpleProgressBar가 올바르게 렌더링됨', (WidgetTester tester) async {
        // Given
        const progress = 0.75;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SimpleProgressBar(
                progress: progress,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(SimpleProgressBar), findsOneWidget);
        expect(find.byType(Container), findsAtLeastNWidgets(1));
        expect(find.byType(FractionallySizedBox), findsOneWidget);
      });
    });

    group('애니메이션 테스트', () {
      testWidgets('애니메이션이 활성화되었을 때 AnimationController가 작동함', (WidgetTester tester) async {
        // Given
        const progress = 0.8;
        const rarity = AchievementRarity.rare;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressBar(
                progress: progress,
                rarity: rarity,
                animated: true,
              ),
            ),
          ),
        );

        // Then
        expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
        
        // 초기 상태에서는 애니메이션이 시작되지 않았을 수 있음
        await tester.pump();
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        
        // 애니메이션이 완료될 때까지 기다림
        await tester.pumpAndSettle();
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('애니메이션이 비활성화되었을 때 즉시 값이 설정됨', (WidgetTester tester) async {
        // Given
        const progress = 0.6;
        const rarity = AchievementRarity.epic;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressBar(
                progress: progress,
                rarity: rarity,
                animated: false,
              ),
            ),
          ),
        );

        // Then
        await tester.pump();
        
        final linearProgressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(linearProgressIndicator.value, equals(progress));
      });

      testWidgets('진행도 변경 시 애니메이션이 업데이트됨', (WidgetTester tester) async {
        // Given
        const initialProgress = 0.3;
        const updatedProgress = 0.7;
        const rarity = AchievementRarity.legendary;

        // When - 초기 상태
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressBar(
                progress: initialProgress,
                rarity: rarity,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // When - 진행도 업데이트
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressBar(
                progress: updatedProgress,
                rarity: rarity,
              ),
            ),
          ),
        );

        // Then
        await tester.pumpAndSettle();
        expect(find.byType(AchievementProgressBar), findsOneWidget);
      });
    });

    group('Rarity 색상 테스트', () {
      testWidgets('Common rarity는 회색으로 표시됨', (WidgetTester tester) async {
        // Given
        const progress = 0.5;
        const rarity = AchievementRarity.common;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressBar(
                progress: progress,
                rarity: rarity,
                animated: false,
              ),
            ),
          ),
        );

        // Then
        await tester.pump();
        final linearProgressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        
        final valueColor = linearProgressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
        expect(valueColor.value, equals(Colors.grey));
      });

      testWidgets('Rare rarity는 파란색으로 표시됨', (WidgetTester tester) async {
        // Given
        const progress = 0.5;
        const rarity = AchievementRarity.rare;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressBar(
                progress: progress,
                rarity: rarity,
                animated: false,
              ),
            ),
          ),
        );

        // Then
        await tester.pump();
        final linearProgressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        
        final valueColor = linearProgressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
        expect(valueColor.value, equals(Colors.blue));
      });

      testWidgets('Epic rarity는 보라색으로 표시됨', (WidgetTester tester) async {
        // Given
        const progress = 0.5;
        const rarity = AchievementRarity.epic;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressBar(
                progress: progress,
                rarity: rarity,
                animated: false,
              ),
            ),
          ),
        );

        // Then
        await tester.pump();
        final linearProgressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        
        final valueColor = linearProgressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
        expect(valueColor.value, equals(Colors.purple));
      });

      testWidgets('Legendary rarity는 주황색으로 표시됨', (WidgetTester tester) async {
        // Given
        const progress = 0.5;
        const rarity = AchievementRarity.legendary;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressBar(
                progress: progress,
                rarity: rarity,
                animated: false,
              ),
            ),
          ),
        );

        // Then
        await tester.pump();
        final linearProgressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        
        final valueColor = linearProgressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
        expect(valueColor.value, equals(Colors.orange));
      });

      testWidgets('100% 완료 시 초록색으로 변경됨', (WidgetTester tester) async {
        // Given
        const progress = 1.0;
        const rarity = AchievementRarity.rare;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressBar(
                progress: progress,
                rarity: rarity,
                animated: false,
              ),
            ),
          ),
        );

        // Then
        await tester.pump();
        final linearProgressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        
        final valueColor = linearProgressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
        expect(valueColor.value, equals(Colors.green));
      });
    });

    group('높이 설정 테스트', () {
      testWidgets('기본 높이가 6.0으로 설정됨', (WidgetTester tester) async {
        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressBar(
                progress: 0.5,
                rarity: AchievementRarity.common,
              ),
            ),
          ),
        );

        // Then
        await tester.pump();
        final containers = tester.widgetList<Container>(find.byType(Container));
        final progressContainer = containers.first;
        
        expect(progressContainer.constraints?.minHeight, equals(6.0));
      });

      testWidgets('커스텀 높이가 올바르게 적용됨', (WidgetTester tester) async {
        // Given
        const customHeight = 12.0;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressBar(
                progress: 0.5,
                rarity: AchievementRarity.common,
                height: customHeight,
              ),
            ),
          ),
        );

        // Then
        await tester.pump();
        final containers = tester.widgetList<Container>(find.byType(Container));
        final progressContainer = containers.first;
        
        expect(progressContainer.constraints?.minHeight, equals(customHeight));
      });
    });

    group('SimpleProgressBar 테스트', () {
      testWidgets('진행도가 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        const progress = 0.75;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SimpleProgressBar(
                progress: progress,
              ),
            ),
          ),
        );

        // Then
        await tester.pump();
        final fractionallySizedBox = tester.widget<FractionallySizedBox>(
          find.byType(FractionallySizedBox),
        );
        
        expect(fractionallySizedBox.widthFactor, equals(progress));
      });

      testWidgets('커스텀 색상이 적용됨', (WidgetTester tester) async {
        // Given
        const progress = 0.6;
        const customColor = Colors.red;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SimpleProgressBar(
                progress: progress,
                color: customColor,
              ),
            ),
          ),
        );

        // Then
        await tester.pump();
        final containers = tester.widgetList<Container>(find.byType(Container));
        final progressContainer = containers.last; // 내부 컨테이너
        final decoration = progressContainer.decoration as BoxDecoration;
        
        expect(decoration.color, equals(customColor));
      });

      testWidgets('진행도가 0.0 미만일 때 0.0으로 클램프됨', (WidgetTester tester) async {
        // Given
        const progress = -0.5;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SimpleProgressBar(
                progress: progress,
              ),
            ),
          ),
        );

        // Then
        await tester.pump();
        final fractionallySizedBox = tester.widget<FractionallySizedBox>(
          find.byType(FractionallySizedBox),
        );
        
        expect(fractionallySizedBox.widthFactor, equals(0.0));
      });

      testWidgets('진행도가 1.0 초과일 때 1.0으로 클램프됨', (WidgetTester tester) async {
        // Given
        const progress = 1.5;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SimpleProgressBar(
                progress: progress,
              ),
            ),
          ),
        );

        // Then
        await tester.pump();
        final fractionallySizedBox = tester.widget<FractionallySizedBox>(
          find.byType(FractionallySizedBox),
        );
        
        expect(fractionallySizedBox.widthFactor, equals(1.0));
      });
    });

    group('글로우 효과 테스트', () {
      testWidgets('showGlow가 true이고 진행도가 70% 이상일 때 BoxShadow 적용', (WidgetTester tester) async {
        // Given
        const progress = 0.8;
        const rarity = AchievementRarity.legendary;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressBar(
                progress: progress,
                rarity: rarity,
                showGlow: true,
                animated: false,
              ),
            ),
          ),
        );

        // Then
        await tester.pump();
        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;
        
        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.isNotEmpty, isTrue);
      });

      testWidgets('showGlow가 false일 때 BoxShadow 적용되지 않음', (WidgetTester tester) async {
        // Given
        const progress = 0.8;
        const rarity = AchievementRarity.legendary;

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressBar(
                progress: progress,
                rarity: rarity,
                showGlow: false,
                animated: false,
              ),
            ),
          ),
        );

        // Then
        await tester.pump();
        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;
        
        expect(decoration.boxShadow, isNull);
      });
    });
  });
} 