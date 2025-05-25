import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mission100_chad_pushup/main.dart';

void main() {
  group('앱 시작 테스트', () {
    testWidgets('Mission100App이 시작되는지 테스트', (WidgetTester tester) async {
      // Given & When: 앱 시작
      await tester.pumpWidget(ProviderScope(child: Mission100App()));

      // 첫 프레임 대기
      await tester.pump();

      // Then: 앱이 시작되어야 함 (오류 없이)
      expect(find.byType(Mission100App), findsOneWidget);
    });

    testWidgets('MaterialApp이 존재하는지 테스트', (WidgetTester tester) async {
      // Given & When: 앱 시작
      await tester.pumpWidget(ProviderScope(child: Mission100App()));

      await tester.pump();

      // Then: MaterialApp이 존재해야 함
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('앱이 렌더링 오류 없이 시작되는지 테스트', (WidgetTester tester) async {
      // Given: 오류 감지
      bool hasErrors = false;
      final originalOnError = FlutterError.onError;

      FlutterError.onError = (FlutterErrorDetails details) {
        hasErrors = true;
        originalOnError?.call(details);
      };

      try {
        // When: 앱 시작
        await tester.pumpWidget(ProviderScope(child: Mission100App()));

        await tester.pump();

        // Then: 렌더링 오류가 없어야 함
        expect(hasErrors, false);
        expect(find.byType(Mission100App), findsOneWidget);
      } finally {
        // 원래 오류 핸들러 복구
        FlutterError.onError = originalOnError;
      }
    });
  });
}
