import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mission100/widgets/challenge_card.dart';
import 'package:mission100/models/challenge.dart';
import 'package:mission100/generated/app_localizations.dart';
import '../test_helper.dart';

void main() {
  group('ChallengeCard Tests', () {
    
    setUpAll(() async {
      await TestHelper.setupTestEnvironment();
    });

    // 테스트용 Challenge 객체 생성 헬퍼
    Challenge createTestChallenge({
      String? id,
      String? title,
      String? description,
      ChallengeStatus? status,
      ChallengeDifficulty? difficulty,
      int? targetValue,
      String? targetUnit,
      int? estimatedDuration,
    }) {
      return Challenge(
        id: id ?? 'test_challenge_1',
        titleKey: 'challenge_title_key',
        descriptionKey: 'challenge_desc_key',
        difficultyKey: 'challenge_diff_key',
        duration: 7,
        targetCount: 100,
        milestones: ['milestone1', 'milestone2'],
        rewardKey: 'reward_key',
        isActive: true,
        currentProgress: 50,
        // 새로운 필드들
        title: title ?? '테스트 챌린지',
        description: description ?? '테스트용 챌린지 설명입니다.',
        status: status,
        difficulty: difficulty,
        targetValue: targetValue,
        targetUnit: targetUnit,
        estimatedDuration: estimatedDuration,
      );
    }

    // 테스트용 앱 래퍼
    Widget createTestApp(Widget child) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko'),
          Locale('en'),
        ],
        home: Scaffold(body: child),
      );
    }

    group('기본 렌더링 테스트', () {
      testWidgets('ChallengeCard가 올바르게 렌더링됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge();

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.byType(ChallengeCard), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.text('테스트 챌린지'), findsOneWidget);
        expect(find.text('테스트용 챌린지 설명입니다.'), findsOneWidget);
      });

      testWidgets('제목과 설명이 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        const title = '100개 푸쉬업 챌린지';
        const description = '하루에 100개의 푸쉬업을 완성하세요';
        final challenge = createTestChallenge(
          title: title,
          description: description,
        );

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.text(title), findsOneWidget);
        expect(find.text(description), findsOneWidget);
      });
    });

    group('상태 표시 테스트', () {
      testWidgets('available 상태가 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          status: ChallengeStatus.available,
        );

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.text('참여 가능'), findsOneWidget);
        
        // 상태 컨테이너의 색상 확인
        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.green));
      });

      testWidgets('active 상태가 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          status: ChallengeStatus.active,
        );

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.text('진행 중'), findsOneWidget);
        
        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.blue));
      });

      testWidgets('completed 상태가 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          status: ChallengeStatus.completed,
        );

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.text('완료'), findsOneWidget);
        
        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.purple));
      });

      testWidgets('상태가 없을 때는 상태 표시가 없음', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(); // status: null

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.text('참여 가능'), findsNothing);
        expect(find.text('진행 중'), findsNothing);
        expect(find.text('완료'), findsNothing);
      });
    });

    group('난이도 표시 테스트', () {
      testWidgets('쉬움 난이도가 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          difficulty: ChallengeDifficulty.easy,
        );

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.text('😊'), findsOneWidget);
        expect(find.text('쉬움'), findsOneWidget);
      });

      testWidgets('어려움 난이도가 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          difficulty: ChallengeDifficulty.hard,
        );

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.text('🔥'), findsOneWidget);
        expect(find.text('어려움'), findsOneWidget);
      });

      testWidgets('극한 난이도가 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          difficulty: ChallengeDifficulty.extreme,
        );

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.text('💀'), findsOneWidget);
        expect(find.text('극한'), findsOneWidget);
      });
    });

    group('목표값 표시 테스트', () {
      testWidgets('목표값이 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          targetValue: 500,
          targetUnit: '개',
        );

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.text('목표: 500개'), findsOneWidget);
      });

      testWidgets('단위가 없는 목표값이 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          targetValue: 100,
        );

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.text('목표: 100'), findsOneWidget);
      });

      testWidgets('목표값이 없을 때는 표시되지 않음', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(); // targetValue: null

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.textContaining('목표:'), findsNothing);
      });
    });

    group('예상 기간 표시 테스트', () {
      testWidgets('예상 기간이 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          estimatedDuration: 7,
        );

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.text('예상 기간: 7일'), findsOneWidget);
      });

      testWidgets('예상 기간이 0일 때는 표시되지 않음', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          estimatedDuration: 0,
        );

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.textContaining('예상 기간:'), findsNothing);
      });
    });

    group('상호작용 테스트', () {
      testWidgets('카드 탭이 올바르게 작동함', (WidgetTester tester) async {
        // Given
        bool tapped = false;
        final challenge = createTestChallenge();

        // When
        await tester.pumpWidget(
          createTestApp(
            ChallengeCard(
              challenge: challenge,
              onTap: () => tapped = true,
            ),
          ),
        );

        await tester.tap(find.byType(ChallengeCard));
        await tester.pumpAndSettle();

        // Then
        expect(tapped, isTrue);
      });

      testWidgets('onTap이 null일 때도 정상 동작함', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge();

        // When & Then (예외 발생하지 않아야 함)
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        await tester.tap(find.byType(ChallengeCard));
        await tester.pumpAndSettle();
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('Card의 elevation과 margin이 올바르게 설정됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge();

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, equals(4));
        expect(card.margin, equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)));
      });

      testWidgets('InkWell의 borderRadius가 올바르게 설정됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge();

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        final inkWell = tester.widget<InkWell>(find.byType(InkWell));
        expect(inkWell.borderRadius, equals(BorderRadius.circular(12)));
      });

      testWidgets('Padding이 올바르게 설정됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge();

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        final padding = tester.widget<Padding>(
          find.descendant(
            of: find.byType(InkWell),
            matching: find.byType(Padding),
          ).first,
        );
        expect(padding.padding, equals(const EdgeInsets.all(16)));
      });
    });

    group('복합 조건 테스트', () {
      testWidgets('모든 속성이 있는 챌린지가 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          title: '완전한 챌린지',
          description: '모든 속성을 가진 챌린지입니다',
          status: ChallengeStatus.active,
          difficulty: ChallengeDifficulty.hard,
          targetValue: 1000,
          targetUnit: '회',
          estimatedDuration: 30,
        );

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.text('완전한 챌린지'), findsOneWidget);
        expect(find.text('모든 속성을 가진 챌린지입니다'), findsOneWidget);
        expect(find.text('진행 중'), findsOneWidget);
        expect(find.text('🔥'), findsOneWidget);
        expect(find.text('어려움'), findsOneWidget);
        expect(find.text('목표: 1000회'), findsOneWidget);
        expect(find.text('예상 기간: 30일'), findsOneWidget);
      });

      testWidgets('최소한의 속성만 있는 챌린지가 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          title: '간단한 챌린지',
          description: '기본 챌린지입니다',
        );

        // When
        await tester.pumpWidget(
          createTestApp(ChallengeCard(challenge: challenge)),
        );

        // Then
        expect(find.text('간단한 챌린지'), findsOneWidget);
        expect(find.text('기본 챌린지입니다'), findsOneWidget);
        // 상태, 난이도, 목표값, 예상 기간은 표시되지 않아야 함
        expect(find.textContaining('참여 가능'), findsNothing);
        expect(find.textContaining('😊'), findsNothing);
        expect(find.textContaining('목표:'), findsNothing);
        expect(find.textContaining('예상 기간:'), findsNothing);
      });
    });
  });
} 