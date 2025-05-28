import 'package:flutter/foundation.dart';

/// 챌린지 타입 열거형
enum ChallengeType {
  consecutiveDays,    // 연속 일수 챌린지 (7일 연속 운동)
  singleSession,      // 단일 세션 챌린지 (50개 한번에)
  cumulative,         // 누적 챌린지 (200개 챌린지)
}

/// 챌린지 난이도 열거형
enum ChallengeDifficulty {
  easy,
  medium,
  hard,
  extreme,
}

/// 챌린지 상태 열거형
enum ChallengeStatus {
  available,    // 시작 가능
  active,       // 진행 중
  completed,    // 완료
  failed,       // 실패
  locked,       // 잠김 (전제 조건 미충족)
}

/// 챌린지 보상 클래스
class ChallengeReward {
  final String type;           // 보상 타입 (badge, points, feature)
  final String value;          // 보상 값
  final String description;    // 보상 설명

  const ChallengeReward({
    required this.type,
    required this.value,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'value': value,
      'description': description,
    };
  }

  factory ChallengeReward.fromMap(Map<String, dynamic> map) {
    return ChallengeReward(
      type: map['type'] as String? ?? '',
      value: map['value'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }
}

/// 챌린지 모델 클래스
class Challenge {
  final String id;
  final String title;
  final String description;
  final String detailedDescription;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final int targetValue;           // 목표값 (7일, 50개, 200개 등)
  final String targetUnit;         // 단위 (일, 개, 회 등)
  final List<String> prerequisites; // 전제 조건 (다른 챌린지 ID들)
  final List<ChallengeReward> rewards; // 보상 목록
  final String iconPath;           // 아이콘 경로
  final int estimatedDuration;     // 예상 소요 시간 (일)
  
  // 진행 상황 관련
  final ChallengeStatus status;
  final int currentProgress;       // 현재 진행률
  final DateTime? startDate;       // 시작 날짜 (deprecated, use startedAt)
  final DateTime? startedAt;       // 시작 날짜
  final DateTime? completionDate;  // 완료 날짜 (deprecated, use completedAt)
  final DateTime? completedAt;     // 완료 날짜
  final DateTime? lastUpdateDate;  // 마지막 업데이트 날짜 (deprecated, use lastUpdatedAt)
  final DateTime? lastUpdatedAt;   // 마지막 업데이트 날짜
  final Map<String, dynamic> metadata; // 추가 메타데이터

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.detailedDescription,
    required this.type,
    required this.difficulty,
    required this.targetValue,
    required this.targetUnit,
    this.prerequisites = const [],
    this.rewards = const [],
    this.iconPath = '',
    this.estimatedDuration = 7,
    this.status = ChallengeStatus.available,
    this.currentProgress = 0,
    this.startDate,
    this.startedAt,
    this.completionDate,
    this.completedAt,
    this.lastUpdateDate,
    this.lastUpdatedAt,
    this.metadata = const {},
  });

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  /// 완료 여부
  bool get isCompleted => status == ChallengeStatus.completed;

  /// 활성 상태 여부
  bool get isActive => status == ChallengeStatus.active;

  /// 시작 가능 여부
  bool get isAvailable => status == ChallengeStatus.available;

  /// 잠김 상태 여부
  bool get isLocked => status == ChallengeStatus.locked;

  /// 실패 상태 여부
  bool get isFailed => status == ChallengeStatus.failed;

  /// 남은 진행량
  int get remainingProgress => (targetValue - currentProgress).clamp(0, targetValue);

  /// 경과 일수 (시작일로부터)
  int get daysSinceStart {
    final start = startedAt ?? startDate;
    if (start == null) return 0;
    return DateTime.now().difference(start).inDays;
  }

  /// 남은 예상 일수
  int get estimatedDaysRemaining {
    if (isCompleted || (startedAt == null && startDate == null)) return 0;
    final elapsed = daysSinceStart;
    return (estimatedDuration - elapsed).clamp(0, estimatedDuration);
  }

  /// 챌린지 복사 (일부 속성 변경)
  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? detailedDescription,
    ChallengeType? type,
    ChallengeDifficulty? difficulty,
    int? targetValue,
    String? targetUnit,
    List<String>? prerequisites,
    List<ChallengeReward>? rewards,
    String? iconPath,
    int? estimatedDuration,
    ChallengeStatus? status,
    int? currentProgress,
    DateTime? startDate,
    DateTime? startedAt,
    DateTime? completionDate,
    DateTime? completedAt,
    DateTime? lastUpdateDate,
    DateTime? lastUpdatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      prerequisites: prerequisites ?? this.prerequisites,
      rewards: rewards ?? this.rewards,
      iconPath: iconPath ?? this.iconPath,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      status: status ?? this.status,
      currentProgress: currentProgress ?? this.currentProgress,
      startDate: startDate ?? this.startDate,
      startedAt: startedAt ?? this.startedAt,
      completionDate: completionDate ?? this.completionDate,
      completedAt: completedAt ?? this.completedAt,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Map으로 변환 (데이터베이스 저장용)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'detailedDescription': detailedDescription,
      'type': type.name,
      'difficulty': difficulty.name,
      'targetValue': targetValue,
      'targetUnit': targetUnit,
      'prerequisites': prerequisites,
      'rewards': rewards.map((r) => r.toMap()).toList(),
      'iconPath': iconPath,
      'estimatedDuration': estimatedDuration,
      'status': status.name,
      'currentProgress': currentProgress,
      'startDate': startDate?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'lastUpdateDate': lastUpdateDate?.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Map에서 생성 (데이터베이스 로드용)
  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      detailedDescription: map['detailedDescription'] as String? ?? '',
      type: ChallengeType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ChallengeType.consecutiveDays,
      ),
      difficulty: ChallengeDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => ChallengeDifficulty.medium,
      ),
      targetValue: map['targetValue'] as int? ?? 0,
      targetUnit: map['targetUnit'] as String? ?? '',
      prerequisites: List<String>.from(map['prerequisites'] as List<dynamic>? ?? []),
      rewards: (map['rewards'] as List<dynamic>?)
          ?.map((r) => ChallengeReward.fromMap(r as Map<String, dynamic>))
          .toList() ?? [],
      iconPath: map['iconPath'] as String? ?? '',
      estimatedDuration: map['estimatedDuration'] as int? ?? 7,
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ChallengeStatus.available,
      ),
      currentProgress: map['currentProgress'] as int? ?? 0,
      startDate: map['startDate'] != null 
          ? DateTime.parse(map['startDate'] as String) 
          : null,
      startedAt: map['startedAt'] != null 
          ? DateTime.parse(map['startedAt'] as String) 
          : null,
      completionDate: map['completionDate'] != null 
          ? DateTime.parse(map['completionDate'] as String) 
          : null,
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt'] as String) 
          : null,
      lastUpdateDate: map['lastUpdateDate'] != null 
          ? DateTime.parse(map['lastUpdateDate'] as String) 
          : null,
      lastUpdatedAt: map['lastUpdatedAt'] != null 
          ? DateTime.parse(map['lastUpdatedAt'] as String) 
          : null,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map<String, dynamic>? ?? {}),
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
    return 'Challenge(id: $id, title: $title, status: $status, progress: $currentProgress/$targetValue)';
  }
}

/// 챌린지 타입별 확장 메서드
extension ChallengeTypeExtension on ChallengeType {
  String get displayName {
    switch (this) {
      case ChallengeType.consecutiveDays:
        return '연속 일수';
      case ChallengeType.singleSession:
        return '단일 세션';
      case ChallengeType.cumulative:
        return '누적 달성';
    }
  }

  String get description {
    switch (this) {
      case ChallengeType.consecutiveDays:
        return '연속으로 운동을 수행하는 챌린지';
      case ChallengeType.singleSession:
        return '한 번의 운동에서 목표를 달성하는 챌린지';
      case ChallengeType.cumulative:
        return '총 누적량으로 목표를 달성하는 챌린지';
    }
  }
}

/// 챌린지 난이도별 확장 메서드
extension ChallengeDifficultyExtension on ChallengeDifficulty {
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

  String get emoji {
    switch (this) {
      case ChallengeDifficulty.easy:
        return '🟢';
      case ChallengeDifficulty.medium:
        return '🟡';
      case ChallengeDifficulty.hard:
        return '🟠';
      case ChallengeDifficulty.extreme:
        return '🔴';
    }
  }
}

/// 챌린지 상태별 확장 메서드
extension ChallengeStatusExtension on ChallengeStatus {
  String get displayName {
    switch (this) {
      case ChallengeStatus.available:
        return '시작 가능';
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

  String get emoji {
    switch (this) {
      case ChallengeStatus.available:
        return '▶️';
      case ChallengeStatus.active:
        return '🔥';
      case ChallengeStatus.completed:
        return '✅';
      case ChallengeStatus.failed:
        return '❌';
      case ChallengeStatus.locked:
        return '🔒';
    }
  }
} 