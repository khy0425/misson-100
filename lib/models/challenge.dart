/// 챌린지 타입
enum ChallengeType {
  consecutiveDays, // 연속 일수
  singleSession,   // 단일 세션
  cumulative;      // 누적
}

/// 챌린지 난이도
enum ChallengeDifficulty {
  easy,
  medium, 
  hard,
  extreme;

  String get emoji {
    switch (this) {
      case ChallengeDifficulty.easy:
        return '😊';
      case ChallengeDifficulty.medium:
        return '💪';
      case ChallengeDifficulty.hard:
        return '🔥';
      case ChallengeDifficulty.extreme:
        return '💀';
    }
  }

  String get displayName {
    switch (this) {
      case ChallengeDifficulty.easy:
        return '쉬움';
      case ChallengeDifficulty.medium:
        return '보통';
      case ChallengeDifficulty.hard:
        return '어려움';
      case ChallengeDifficulty.extreme:
        return '극한';
    }
  }
}

/// 챌린지 상태
enum ChallengeStatus {
  available,  // 참여 가능
  active,     // 진행 중
  completed,  // 완료
  failed,     // 실패
  locked;     // 잠김

  String get emoji {
    switch (this) {
      case ChallengeStatus.available:
        return '⭐';
      case ChallengeStatus.active:
        return '⚡';
      case ChallengeStatus.completed:
        return '✅';
      case ChallengeStatus.failed:
        return '❌';
      case ChallengeStatus.locked:
        return '🔒';
    }
  }

  String get displayName {
    switch (this) {
      case ChallengeStatus.available:
        return '참여 가능';
      case ChallengeStatus.active:
        return '진행 중';
      case ChallengeStatus.completed:
        return '완료';
      case ChallengeStatus.failed:
        return '실패';
      case ChallengeStatus.locked:
        return '잠김';
    }
  }
}

/// 챌린지 보상
class ChallengeReward {
  final String type; // 'badge', 'points', 'feature' 등
  final String value;
  final String description;

  const ChallengeReward({
    required this.type,
    required this.value,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      'description': description,
    };
  }

  factory ChallengeReward.fromJson(Map<String, dynamic> json) {
    return ChallengeReward(
      type: json['type'] as String? ?? '',
      value: json['value'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class Challenge {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final String difficultyKey;
  final int duration; // 일
  final int targetCount; // 목표 개수
  final List<String> milestones; // 마일스톤 설명 키들
  final String rewardKey;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final int currentProgress;

  // 새로운 필드들 추가
  final String? title;
  final String? description;
  final String? detailedDescription;
  final ChallengeType? type;
  final ChallengeDifficulty? difficulty;
  final int? targetValue;
  final String? targetUnit;
  final List<String>? prerequisites;
  final int? estimatedDuration;
  final List<ChallengeReward>? rewards;
  final String? iconPath;
  final ChallengeStatus? status;
  final DateTime? completionDate;
  final DateTime? lastUpdatedAt;

  const Challenge({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.difficultyKey,
    required this.duration,
    required this.targetCount,
    required this.milestones,
    required this.rewardKey,
    required this.isActive,
    this.startDate,
    this.endDate,
    required this.currentProgress,
    // 새로운 필드들
    this.title,
    this.description,
    this.detailedDescription,
    this.type,
    this.difficulty,
    this.targetValue,
    this.targetUnit,
    this.prerequisites,
    this.estimatedDuration,
    this.rewards,
    this.iconPath,
    this.status,
    this.completionDate,
    this.lastUpdatedAt,
  });

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progressPercentage {
    if (targetCount == 0) return 0.0;
    return (currentProgress / targetCount).clamp(0.0, 1.0);
  }

  /// 완료 여부
  bool get isCompleted => endDate != null;

  /// 시작 가능 여부
  bool get isAvailable => startDate == null;

  /// 잠김 상태 여부
  bool get isLocked => !isActive;

  /// 실패 상태 여부
  bool get isFailed => false; // Assuming no failure status in the new model

  /// 시작 일시 (테스트 호환성을 위한 getter)
  DateTime? get startedAt => startDate;

  /// 남은 진행량
  int get remainingProgress => (targetCount - currentProgress).clamp(0, targetCount);

  /// 경과 일수 (시작일로부터)
  int get daysSinceStart {
    if (startDate == null) return 0;
    return DateTime.now().difference(startDate!).inDays;
  }

  /// 남은 예상 일수
  int get estimatedDaysRemaining {
    if (isCompleted || (startDate == null && endDate == null)) return 0;
    final elapsed = daysSinceStart;
    return (duration - elapsed).clamp(0, duration);
  }

  Challenge copyWith({
    String? id,
    String? titleKey,
    String? descriptionKey,
    String? difficultyKey,
    int? duration,
    int? targetCount,
    List<String>? milestones,
    String? rewardKey,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    int? currentProgress,
    String? title,
    String? description,
    String? detailedDescription,
    ChallengeType? type,
    ChallengeDifficulty? difficulty,
    int? targetValue,
    String? targetUnit,
    List<String>? prerequisites,
    int? estimatedDuration,
    List<ChallengeReward>? rewards,
    String? iconPath,
    ChallengeStatus? status,
    DateTime? completionDate,
    DateTime? lastUpdatedAt,
  }) {
    return Challenge(
      id: id ?? this.id,
      titleKey: titleKey ?? this.titleKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      difficultyKey: difficultyKey ?? this.difficultyKey,
      duration: duration ?? this.duration,
      targetCount: targetCount ?? this.targetCount,
      milestones: milestones ?? this.milestones,
      rewardKey: rewardKey ?? this.rewardKey,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currentProgress: currentProgress ?? this.currentProgress,
      title: title ?? this.title,
      description: description ?? this.description,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      prerequisites: prerequisites ?? this.prerequisites,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      rewards: rewards ?? this.rewards,
      iconPath: iconPath ?? this.iconPath,
      status: status ?? this.status,
      completionDate: completionDate ?? this.completionDate,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleKey': titleKey,
      'descriptionKey': descriptionKey,
      'difficultyKey': difficultyKey,
      'duration': duration,
      'targetCount': targetCount,
      'milestones': milestones,
      'rewardKey': rewardKey,
      'isActive': isActive,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'currentProgress': currentProgress,
      'title': title,
      'description': description,
      'detailedDescription': detailedDescription,
      'type': type?.name,
      'difficulty': difficulty?.name,
      'targetValue': targetValue,
      'targetUnit': targetUnit,
      'prerequisites': prerequisites,
      'estimatedDuration': estimatedDuration,
      'rewards': rewards?.map((r) => r.toJson()).toList(),
      'iconPath': iconPath,
      'status': status?.name,
      'completionDate': completionDate?.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String? ?? '',
      titleKey: json['titleKey'] as String? ?? '',
      descriptionKey: json['descriptionKey'] as String? ?? '',
      difficultyKey: json['difficultyKey'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      targetCount: json['targetCount'] as int? ?? 0,
      milestones: List<String>.from(json['milestones'] as List? ?? []),
      rewardKey: json['rewardKey'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      currentProgress: json['currentProgress'] as int? ?? 0,
      title: json['title'] as String?,
      description: json['description'] as String?,
      detailedDescription: json['detailedDescription'] as String?,
      type: json['type'] != null ? ChallengeType.values.firstWhere((e) => e.name == (json['type'] as String)) : null,
      difficulty: json['difficulty'] != null ? ChallengeDifficulty.values.firstWhere((e) => e.name == (json['difficulty'] as String)) : null,
      targetValue: json['targetValue'] as int?,
      targetUnit: json['targetUnit'] as String?,
      prerequisites: json['prerequisites'] != null ? List<String>.from(json['prerequisites'] as List) : null,
      estimatedDuration: json['estimatedDuration'] as int?,
      rewards: json['rewards'] != null 
        ? (json['rewards'] as List).map((r) => ChallengeReward.fromJson(r as Map<String, dynamic>)).toList()
        : null,
      iconPath: json['iconPath'] as String?,
      status: json['status'] != null ? ChallengeStatus.values.firstWhere((e) => e.name == (json['status'] as String)) : null,
      completionDate: json['completionDate'] != null ? DateTime.parse(json['completionDate'] as String) : null,
      lastUpdatedAt: json['lastUpdatedAt'] != null ? DateTime.parse(json['lastUpdatedAt'] as String) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Challenge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Challenge(id: $id, title: $titleKey, status: ${isActive ? "Active" : "Inactive"}, progress: $currentProgress/$targetCount)';
  }
}

/// 챌린지 난이도별 확장 메서드
extension ChallengeDifficultyExtension on String {
  String get displayName {
    switch (this) {
      case 'easy':
        return '쉬움';
      case 'medium':
        return '보통';
      case 'hard':
        return '어려움';
      case 'extreme':
        return '극한';
      default:
        throw Exception('Unknown difficulty: $this');
    }
  }

  String get emoji {
    switch (this) {
      case 'easy':
        return '🟢';
      case 'medium':
        return '🟡';
      case 'hard':
        return '🟠';
      case 'extreme':
        return '🔴';
      default:
        throw Exception('Unknown difficulty: $this');
    }
  }
}

/// 챌린지 상태별 확장 메서드
extension ChallengeStatusExtension on bool {
  String get displayName {
    return this ? 'Active' : 'Inactive';
  }

  String get emoji {
    return this ? '🔥' : '🔒';
  }
} 