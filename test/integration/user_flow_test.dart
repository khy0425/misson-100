import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/main.dart' as app;
import 'package:mission100/models/user_profile.dart';
import 'package:mission100/services/database_service.dart';
import '../test_helper.dart';

void main() {
  setUpAll(() {
    setupTestEnvironment();
  });

  tearDownAll(() {
    tearDownTestEnvironment();
  });

  // 헬퍼 메서드들을 먼저 정의
  Future<void> setupUserProfile() async {
    final dbService = DatabaseService();
    
    final profile = UserProfile(
      id: 1,
      level: UserLevel.rookie,
      initialMaxReps: 10,
      startDate: DateTime.now(),
    );
    
    await dbService.insertUserProfile(profile);
  }

  Future<void> completeWorkoutSession(WidgetTester tester) async {
    // 홈 화면에서 운동 시작
    final todayWorkoutCard = find.text('오늘의 미션');
    if (todayWorkoutCard.evaluate().isNotEmpty) {
      await tester.tap(todayWorkoutCard);
      await tester.pumpAndSettle();
    }

    // 운동 완료 시뮬레이션
    final startButton = find.text('운동 시작');
    if (startButton.evaluate().isNotEmpty) {
      await tester.tap(startButton);
      await tester.pumpAndSettle();
    }

    // 모든 세트 완료
    for (int i = 0; i < 3; i++) {
      final completeButton = find.text('세트 완료');
      if (completeButton.evaluate().isNotEmpty) {
        await tester.tap(completeButton);
        await tester.pumpAndSettle();
      }
    }

    // 운동 완료
    final finishButton = find.text('운동 완료');
    if (finishButton.evaluate().isNotEmpty) {
      await tester.tap(finishButton);
      await tester.pumpAndSettle();
    }

    // 홈으로 돌아가기
    final homeButton = find.byIcon(Icons.home);
    if (homeButton.evaluate().isNotEmpty) {
      await tester.tap(homeButton);
      await tester.pumpAndSettle();
    }
  }

  group('Critical User Flow Integration Tests', () {
    testWidgets('완전한 사용자 온보딩 플로우 테스트', (WidgetTester tester) async {
      // Given: 앱 시작
      app.main();
      await tester.pumpAndSettle();

      // When: 온보딩 화면에서 사용자 레벨 선택
      // 초보자 레벨 선택
      final rookieButton = find.text('초보자');
      if (rookieButton.evaluate().isNotEmpty) {
        await tester.tap(rookieButton);
        await tester.pumpAndSettle();
      }

      // 초기 최대 반복 횟수 설정
      final maxRepsField = find.byType(TextField);
      if (maxRepsField.evaluate().isNotEmpty) {
        await tester.enterText(maxRepsField.first, '10');
        await tester.pumpAndSettle();
      }

      // 시작 버튼 탭
      final startButton = find.text('시작하기');
      if (startButton.evaluate().isNotEmpty) {
        await tester.tap(startButton);
        await tester.pumpAndSettle();
      }

      // Then: 홈 화면으로 이동되어야 함
      expect(find.text('Mission 100'), findsOneWidget);
    });

    testWidgets('운동 세션 완료 플로우 테스트', (WidgetTester tester) async {
      // Given: 앱이 실행되고 홈 화면에 있음
      app.main();
      await tester.pumpAndSettle();

      // 사용자 프로필이 설정되어 있다고 가정
      await setupUserProfile();

      // When: 오늘의 운동 카드 탭
      final todayWorkoutCard = find.text('오늘의 미션');
      if (todayWorkoutCard.evaluate().isNotEmpty) {
        await tester.tap(todayWorkoutCard);
        await tester.pumpAndSettle();
      }

      // 운동 화면에서 운동 시작
      final startWorkoutButton = find.text('운동 시작');
      if (startWorkoutButton.evaluate().isNotEmpty) {
        await tester.tap(startWorkoutButton);
        await tester.pumpAndSettle();
      }

      // 첫 번째 세트 완료
      final completeSetButton = find.text('세트 완료');
      if (completeSetButton.evaluate().isNotEmpty) {
        await tester.tap(completeSetButton);
        await tester.pumpAndSettle();
      }

      // Then: 진행 상황이 업데이트되어야 함
      expect(find.text('1/3 세트 완료'), findsOneWidget);
    });

    testWidgets('통계 화면 네비게이션 플로우 테스트', (WidgetTester tester) async {
      // Given: 앱이 실행되고 홈 화면에 있음
      app.main();
      await tester.pumpAndSettle();

      // When: 하단 네비게이션에서 통계 탭 선택
      final statsTab = find.byIcon(Icons.bar_chart);
      if (statsTab.evaluate().isNotEmpty) {
        await tester.tap(statsTab);
        await tester.pumpAndSettle();
      }

      // Then: 통계 화면이 표시되어야 함
      expect(find.text('통계'), findsOneWidget);
      expect(find.text('총 푸시업'), findsOneWidget);
      expect(find.text('완료한 운동'), findsOneWidget);
    });

    testWidgets('업적 화면 네비게이션 플로우 테스트', (WidgetTester tester) async {
      // Given: 앱이 실행되고 홈 화면에 있음
      app.main();
      await tester.pumpAndSettle();

      // When: 하단 네비게이션에서 업적 탭 선택
      final achievementsTab = find.byIcon(Icons.emoji_events);
      if (achievementsTab.evaluate().isNotEmpty) {
        await tester.tap(achievementsTab);
        await tester.pumpAndSettle();
      }

      // Then: 업적 화면이 표시되어야 함
      expect(find.text('업적'), findsOneWidget);
      
      // 업적 카드들이 표시되어야 함
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('설정 화면 접근 및 기능 테스트', (WidgetTester tester) async {
      // Given: 앱이 실행되고 홈 화면에 있음
      app.main();
      await tester.pumpAndSettle();

      // When: 하단 네비게이션에서 설정 탭 선택
      final settingsTab = find.byIcon(Icons.settings);
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();
      }

      // Then: 설정 화면이 표시되어야 함
      expect(find.text('설정'), findsOneWidget);
      
      // 설정 옵션들이 표시되어야 함
      expect(find.text('데이터 백업'), findsOneWidget);
      expect(find.text('데이터 복원'), findsOneWidget);
      expect(find.text('앱 정보'), findsOneWidget);
    });

    testWidgets('데이터 백업 기능 테스트', (WidgetTester tester) async {
      // Given: 설정 화면에 있음
      app.main();
      await tester.pumpAndSettle();

      final settingsTab = find.byIcon(Icons.settings);
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();
      }

      // When: 데이터 백업 버튼 탭
      final backupButton = find.text('데이터 백업');
      if (backupButton.evaluate().isNotEmpty) {
        await tester.tap(backupButton);
        await tester.pumpAndSettle();
      }

      // Then: 백업 확인 다이얼로그가 표시되어야 함
      expect(find.text('백업 완료'), findsOneWidget);
    });

    testWidgets('앱 정보 화면 접근 테스트', (WidgetTester tester) async {
      // Given: 설정 화면에 있음
      app.main();
      await tester.pumpAndSettle();

      final settingsTab = find.byIcon(Icons.settings);
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();
      }

      // When: 앱 정보 버튼 탭
      final appInfoButton = find.text('앱 정보');
      if (appInfoButton.evaluate().isNotEmpty) {
        await tester.tap(appInfoButton);
        await tester.pumpAndSettle();
      }

      // Then: 앱 정보 화면이 표시되어야 함
      expect(find.text('Mission 100'), findsOneWidget);
      expect(find.text('버전'), findsOneWidget);
    });

    testWidgets('운동 기록 저장 및 조회 플로우 테스트', (WidgetTester tester) async {
      // Given: 앱이 실행되고 사용자 프로필이 설정됨
      app.main();
      await tester.pumpAndSettle();
      await setupUserProfile();

      // When: 운동을 완료하고 기록 저장
      await completeWorkoutSession(tester);

      // 통계 화면으로 이동
      final statsTab = find.byIcon(Icons.bar_chart);
      if (statsTab.evaluate().isNotEmpty) {
        await tester.tap(statsTab);
        await tester.pumpAndSettle();
      }

      // Then: 완료된 운동이 통계에 반영되어야 함
      expect(find.text('1'), findsWidgets); // 완료된 운동 수
    });

    testWidgets('업적 해제 플로우 테스트', (WidgetTester tester) async {
      // Given: 앱이 실행되고 여러 운동을 완료함
      app.main();
      await tester.pumpAndSettle();
      await setupUserProfile();

      // When: 충분한 운동을 완료하여 업적 조건 달성
      for (int i = 0; i < 5; i++) {
        await completeWorkoutSession(tester);
      }

      // 업적 화면으로 이동
      final achievementsTab = find.byIcon(Icons.emoji_events);
      if (achievementsTab.evaluate().isNotEmpty) {
        await tester.tap(achievementsTab);
        await tester.pumpAndSettle();
      }

      // Then: 해제된 업적이 표시되어야 함
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('전체 앱 네비게이션 플로우 테스트', (WidgetTester tester) async {
      // Given: 앱이 실행됨
      app.main();
      await tester.pumpAndSettle();

      // When: 모든 탭을 순차적으로 방문
      final tabs = [
        Icons.home,
        Icons.bar_chart,
        Icons.emoji_events,
        Icons.settings,
      ];

      for (final tabIcon in tabs) {
        final tab = find.byIcon(tabIcon);
        if (tab.evaluate().isNotEmpty) {
          await tester.tap(tab);
          await tester.pumpAndSettle();
          
          // 각 화면이 올바르게 로드되었는지 확인
          expect(find.byType(Scaffold), findsOneWidget);
        }
      }

      // Then: 모든 탭 네비게이션이 성공해야 함
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
} 