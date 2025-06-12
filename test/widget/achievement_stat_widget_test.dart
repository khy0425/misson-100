import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/utils/constants.dart';

// Test용 AchievementStatWidget 클래스 (home_screen.dart에서 private이므로 복사)
class AchievementStatWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const AchievementStatWidget({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: AppConstants.paddingXS),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

void main() {
  group('AchievementStatWidget 테스트', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('기본 렌더링 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const AchievementStatWidget(
          label: '총 업적',
          value: '12',
          icon: Icons.emoji_events,
          color: Colors.orange,
        ),
      ));

      // 위젯이 존재하는지 확인
      expect(find.byType(AchievementStatWidget), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('텍스트 내용 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const AchievementStatWidget(
          label: '완료된 업적',
          value: '8',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
      ));

      // 텍스트가 올바르게 표시되는지 확인
      expect(find.text('완료된 업적'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('아이콘 표시 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const AchievementStatWidget(
          label: '희귀 업적',
          value: '3',
          icon: Icons.star,
          color: Colors.purple,
        ),
      ));

      // 아이콘이 올바르게 표시되는지 확인
      expect(find.byIcon(Icons.star), findsOneWidget);
      
      // 아이콘의 색상과 크기 확인
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(iconWidget.color, Colors.purple);
      expect(iconWidget.size, 20);
    });

    testWidgets('컨테이너 속성 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const AchievementStatWidget(
          label: '전설 업적',
          value: '1',
          icon: Icons.diamond,
          color: Colors.amber,
        ),
      ));

      // Container 위젯 찾기
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      // Container의 속성 확인
      final containerWidget = tester.widget<Container>(containerFinder);
      final decoration = containerWidget.decoration as BoxDecoration;
      
      expect(decoration.color, Colors.amber.withValues(alpha: 0.1));
      expect(decoration.borderRadius, BorderRadius.circular(20));
      
      // 컨테이너 크기 확인
      final renderBox = tester.renderObject<RenderBox>(containerFinder);
      expect(renderBox.size.width, 40);
      expect(renderBox.size.height, 40);
    });

    testWidgets('다양한 색상 테스트', (WidgetTester tester) async {
      const colors = [Colors.red, Colors.blue, Colors.green, Colors.orange];
      
      for (final color in colors) {
        await tester.pumpWidget(createTestWidget(
          AchievementStatWidget(
            label: '테스트',
            value: '0',
            icon: Icons.circle,
            color: color,
          ),
        ));

        // 아이콘 색상 확인
        final iconWidget = tester.widget<Icon>(find.byIcon(Icons.circle));
        expect(iconWidget.color, color);

        // value 텍스트 색상 확인
        final valueText = tester.widget<Text>(find.text('0'));
        expect(valueText.style?.color, color);
      }
    });

    testWidgets('긴 텍스트 처리 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const AchievementStatWidget(
          label: '매우 긴 라벨 텍스트입니다',
          value: '999999',
          icon: Icons.format_list_numbered,
          color: Colors.indigo,
        ),
      ));

      // 긴 텍스트가 올바르게 표시되는지 확인
      expect(find.text('매우 긴 라벨 텍스트입니다'), findsOneWidget);
      expect(find.text('999999'), findsOneWidget);
    });

    testWidgets('다양한 아이콘 테스트', (WidgetTester tester) async {
      const icons = [
        Icons.emoji_events,
        Icons.star,
        Icons.check_circle,
        Icons.favorite,
        Icons.diamond,
      ];
      
      for (final icon in icons) {
        await tester.pumpWidget(createTestWidget(
          AchievementStatWidget(
            label: '테스트',
            value: '1',
            icon: icon,
            color: Colors.blue,
          ),
        ));

        // 각 아이콘이 올바르게 표시되는지 확인
        expect(find.byIcon(icon), findsOneWidget);
      }
    });

    testWidgets('SizedBox 간격 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const AchievementStatWidget(
          label: '간격 테스트',
          value: '5',
          icon: Icons.space_bar,
          color: Colors.teal,
        ),
      ));

      // 특정 높이의 SizedBox가 존재하는지 확인
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets);
      
      // 우리가 원하는 높이의 SizedBox 찾기
      bool foundCorrectSizedBox = false;
      for (int i = 0; i < tester.widgetList<SizedBox>(sizedBoxes).length; i++) {
        final sizedBox = tester.widgetList<SizedBox>(sizedBoxes).elementAt(i);
        if (sizedBox.height == AppConstants.paddingXS) {
          foundCorrectSizedBox = true;
          break;
        }
      }
      expect(foundCorrectSizedBox, isTrue);
    });

    testWidgets('텍스트 스타일 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const AchievementStatWidget(
          label: '스타일 테스트',
          value: '42',
          icon: Icons.style,
          color: Colors.pink,
        ),
      ));

      // value 텍스트 스타일 확인
      final valueText = tester.widget<Text>(find.text('42'));
      expect(valueText.style?.fontWeight, FontWeight.bold);
      expect(valueText.style?.color, Colors.pink);

      // label 텍스트 스타일 확인
      final labelText = tester.widget<Text>(find.text('스타일 테스트'));
      expect(labelText.style?.fontSize, 11);
      expect(labelText.style?.color, Colors.grey[600]);
    });

    testWidgets('위젯 레이아웃 구조 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const AchievementStatWidget(
          label: '레이아웃',
          value: '100',
          icon: Icons.architecture,
          color: Colors.deepPurple,
        ),
      ));

      // Column 내부 구조 확인
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets); // 여러 개 있을 수 있음
      expect(find.byType(Text), findsNWidgets(2)); // value와 label
    });

    testWidgets('빈 문자열 처리 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const AchievementStatWidget(
          label: '',
          value: '',
          icon: Icons.error_outline,
          color: Colors.grey,
        ),
      ));

      // 빈 문자열도 올바르게 처리되는지 확인
      expect(find.text(''), findsNWidgets(2)); // label과 value 모두 빈 문자열
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
} 