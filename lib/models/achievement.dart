enum AchievementType {
  first, // 첫 번째 달성
  streak, // 연속 달성
  volume, // 총량 달성
  perfect, // 완벽한 수행
  special, // 특별한 조건
}

enum AchievementRarity {
  common, // 일반
  rare, // 레어
  epic, // 에픽
  legendary, // 레전더리
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconCode; // 이모지나 아이콘 코드
  final AchievementType type;
  final AchievementRarity rarity;
  final int targetValue; // 달성 목표값
  final int currentValue; // 현재 진행값
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int xpReward; // 경험치 보상
  final String motivationalMessage; // 달성 시 메시지

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconCode,
    required this.type,
    required this.rarity,
    required this.targetValue,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.xpReward = 0,
    required this.motivationalMessage,
  });

  double get progress => currentValue / targetValue;
  bool get isCompleted => currentValue >= targetValue;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconCode,
    AchievementType? type,
    AchievementRarity? rarity,
    int? targetValue,
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? xpReward,
    String? motivationalMessage,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      xpReward: xpReward ?? this.xpReward,
      motivationalMessage: motivationalMessage ?? this.motivationalMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconCode': iconCode,
      'type': type.name,
      'rarity': rarity.name,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'isUnlocked': isUnlocked ? 1 : 0,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'xpReward': xpReward,
      'motivationalMessage': motivationalMessage,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      iconCode: map['iconCode'],
      type: AchievementType.values.firstWhere((e) => e.name == map['type']),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == map['rarity'],
      ),
      targetValue: map['targetValue'],
      currentValue: map['currentValue'] ?? 0,
      isUnlocked: map['isUnlocked'] == 1,
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'])
          : null,
      xpReward: map['xpReward'] ?? 0,
      motivationalMessage: map['motivationalMessage'],
    );
  }

  // 레어도에 따른 색상 반환
  int getRarityColor() {
    switch (rarity) {
      case AchievementRarity.common:
        return 0xFF9E9E9E; // 회색
      case AchievementRarity.rare:
        return 0xFF2196F3; // 파란색
      case AchievementRarity.epic:
        return 0xFF9C27B0; // 보라색
      case AchievementRarity.legendary:
        return 0xFFFF9800; // 주황색
    }
  }

  // 레어도 이름 반환
  String getRarityName() {
    switch (rarity) {
      case AchievementRarity.common:
        return '일반';
      case AchievementRarity.rare:
        return '레어';
      case AchievementRarity.epic:
        return '에픽';
      case AchievementRarity.legendary:
        return '레전더리';
    }
  }
}

// 미리 정의된 업적들
class PredefinedAchievements {
  static List<Achievement> get all => [
    // 첫 번째 달성 시리즈
    Achievement(
      id: 'first_workout',
      title: '차드 여정의 시작',
      description: '첫 번째 운동을 완료했습니다',
      iconCode: '🎯',
      type: AchievementType.first,
      rarity: AchievementRarity.common,
      targetValue: 1,
      xpReward: 100,
      motivationalMessage: '모든 차드는 첫 걸음부터 시작합니다! 💪',
    ),

    Achievement(
      id: 'first_perfect_set',
      title: '완벽한 첫 세트',
      description: '목표를 100% 달성한 첫 번째 세트',
      iconCode: '⭐',
      type: AchievementType.first,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 200,
      motivationalMessage: '완벽함이 바로 차드의 시작입니다! ⭐',
    ),

    Achievement(
      id: 'first_level_up',
      title: '레벨업 달성',
      description: '첫 번째 레벨업을 달성했습니다',
      iconCode: '🚀',
      type: AchievementType.first,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 300,
      motivationalMessage: '성장하는 차드! 다음 레벨을 향해! 🚀',
    ),

    // 연속 달성 시리즈
    Achievement(
      id: 'streak_3_days',
      title: '3일 연속 차드',
      description: '3일 연속으로 운동을 완료했습니다',
      iconCode: '🔥',
      type: AchievementType.streak,
      rarity: AchievementRarity.common,
      targetValue: 3,
      xpReward: 300,
      motivationalMessage: '일관성이 차드를 만든다! 🔥',
    ),

    Achievement(
      id: 'streak_7_days',
      title: '일주일 차드',
      description: '7일 연속으로 운동을 완료했습니다',
      iconCode: '💪',
      type: AchievementType.streak,
      rarity: AchievementRarity.rare,
      targetValue: 7,
      xpReward: 500,
      motivationalMessage: '한 주를 정복한 진정한 차드! 💪',
    ),

    Achievement(
      id: 'streak_14_days',
      title: '2주 마라톤 차드',
      description: '14일 연속으로 운동을 완료했습니다',
      iconCode: '🏃‍♂️',
      type: AchievementType.streak,
      rarity: AchievementRarity.epic,
      targetValue: 14,
      xpReward: 800,
      motivationalMessage: '지속성의 왕! 차드 중의 차드! 🏃‍♂️',
    ),

    Achievement(
      id: 'streak_30_days',
      title: '한 달 울티메이트 차드',
      description: '30일 연속으로 운동을 완료했습니다',
      iconCode: '👑',
      type: AchievementType.streak,
      rarity: AchievementRarity.legendary,
      targetValue: 30,
      xpReward: 1500,
      motivationalMessage: '당신은 이제 차드의 왕입니다! 👑',
    ),

    // 총량 달성 시리즈
    Achievement(
      id: 'total_100_pushups',
      title: '첫 100개 돌파',
      description: '총 100개의 푸시업을 완료했습니다',
      iconCode: '💯',
      type: AchievementType.volume,
      rarity: AchievementRarity.common,
      targetValue: 100,
      xpReward: 200,
      motivationalMessage: '첫 100개 돌파! 차드의 기본기 완성! 💯',
    ),

    Achievement(
      id: 'total_500_pushups',
      title: '500개 차드',
      description: '총 500개의 푸시업을 완료했습니다',
      iconCode: '🚀',
      type: AchievementType.volume,
      rarity: AchievementRarity.rare,
      targetValue: 500,
      xpReward: 500,
      motivationalMessage: '500개 돌파! 중급 차드 등극! 🚀',
    ),

    Achievement(
      id: 'total_1000_pushups',
      title: '1000개 메가 차드',
      description: '총 1000개의 푸시업을 완료했습니다',
      iconCode: '⚡',
      type: AchievementType.volume,
      rarity: AchievementRarity.epic,
      targetValue: 1000,
      xpReward: 1000,
      motivationalMessage: '1000개 돌파! 메가 차드 등극! ⚡',
    ),

    Achievement(
      id: 'total_5000_pushups',
      title: '5000개 울트라 차드',
      description: '총 5000개의 푸시업을 완료했습니다',
      iconCode: '🌟',
      type: AchievementType.volume,
      rarity: AchievementRarity.legendary,
      targetValue: 5000,
      xpReward: 2000,
      motivationalMessage: '5000개! 당신은 울트라 차드입니다! 🌟',
    ),

    // 완벽 수행 시리즈
    Achievement(
      id: 'perfect_workout_5',
      title: '완벽주의 차드',
      description: '5번의 완벽한 운동을 달성했습니다',
      iconCode: '🎯',
      type: AchievementType.perfect,
      rarity: AchievementRarity.rare,
      targetValue: 5,
      xpReward: 400,
      motivationalMessage: '완벽을 추구하는 진정한 차드! 🎯',
    ),

    Achievement(
      id: 'perfect_workout_10',
      title: '마스터 차드',
      description: '10번의 완벽한 운동을 달성했습니다',
      iconCode: '🏆',
      type: AchievementType.perfect,
      rarity: AchievementRarity.epic,
      targetValue: 10,
      xpReward: 800,
      motivationalMessage: '완벽함의 마스터! 차드 중의 차드! 🏆',
    ),

    // 특별 업적
    Achievement(
      id: 'tutorial_explorer',
      title: '탐구하는 차드',
      description: '첫 번째 푸시업 튜토리얼을 확인했습니다',
      iconCode: '🔍',
      type: AchievementType.special,
      rarity: AchievementRarity.common,
      targetValue: 1,
      xpReward: 50,
      motivationalMessage: '지식은 차드의 첫 번째 힘! 🔍',
    ),

    Achievement(
      id: 'tutorial_student',
      title: '학습하는 차드',
      description: '5가지 푸시업 튜토리얼을 확인했습니다',
      iconCode: '📚',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 5,
      xpReward: 250,
      motivationalMessage: '다양한 기술을 익히는 진정한 차드! 📚',
    ),

    Achievement(
      id: 'tutorial_master',
      title: '푸시업 마스터',
      description: '모든 푸시업 튜토리얼을 확인했습니다',
      iconCode: '🎓',
      type: AchievementType.special,
      rarity: AchievementRarity.epic,
      targetValue: 10,
      xpReward: 500,
      motivationalMessage: '모든 기술을 마스터한 푸시업 박사! 🎓',
    ),

    Achievement(
      id: 'weekend_warrior',
      title: '주말 전사',
      description: '주말에도 꾸준히 운동하는 차드',
      iconCode: '⚔️',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 4, // 4번의 주말 운동
      xpReward: 600,
      motivationalMessage: '주말에도 멈추지 않는 전사! ⚔️',
    ),

    Achievement(
      id: 'early_bird',
      title: '새벽 차드',
      description: '오전 7시 전에 5번 운동했습니다',
      iconCode: '🌅',
      type: AchievementType.special,
      rarity: AchievementRarity.epic,
      targetValue: 5,
      xpReward: 700,
      motivationalMessage: '새벽을 정복한 얼리버드 차드! 🌅',
    ),

    Achievement(
      id: 'night_owl',
      title: '야행성 차드',
      description: '밤 10시 이후에 5번 운동했습니다',
      iconCode: '🦉',
      type: AchievementType.special,
      rarity: AchievementRarity.epic,
      targetValue: 5,
      xpReward: 700,
      motivationalMessage: '밤에도 포기하지 않는 올빼미 차드! 🦉',
    ),
  ];
}
