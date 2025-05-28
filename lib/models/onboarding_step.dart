/// 온보딩 스텝 타입 열거형
enum OnboardingStepType {
  welcome,
  programIntroduction,
  chadEvolution,
  initialTest,
  completion,
}

/// 온보딩 스텝 데이터 모델
class OnboardingStep {
  final OnboardingStepType type;
  final String title;
  final String description;
  final String? imagePath;
  final String? buttonText;
  final bool canSkip;
  final Map<String, dynamic>? additionalData;

  const OnboardingStep({
    required this.type,
    required this.title,
    required this.description,
    this.imagePath,
    this.buttonText,
    this.canSkip = true,
    this.additionalData,
  });

  /// JSON으로부터 OnboardingStep 생성
  factory OnboardingStep.fromJson(Map<String, dynamic> json) {
    return OnboardingStep(
      type: OnboardingStepType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => OnboardingStepType.welcome,
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      buttonText: json['buttonText'] as String?,
      canSkip: json['canSkip'] as bool? ?? true,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  /// OnboardingStep을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'buttonText': buttonText,
      'canSkip': canSkip,
      'additionalData': additionalData,
    };
  }

  /// OnboardingStep 복사본 생성
  OnboardingStep copyWith({
    OnboardingStepType? type,
    String? title,
    String? description,
    String? imagePath,
    String? buttonText,
    bool? canSkip,
    Map<String, dynamic>? additionalData,
  }) {
    return OnboardingStep(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      buttonText: buttonText ?? this.buttonText,
      canSkip: canSkip ?? this.canSkip,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingStep &&
        other.type == type &&
        other.title == title &&
        other.description == description &&
        other.imagePath == imagePath &&
        other.buttonText == buttonText &&
        other.canSkip == canSkip;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        title.hashCode ^
        description.hashCode ^
        imagePath.hashCode ^
        buttonText.hashCode ^
        canSkip.hashCode;
  }

  @override
  String toString() {
    return 'OnboardingStep(type: $type, title: $title, description: $description)';
  }
}

/// 온보딩 상태 열거형
enum OnboardingStatus {
  notStarted,
  inProgress,
  completed,
  skipped,
}

/// 온보딩 진행 상태 모델
class OnboardingProgress {
  final OnboardingStatus status;
  final int currentStepIndex;
  final int totalSteps;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final bool wasSkipped;

  const OnboardingProgress({
    required this.status,
    required this.currentStepIndex,
    required this.totalSteps,
    this.startedAt,
    this.completedAt,
    this.wasSkipped = false,
  });

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progressPercentage {
    if (totalSteps == 0) return 0.0;
    return currentStepIndex / totalSteps;
  }

  /// 완료 여부
  bool get isCompleted => status == OnboardingStatus.completed;

  /// 진행 중 여부
  bool get isInProgress => status == OnboardingStatus.inProgress;

  /// JSON으로부터 OnboardingProgress 생성
  factory OnboardingProgress.fromJson(Map<String, dynamic> json) {
    return OnboardingProgress(
      status: OnboardingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OnboardingStatus.notStarted,
      ),
      currentStepIndex: json['currentStepIndex'] as int? ?? 0,
      totalSteps: json['totalSteps'] as int? ?? 0,
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      wasSkipped: json['wasSkipped'] as bool? ?? false,
    );
  }

  /// OnboardingProgress를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'status': status.toString().split('.').last,
      'currentStepIndex': currentStepIndex,
      'totalSteps': totalSteps,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'wasSkipped': wasSkipped,
    };
  }

  /// OnboardingProgress 복사본 생성
  OnboardingProgress copyWith({
    OnboardingStatus? status,
    int? currentStepIndex,
    int? totalSteps,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? wasSkipped,
  }) {
    return OnboardingProgress(
      status: status ?? this.status,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      totalSteps: totalSteps ?? this.totalSteps,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      wasSkipped: wasSkipped ?? this.wasSkipped,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingProgress &&
        other.status == status &&
        other.currentStepIndex == currentStepIndex &&
        other.totalSteps == totalSteps &&
        other.startedAt == startedAt &&
        other.completedAt == completedAt &&
        other.wasSkipped == wasSkipped;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        currentStepIndex.hashCode ^
        totalSteps.hashCode ^
        startedAt.hashCode ^
        completedAt.hashCode ^
        wasSkipped.hashCode;
  }

  @override
  String toString() {
    return 'OnboardingProgress(status: $status, currentStep: $currentStepIndex/$totalSteps)';
  }
} 