import 'dart:math';
import 'package:flutter/material.dart';

/// 기가차드 스타일 격려 메시지 서비스
class ChadEncouragementService {
  static final ChadEncouragementService _instance =
      ChadEncouragementService._internal();
  factory ChadEncouragementService() => _instance;
  ChadEncouragementService._internal();

  final Random _random = Random();

  /// 튜토리얼 시작 시 격려 메시지들 (다국어 지원을 위해 키값 사용)
  static const List<String> _tutorialStartMessageKeys = [
    'encouragement_tutorial_start_1',
    'encouragement_tutorial_start_2', 
    'encouragement_tutorial_start_3',
    'encouragement_tutorial_start_4',
    'encouragement_tutorial_start_5',
    'encouragement_tutorial_start_6',
    'encouragement_tutorial_start_7',
  ];

  /// 기본 격려 메시지들 (다국어 지원 전까지 임시 사용)
  static const List<String> _defaultMessages = [
    '💪 Great choice!',
    '🔥 Keep going!',
    '⚡ You got this!',
    '🎯 Perfect!',
    '💯 Excellent!',
    '🚀 Amazing!',
    '🏆 Outstanding!',
  ];

  /// 랜덤 격려 메시지 가져오기
  String getRandomMessage() {
    return _defaultMessages[_random.nextInt(_defaultMessages.length)];
  }

  String getRandomTutorialStartMessage() {
    return getRandomMessage();
  }

  String getRandomPushupSelectionMessage() {
    return getRandomMessage();
  }

  String getRandomChallengingMessage() {
    return getRandomMessage();
  }

  String getRandomBeginnerMessage() {
    return getRandomMessage();
  }

  /// 푸시업 난이도에 따른 적절한 메시지 선택
  String getMessageForDifficulty(String difficulty) {
    return getRandomMessage();
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
    showDialog<void>(
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
              'OK',
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
      '🎉 Congratulations!',
      '🏆 Perfect achievement!',
      '💪 Outstanding performance!',
      '🔥 Incredible work!',
    ];

    final message = messages[_random.nextInt(messages.length)];
    showEncouragementDialog(context, '🎊 Achievement!', message);
  }
}
