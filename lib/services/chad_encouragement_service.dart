import 'dart:math';
import 'package:flutter/material.dart';

/// 기가차드 스타일 격려 메시지 서비스
class ChadEncouragementService {
  static final ChadEncouragementService _instance =
      ChadEncouragementService._internal();
  factory ChadEncouragementService() => _instance;
  ChadEncouragementService._internal();

  final Random _random = Random();

  /// 튜토리얼 시작 시 격려 메시지들
  static const List<String> _tutorialStartMessages = [
    "차드의 길을 걷기 시작했구나, 만삣삐! 🔥",
    "진짜 차드는 공부부터 다르다! Let's go! 💪",
    "폼이 곧 실력이다, fxxk yeah! 📚",
    "기본기 없는 차드는 가짜 차드야, 만삣삐! ⚡",
    "지금 시작하는 것이 차드의 첫걸음이다! 🚀",
    "완벽한 폼으로 진짜 차드가 되어라! 💯",
    "약자들은 대충 하지만 차드는 완벽하게 한다! 🎯",
  ];

  /// 특정 푸시업 타입 선택 시 격려 메시지들
  static const List<String> _pushupSelectionMessages = [
    "좋은 선택이다, 차드! 이제 제대로 배워보자! 💪",
    "이 푸시업으로 진짜 차드 몸매를 만들어라! 🔥",
    "영상 잘 보고 따라 해봐, 만삣삐! 📺",
    "차드는 디테일에 강하다! 놓치지 마라! 👀",
    "이거 마스터하면 레벨업이다, fxxk yeah! ⬆️",
    "진짜 차드의 폼을 흡수해라! 🧠",
    "한 번 보는 걸로 끝나면 약자야! 반복하라! 🔄",
  ];

  /// 어려운 난이도 선택 시 격려 메시지들
  static const List<String> _challengingMessages = [
    "오, 도전적이구나! 진짜 차드의 기질이 보인다! 🔥",
    "이 레벨까지 보다니, 너 진짜 차드 되고 싶구나! 💪",
    "어려운 걸 선택하는 것이 차드다! 무섭지 않아! ⚡",
    "극한 레벨! 이거 되면 진짜 기가차드 인정! 🚀",
    "약자들은 도망가는 레벨이다! 차드는 도전한다! 🎯",
    "이 난이도면 99%가 포기하는데, 넌 1%가 되어라! 💯",
    "힘들어도 참아라! 차드의 길은 원래 험하다! 🏔️",
  ];

  /// 초급 레벨 선택 시 격려 메시지들
  static const List<String> _beginnerMessages = [
    "시작이 반이다! 기본기가 제일 중요해, 만삣삐! 🌱",
    "차드도 처음엔 초보였다! 부끄러워하지 마라! 💚",
    "기본을 완벽히 하면 다음 레벨이 쉬워진다! 📈",
    "차근차근 올라가는 것이 진짜 차드의 길이다! 🪜",
    "완벽한 폼으로 시작하면 차드 확정이야! ✅",
    "초급이라고 우습게 보지 마라! 기본이 제일 어렵다! 🎯",
    "지금 제대로 배우면 나중에 차드 될 수 있어! 🚀",
  ];

  /// 랜덤 격려 메시지 가져오기
  String getRandomTutorialStartMessage() {
    return _tutorialStartMessages[_random.nextInt(
      _tutorialStartMessages.length,
    )];
  }

  String getRandomPushupSelectionMessage() {
    return _pushupSelectionMessages[_random.nextInt(
      _pushupSelectionMessages.length,
    )];
  }

  String getRandomChallengingMessage() {
    return _challengingMessages[_random.nextInt(_challengingMessages.length)];
  }

  String getRandomBeginnerMessage() {
    return _beginnerMessages[_random.nextInt(_beginnerMessages.length)];
  }

  /// 푸시업 난이도에 따른 적절한 메시지 선택
  String getMessageForDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
      case '초급':
        return getRandomBeginnerMessage();
      case 'advanced':
      case 'extreme':
      case '고급':
      case '극한':
        return getRandomChallengingMessage();
      default:
        return getRandomPushupSelectionMessage();
    }
  }

  /// 격려 스낵바 표시
  void showEncouragementSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.psychology, color: Color(0xFFFFD43B)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFFFD43B), width: 1),
        ),
      ),
    );
  }

  /// 격려 다이얼로그 표시
  void showEncouragementDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFFFD43B), width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.psychology, color: Color(0xFFFFD43B), size: 28),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFD43B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFFD43B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "차드답게 가자! 💪",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 랜덤으로 격려 시스템 실행 (30% 확률)
  void maybeShowEncouragement(BuildContext context, {String? customMessage}) {
    if (_random.nextDouble() < 0.3) {
      // 30% 확률
      final message = customMessage ?? getRandomTutorialStartMessage();
      showEncouragementSnackBar(context, message);
    }
  }

  /// 특별한 순간에 축하 메시지 (항상 표시)
  void showCelebration(BuildContext context, String achievement) {
    final messages = [
      "축하한다, 차드! $achievement 완료했구나! 🎉",
      "$achievement 마스터! 진짜 차드의 기질이 보인다! 🔥",
      "이제 $achievement는 너의 것이다! fxxk yeah! 💪",
      "$achievement 정복! 다음 레벨로 가자, 만삣삐! 🚀",
    ];

    final message = messages[_random.nextInt(messages.length)];
    showEncouragementDialog(context, "기가차드 달성!", message);
  }
}
