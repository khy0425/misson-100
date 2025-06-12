import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test용 DescriptionContainerWidget 클래스 (onboarding_screen.dart에서 private이므로 복사)
class DescriptionContainerWidget extends StatelessWidget {
  final String description;
  final Color borderColor;
  final bool isDark;

  const DescriptionContainerWidget({
    super.key,
    required this.description,
    required this.borderColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF1A1A1A) 
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.grey[300] : Colors.grey[700],
          height: 1.6,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}

void main() {
  group('DescriptionContainerWidget 위젯 테스트', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('기본 렌더링 테스트 (라이트 모드)', (WidgetTester tester) async {
      const description = '테스트 설명입니다.';
      const borderColor = Colors.blue;
      
      await tester.pumpWidget(createTestWidget(
        const DescriptionContainerWidget(
          description: description,
          borderColor: borderColor,
          isDark: false,
        ),
      ));

      // Container가 존재하는지 확인
      expect(find.byType(Container), findsOneWidget); // DescriptionContainerWidget의 Container
      
      // Text가 존재하는지 확인
      expect(find.text(description), findsOneWidget);
      
      // DescriptionContainerWidget이 존재하는지 확인
      expect(find.byType(DescriptionContainerWidget), findsOneWidget);
    });

    testWidgets('다크 모드 렌더링 테스트', (WidgetTester tester) async {
      const description = '다크 모드 설명입니다.';
      const borderColor = Colors.red;
      
      await tester.pumpWidget(createTestWidget(
        const DescriptionContainerWidget(
          description: description,
          borderColor: borderColor,
          isDark: true,
        ),
      ));

      // 텍스트가 올바르게 표시되는지 확인
      expect(find.text(description), findsOneWidget);
      
      // 위젯이 올바르게 렌더링되는지 확인
      expect(find.byType(DescriptionContainerWidget), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('텍스트 스타일이 올바르게 적용되는지 테스트 (라이트 모드)', (WidgetTester tester) async {
      const description = '스타일 테스트';
      
      await tester.pumpWidget(createTestWidget(
        const DescriptionContainerWidget(
          description: description,
          borderColor: Colors.green,
          isDark: false,
        ),
      ));

      // Text 위젯의 스타일 확인
      final textWidget = tester.widget<Text>(find.text(description));
      expect(textWidget.style?.fontSize, equals(16));
      expect(textWidget.style?.height, equals(1.6));
      expect(textWidget.textAlign, equals(TextAlign.left));
    });

    testWidgets('텍스트 스타일이 올바르게 적용되는지 테스트 (다크 모드)', (WidgetTester tester) async {
      const description = '다크 모드 스타일 테스트';
      
      await tester.pumpWidget(createTestWidget(
        const DescriptionContainerWidget(
          description: description,
          borderColor: Colors.purple,
          isDark: true,
        ),
      ));

      // Text 위젯의 스타일 확인
      final textWidget = tester.widget<Text>(find.text(description));
      expect(textWidget.style?.fontSize, equals(16));
      expect(textWidget.style?.height, equals(1.6));
      expect(textWidget.textAlign, equals(TextAlign.left));
    });

    testWidgets('다양한 border 색상이 올바르게 처리되는지 테스트', (WidgetTester tester) async {
      const testCases = [
        {
          'description': '빨간 테두리',
          'borderColor': Colors.red,
          'isDark': false,
        },
        {
          'description': '파란 테두리',
          'borderColor': Colors.blue, 
          'isDark': true,
        },
        {
          'description': '초록 테두리',
          'borderColor': Colors.green,
          'isDark': false,
        },
      ];

      for (final testCase in testCases) {
        await tester.pumpWidget(createTestWidget(
          DescriptionContainerWidget(
            description: testCase['description'] as String,
            borderColor: testCase['borderColor'] as Color,
            isDark: testCase['isDark'] as bool,
          ),
        ));

        // 각 케이스마다 위젯이 올바르게 렌더링되는지 확인
        expect(find.text(testCase['description'] as String), findsOneWidget);
        expect(find.byType(DescriptionContainerWidget), findsOneWidget);
        
        await tester.pumpAndSettle();
      }
    });

    testWidgets('긴 텍스트가 올바르게 처리되는지 테스트', (WidgetTester tester) async {
      const longDescription = '''이것은 매우 긴 설명 텍스트입니다. 
여러 줄에 걸쳐 작성되었으며, 
위젯이 긴 텍스트를 올바르게 처리하는지 
확인하기 위한 테스트입니다.
레이아웃이 깨지지 않고 
모든 텍스트가 올바르게 표시되어야 합니다.''';
      
      await tester.pumpWidget(createTestWidget(
        const DescriptionContainerWidget(
          description: longDescription,
          borderColor: Colors.orange,
          isDark: false,
        ),
      ));

      // 긴 텍스트가 올바르게 표시되는지 확인
      expect(find.text(longDescription), findsOneWidget);
      expect(find.byType(DescriptionContainerWidget), findsOneWidget);
    });

    testWidgets('빈 텍스트에 대한 처리', (WidgetTester tester) async {
      const emptyDescription = '';
      
      await tester.pumpWidget(createTestWidget(
        const DescriptionContainerWidget(
          description: emptyDescription,
          borderColor: Colors.grey,
          isDark: false,
        ),
      ));

      // 빈 텍스트도 올바르게 처리되는지 확인
      expect(find.text(emptyDescription), findsOneWidget);
      expect(find.byType(DescriptionContainerWidget), findsOneWidget);
    });

    testWidgets('특수 문자가 포함된 텍스트 처리', (WidgetTester tester) async {
      const specialCharDescription = '특수 문자: !@#\$%^&*()_+-=[]{}|;:"<>?,./ 🎉🚀💪';
      
      await tester.pumpWidget(createTestWidget(
        const DescriptionContainerWidget(
          description: specialCharDescription,
          borderColor: Colors.cyan,
          isDark: true,
        ),
      ));

      // 특수 문자가 올바르게 표시되는지 확인
      expect(find.text(specialCharDescription), findsOneWidget);
      expect(find.byType(DescriptionContainerWidget), findsOneWidget);
    });

    testWidgets('Container 스타일이 올바르게 적용되는지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const DescriptionContainerWidget(
          description: '컨테이너 스타일 테스트',
          borderColor: Colors.amber,
          isDark: false,
        ),
      ));

      // Container 위젯이 존재하는지 확인
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      
      // Text 위젯이 Container 내부에 있는지 확인
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('투명한 색상에 대한 처리', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const DescriptionContainerWidget(
          description: '투명 색상 테스트',
          borderColor: Colors.transparent,
          isDark: false,
        ),
      ));

      // 투명 색상도 정상적으로 처리되는지 확인
      expect(find.text('투명 색상 테스트'), findsOneWidget);
      expect(find.byType(DescriptionContainerWidget), findsOneWidget);
    });

    testWidgets('여러 DescriptionContainerWidget 동시 렌더링', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        Column(
          children: const [
            DescriptionContainerWidget(
              description: '첫 번째 설명',
              borderColor: Colors.red,
              isDark: false,
            ),
            SizedBox(height: 16),
            DescriptionContainerWidget(
              description: '두 번째 설명',
              borderColor: Colors.blue,
              isDark: true,
            ),
          ],
        ),
      ));

      // 두 위젯이 모두 올바르게 렌더링되는지 확인
      expect(find.text('첫 번째 설명'), findsOneWidget);
      expect(find.text('두 번째 설명'), findsOneWidget);
      expect(find.byType(DescriptionContainerWidget), findsNWidgets(2));
    });
  });
} 