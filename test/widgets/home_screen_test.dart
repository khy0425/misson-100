import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mission100/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mission100/generated/app_localizations.dart';
import '../test_helper.dart';

void main() {
  setUpAll(() {
    setupTestEnvironment();
  });

  tearDownAll(() {
    tearDownTestEnvironment();
  });

  group('HomeScreen Basic Tests', () {
    testWidgets('홈 스크린이 기본적으로 렌더링되는지 테스트', (WidgetTester tester) async {
      // Given: 기본 앱 설정
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ko', 'KR'),
              Locale('en', 'US'),
            ],
            home: const HomeScreen(),
          ),
        ),
      );

      // When: 위젯이 렌더링됨
      await tester.pump();

      // Then: 홈 스크린이 렌더링되어야 함
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('로딩 상태가 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 기본 앱 설정
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ko', 'KR'),
              Locale('en', 'US'),
            ],
            home: const HomeScreen(),
          ),
        ),
      );

      // When: 위젯이 렌더링됨
      await tester.pump();

      // Then: 로딩 인디케이터가 표시되어야 함
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('앱바가 올바르게 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 기본 앱 설정
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ko', 'KR'),
              Locale('en', 'US'),
            ],
            home: const HomeScreen(),
          ),
        ),
      );

      // When: 위젯이 렌더링됨
      await tester.pump();

      // Then: 앱바가 표시되어야 함
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
