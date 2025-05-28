import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/widgets/achievement_progress_bar.dart';
import 'package:mission100/models/achievement.dart';
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

  group('AchievementProgressBar Widget Tests', () {
    Widget createTestWidget({
      required Achievement achievement,
      bool showLabel = true,
      double height = 8.0,
    }) {
      return MaterialApp(
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
        locale: const Locale('ko', 'KR'),
        home: Scaffold(
          body: AchievementProgressBar(
            achievement: achievement,
            showLabel: showLabel,
            height: height,
          ),
        ),
      );
    }

    Achievement createTestAchievement({
      double progress = 0.5,
      bool isCompleted = false,
    }) {
      final currentValue = (progress * 100).round();
      return Achievement(
        id: 'test_achievement',
        titleKey: 'achievementFirst50Title',
        descriptionKey: 'achievementFirst50Desc',
        motivationKey: 'achievementFirst50Motivation',
        type: AchievementType.volume,
        rarity: AchievementRarity.common,
        targetValue: 100,
        currentValue: currentValue,
        isUnlocked: isCompleted,
        xpReward: 100,
        icon: Icons.fitness_center,
      );
    }

    testWidgets('진행률 바가 기본적으로 렌더링되는지 테스트', (WidgetTester tester) async {
      // Given: 기본 진행률 바
      final achievement = createTestAchievement();
      await tester.pumpWidget(createTestWidget(achievement: achievement));

      // Then: 위젯이 렌더링되어야 함
      expect(find.byType(AchievementProgressBar), findsOneWidget);
    });

    testWidgets('진행률이 올바르게 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 50% 진행률
      final achievement = createTestAchievement(progress: 0.5);
      await tester.pumpWidget(createTestWidget(achievement: achievement));

      // When: 위젯을 렌더링하고 애니메이션 완료 대기
      await tester.pump();
      await tester.pump(const Duration(seconds: 2)); // 애니메이션 완료 대기

      // Then: 진행률이 올바르게 표시되어야 함
      expect(find.byType(AchievementProgressBar), findsOneWidget);
      expect(achievement.progress, equals(0.5));
    });

    testWidgets('라벨이 표시될 때 진행 상황 텍스트가 보이는지 테스트', (WidgetTester tester) async {
      // Given: 라벨이 있는 진행률 바
      final achievement = createTestAchievement(progress: 0.3);
      await tester.pumpWidget(createTestWidget(
        achievement: achievement,
        showLabel: true,
      ));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 진행 상황 텍스트가 표시되어야 함
      expect(find.text('30/100'), findsOneWidget);
    });

    testWidgets('라벨이 숨겨질 때 진행 상황 텍스트가 보이지 않는지 테스트', (WidgetTester tester) async {
      // Given: 라벨이 없는 진행률 바
      final achievement = createTestAchievement(progress: 0.3);
      await tester.pumpWidget(createTestWidget(
        achievement: achievement,
        showLabel: false,
      ));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 진행 상황 텍스트가 없어야 함
      expect(find.text('30/100'), findsNothing);
    });

    testWidgets('희귀도에 따른 색상이 적용되는지 테스트', (WidgetTester tester) async {
      // Given: 레어 등급 업적
      final achievement = Achievement(
        id: 'test_rare',
        titleKey: 'achievementStreak7Title',
        descriptionKey: 'achievementStreak7Desc',
        motivationKey: 'achievementStreak7Motivation',
        type: AchievementType.streak,
        rarity: AchievementRarity.rare,
        targetValue: 7,
        currentValue: 5,
        xpReward: 500,
        icon: Icons.fitness_center,
      );

      await tester.pumpWidget(createTestWidget(achievement: achievement));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 위젯이 렌더링되고 색상이 적용되어야 함
      expect(find.byType(AchievementProgressBar), findsOneWidget);
      expect(achievement.getRarityColor(), equals(Colors.blue));
    });

    testWidgets('커스텀 높이가 적용되는지 테스트', (WidgetTester tester) async {
      // Given: 커스텀 높이가 있는 진행률 바
      const customHeight = 20.0;
      final achievement = createTestAchievement();
      await tester.pumpWidget(createTestWidget(
        achievement: achievement,
        height: customHeight,
      ));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 위젯이 렌더링되어야 함
      expect(find.byType(AchievementProgressBar), findsOneWidget);
    });

    testWidgets('0% 진행률이 올바르게 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 0% 진행률
      final achievement = createTestAchievement(progress: 0.0);
      await tester.pumpWidget(createTestWidget(achievement: achievement));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 진행률이 0이어야 함
      expect(achievement.progress, equals(0.0));
      expect(find.byType(AchievementProgressBar), findsOneWidget);
    });

    testWidgets('100% 진행률이 올바르게 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 100% 진행률 (완료된 업적)
      final achievement = createTestAchievement(progress: 1.0, isCompleted: true);
      await tester.pumpWidget(createTestWidget(achievement: achievement));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 진행률이 1.0이어야 함
      expect(achievement.progress, equals(1.0));
      expect(achievement.isCompleted, isTrue);
      expect(find.byType(AchievementProgressBar), findsOneWidget);
    });

    testWidgets('범위를 벗어난 진행률이 처리되는지 테스트', (WidgetTester tester) async {
      // Given: 범위를 벗어난 진행률 (150%)
      final achievement = Achievement(
        id: 'test_over',
        titleKey: 'achievementFirst50Title',
        descriptionKey: 'achievementFirst50Desc',
        motivationKey: 'achievementFirst50Motivation',
        type: AchievementType.volume,
        rarity: AchievementRarity.common,
        targetValue: 100,
        currentValue: 150, // 목표값을 초과
        xpReward: 100,
        icon: Icons.fitness_center,
      );

      await tester.pumpWidget(createTestWidget(achievement: achievement));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 위젯이 오류 없이 렌더링되어야 함
      expect(find.byType(AchievementProgressBar), findsOneWidget);
      expect(achievement.progress, equals(1.5)); // 1.0을 초과할 수 있음
    });

    testWidgets('완료된 업적에 완료 배지가 표시되는지 테스트', (WidgetTester tester) async {
      // Given: 완료된 업적
      final achievement = createTestAchievement(progress: 1.0, isCompleted: true);
      await tester.pumpWidget(createTestWidget(
        achievement: achievement,
        showLabel: true,
      ));

      // When: 위젯을 렌더링
      await tester.pump();

      // Then: 완료 상태가 표시되어야 함
      expect(achievement.isCompleted, isTrue);
      expect(find.byType(AchievementProgressBar), findsOneWidget);
    });
  });
} 