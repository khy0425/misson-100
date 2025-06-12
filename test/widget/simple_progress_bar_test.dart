import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/widgets/achievement_progress_bar.dart';
import '../test_helper.dart';

void main() {
  group('SimpleProgressBar 위젯 테스트', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('기본 렌더링 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const SimpleProgressBar(
          progress: 0.5,
        ),
      ));

      // Container 위젯이 존재하는지 확인
      expect(find.byType(Container), findsNWidgets(2)); // 외부와 내부 Container
      
      // SimpleProgressBar 위젯이 존재하는지 확인
      expect(find.byType(SimpleProgressBar), findsOneWidget);
    });

    testWidgets('progress 값이 올바르게 반영되는지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const SimpleProgressBar(
          progress: 0.7,
          height: 8.0,
        ),
      ));

      // 위젯이 렌더링되는지 확인
      expect(find.byType(SimpleProgressBar), findsOneWidget);
      expect(find.byType(Container), findsNWidgets(2));
      expect(find.byType(FractionallySizedBox), findsOneWidget);
      
      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.widthFactor, equals(0.7));
    });

    testWidgets('progress 값이 0일 때 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const SimpleProgressBar(
          progress: 0.0,
          height: 6.0,
        ),
      ));

      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.widthFactor, equals(0.0));
    });

    testWidgets('progress 값이 1일 때 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const SimpleProgressBar(
          progress: 1.0,
        ),
      ));

      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.widthFactor, equals(1.0));
    });

    testWidgets('progress 값이 1보다 클 때 clamp 되는지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const SimpleProgressBar(
          progress: 1.5,
        ),
      ));

      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.widthFactor, equals(1.0));
    });

    testWidgets('progress 값이 음수일 때 clamp 되는지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const SimpleProgressBar(
          progress: -0.3,
        ),
      ));

      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.widthFactor, equals(0.0));
    });

    testWidgets('사용자 정의 색상이 적용되는지 테스트', (WidgetTester tester) async {
      const customColor = Colors.red;
      
      await tester.pumpWidget(createTestWidget(
        const SimpleProgressBar(
          progress: 0.6,
          color: customColor,
        ),
      ));

      // 내부 컨테이너의 색상을 확인
      final containers = tester.widgetList<Container>(find.byType(Container));
      final innerContainer = containers.last;
      final decoration = innerContainer.decoration as BoxDecoration;
      
      expect(decoration.color, equals(customColor));
    });

    testWidgets('사용자 정의 높이가 적용되는지 테스트', (WidgetTester tester) async {
      const customHeight = 10.0;
      
      await tester.pumpWidget(createTestWidget(
        const SimpleProgressBar(
          progress: 0.4,
          height: customHeight,
        ),
      ));

      // 외부 컨테이너의 높이를 확인
      final outerContainer = tester.widgetList<Container>(find.byType(Container)).first;
      expect(outerContainer.constraints?.maxHeight, equals(customHeight));
    });

    testWidgets('FractionallySizedBox alignment 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const SimpleProgressBar(
          progress: 0.3,
        ),
      ));

      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.alignment, equals(Alignment.centerLeft));
    });

    testWidgets('BorderRadius가 올바르게 적용되는지 테스트', (WidgetTester tester) async {
      const customHeight = 8.0;
      const expectedRadius = customHeight / 2; // 4.0
      
      await tester.pumpWidget(createTestWidget(
        const SimpleProgressBar(
          progress: 0.5,
          height: customHeight,
        ),
      ));

      final containers = tester.widgetList<Container>(find.byType(Container));
      
      // 외부 컨테이너의 borderRadius 확인
      final outerDecoration = containers.first.decoration as BoxDecoration;
      final outerBorderRadius = outerDecoration.borderRadius as BorderRadius;
      expect(outerBorderRadius.topLeft.x, equals(expectedRadius));
      
      // 내부 컨테이너의 borderRadius 확인
      final innerDecoration = containers.last.decoration as BoxDecoration;
      final innerBorderRadius = innerDecoration.borderRadius as BorderRadius;
      expect(innerBorderRadius.topLeft.x, equals(expectedRadius));
    });

    testWidgets('다양한 progress 값으로 테스트', (WidgetTester tester) async {
      final testValues = [0.0, 0.25, 0.5, 0.75, 1.0];
      
      for (final progress in testValues) {
        await tester.pumpWidget(createTestWidget(
          SimpleProgressBar(
            progress: progress,
          ),
        ));

        final fractionallySizedBox = tester.widget<FractionallySizedBox>(
          find.byType(FractionallySizedBox),
        );
        expect(fractionallySizedBox.widthFactor, equals(progress));
        
        await tester.pumpAndSettle();
      }
    });

    testWidgets('다양한 높이 값으로 테스트', (WidgetTester tester) async {
      final testHeights = [2.0, 4.0, 6.0, 8.0, 10.0];
      
      for (final height in testHeights) {
        await tester.pumpWidget(createTestWidget(
          SimpleProgressBar(
            progress: 0.5,
            height: height,
          ),
        ));

        final outerContainer = tester.widgetList<Container>(find.byType(Container)).first;
        expect(outerContainer.constraints?.maxHeight, equals(height));
        
        await tester.pumpAndSettle();
      }
    });

    testWidgets('다양한 색상으로 테스트', (WidgetTester tester) async {
      final testColors = [Colors.red, Colors.blue, Colors.green, Colors.orange];
      
      for (final color in testColors) {
        await tester.pumpWidget(createTestWidget(
          SimpleProgressBar(
            progress: 0.6,
            color: color,
          ),
        ));

        final containers = tester.widgetList<Container>(find.byType(Container));
        final innerContainer = containers.last;
        final decoration = innerContainer.decoration as BoxDecoration;
        expect(decoration.color, equals(color));
        
        await tester.pumpAndSettle();
      }
    });

    testWidgets('극값 테스트 (매우 작은 progress)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const SimpleProgressBar(
          progress: 0.001,
        ),
      ));

      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.widthFactor, equals(0.001));
    });

    testWidgets('극값 테스트 (매우 큰 progress)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const SimpleProgressBar(
          progress: 100.0,
        ),
      ));

      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.widthFactor, equals(1.0)); // clamp 확인
    });

    testWidgets('매우 작은 높이로 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const SimpleProgressBar(
          progress: 0.5,
          height: 1.0,
        ),
      ));

      expect(find.byType(SimpleProgressBar), findsOneWidget);
      expect(find.byType(Container), findsNWidgets(2));
    });

    testWidgets('매우 큰 높이로 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const SimpleProgressBar(
          progress: 0.5,
          height: 50.0,
        ),
      ));

      expect(find.byType(SimpleProgressBar), findsOneWidget);
      expect(find.byType(Container), findsNWidgets(2));
    });
  });
} 