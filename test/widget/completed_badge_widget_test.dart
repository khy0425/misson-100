import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/utils/constants.dart';

// Test용 CompletedBadgeWidget 클래스 (enhanced_achievement_card.dart에서 private이므로 복사)
class CompletedBadgeWidget extends StatelessWidget {
  final bool isCompleted;
  final Color color;
  final String text;

  const CompletedBadgeWidget({
    super.key,
    required this.isCompleted,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCompleted) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

void main() {
  group('CompletedBadgeWidget 위젯 테스트', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('완료된 상태에서 배지 렌더링', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CompletedBadgeWidget(
          isCompleted: true,
          color: Colors.green,
          text: '완료',
        ),
      ));

      // 위젯이 존재하는지 확인
      expect(find.byType(CompletedBadgeWidget), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.text('완료'), findsOneWidget);
    });

    testWidgets('완료되지 않은 상태에서 SizedBox.shrink 렌더링', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CompletedBadgeWidget(
          isCompleted: false,
          color: Colors.green,
          text: '완료',
        ),
      ));

      // SizedBox.shrink가 렌더링되는지 확인
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('완료'), findsNothing);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('다양한 텍스트 표시', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CompletedBadgeWidget(
          isCompleted: true,
          color: Colors.blue,
          text: 'COMPLETED',
        ),
      ));

      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('다양한 색상 적용', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CompletedBadgeWidget(
          isCompleted: true,
          color: Colors.purple,
          text: '달성',
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.purple);
    });

    testWidgets('텍스트 스타일 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CompletedBadgeWidget(
          isCompleted: true,
          color: Colors.orange,
          text: '성공',
        ),
      ));

      final textWidget = tester.widget<Text>(find.text('성공'));
      expect(textWidget.style?.color, Colors.white);
      expect(textWidget.style?.fontSize, 10);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('컨테이너 속성 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CompletedBadgeWidget(
          isCompleted: true,
          color: Colors.red,
          text: '완료됨',
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingS,
        vertical: 2,
      ));
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(AppConstants.radiusS));
      expect(decoration.boxShadow?.length, 1);
    });

    testWidgets('박스 섀도우 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CompletedBadgeWidget(
          isCompleted: true,
          color: Colors.teal,
          text: '달성완료',
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      final boxShadow = decoration.boxShadow!.first;
      
      expect(boxShadow.color, Colors.teal.withOpacity(0.3));
      expect(boxShadow.blurRadius, 4);
      expect(boxShadow.spreadRadius, 1);
    });

    testWidgets('긴 텍스트 처리', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CompletedBadgeWidget(
          isCompleted: true,
          color: Colors.indigo,
          text: '업적이 완전히 달성되었습니다',
        ),
      ));

      expect(find.text('업적이 완전히 달성되었습니다'), findsOneWidget);
    });

    testWidgets('빈 텍스트 처리', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CompletedBadgeWidget(
          isCompleted: true,
          color: Colors.cyan,
          text: '',
        ),
      ));

      expect(find.text(''), findsOneWidget);
    });

    testWidgets('위젯 레이아웃 구조 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CompletedBadgeWidget(
          isCompleted: true,
          color: Colors.amber,
          text: '레이아웃',
        ),
      ));

      // 기본 구조 확인
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      
      // SizedBox.shrink는 없어야 함 (완료된 상태)
      expect(find.byType(SizedBox), findsNothing);
    });
  });
} 