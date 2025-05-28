import 'dart:math';
import 'package:flutter/foundation.dart';

/// 동기부여 메시지 카테고리
enum MessageCategory {
  workoutStart,
  setCompletion,
  workoutCompletion,
  restDay,
  goalAchievement,
  failure,
  success,
  encouragement,
  milestone,
  comeback,
}

/// 동기부여 메시지 데이터 클래스
class MotivationalMessage {
  final String message;
  final MessageCategory category;
  final int weight; // 메시지 선택 가중치 (1-10)
  final int minLevel; // 최소 레벨 요구사항
  final int maxLevel; // 최대 레벨 요구사항 (-1은 제한 없음)

  const MotivationalMessage({
    required this.message,
    required this.category,
    this.weight = 5,
    this.minLevel = 0,
    this.maxLevel = -1,
  });
}

/// Chad 스타일 동기부여 메시지 서비스
class MotivationalMessageService {
  static final MotivationalMessageService _instance = MotivationalMessageService._internal();
  factory MotivationalMessageService() => _instance;
  MotivationalMessageService._internal();

  final Random _random = Random();

  /// 모든 동기부여 메시지 데이터
  static const List<MotivationalMessage> _messages = [
    // 운동 시작 메시지
    MotivationalMessage(
      message: "진짜 차드는 변명하지 않는다! 💪",
      category: MessageCategory.workoutStart,
      weight: 8,
    ),
    MotivationalMessage(
      message: "오늘도 차드가 되는 여정이 시작된다!",
      category: MessageCategory.workoutStart,
      weight: 7,
    ),
    MotivationalMessage(
      message: "차드의 길은 쉽지 않지만, 그래서 더 가치있다!",
      category: MessageCategory.workoutStart,
      weight: 6,
    ),
    MotivationalMessage(
      message: "100개의 팔굽혀펴기, 100개의 기회! 시작하자!",
      category: MessageCategory.workoutStart,
      weight: 9,
    ),
    MotivationalMessage(
      message: "차드는 태어나는 게 아니라 만들어진다! 🔥",
      category: MessageCategory.workoutStart,
      weight: 8,
    ),

    // 세트 완료 메시지
    MotivationalMessage(
      message: "바로 그거야! 계속 가자! 🚀",
      category: MessageCategory.setCompletion,
      weight: 8,
    ),
    MotivationalMessage(
      message: "차드의 기운이 느껴진다!",
      category: MessageCategory.setCompletion,
      weight: 7,
    ),
    MotivationalMessage(
      message: "완벽한 폼이었어! 다음 세트도 화이팅!",
      category: MessageCategory.setCompletion,
      weight: 6,
    ),
    MotivationalMessage(
      message: "이런 게 진짜 차드의 자세지!",
      category: MessageCategory.setCompletion,
      weight: 7,
    ),
    MotivationalMessage(
      message: "한 세트 더 차드에 가까워졌다! 💯",
      category: MessageCategory.setCompletion,
      weight: 8,
    ),

    // 운동 완료 메시지
    MotivationalMessage(
      message: "차드에 한 걸음 더 가까워졌다! 🏆",
      category: MessageCategory.workoutCompletion,
      weight: 9,
    ),
    MotivationalMessage(
      message: "오늘의 미션 완료! 차드의 DNA가 깨어나고 있어!",
      category: MessageCategory.workoutCompletion,
      weight: 8,
    ),
    MotivationalMessage(
      message: "완벽한 운동이었어! 내일도 기대된다!",
      category: MessageCategory.workoutCompletion,
      weight: 7,
    ),
    MotivationalMessage(
      message: "이제 진짜 차드의 모습이 보이기 시작한다!",
      category: MessageCategory.workoutCompletion,
      weight: 8,
    ),
    MotivationalMessage(
      message: "오늘도 한계를 뛰어넘었다! 차드 인증! ✅",
      category: MessageCategory.workoutCompletion,
      weight: 9,
    ),

    // 휴식일 메시지
    MotivationalMessage(
      message: "차드도 휴식이 필요하지만, 너무 오래는 안 돼! 😎",
      category: MessageCategory.restDay,
      weight: 8,
    ),
    MotivationalMessage(
      message: "오늘은 근육이 자라는 날! 내일 더 강해져서 돌아오자!",
      category: MessageCategory.restDay,
      weight: 7,
    ),
    MotivationalMessage(
      message: "휴식도 차드가 되는 과정의 일부야!",
      category: MessageCategory.restDay,
      weight: 6,
    ),
    MotivationalMessage(
      message: "충분히 쉬었으면 이제 다시 시작할 시간이야!",
      category: MessageCategory.restDay,
      weight: 7,
    ),

    // 목표 달성 메시지
    MotivationalMessage(
      message: "차드 형제단에 온 것을 환영한다! 🎉",
      category: MessageCategory.goalAchievement,
      weight: 10,
      minLevel: 50,
    ),
    MotivationalMessage(
      message: "드디어 해냈다! 진짜 차드의 탄생! 👑",
      category: MessageCategory.goalAchievement,
      weight: 10,
      minLevel: 100,
    ),
    MotivationalMessage(
      message: "목표 달성! 이제 더 큰 꿈을 꿔보자!",
      category: MessageCategory.goalAchievement,
      weight: 8,
    ),
    MotivationalMessage(
      message: "불가능을 가능으로 만들었다! 차드 레전드! 🔥",
      category: MessageCategory.goalAchievement,
      weight: 9,
      minLevel: 75,
    ),

    // 실패 시 격려 메시지
    MotivationalMessage(
      message: "차드는 넘어져도 다시 일어난다! 💪",
      category: MessageCategory.failure,
      weight: 8,
    ),
    MotivationalMessage(
      message: "실패는 성공의 어머니! 다시 도전하자!",
      category: MessageCategory.failure,
      weight: 7,
    ),
    MotivationalMessage(
      message: "이런 날도 있는 거야. 중요한 건 포기하지 않는 것!",
      category: MessageCategory.failure,
      weight: 6,
    ),
    MotivationalMessage(
      message: "차드가 되는 길에는 시행착오가 필요해!",
      category: MessageCategory.failure,
      weight: 7,
    ),

    // 성공 시 축하 메시지
    MotivationalMessage(
      message: "완벽한 성과! 차드의 기운이 넘친다! ⚡",
      category: MessageCategory.success,
      weight: 9,
    ),
    MotivationalMessage(
      message: "이런 게 진짜 차드의 실력이지!",
      category: MessageCategory.success,
      weight: 8,
    ),
    MotivationalMessage(
      message: "목표를 뛰어넘었다! 차드 DNA 100% 활성화! 🧬",
      category: MessageCategory.success,
      weight: 9,
    ),

    // 격려 메시지
    MotivationalMessage(
      message: "포기하지 마! 차드는 절대 포기하지 않아!",
      category: MessageCategory.encouragement,
      weight: 8,
    ),
    MotivationalMessage(
      message: "힘들 때일수록 진짜 차드가 나온다!",
      category: MessageCategory.encouragement,
      weight: 7,
    ),
    MotivationalMessage(
      message: "지금이 바로 한계를 뛰어넘을 순간이야! 🚀",
      category: MessageCategory.encouragement,
      weight: 8,
    ),

    // 마일스톤 메시지
    MotivationalMessage(
      message: "10일 연속 달성! 차드의 습관이 만들어지고 있어!",
      category: MessageCategory.milestone,
      weight: 9,
      minLevel: 10,
    ),
    MotivationalMessage(
      message: "30일 돌파! 이제 진짜 차드의 시작이야! 🎯",
      category: MessageCategory.milestone,
      weight: 10,
      minLevel: 30,
    ),
    MotivationalMessage(
      message: "50일 달성! 차드 중급자 인증! 🥉",
      category: MessageCategory.milestone,
      weight: 10,
      minLevel: 50,
    ),
    MotivationalMessage(
      message: "75일 돌파! 차드 고급자의 경지! 🥈",
      category: MessageCategory.milestone,
      weight: 10,
      minLevel: 75,
    ),

    // 컴백 메시지
    MotivationalMessage(
      message: "돌아온 차드! 오늘부터 다시 시작하자!",
      category: MessageCategory.comeback,
      weight: 8,
    ),
    MotivationalMessage(
      message: "쉬는 동안 더 강해졌을 거야! 보여줘!",
      category: MessageCategory.comeback,
      weight: 7,
    ),
    MotivationalMessage(
      message: "차드는 언제든 다시 일어날 수 있어! 💪",
      category: MessageCategory.comeback,
      weight: 8,
    ),
  ];

  /// 카테고리별 메시지 가져오기
  List<MotivationalMessage> _getMessagesByCategory(MessageCategory category) {
    return _messages.where((msg) => msg.category == category).toList();
  }

  /// 레벨에 맞는 메시지 필터링
  List<MotivationalMessage> _filterByLevel(List<MotivationalMessage> messages, int userLevel) {
    return messages.where((msg) {
      if (msg.minLevel > userLevel) return false;
      if (msg.maxLevel != -1 && msg.maxLevel < userLevel) return false;
      return true;
    }).toList();
  }

  /// 가중치를 고려한 랜덤 메시지 선택
  MotivationalMessage _selectWeightedRandom(List<MotivationalMessage> messages) {
    if (messages.isEmpty) {
      return const MotivationalMessage(
        message: "차드가 되는 여정을 계속하자! 💪",
        category: MessageCategory.encouragement,
      );
    }

    int totalWeight = messages.fold(0, (sum, msg) => sum + msg.weight);
    int randomValue = _random.nextInt(totalWeight);
    
    int currentWeight = 0;
    for (var message in messages) {
      currentWeight += message.weight;
      if (randomValue < currentWeight) {
        return message;
      }
    }
    
    return messages.last;
  }

  /// 운동 시작 메시지 가져오기
  String getWorkoutStartMessage({int userLevel = 0}) {
    var messages = _getMessagesByCategory(MessageCategory.workoutStart);
    messages = _filterByLevel(messages, userLevel);
    return _selectWeightedRandom(messages).message;
  }

  /// 세트 완료 메시지 가져오기
  String getSetCompletionMessage({int userLevel = 0}) {
    var messages = _getMessagesByCategory(MessageCategory.setCompletion);
    messages = _filterByLevel(messages, userLevel);
    return _selectWeightedRandom(messages).message;
  }

  /// 운동 완료 메시지 가져오기
  String getWorkoutCompletionMessage({int userLevel = 0}) {
    var messages = _getMessagesByCategory(MessageCategory.workoutCompletion);
    messages = _filterByLevel(messages, userLevel);
    return _selectWeightedRandom(messages).message;
  }

  /// 휴식일 메시지 가져오기
  String getRestDayMessage({int userLevel = 0}) {
    var messages = _getMessagesByCategory(MessageCategory.restDay);
    messages = _filterByLevel(messages, userLevel);
    return _selectWeightedRandom(messages).message;
  }

  /// 목표 달성 메시지 가져오기
  String getGoalAchievementMessage({int userLevel = 0}) {
    var messages = _getMessagesByCategory(MessageCategory.goalAchievement);
    messages = _filterByLevel(messages, userLevel);
    return _selectWeightedRandom(messages).message;
  }

  /// 실패 시 격려 메시지 가져오기
  String getFailureMessage({int userLevel = 0}) {
    var messages = _getMessagesByCategory(MessageCategory.failure);
    messages = _filterByLevel(messages, userLevel);
    return _selectWeightedRandom(messages).message;
  }

  /// 성공 시 축하 메시지 가져오기
  String getSuccessMessage({int userLevel = 0}) {
    var messages = _getMessagesByCategory(MessageCategory.success);
    messages = _filterByLevel(messages, userLevel);
    return _selectWeightedRandom(messages).message;
  }

  /// 격려 메시지 가져오기
  String getEncouragementMessage({int userLevel = 0}) {
    var messages = _getMessagesByCategory(MessageCategory.encouragement);
    messages = _filterByLevel(messages, userLevel);
    return _selectWeightedRandom(messages).message;
  }

  /// 마일스톤 메시지 가져오기
  String getMilestoneMessage({int userLevel = 0}) {
    var messages = _getMessagesByCategory(MessageCategory.milestone);
    messages = _filterByLevel(messages, userLevel);
    return _selectWeightedRandom(messages).message;
  }

  /// 컴백 메시지 가져오기
  String getComebackMessage({int userLevel = 0}) {
    var messages = _getMessagesByCategory(MessageCategory.comeback);
    messages = _filterByLevel(messages, userLevel);
    return _selectWeightedRandom(messages).message;
  }

  /// 컨텍스트 기반 메시지 가져오기
  String getContextualMessage({
    required MessageCategory category,
    int userLevel = 0,
    int consecutiveDays = 0,
    bool isPersonalBest = false,
    bool isComingBack = false,
  }) {
    // 특별한 상황에 따른 메시지 선택
    if (isComingBack) {
      return getComebackMessage(userLevel: userLevel);
    }

    // 마일스톤 체크
    if (consecutiveDays > 0 && _isMilestone(consecutiveDays)) {
      return getMilestoneMessage(userLevel: userLevel);
    }

    // 개인 최고 기록일 때
    if (isPersonalBest && category == MessageCategory.workoutCompletion) {
      return getSuccessMessage(userLevel: userLevel);
    }

    // 기본 카테고리별 메시지
    switch (category) {
      case MessageCategory.workoutStart:
        return getWorkoutStartMessage(userLevel: userLevel);
      case MessageCategory.setCompletion:
        return getSetCompletionMessage(userLevel: userLevel);
      case MessageCategory.workoutCompletion:
        return getWorkoutCompletionMessage(userLevel: userLevel);
      case MessageCategory.restDay:
        return getRestDayMessage(userLevel: userLevel);
      case MessageCategory.goalAchievement:
        return getGoalAchievementMessage(userLevel: userLevel);
      case MessageCategory.failure:
        return getFailureMessage(userLevel: userLevel);
      case MessageCategory.success:
        return getSuccessMessage(userLevel: userLevel);
      case MessageCategory.encouragement:
        return getEncouragementMessage(userLevel: userLevel);
      case MessageCategory.milestone:
        return getMilestoneMessage(userLevel: userLevel);
      case MessageCategory.comeback:
        return getComebackMessage(userLevel: userLevel);
    }
  }

  /// 마일스톤 여부 확인
  bool _isMilestone(int days) {
    const milestones = [7, 10, 14, 21, 30, 50, 75, 100];
    return milestones.contains(days);
  }

  /// 모든 메시지 가져오기 (테스트용)
  @visibleForTesting
  List<MotivationalMessage> getAllMessages() => _messages;

  /// 카테고리별 메시지 개수 가져오기 (테스트용)
  @visibleForTesting
  Map<MessageCategory, int> getMessageCountByCategory() {
    Map<MessageCategory, int> counts = {};
    for (var category in MessageCategory.values) {
      counts[category] = _getMessagesByCategory(category).length;
    }
    return counts;
  }
} 