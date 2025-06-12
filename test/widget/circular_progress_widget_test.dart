import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test용 CircularProgressWidget 클래스 (statistics_screen.dart에서 private이므로 복사)
class CircularProgressWidget extends StatelessWidget {
  final String title;
  final double progress;
  final int current;
  final int target;
  final Color color;
  final IconData icon;

  const CircularProgressWidget({
    super.key,
    required this.title,
    required this.progress,
    required this.current,
    required this.target,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 4),
                Text(
                  '$current',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '/$target',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

void main() {
  group('CircularProgressWidget 위젯 테스트', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('기본 렌더링 및 Column 구조 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CircularProgressWidget(
          title: '총 운동',
          progress: 0.75,
          current: 75,
          target: 100,
          color: Colors.blue,
          icon: Icons.fitness_center,
        ),
      ));

      // 위젯이 존재하는지 확인
      expect(find.byType(CircularProgressWidget), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(2)); // 메인 Column + 내부 Column
      expect(find.byType(Stack), findsAtLeastNWidgets(1)); // 최소 1개의 Stack
    });

    testWidgets('텍스트 내용 표시 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CircularProgressWidget(
          title: '푸쉬업 횟수',
          progress: 0.6,
          current: 60,
          target: 100,
          color: Colors.green,
          icon: Icons.trending_up,
        ),
      ));

      // 텍스트 요소들 확인
      expect(find.text('푸쉬업 횟수'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('/100'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget); // (0.6 * 100).toInt() = 60
    });

    testWidgets('아이콘 표시 및 속성 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CircularProgressWidget(
          title: '완료율',
          progress: 0.9,
          current: 90,
          target: 100,
          color: Colors.orange,
          icon: Icons.check_circle,
        ),
      ));

      // 아이콘 확인
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(iconWidget.color, Colors.orange);
      expect(iconWidget.size, 20);
    });

    testWidgets('CircularProgressIndicator 속성 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CircularProgressWidget(
          title: '진행도',
          progress: 0.3,
          current: 30,
          target: 100,
          color: Colors.purple,
          icon: Icons.timer,
        ),
      ));

      // CircularProgressIndicator 확인
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator)
      );
      expect(progressIndicator.value, 0.3);
      expect(progressIndicator.strokeWidth, 8);
    });

    testWidgets('다양한 색상 적용 테스트', (WidgetTester tester) async {
      const colors = [Colors.red, Colors.blue, Colors.green, Colors.orange];
      
      for (final color in colors) {
        await tester.pumpWidget(createTestWidget(
          CircularProgressWidget(
            title: '색상 테스트',
            progress: 0.5,
            current: 50,
            target: 100,
            color: color,
            icon: Icons.palette,
          ),
        ));

        // 아이콘 색상 확인
        final iconWidget = tester.widget<Icon>(find.byIcon(Icons.palette));
        expect(iconWidget.color, color);
      }
    });

    testWidgets('다양한 진행도 값 테스트', (WidgetTester tester) async {
      const progressValues = [0.0, 0.25, 0.5, 0.75, 1.0];
      
      for (final progress in progressValues) {
        await tester.pumpWidget(createTestWidget(
          CircularProgressWidget(
            title: '진행도 테스트',
            progress: progress,
            current: (progress * 100).toInt(),
            target: 100,
            color: Colors.blue,
            icon: Icons.assessment,
          ),
        ));

        // 퍼센트 텍스트 확인
        final expectedPercent = '${(progress * 100).toInt()}%';
        expect(find.text(expectedPercent), findsOneWidget);
      }
    });

    testWidgets('긴 제목 처리 능력 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CircularProgressWidget(
          title: '매우 긴 제목이 포함된 원형 진행도 위젯 테스트',
          progress: 0.8,
          current: 80,
          target: 100,
          color: Colors.teal,
          icon: Icons.text_fields,
        ),
      ));

      // 긴 제목이 렌더링되는지 확인
      expect(find.text('매우 긴 제목이 포함된 원형 진행도 위젯 테스트'), findsOneWidget);
    });

    testWidgets('SizedBox 간격 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CircularProgressWidget(
          title: '간격 테스트',
          progress: 0.4,
          current: 40,
          target: 100,
          color: Colors.brown,
          icon: Icons.space_bar,
        ),
      ));

      // 특정 높이의 SizedBox가 존재하는지 확인
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsAtLeastNWidgets(2)); // 최소 2개 (내부 4px + 외부 8px)
      
      // 8px 높이의 SizedBox 찾기
      bool foundExpectedSizedBox = false;
      for (int i = 0; i < tester.widgetList(sizedBoxes).length; i++) {
        final sizedBoxWidget = tester.widgetList<SizedBox>(sizedBoxes).elementAt(i);
        if (sizedBoxWidget.height == 8) {
          foundExpectedSizedBox = true;
          break;
        }
      }
      expect(foundExpectedSizedBox, isTrue);
    });

    testWidgets('SizedBox 컨테이너 크기 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CircularProgressWidget(
          title: '크기 테스트',
          progress: 0.7,
          current: 70,
          target: 100,
          color: Colors.indigo,
          icon: Icons.adjust,
        ),
      ));

      // CircularProgressIndicator를 감싸는 SizedBox 확인
      final sizedBoxes = find.byType(SizedBox);
      bool foundCorrectSizedBox = false;
      
      for (int i = 0; i < tester.widgetList(sizedBoxes).length; i++) {
        final sizedBoxWidget = tester.widgetList<SizedBox>(sizedBoxes).elementAt(i);
        if (sizedBoxWidget.width == 80 && sizedBoxWidget.height == 80) {
          foundCorrectSizedBox = true;
          break;
        }
      }
      expect(foundCorrectSizedBox, isTrue);
    });

    testWidgets('위젯 레이아웃 구조 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const CircularProgressWidget(
          title: '구조 테스트',
          progress: 0.85,
          current: 85,
          target: 100,
          color: Colors.deepOrange,
          icon: Icons.architecture,
        ),
      ));

      // 레이아웃 구조 확인
      expect(find.byType(Column), findsAtLeastNWidgets(2));
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
      expect(find.byType(SizedBox), findsAtLeastNWidgets(2));
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(4)); // title, current, target, percentage
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
} 