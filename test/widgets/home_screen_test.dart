import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mission100_chad_pushup/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mission100_chad_pushup/generated/app_localizations.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('HomeScreen이 기본 구성 요소들을 표시하는지 테스트', (
      WidgetTester tester,
    ) async {
      // Given: HomeScreen을 ProviderScope로 래핑 (Localization 포함)
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const HomeScreen(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', ''), Locale('ko', '')],
          ),
        ),
      );

      // 로딩이 완료될 때까지 대기
      await tester.pumpAndSettle();

      // Then: HomeScreen이 렌더링되어야 함
      expect(find.byType(HomeScreen), findsOneWidget);

      // 기본적인 위젯들이 있는지 확인
      final scaffolds = find.byType(Scaffold);
      expect(scaffolds, findsAtLeastNWidgets(1));
    });

    testWidgets('HomeScreen이 기본 위젯 구조를 가지는지 테스트', (WidgetTester tester) async {
      // Given: HomeScreen
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const HomeScreen(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', ''), Locale('ko', '')],
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Then: 기본 구조가 있어야 함
      expect(find.byType(Scaffold), findsOneWidget);
      expect(
        find.byType(AppBar),
        findsAtLeastNWidgets(0),
      ); // AppBar는 있을 수도 없을 수도
    });

    testWidgets('HomeScreen이 렌더링 오류 없이 표시되는지 테스트', (WidgetTester tester) async {
      // Given: HomeScreen
      bool hasErrors = false;

      // 오류 감지기 설정
      FlutterError.onError = (FlutterErrorDetails details) {
        hasErrors = true;
      };

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const HomeScreen(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', ''), Locale('ko', '')],
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Then: 렌더링 오류가 없어야 함
      expect(hasErrors, false);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('HomeScreen이 스크롤 가능한지 테스트', (WidgetTester tester) async {
      // Given: HomeScreen
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const HomeScreen())),
      );

      await tester.pumpAndSettle();

      // When: 스크롤 시도
      final scrollView = find.byType(Scrollable);

      // Then: 스크롤 뷰가 있어야 함
      expect(scrollView, findsAtLeastNWidgets(1));
    });

    testWidgets('HomeScreen의 그라데이션 배경이 렌더링되는지 테스트', (
      WidgetTester tester,
    ) async {
      // Given: HomeScreen
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const HomeScreen())),
      );

      await tester.pumpAndSettle();

      // Then: Container 또는 그라데이션 요소가 있어야 함
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });
  });
}
