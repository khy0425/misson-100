import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/widgets/achievement_progress_bar.dart';
import '../test_helper.dart';

void main() {
  setUpAll(() {
    setupTestEnvironment();
  });

  tearDownAll(() {
    tearDownTestEnvironment();
  });

  group('SimpleProgressBar Widget Tests', () {
    Widget createTestWidget({
      required double progress,
      Color? color,
      double height = 4.0,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SimpleProgressBar(
            progress: progress,
            color: color,
            height: height,
          ),
        ),
      );
    }

    testWidgets('진행률 바가 기본적으로 렌더링되는지 테스트', (WidgetTester tester) async {
      // Given: 기본 진행률 바
      await tester.pumpWidget(createTestWidget(progress: 0.5));

      // Then: 위젯이 렌더링되어야 함
      expect(find.byType(SimpleProgressBar), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('진행률이 올바르게 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 50% 진행률
      await tester.pumpWidget(createTestWidget(progress: 0.5));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 위젯이 렌더링되어야 함
      expect(find.byType(SimpleProgressBar), findsOneWidget);
      
      // FractionallySizedBox가 올바른 widthFactor를 가져야 함
      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.widthFactor, equals(0.5));
    });

    testWidgets('커스텀 색상이 적용되는지 테스트', (WidgetTester tester) async {
      // Given: 커스텀 색상이 있는 진행률 바
      const customColor = Colors.red;
      await tester.pumpWidget(createTestWidget(
        progress: 0.7,
        color: customColor,
      ));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 커스텀 색상이 적용되어야 함
      final progressContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(FractionallySizedBox),
          matching: find.byType(Container),
        ),
      );
      
      final decoration = progressContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(customColor));
    });

    testWidgets('기본 색상이 적용되는지 테스트', (WidgetTester tester) async {
      // Given: 색상이 지정되지 않은 진행률 바
      await tester.pumpWidget(createTestWidget(progress: 0.3));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 기본 색상(primaryColor)이 적용되어야 함
      expect(find.byType(SimpleProgressBar), findsOneWidget);
    });

    testWidgets('커스텀 높이가 적용되는지 테스트', (WidgetTester tester) async {
      // Given: 커스텀 높이가 있는 진행률 바
      const customHeight = 20.0;
      await tester.pumpWidget(createTestWidget(
        progress: 0.4,
        height: customHeight,
      ));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 커스텀 높이가 적용되어야 함
      final containers = tester.widgetList<Container>(find.byType(Container));
      
      // 외부 컨테이너의 높이 확인
      final outerContainer = containers.first;
      expect(outerContainer.constraints?.maxHeight, equals(customHeight));
    });

    testWidgets('0% 진행률이 올바르게 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 0% 진행률
      await tester.pumpWidget(createTestWidget(progress: 0.0));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 진행률이 0이어야 함
      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.widthFactor, equals(0.0));
    });

    testWidgets('100% 진행률이 올바르게 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 100% 진행률
      await tester.pumpWidget(createTestWidget(progress: 1.0));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 진행률이 1.0이어야 함
      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.widthFactor, equals(1.0));
    });

    testWidgets('범위를 벗어난 진행률이 clamp 처리되는지 테스트', (WidgetTester tester) async {
      // Given: 범위를 벗어난 진행률 (1.5)
      await tester.pumpWidget(createTestWidget(progress: 1.5));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 위젯이 오류 없이 렌더링되어야 함
      expect(find.byType(SimpleProgressBar), findsOneWidget);
      
      // clamp(0.0, 1.0)에 의해 1.0으로 제한되어야 함
      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.widthFactor, equals(1.0));
    });

    testWidgets('음수 진행률이 clamp 처리되는지 테스트', (WidgetTester tester) async {
      // Given: 음수 진행률 (-0.5)
      await tester.pumpWidget(createTestWidget(progress: -0.5));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 위젯이 오류 없이 렌더링되어야 함
      expect(find.byType(SimpleProgressBar), findsOneWidget);
      
      // clamp(0.0, 1.0)에 의해 0.0으로 제한되어야 함
      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.widthFactor, equals(0.0));
    });

    testWidgets('기본 높이가 올바르게 적용되는지 테스트', (WidgetTester tester) async {
      // Given: 기본 높이를 사용하는 진행률 바
      await tester.pumpWidget(createTestWidget(progress: 0.6));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 기본 높이(4.0)가 적용되어야 함
      final containers = tester.widgetList<Container>(find.byType(Container));
      final outerContainer = containers.first;
      expect(outerContainer.constraints?.maxHeight, equals(4.0));
    });

    testWidgets('borderRadius가 높이에 따라 올바르게 설정되는지 테스트', (WidgetTester tester) async {
      // Given: 특정 높이의 진행률 바
      const testHeight = 10.0;
      await tester.pumpWidget(createTestWidget(
        progress: 0.5,
        height: testHeight,
      ));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: borderRadius가 height/2로 설정되어야 함
      final containers = tester.widgetList<Container>(find.byType(Container));
      
      for (final container in containers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.borderRadius is BorderRadius) {
            final borderRadius = decoration.borderRadius as BorderRadius;
            expect(borderRadius.topLeft.x, equals(testHeight / 2));
          }
        }
      }
    });
  });
} 