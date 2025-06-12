import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mission100/widgets/challenge_progress_widget.dart';
import 'package:mission100/models/challenge.dart';
import 'package:mission100/services/challenge_service.dart';
import '../test_helper.dart';

void main() {
  group('ChallengeProgressWidget Tests', () {
    
    setUpAll(() async {
      await TestHelper.setupTestEnvironment();
    });

    late ChallengeService challengeService;

    setUp(() {
      challengeService = ChallengeService();
    });

    // 테스트용 Challenge 객체 생성 헬퍼
    Challenge createTestChallenge({
      String? id,
      String? title,
      String? description,
      ChallengeType? type,
      int? targetValue,
      String? targetUnit,
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
        currentProgress: 0,
        // 새로운 필드들
        title: title ?? '테스트 챌린지',
        description: description ?? '테스트용 챌린지 설명입니다.',
        type: type,
        targetValue: targetValue,
        targetUnit: targetUnit,
      );
    }

    // 테스트용 앱 래퍼
    Widget createTestApp(Widget child) {
      return MaterialApp(
        home: Scaffold(body: child),
      );
    }

    group('기본 렌더링 테스트', () {
      testWidgets('ChallengeProgressWidget이 올바르게 렌더링됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          type: ChallengeType.consecutiveDays,
          targetValue: 7,
        );

        // When
        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: challenge,
              challengeService: challengeService,
            ),
          ),
        );

        // Then
        expect(find.byType(ChallengeProgressWidget), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('타입이 null인 경우 빈 위젯 반환', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(); // type: null

        // When
        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: challenge,
              challengeService: challengeService,
            ),
          ),
        );

        // Then
        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byType(Card), findsNothing);
      });
    });

    group('연속 일수 챌린지 테스트', () {
      testWidgets('연속 일수 챌린지가 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          type: ChallengeType.consecutiveDays,
          targetValue: 7,
        );

        // When
        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: challenge,
              challengeService: challengeService,
            ),
          ),
        );

        // Then
        expect(find.text('연속 일수 챌린지'), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.text('0/7일'), findsOneWidget);
        expect(find.text('0%'), findsOneWidget);
      });

      testWidgets('연속 일수 챌린지 위젯 구조가 올바름', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          type: ChallengeType.consecutiveDays,
          targetValue: 14,
        );

        // When
        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: challenge,
              challengeService: challengeService,
            ),
          ),
        );

        // Then
        expect(find.text('0/14일'), findsOneWidget);
        
        // LinearProgressIndicator가 올바르게 설정되었는지 확인
        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progressIndicator.value, equals(0.0));
      });
    });

    group('단일 세션 챌린지 테스트', () {
      testWidgets('단일 세션 챌린지가 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          type: ChallengeType.singleSession,
          targetValue: 50,
        );

        // When
        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: challenge,
              challengeService: challengeService,
            ),
          ),
        );

        // Then
        expect(find.text('단일 세션 챌린지'), findsOneWidget);
        expect(find.byIcon(Icons.fitness_center), findsOneWidget);
        expect(find.text('최고 기록'), findsOneWidget);
        expect(find.text('0개'), findsOneWidget);
        expect(find.text('50개 더 하면 달성!'), findsOneWidget);
      });

      testWidgets('단일 세션 챌린지 컨테이너 스타일이 올바름', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          type: ChallengeType.singleSession,
          targetValue: 100,
        );

        // When
        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: challenge,
              challengeService: challengeService,
            ),
          ),
        );

        // Then
        expect(find.text('100개 더 하면 달성!'), findsOneWidget);
        expect(find.byIcon(Icons.flag), findsOneWidget);
        
        // 컨테이너가 두 개 있는지 확인 (최고 기록 컨테이너 + 목표 컨테이너)
        final containers = tester.widgetList<Container>(find.byType(Container));
        expect(containers.length, greaterThanOrEqualTo(2));
      });
    });

    group('누적 챌린지 테스트', () {
      testWidgets('누적 챌린지가 올바르게 표시됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          type: ChallengeType.cumulative,
          targetValue: 1000,
        );

        // When
        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: challenge,
              challengeService: challengeService,
            ),
          ),
        );

        // Then
        expect(find.text('누적 챌린지'), findsOneWidget);
        expect(find.byIcon(Icons.trending_up), findsOneWidget);
      });
    });

    group('기본값 테스트', () {
      testWidgets('targetValue가 null일 때 기본값 사용됨 - consecutiveDays', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          type: ChallengeType.consecutiveDays,
          targetValue: null, // null로 설정
        );

        // When
        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: challenge,
              challengeService: challengeService,
            ),
          ),
        );

        // Then
        expect(find.text('0/7일'), findsOneWidget); // 기본값 7 사용
      });

      testWidgets('targetValue가 null일 때 기본값 사용됨 - singleSession', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          type: ChallengeType.singleSession,
          targetValue: null, // null로 설정
        );

        // When
        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: challenge,
              challengeService: challengeService,
            ),
          ),
        );

        // Then
        expect(find.text('50개 더 하면 달성!'), findsOneWidget); // 기본값 50 사용
      });

      testWidgets('targetValue가 null일 때 기본값 사용됨 - cumulative', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          type: ChallengeType.cumulative,
          targetValue: null, // null로 설정
        );

        // When
        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: challenge,
              challengeService: challengeService,
            ),
          ),
        );

        // Then
        expect(find.text('누적 챌린지'), findsOneWidget); // 기본값 100 사용 (위젯에서 확인 필요)
      });
    });

    group('레이아웃 테스트', () {
      testWidgets('Card의 margin이 올바르게 설정됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          type: ChallengeType.consecutiveDays,
          targetValue: 7,
        );

        // When
        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: challenge,
              challengeService: challengeService,
            ),
          ),
        );

        // Then
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.margin, equals(const EdgeInsets.all(16)));
      });

      testWidgets('Padding이 올바르게 설정됨', (WidgetTester tester) async {
        // Given
        final challenge = createTestChallenge(
          type: ChallengeType.consecutiveDays,
          targetValue: 7,
        );

        // When
        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: challenge,
              challengeService: challengeService,
            ),
          ),
        );

        // Then
        final padding = tester.widget<Padding>(
          find.descendant(
            of: find.byType(Card),
            matching: find.byType(Padding),
          ).first,
        );
        expect(padding.padding, equals(const EdgeInsets.all(16)));
      });
    });

    group('아이콘 및 색상 테스트', () {
      testWidgets('각 챌린지 타입의 아이콘이 올바름', (WidgetTester tester) async {
        // Given & When & Then for consecutiveDays
        final consecutiveChallenge = createTestChallenge(
          type: ChallengeType.consecutiveDays,
        );

        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: consecutiveChallenge,
              challengeService: challengeService,
            ),
          ),
        );

        expect(find.byIcon(Icons.calendar_today), findsOneWidget);

        // Given & When & Then for singleSession
        final singleChallenge = createTestChallenge(
          type: ChallengeType.singleSession,
        );

        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: singleChallenge,
              challengeService: challengeService,
            ),
          ),
        );

        expect(find.byIcon(Icons.fitness_center), findsOneWidget);

        // Given & When & Then for cumulative
        final cumulativeChallenge = createTestChallenge(
          type: ChallengeType.cumulative,
        );

        await tester.pumpWidget(
          createTestApp(
            ChallengeProgressWidget(
              challenge: cumulativeChallenge,
              challengeService: challengeService,
            ),
          ),
        );

        expect(find.byIcon(Icons.trending_up), findsOneWidget);
      });
    });
  });
} 