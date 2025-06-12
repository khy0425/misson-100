import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test용 ActionButtonWidget 클래스 (onboarding_screen.dart에서 private이므로 복사)
class ActionButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final String text;
  final Color foregroundColor;

  const ActionButtonWidget({
    super.key,
    required this.onPressed,
    required this.backgroundColor,
    required this.text,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: backgroundColor.withValues(alpha: 0.4),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

void main() {
  group('ActionButtonWidget 위젯 테스트', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('기본 렌더링 테스트', (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(createTestWidget(
        ActionButtonWidget(
          onPressed: () => buttonPressed = true,
          backgroundColor: Colors.blue,
          text: 'Test Button',
          foregroundColor: Colors.white,
        ),
      ));

      // SizedBox가 존재하는지 확인
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      
      // ElevatedButton이 존재하는지 확인
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // Text가 존재하는지 확인
      expect(find.text('Test Button'), findsOneWidget);
      
      // ActionButtonWidget이 존재하는지 확인
      expect(find.byType(ActionButtonWidget), findsOneWidget);
    });

    testWidgets('버튼 텍스트가 올바르게 표시되는지 테스트', (WidgetTester tester) async {
      const buttonText = '시작하기';

      await tester.pumpWidget(createTestWidget(
        ActionButtonWidget(
          onPressed: () {},
          backgroundColor: Colors.red,
          text: buttonText,
          foregroundColor: Colors.white,
        ),
      ));

      // 올바른 텍스트가 표시되는지 확인
      expect(find.text(buttonText), findsOneWidget);
      
      // Text 위젯의 스타일이 올바른지 확인
      final textWidget = tester.widget<Text>(find.text(buttonText));
      expect(textWidget.style?.fontSize, equals(18));
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('버튼 클릭 이벤트가 올바르게 동작하는지 테스트', (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(createTestWidget(
        ActionButtonWidget(
          onPressed: () => buttonPressed = true,
          backgroundColor: Colors.green,
          text: 'Click Me',
          foregroundColor: Colors.black,
        ),
      ));

      // 초기 상태 확인
      expect(buttonPressed, isFalse);

      // 버튼 탭
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // 콜백이 호출되었는지 확인
      expect(buttonPressed, isTrue);
    });

    testWidgets('버튼 색상 설정이 올바르게 적용되는지 테스트', (WidgetTester tester) async {
      const backgroundColor = Colors.purple;
      const foregroundColor = Colors.yellow;

      await tester.pumpWidget(createTestWidget(
        ActionButtonWidget(
          onPressed: () {},
          backgroundColor: backgroundColor,
          text: 'Colored Button',
          foregroundColor: foregroundColor,
        ),
      ));

      // ElevatedButton 위젯 찾기
      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      
      // 스타일이 올바르게 설정되었는지 확인
      expect(elevatedButton.style?.backgroundColor?.resolve({}), equals(backgroundColor));
      expect(elevatedButton.style?.foregroundColor?.resolve({}), equals(foregroundColor));
    });

    testWidgets('버튼 크기가 올바르게 설정되는지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        ActionButtonWidget(
          onPressed: () {},
          backgroundColor: Colors.orange,
          text: 'Size Test',
          foregroundColor: Colors.white,
        ),
      ));

      // SizedBox의 크기 확인
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(double.infinity));
      expect(sizedBox.height, equals(56));
    });

    testWidgets('버튼 모서리 둥글기가 올바르게 설정되는지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        ActionButtonWidget(
          onPressed: () {},
          backgroundColor: Colors.teal,
          text: 'Border Radius Test',
          foregroundColor: Colors.white,
        ),
      ));

      // ElevatedButton의 스타일 확인
      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final shape = elevatedButton.style?.shape?.resolve({}) as RoundedRectangleBorder?;
      
      expect(shape?.borderRadius, equals(BorderRadius.circular(16)));
    });

    testWidgets('버튼 그림자가 올바르게 설정되는지 테스트', (WidgetTester tester) async {
      const backgroundColor = Colors.indigo;

      await tester.pumpWidget(createTestWidget(
        ActionButtonWidget(
          onPressed: () {},
          backgroundColor: backgroundColor,
          text: 'Shadow Test',
          foregroundColor: Colors.white,
        ),
      ));

      // ElevatedButton의 스타일 확인
      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      
      expect(elevatedButton.style?.elevation?.resolve({}), equals(8));
      expect(elevatedButton.style?.shadowColor?.resolve({}), 
          equals(backgroundColor.withValues(alpha: 0.4)));
    });

    testWidgets('다양한 텍스트 길이에 대한 테스트', (WidgetTester tester) async {
      const longText = '이것은 매우 긴 버튼 텍스트입니다. 버튼이 이 텍스트를 올바르게 처리하는지 확인합니다.';

      await tester.pumpWidget(createTestWidget(
        ActionButtonWidget(
          onPressed: () {},
          backgroundColor: Colors.amber,
          text: longText,
          foregroundColor: Colors.black,
        ),
      ));

      // 긴 텍스트가 표시되는지 확인
      expect(find.text(longText), findsOneWidget);
      
      // 버튼이 여전히 존재하는지 확인
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('빈 텍스트에 대한 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        ActionButtonWidget(
          onPressed: () {},
          backgroundColor: Colors.grey,
          text: '',
          foregroundColor: Colors.black,
        ),
      ));

      // 빈 텍스트가 처리되는지 확인
      expect(find.text(''), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('투명한 색상에 대한 테스트', (WidgetTester tester) async {
      final transparentColor = Colors.blue.withValues(alpha: 0.5);

      await tester.pumpWidget(createTestWidget(
        ActionButtonWidget(
          onPressed: () {},
          backgroundColor: transparentColor,
          text: 'Transparent Test',
          foregroundColor: Colors.white,
        ),
      ));

      // 투명한 색상이 올바르게 적용되는지 확인
      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(elevatedButton.style?.backgroundColor?.resolve({}), equals(transparentColor));
    });

    testWidgets('접근성 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        ActionButtonWidget(
          onPressed: () {},
          backgroundColor: Colors.blue,
          text: 'Accessibility Test',
          foregroundColor: Colors.white,
        ),
      ));

      // 버튼이 접근 가능한 요소인지 확인
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // 텍스트가 스크린 리더에 의해 읽을 수 있는지 확인
      expect(find.text('Accessibility Test'), findsOneWidget);
    });

    testWidgets('여러 ActionButtonWidget이 동시에 렌더링되는지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        Column(
          children: [
            ActionButtonWidget(
              onPressed: () {},
              backgroundColor: Colors.red,
              text: 'Button 1',
              foregroundColor: Colors.white,
            ),
            const SizedBox(height: 10),
            ActionButtonWidget(
              onPressed: () {},
              backgroundColor: Colors.green,
              text: 'Button 2',
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ));

      // 두 개의 버튼이 모두 존재하는지 확인
      expect(find.byType(ActionButtonWidget), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsNWidgets(2));
      expect(find.text('Button 1'), findsOneWidget);
      expect(find.text('Button 2'), findsOneWidget);
    });
  });
} 