import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mission100_chad_pushup/main.dart';
import 'package:mission100_chad_pushup/screens/main_navigation_screen.dart';

void main() {
  group('Mission100 App Integration Tests', () {
    testWidgets('Mission100App이 시작되는지 테스트', (WidgetTester tester) async {
      // Given: Mission100App 위젯
      await tester.pumpWidget(ProviderScope(child: Mission100App()));

      // When: 위젯이 렌더링됨
      expect(find.byType(MainNavigationScreen), findsNothing); // 아직 홈 화면은 없음
      expect(find.byType(MaterialApp), findsOneWidget);

      // Then: 앱이 정상적으로 시작되어야 함
      expect(tester.takeException(), isNull);
    });

    testWidgets('MaterialApp이 존재하는지 테스트', (WidgetTester tester) async {
      // Given: Mission100App 위젯
      await tester.pumpWidget(ProviderScope(child: Mission100App()));

      // When: 위젯이 렌더링됨
      await tester.pump();

      // Then: MaterialApp이 존재해야 함
      expect(find.byType(MaterialApp), findsOneWidget);

      // MaterialApp의 속성들 확인
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('Mission: 100'));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('앱이 렌더링 오류 없이 시작되는지 테스트', (WidgetTester tester) async {
      // Given & When: Mission100App 시작
      await tester.pumpWidget(ProviderScope(child: Mission100App()));

      // 모든 애니메이션과 이벤트 완료까지 대기
      await tester.pumpAndSettle();

      // Then: 렌더링 오류가 없어야 함
      expect(tester.takeException(), isNull);

      // Scaffold 위젯이 존재해야 함 (스플래시 화면)
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('스플래시 화면 요소들이 올바르게 렌더링되는지 테스트', (WidgetTester tester) async {
      // Given: Mission100App 시작
      await tester.pumpWidget(ProviderScope(child: Mission100App()));
      await tester.pumpAndSettle();

      // Then: 핵심 UI 요소들이 존재해야 함
      expect(find.text('Mission: 100'), findsOneWidget);
      expect(find.text('Start for Chad'), findsOneWidget);
      expect(find.text('Real Chads don\'t make excuses'), findsOneWidget);

      // 언어 토글 버튼 존재 확인
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('언어 토글 버튼이 작동하는지 테스트', (WidgetTester tester) async {
      // Given: Mission100App 시작
      await tester.pumpWidget(ProviderScope(child: Mission100App()));
      await tester.pumpAndSettle();

      // When: 언어 토글 버튼 클릭
      final languageButton = find.byIcon(Icons.language);
      expect(languageButton, findsOneWidget);

      await tester.tap(languageButton);
      await tester.pump();

      // Then: 오류 없이 처리되어야 함
      expect(tester.takeException(), isNull);
    });

    testWidgets('시작 버튼 탭 시 네비게이션이 동작하는지 테스트', (WidgetTester tester) async {
      // Given: Mission100App 시작
      await tester.pumpWidget(ProviderScope(child: Mission100App()));
      await tester.pumpAndSettle();

      // When: 시작 버튼 클릭
      final startButton = find.text('Start for Chad');
      expect(startButton, findsOneWidget);

      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // Then: 네비게이션이 시도되어야 함 (InitialTestScreen으로)
      // 실제 화면 전환은 라우트 설정에 따라 달라질 수 있음
      expect(tester.takeException(), isNull);
    });

    testWidgets('앱 시작 및 메인 네비게이션 테스트', (WidgetTester tester) async {
      // Given: 앱 시작
      await tester.pumpWidget(ProviderScope(child: Mission100App()));
      await tester.pumpAndSettle();

      // Then: MainNavigationScreen이 렌더링되어야 함
      expect(find.byType(MainNavigationScreen), findsOneWidget);

      // 기본적으로 홈 화면이 선택되어야 함
      expect(find.text('오늘의 운동'), findsOneWidget);
    });

    testWidgets('네비게이션 탭 전환 테스트', (WidgetTester tester) async {
      // Given: 앱 시작
      await tester.pumpWidget(ProviderScope(child: Mission100App()));
      await tester.pumpAndSettle();

      // When: 캘린더 탭 클릭
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // Then: 캘린더 화면이 표시되어야 함
      expect(find.text('운동 캘린더'), findsOneWidget);

      // When: 업적 탭 클릭
      await tester.tap(find.byIcon(Icons.emoji_events));
      await tester.pumpAndSettle();

      // Then: 업적 화면이 표시되어야 함
      expect(find.text('업적'), findsOneWidget);

      // When: 통계 탭 클릭
      await tester.tap(find.byIcon(Icons.analytics));
      await tester.pumpAndSettle();

      // Then: 통계 화면이 표시되어야 함
      expect(find.text('운동 통계'), findsOneWidget);

      // When: 설정 탭 클릭
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Then: 설정 화면이 표시되어야 함
      expect(find.text('설정'), findsOneWidget);
    });

    testWidgets('홈 화면 기본 요소 테스트', (WidgetTester tester) async {
      // Given: 앱 시작 (홈 화면)
      await tester.pumpWidget(ProviderScope(child: Mission100App()));
      await tester.pumpAndSettle();

      // Then: 홈 화면의 주요 요소들이 표시되어야 함
      expect(find.text('오늘의 운동'), findsOneWidget);
      expect(find.text('푸시업 시작하기'), findsOneWidget);
      expect(find.text('내 진행률'), findsOneWidget);

      // 운동 시작 버튼이 있어야 함
      expect(find.byKey(const Key('start_workout_button')), findsOneWidget);
    });

    testWidgets('업적 화면 기본 표시 테스트', (WidgetTester tester) async {
      // Given: 앱 시작 후 업적 탭으로 이동
      await tester.pumpWidget(ProviderScope(child: Mission100App()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.emoji_events));
      await tester.pumpAndSettle();

      // Then: 업적 관련 요소들이 표시되어야 함
      expect(find.text('업적'), findsOneWidget);
      expect(find.text('달성한 업적'), findsOneWidget);
      expect(find.text('진행 중인 업적'), findsOneWidget);

      // XP 정보가 표시되어야 함
      expect(find.textContaining('XP'), findsWidgets);
    });

    testWidgets('설정 화면 기본 토글들 테스트', (WidgetTester tester) async {
      // Given: 앱 시작 후 설정 탭으로 이동
      await tester.pumpWidget(ProviderScope(child: Mission100App()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Then: 설정 항목들이 표시되어야 함
      expect(find.text('설정'), findsOneWidget);
      expect(find.text('알림 설정'), findsOneWidget);
      expect(find.text('푸시 알림'), findsOneWidget);
      expect(find.text('업적 알림'), findsOneWidget);
      expect(find.text('운동 리마인더'), findsOneWidget);

      // 토글 스위치들이 있어야 함
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('캘린더 화면 월간 표시 테스트', (WidgetTester tester) async {
      // Given: 앱 시작 후 캘린더 탭으로 이동
      await tester.pumpWidget(ProviderScope(child: Mission100App()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // Then: 캘린더 관련 요소들이 표시되어야 함
      expect(find.text('운동 캘린더'), findsOneWidget);
      expect(find.text('연속 운동일'), findsOneWidget);

      // 월간 캘린더가 표시되어야 함
      expect(find.byKey(const Key('monthly_calendar')), findsOneWidget);
    });

    testWidgets('에러 없이 모든 화면 전환 테스트', (WidgetTester tester) async {
      // Given: 앱 시작
      await tester.pumpWidget(ProviderScope(child: Mission100App()));
      await tester.pumpAndSettle();

      // 모든 탭을 순서대로 클릭해서 에러가 없는지 확인
      final tabIcons = [
        Icons.home,
        Icons.calendar_today,
        Icons.emoji_events,
        Icons.analytics,
        Icons.settings,
      ];

      for (final icon in tabIcons) {
        // When: 각 탭 클릭
        await tester.tap(find.byIcon(icon));
        await tester.pumpAndSettle();

        // Then: 에러 없이 화면이 렌더링되어야 함
        expect(tester.takeException(), isNull);
      }
    });
  });
}
