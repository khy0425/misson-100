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
    this.currentProgress = 0,
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

  /// 챌린지 복사 (일부 속성 변경)
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
    );
  }

  /// Map으로 변환 (데이터베이스 저장용)
  Map<String, dynamic> toMap() {
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
    };
  }

  /// Map에서 생성 (데이터베이스 로드용)
  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] as String? ?? '',
      titleKey: map['titleKey'] as String? ?? '',
      descriptionKey: map['descriptionKey'] as String? ?? '',
      difficultyKey: map['difficultyKey'] as String? ?? '',
      duration: map['duration'] as int? ?? 0,
      targetCount: map['targetCount'] as int? ?? 0,
      milestones: List<String>.from(map['milestones'] as List<dynamic>? ?? []),
      rewardKey: map['rewardKey'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? false,
      startDate: map['startDate'] != null 
          ? DateTime.parse(map['startDate'] as String) 
          : null,
      endDate: map['endDate'] != null 
          ? DateTime.parse(map['endDate'] as String) 
          : null,
      currentProgress: map['currentProgress'] as int? ?? 0,
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
        throw Exception("Unknown difficulty: $this");
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
        throw Exception("Unknown difficulty: $this");
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