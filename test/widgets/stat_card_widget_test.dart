import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/widgets/stat_card_widget.dart';
import 'package:mission100/utils/constants.dart';
import '../test_helper.dart';

void main() {
  setUpAll(() {
    setupTestEnvironment();
  });

  tearDownAll(() {
    tearDownTestEnvironment();
  });

  group('StatCardWidget Tests', () {
    Widget createTestWidget({
      required String title,
      required String value,
      required IconData icon,
      required Color color,
      required String subtitle,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: StatCardWidget(
            title: title,
            value: value,
            icon: icon,
            color: color,
            subtitle: subtitle,
          ),
        ),
      );
    }

    testWidgets('StatCardWidget이 기본적으로 렌더링되는지 테스트', (WidgetTester tester) async {
      // Given: 기본 통계 카드
      await tester.pumpWidget(createTestWidget(
        title: '총 운동',
        value: '42회',
        icon: Icons.fitness_center,
        color: Colors.blue,
        subtitle: '차드 데이',
      ));

      // Then: 위젯이 렌더링되어야 함
      expect(find.byType(StatCardWidget), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.text('총 운동'), findsOneWidget);
      expect(find.text('42회'), findsOneWidget);
      expect(find.text('차드 데이'), findsOneWidget);
    });

    testWidgets('아이콘이 올바르게 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 특정 아이콘이 있는 통계 카드
      const testIcon = Icons.trending_up;
      const testColor = Colors.green;
      
      await tester.pumpWidget(createTestWidget(
        title: '총 푸시업',
        value: '1000개',
        icon: testIcon,
        color: testColor,
        subtitle: '진짜 차드 파워',
      ));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 올바른 아이콘이 표시되어야 함
      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(iconWidget.icon, equals(testIcon));
      expect(iconWidget.color, equals(testColor));
      expect(iconWidget.size, equals(32.0));
    });

    testWidgets('색상이 올바르게 적용되는지 테스트', (WidgetTester tester) async {
      // Given: 특정 색상이 있는 통계 카드
      const testColor = Colors.red;
      
      await tester.pumpWidget(createTestWidget(
        title: '평균 완료율',
        value: '95%',
        icon: Icons.track_changes,
        color: testColor,
        subtitle: '완벽한 실행',
      ));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 색상이 올바르게 적용되어야 함
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      
      // 배경색 확인 (alpha 0.1)
      expect(decoration.color, equals(testColor.withValues(alpha: 0.1)));
      
      // 테두리 색상 확인 (alpha 0.3)
      expect(decoration.border, isA<Border>());
      final border = decoration.border as Border;
      expect(border.top.color, equals(testColor.withValues(alpha: 0.3)));
    });

    testWidgets('텍스트 스타일이 올바르게 적용되는지 테스트', (WidgetTester tester) async {
      // Given: 통계 카드
      const testColor = Colors.orange;
      
      await tester.pumpWidget(createTestWidget(
        title: '이번 달 운동',
        value: '15회',
        icon: Icons.calendar_today,
        color: testColor,
        subtitle: '꾸준한 차드',
      ));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 텍스트 스타일이 올바르게 적용되어야 함
      final titleText = tester.widget<Text>(find.text('이번 달 운동'));
      expect(titleText.style?.color, equals(testColor));
      expect(titleText.style?.fontWeight, equals(FontWeight.w600));
      expect(titleText.textAlign, equals(TextAlign.center));

      final valueText = tester.widget<Text>(find.text('15회'));
      expect(valueText.style?.color, equals(testColor));
      expect(valueText.style?.fontWeight, equals(FontWeight.bold));

      final subtitleText = tester.widget<Text>(find.text('꾸준한 차드'));
      expect(subtitleText.style?.color, equals(testColor.withValues(alpha: 0.7)));
      expect(subtitleText.style?.fontSize, equals(10.0));
      expect(subtitleText.textAlign, equals(TextAlign.center));
    });

    testWidgets('컨테이너 스타일이 올바르게 적용되는지 테스트', (WidgetTester tester) async {
      // Given: 통계 카드
      await tester.pumpWidget(createTestWidget(
        title: '테스트 제목',
        value: '테스트 값',
        icon: Icons.star,
        color: Colors.purple,
        subtitle: '테스트 부제목',
      ));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 컨테이너 스타일이 올바르게 적용되어야 함
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      
      // 패딩 확인
      expect(container.padding, equals(const EdgeInsets.all(AppConstants.paddingM)));
      
      // 테두리 반지름 확인
      expect(decoration.borderRadius, equals(BorderRadius.circular(AppConstants.radiusL)));
      
      // 테두리 두께 확인
      final border = decoration.border as Border;
      expect(border.top.width, equals(1.0));
    });

    testWidgets('Column 레이아웃이 올바르게 구성되는지 테스트', (WidgetTester tester) async {
      // Given: 통계 카드
      await tester.pumpWidget(createTestWidget(
        title: '레이아웃 테스트',
        value: '123',
        icon: Icons.check,
        color: Colors.teal,
        subtitle: '레이아웃 확인',
      ));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: Column이 올바르게 구성되어야 함
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
      expect(column.children.length, equals(6)); // Icon, SizedBox, Text, SizedBox, Text, Text
    });

    testWidgets('긴 텍스트가 올바르게 처리되는지 테스트', (WidgetTester tester) async {
      // Given: 긴 텍스트가 있는 통계 카드
      await tester.pumpWidget(createTestWidget(
        title: '매우 긴 제목이 있는 통계 카드 위젯 테스트',
        value: '999,999,999개',
        icon: Icons.fitness_center,
        color: Colors.indigo,
        subtitle: '매우 긴 부제목이 있는 통계 카드 위젯 테스트입니다',
      ));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 위젯이 오류 없이 렌더링되어야 함
      expect(find.byType(StatCardWidget), findsOneWidget);
      expect(find.text('매우 긴 제목이 있는 통계 카드 위젯 테스트'), findsOneWidget);
      expect(find.text('999,999,999개'), findsOneWidget);
      expect(find.text('매우 긴 부제목이 있는 통계 카드 위젯 테스트입니다'), findsOneWidget);
    });

    testWidgets('다양한 아이콘 타입이 지원되는지 테스트', (WidgetTester tester) async {
      // Given: 다양한 아이콘들
      final testCases = [
        Icons.fitness_center,
        Icons.trending_up,
        Icons.track_changes,
        Icons.calendar_today,
        Icons.star,
        Icons.favorite,
      ];

      for (final icon in testCases) {
        await tester.pumpWidget(createTestWidget(
          title: '아이콘 테스트',
          value: '테스트',
          icon: icon,
          color: Colors.blue,
          subtitle: '아이콘 확인',
        ));

        // When: 위젯을 렌더링
        await tester.pump();

        // Then: 아이콘이 올바르게 표시되어야 함
        final iconWidget = tester.widget<Icon>(find.byType(Icon));
        expect(iconWidget.icon, equals(icon));
      }
    });

    testWidgets('다양한 색상이 지원되는지 테스트', (WidgetTester tester) async {
      // Given: 다양한 색상들
      final testColors = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
        const Color(AppColors.primaryColor),
        const Color(AppColors.secondaryColor),
      ];

      for (final color in testColors) {
        await tester.pumpWidget(createTestWidget(
          title: '색상 테스트',
          value: '테스트',
          icon: Icons.star,
          color: color,
          subtitle: '색상 확인',
        ));

        // When: 위젯을 렌더링
        await tester.pump();

        // Then: 색상이 올바르게 적용되어야 함
        final iconWidget = tester.widget<Icon>(find.byType(Icon));
        expect(iconWidget.color, equals(color));
      }
    });

    testWidgets('빈 문자열이 올바르게 처리되는지 테스트', (WidgetTester tester) async {
      // Given: 빈 문자열이 있는 통계 카드
      await tester.pumpWidget(createTestWidget(
        title: '',
        value: '',
        icon: Icons.help,
        color: Colors.grey,
        subtitle: '',
      ));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 위젯이 오류 없이 렌더링되어야 함
      expect(find.byType(StatCardWidget), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(3)); // 빈 텍스트도 Text 위젯으로 렌더링됨
    });
  });
} 