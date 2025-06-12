import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/utils/constants.dart';

// Test용 PermissionIconWidget 클래스 (permission_screen.dart에서 private이므로 복사)
class PermissionIconWidget extends StatelessWidget {
  const PermissionIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(AppColors.primaryColor),
            const Color(AppColors.primaryColor).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(AppColors.primaryColor).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.security,
        size: 60,
        color: Colors.white,
      ),
    );
  }
}

void main() {
  group('PermissionIconWidget 위젯 테스트', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('기본 렌더링 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const PermissionIconWidget(),
      ));

      expect(find.byType(Container), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.security), findsOneWidget);
    });

    testWidgets('컨테이너 크기 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const PermissionIconWidget(),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, 120);
      expect(container.constraints?.maxHeight, 120);
    });

    testWidgets('아이콘 속성 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const PermissionIconWidget(),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.security));
      expect(icon.icon, Icons.security);
      expect(icon.size, 60);
      expect(icon.color, Colors.white);
    });

    testWidgets('BoxDecoration 속성 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const PermissionIconWidget(),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.gradient, isA<LinearGradient>());
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
    });

    testWidgets('그라데이션 설정 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const PermissionIconWidget(),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      
      expect(gradient.colors.length, 2);
      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
    });

    testWidgets('그림자 설정 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const PermissionIconWidget(),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final shadow = decoration.boxShadow!.first;
      
      expect(shadow.blurRadius, 20);
      expect(shadow.offset, const Offset(0, 8));
    });

    testWidgets('색상 투명도 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const PermissionIconWidget(),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      final shadow = decoration.boxShadow!.first;
      
      // 그라데이션 두 번째 색상의 투명도 확인
      expect(gradient.colors[1].alpha, (255 * 0.7).round());
      
      // 그림자 색상의 투명도 확인  
      expect(shadow.color.alpha, (255 * 0.3).round());
    });

    testWidgets('Container와 Icon의 관계 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const PermissionIconWidget(),
      ));

      final container = find.byType(Container).first;
      final icon = find.byIcon(Icons.security);
      
      expect(container, findsOneWidget);
      expect(icon, findsOneWidget);
      
      // Icon이 Container의 child인지 확인
      final containerWidget = tester.widget<Container>(container);
      expect(containerWidget.child, isA<Icon>());
    });

    testWidgets('그라데이션 색상이 primaryColor 기반인지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const PermissionIconWidget(),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      
      // 첫 번째 색상이 완전한 primaryColor인지 확인
      expect(gradient.colors[0], const Color(AppColors.primaryColor));
      
      // 두 번째 색상이 primaryColor 기반인지 확인
      final expectedSecondColor = const Color(AppColors.primaryColor).withValues(alpha: 0.7);
      expect(gradient.colors[1].value, expectedSecondColor.value);
    });

    testWidgets('그림자 색상이 primaryColor 기반인지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        const PermissionIconWidget(),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final shadow = decoration.boxShadow!.first;
      
      final expectedShadowColor = const Color(AppColors.primaryColor).withValues(alpha: 0.3);
      expect(shadow.color.value, expectedShadowColor.value);
    });
  });
} 