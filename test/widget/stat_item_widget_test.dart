import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test용 StatItemWidget 클래스 (progress_tracking_screen.dart에서 private이므로 복사)
class StatItemWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatItemWidget({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

void main() {
  group('StatItemWidget 위젯 테스트', () {
    // 테스트용 위젯을 감싸는 헬퍼 함수
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('기본 렌더링 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const StatItemWidget(
          label: '총 운동 횟수',
          value: '42',
          icon: Icons.fitness_center,
          color: Colors.blue,
        ),
      ));

      // 위젯이 존재하는지 확인
      expect(find.byType(StatItemWidget), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('텍스트 내용 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const StatItemWidget(
          label: '이번 주 운동',
          value: '15회',
          icon: Icons.star,
          color: Colors.orange,
        ),
      ));

      // 텍스트 내용 확인
      expect(find.text('이번 주 운동'), findsOneWidget);
      expect(find.text('15회'), findsOneWidget);
    });

    testWidgets('아이콘 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const StatItemWidget(
          label: '달성도',
          value: '85%',
          icon: Icons.trending_up,
          color: Colors.green,
        ),
      ));

      // 아이콘 확인
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.trending_up));
      expect(iconWidget.color, Colors.green);
      expect(iconWidget.size, 20);
    });

    testWidgets('컨테이너 속성 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const StatItemWidget(
          label: '테스트',
          value: '100',
          icon: Icons.check,
          color: Colors.red,
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, const EdgeInsets.all(12));
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(8));
      expect(decoration.border?.top.width, 1);
    });

    testWidgets('다양한 색상 테스트', (WidgetTester tester) async {
      // Purple 색상 테스트
      await tester.pumpWidget(createTestWidget(
        const StatItemWidget(
          label: 'Purple Test',
          value: '123',
          icon: Icons.palette,
          color: Colors.purple,
        ),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.palette));
      expect(icon.color, Colors.purple);

      // Teal 색상 테스트
      await tester.pumpWidget(createTestWidget(
        const StatItemWidget(
          label: 'Teal Test',
          value: '456',
          icon: Icons.water,
          color: Colors.teal,
        ),
      ));

      final icon2 = tester.widget<Icon>(find.byIcon(Icons.water));
      expect(icon2.color, Colors.teal);
    });

    testWidgets('value 텍스트 스타일 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const StatItemWidget(
          label: '스타일 테스트',
          value: '999',
          icon: Icons.format_paint,
          color: Colors.indigo,
        ),
      ));

      final valueText = tester.widget<Text>(find.text('999'));
      expect(valueText.style?.fontSize, 16);
      expect(valueText.style?.fontWeight, FontWeight.bold);
      expect(valueText.style?.color, Colors.indigo);
    });

    testWidgets('label 텍스트 스타일 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const StatItemWidget(
          label: '라벨 스타일',
          value: '777',
          icon: Icons.label,
          color: Colors.cyan,
        ),
      ));

      final labelText = tester.widget<Text>(find.text('라벨 스타일'));
      expect(labelText.style?.fontSize, 12);
      expect(labelText.style?.color, Colors.grey[600]);
      expect(labelText.textAlign, TextAlign.center);
    });

    testWidgets('긴 텍스트 처리', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const StatItemWidget(
          label: '매우 긴 라벨 텍스트입니다 테스트용',
          value: '999999',
          icon: Icons.text_fields,
          color: Colors.amber,
        ),
      ));

      // 긴 텍스트가 렌더링되는지 확인
      expect(find.text('매우 긴 라벨 텍스트입니다 테스트용'), findsOneWidget);
      expect(find.text('999999'), findsOneWidget);
    });

    testWidgets('SizedBox 간격 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const StatItemWidget(
          label: '간격 테스트',
          value: '10',
          icon: Icons.space_bar,
          color: Colors.brown,
        ),
      ));

      // 특정 높이의 SizedBox가 존재하는지 확인
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets);
      
      // 높이가 4인 SizedBox를 찾기
      final heightSizedBoxes = tester.widgetList<SizedBox>(sizedBoxes)
          .where((box) => box.height == 4);
      expect(heightSizedBoxes, hasLength(1));
    });

    testWidgets('위젯 레이아웃 구조 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const StatItemWidget(
          label: '구조 테스트',
          value: '50',
          icon: Icons.architecture,
          color: Colors.deepOrange,
        ),
      ));

      // Column 내부 구조 확인
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets); // 여러 개가 있을 수 있음
      expect(find.byType(Text), findsNWidgets(2)); // value와 label
    });
  });
} 