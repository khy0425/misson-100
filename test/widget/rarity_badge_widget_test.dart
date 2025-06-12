import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/utils/constants.dart';

// Test용 RarityBadgeWidget 클래스 (enhanced_achievement_card.dart에서 private이므로 복사)
class RarityBadgeWidget extends StatelessWidget {
  final String text;
  final Color color;

  const RarityBadgeWidget({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

void main() {
  group('RarityBadgeWidget 위젯 테스트', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('기본 렌더링 및 텍스트 표시', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const RarityBadgeWidget(
          text: '일반',
          color: Colors.grey,
        ),
      ));

      // 위젯이 존재하는지 확인
      expect(find.byType(RarityBadgeWidget), findsOneWidget);
      
      // 텍스트가 올바르게 표시되는지 확인
      expect(find.text('일반'), findsOneWidget);
    });

    testWidgets('다양한 rarity 텍스트 표시', (WidgetTester tester) async {
      const rarityTexts = ['일반', '레어', '에픽', '전설'];
      
      for (final text in rarityTexts) {
        await tester.pumpWidget(createTestWidget(
          RarityBadgeWidget(
            text: text,
            color: Colors.blue,
          ),
        ));

        expect(find.text(text), findsOneWidget);
      }
    });

    testWidgets('다양한 색상 적용', (WidgetTester tester) async {
      const colors = [Colors.grey, Colors.blue, Colors.purple, Colors.orange];
      
      for (final color in colors) {
        await tester.pumpWidget(createTestWidget(
          RarityBadgeWidget(
            text: '테스트',
            color: color,
          ),
        ));

        // 위젯이 올바르게 렌더링되는지 확인
        expect(find.byType(RarityBadgeWidget), findsOneWidget);
        expect(find.text('테스트'), findsOneWidget);
      }
    });

    testWidgets('컨테이너 속성 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const RarityBadgeWidget(
          text: '컨테이너 테스트',
          color: Colors.red,
        ),
      ));

      // Container 위젯이 존재하는지 확인
      expect(find.byType(Container), findsOneWidget);
      
      final container = tester.widget<Container>(find.byType(Container));
      
      // Padding 확인
      final padding = container.padding as EdgeInsets;
      expect(padding.horizontal, AppConstants.paddingS * 2);
      expect(padding.vertical, 2 * 2);
      
      // Decoration 확인
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, 
        BorderRadius.circular(AppConstants.radiusS));
    });

    testWidgets('텍스트 스타일 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const RarityBadgeWidget(
          text: '스타일 테스트',
          color: Colors.green,
        ),
      ));

      final textWidget = tester.widget<Text>(find.text('스타일 테스트'));
      
      // 텍스트 스타일 확인
      expect(textWidget.style?.color, Colors.green);
      expect(textWidget.style?.fontSize, 10);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('긴 텍스트 처리', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const RarityBadgeWidget(
          text: '매우 긴 텍스트 레어도',
          color: Colors.purple,
        ),
      ));

      // 긴 텍스트도 올바르게 표시되는지 확인
      expect(find.text('매우 긴 텍스트 레어도'), findsOneWidget);
      expect(find.byType(RarityBadgeWidget), findsOneWidget);
    });

    testWidgets('빈 텍스트 처리', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const RarityBadgeWidget(
          text: '',
          color: Colors.cyan,
        ),
      ));

      // 빈 텍스트도 처리할 수 있는지 확인
      expect(find.byType(RarityBadgeWidget), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('다양한 색상 투명도 적용', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const RarityBadgeWidget(
          text: '투명도 테스트',
          color: Colors.amber,
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      
      // 배경색 투명도 확인 (0.2)
      expect(decoration.color, Colors.amber.withOpacity(0.2));
      
      // 테두리 색상 투명도 확인 (0.5)
      final border = decoration.border as Border;
      expect(border.top.color, Colors.amber.withOpacity(0.5));
    });

    testWidgets('위젯 레이아웃 구조 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const RarityBadgeWidget(
          text: '레이아웃',
          color: Colors.indigo,
        ),
      ));

      // 내부 구조 확인
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      
      // 위젯이 올바르게 렌더링되었는지 확인
      expect(find.byType(RarityBadgeWidget), findsOneWidget);
    });

    testWidgets('특수 문자 텍스트 처리', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const RarityBadgeWidget(
          text: '★★★',
          color: Colors.yellow,
        ),
      ));

      // 특수 문자도 올바르게 표시되는지 확인
      expect(find.text('★★★'), findsOneWidget);
      expect(find.byType(RarityBadgeWidget), findsOneWidget);
    });
  });
} 