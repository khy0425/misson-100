import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test용 ConnectorLineWidget 클래스 (progress_tracking_screen.dart에서 private이므로 복사)
class ConnectorLineWidget extends StatelessWidget {
  final bool isUnlocked;
  final bool showConnector;

  const ConnectorLineWidget({
    super.key,
    required this.isUnlocked,
    required this.showConnector,
  });

  @override
  Widget build(BuildContext context) {
    if (!showConnector) return const SizedBox.shrink();
    
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.only(left: 30),
          width: 2,
          height: 20,
          color: isUnlocked 
              ? const Color(0xFF51CF66).withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

void main() {
  group('ConnectorLineWidget 위젯 테스트', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('showConnector가 false일 때 SizedBox.shrink 렌더링', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ConnectorLineWidget(
          isUnlocked: true,
          showConnector: false,
        ),
      ));

      // SizedBox.shrink이 렌더링되는지 확인
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Container), findsNothing);
      expect(find.byType(Column), findsNothing);
    });

    testWidgets('showConnector가 true일 때 연결선 렌더링', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ConnectorLineWidget(
          isUnlocked: true,
          showConnector: true,
        ),
      ));

      // 위젯 구조 확인
      expect(find.byType(ConnectorLineWidget), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(SizedBox), findsNWidgets(2)); // 위아래 간격
    });

    testWidgets('unlocked 상태에서 색상 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ConnectorLineWidget(
          isUnlocked: true,
          showConnector: true,
        ),
      ));

      // Container 위젯 찾기
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      
      // unlocked 색상 확인 (녹색 투명도 0.5)
      expect(container.color, const Color(0xFF51CF66).withValues(alpha: 0.5));
    });

    testWidgets('locked 상태에서 색상 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ConnectorLineWidget(
          isUnlocked: false,
          showConnector: true,
        ),
      ));

      // Container 위젯 찾기
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      
      // locked 색상 확인 (회색 투명도 0.3)
      expect(container.color, Colors.grey.withValues(alpha: 0.3));
    });

    testWidgets('Container 크기 및 마진 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ConnectorLineWidget(
          isUnlocked: true,
          showConnector: true,
        ),
      ));

      final containerFinder = find.byType(Container);
      final container = tester.widget<Container>(containerFinder);
      
      // 크기 확인
      expect(container.constraints?.minWidth, 2);
      expect(container.constraints?.minHeight, 20);
      
      // 마진 확인
      expect(container.margin, const EdgeInsets.only(left: 30));
    });

    testWidgets('SizedBox 간격 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ConnectorLineWidget(
          isUnlocked: true,
          showConnector: true,
        ),
      ));

      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsNWidgets(2));
      
      // 각 SizedBox의 높이가 8인지 확인
      final sizedBoxWidgets = tester.widgetList<SizedBox>(sizedBoxes);
      for (final sizedBox in sizedBoxWidgets) {
        expect(sizedBox.height, 8.0);
      }
    });

    testWidgets('여러 상태 조합 테스트', (WidgetTester tester) async {
      // unlocked + showConnector = true
      await tester.pumpWidget(createTestWidget(
        const ConnectorLineWidget(
          isUnlocked: true,
          showConnector: true,
        ),
      ));
      
      expect(find.byType(Container), findsOneWidget);
      
      // locked + showConnector = true
      await tester.pumpWidget(createTestWidget(
        const ConnectorLineWidget(
          isUnlocked: false,
          showConnector: true,
        ),
      ));
      
      expect(find.byType(Container), findsOneWidget);
      
      // 어떤 상태든 showConnector = false
      await tester.pumpWidget(createTestWidget(
        const ConnectorLineWidget(
          isUnlocked: true,
          showConnector: false,
        ),
      ));
      
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('위젯 레이아웃 구조 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const ConnectorLineWidget(
          isUnlocked: true,
          showConnector: true,
        ),
      ));

      // Column 내부에 올바른 순서로 위젯들이 배치되어 있는지 확인
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);
      
      final column = tester.widget<Column>(columnFinder);
      expect(column.children.length, 3); // SizedBox + Container + SizedBox
      
      // 순서 확인
      expect(column.children[0], isA<SizedBox>());
      expect(column.children[1], isA<Container>());
      expect(column.children[2], isA<SizedBox>());
    });

    testWidgets('색상 투명도 정확성 확인', (WidgetTester tester) async {
      // unlocked 상태 테스트
      await tester.pumpWidget(createTestWidget(
        const ConnectorLineWidget(
          isUnlocked: true,
          showConnector: true,
        ),
      ));

      var container = tester.widget<Container>(find.byType(Container));
      var unlockedColor = container.color;
      
      // 정확한 색상과 투명도 확인 (근사값 비교)
      expect(unlockedColor?.red, const Color(0xFF51CF66).red);
      expect(unlockedColor?.green, const Color(0xFF51CF66).green);
      expect(unlockedColor?.blue, const Color(0xFF51CF66).blue);
      expect(unlockedColor?.opacity, closeTo(0.5, 0.01));

      // locked 상태 테스트
      await tester.pumpWidget(createTestWidget(
        const ConnectorLineWidget(
          isUnlocked: false,
          showConnector: true,
        ),
      ));

      container = tester.widget<Container>(find.byType(Container));
      var lockedColor = container.color;
      
      expect(lockedColor?.opacity, closeTo(0.3, 0.01));
    });
  });
} 