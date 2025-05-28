import 'package:flutter/material.dart';

/// Chad 진화 단계 열거형
enum ChadEvolutionStage {
  sleepCapChad,    // Stage 0: 수면모자차드 (시작)
  basicChad,       // Stage 1: 기본차드 (1주차 완료)
  coffeeChad,      // Stage 2: 커피차드 (2주차 완료)
  frontFacingChad, // Stage 3: 정면차드 (3주차 완료)
  sunglassesChad,  // Stage 4: 썬글차드 (4주차 완료)
  glowingEyesChad, // Stage 5: 빛나는눈차드 (5주차 완료)
  doubleChad,      // Stage 6: 더블차드 (6주차 완료)
}

/// Chad 진화 데이터 모델
class ChadEvolution {
  final ChadEvolutionStage stage;
  final String name;
  final String description;
  final String imagePath;
  final int requiredWeek;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String unlockMessage;

  const ChadEvolution({
    required this.stage,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.requiredWeek,
    required this.isUnlocked,
    this.unlockedAt,
    required this.unlockMessage,
  });

  /// 기본 Chad 진화 단계들
  static const List<ChadEvolution> defaultStages = [
    ChadEvolution(
      stage: ChadEvolutionStage.sleepCapChad,
      name: '수면모자 Chad',
      description: '여정을 시작하는 Chad입니다.\n아직 잠이 덜 깬 상태지만 곧 깨어날 것입니다!',
      imagePath: 'assets/images/수면모자차드.jpg',
      requiredWeek: 0,
      isUnlocked: true,
      unlockMessage: 'Mission 100에 오신 것을 환영합니다!',
    ),
    ChadEvolution(
      stage: ChadEvolutionStage.basicChad,
      name: '기본 Chad',
      description: '첫 번째 진화를 완료한 Chad입니다.\n기초 체력을 다지기 시작했습니다!',
      imagePath: 'assets/images/기본차드.jpg',
      requiredWeek: 1,
      isUnlocked: false,
      unlockMessage: '축하합니다! 1주차를 완료하여 기본 Chad로 진화했습니다!',
    ),
    ChadEvolution(
      stage: ChadEvolutionStage.coffeeChad,
      name: '커피 Chad',
      description: '에너지가 넘치는 Chad입니다.\n커피의 힘으로 더욱 강해졌습니다!',
      imagePath: 'assets/images/커피차드.jpg',
      requiredWeek: 2,
      isUnlocked: false,
      unlockMessage: '대단합니다! 2주차를 완료하여 커피 Chad로 진화했습니다!',
    ),
    ChadEvolution(
      stage: ChadEvolutionStage.frontFacingChad,
      name: '정면 Chad',
      description: '자신감이 넘치는 Chad입니다.\n정면을 당당히 바라보며 도전합니다!',
      imagePath: 'assets/images/정면차드.jpg',
      requiredWeek: 3,
      isUnlocked: false,
      unlockMessage: '놀랍습니다! 3주차를 완료하여 정면 Chad로 진화했습니다!',
    ),
    ChadEvolution(
      stage: ChadEvolutionStage.sunglassesChad,
      name: '썬글라스 Chad',
      description: '쿨한 매력의 Chad입니다.\n선글라스를 쓰고 멋진 모습을 보여줍니다!',
      imagePath: 'assets/images/썬글차드.jpg',
      requiredWeek: 4,
      isUnlocked: false,
      unlockMessage: '멋집니다! 4주차를 완료하여 썬글라스 Chad로 진화했습니다!',
    ),
    ChadEvolution(
      stage: ChadEvolutionStage.glowingEyesChad,
      name: '빛나는눈 Chad',
      description: '강력한 힘을 가진 Chad입니다.\n눈에서 빛이 나며 엄청난 파워를 보여줍니다!',
      imagePath: 'assets/images/빛나는눈차드.jpg',
      requiredWeek: 5,
      isUnlocked: false,
      unlockMessage: '경이롭습니다! 5주차를 완료하여 빛나는눈 Chad로 진화했습니다!',
    ),
    ChadEvolution(
      stage: ChadEvolutionStage.doubleChad,
      name: '더블 Chad',
      description: '최종 진화를 완료한 전설의 Chad입니다.\n두 배의 파워로 모든 것을 정복합니다!',
      imagePath: 'assets/images/더블차드.jpg',
      requiredWeek: 6,
      isUnlocked: false,
      unlockMessage: '전설입니다! 6주차를 완료하여 더블 Chad로 진화했습니다!',
    ),
  ];

  /// 단계별 색상 테마
  Color get themeColor {
    switch (stage) {
      case ChadEvolutionStage.sleepCapChad:
        return const Color(0xFF9C88FF); // 보라색
      case ChadEvolutionStage.basicChad:
        return const Color(0xFF4DABF7); // 파란색
      case ChadEvolutionStage.coffeeChad:
        return const Color(0xFF8B4513); // 갈색
      case ChadEvolutionStage.frontFacingChad:
        return const Color(0xFF51CF66); // 초록색
      case ChadEvolutionStage.sunglassesChad:
        return const Color(0xFF000000); // 검은색
      case ChadEvolutionStage.glowingEyesChad:
        return const Color(0xFFFF6B6B); // 빨간색
      case ChadEvolutionStage.doubleChad:
        return const Color(0xFFFFD43B); // 금색
    }
  }

  /// 단계 번호 (0-6)
  int get stageNumber => stage.index;

  /// 다음 단계 여부
  bool get hasNextStage => stageNumber < ChadEvolutionStage.values.length - 1;

  /// 최종 단계 여부
  bool get isFinalStage => stage == ChadEvolutionStage.doubleChad;

  /// JSON으로부터 ChadEvolution 생성
  factory ChadEvolution.fromJson(Map<String, dynamic> json) {
    return ChadEvolution(
      stage: ChadEvolutionStage.values.firstWhere(
        (e) => e.toString().split('.').last == json['stage'],
        orElse: () => ChadEvolutionStage.sleepCapChad,
      ),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      requiredWeek: json['requiredWeek'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      unlockMessage: json['unlockMessage'] as String? ?? '',
    );
  }

  /// ChadEvolution을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'stage': stage.toString().split('.').last,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'requiredWeek': requiredWeek,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'unlockMessage': unlockMessage,
    };
  }

  /// ChadEvolution 복사본 생성
  ChadEvolution copyWith({
    ChadEvolutionStage? stage,
    String? name,
    String? description,
    String? imagePath,
    int? requiredWeek,
    bool? isUnlocked,
    DateTime? unlockedAt,
    String? unlockMessage,
  }) {
    return ChadEvolution(
      stage: stage ?? this.stage,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      requiredWeek: requiredWeek ?? this.requiredWeek,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      unlockMessage: unlockMessage ?? this.unlockMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChadEvolution &&
        other.stage == stage &&
        other.name == name &&
        other.description == description &&
        other.imagePath == imagePath &&
        other.requiredWeek == requiredWeek &&
        other.isUnlocked == isUnlocked &&
        other.unlockedAt == unlockedAt &&
        other.unlockMessage == unlockMessage;
  }

  @override
  int get hashCode {
    return stage.hashCode ^
        name.hashCode ^
        description.hashCode ^
        imagePath.hashCode ^
        requiredWeek.hashCode ^
        isUnlocked.hashCode ^
        unlockedAt.hashCode ^
        unlockMessage.hashCode;
  }

  @override
  String toString() {
    return 'ChadEvolution(stage: $stage, name: $name, isUnlocked: $isUnlocked)';
  }
}

/// Chad 진화 상태 모델
class ChadEvolutionState {
  final ChadEvolutionStage currentStage;
  final List<ChadEvolution> unlockedStages;
  final DateTime? lastEvolutionAt;
  final int totalEvolutions;

  const ChadEvolutionState({
    required this.currentStage,
    required this.unlockedStages,
    this.lastEvolutionAt,
    required this.totalEvolutions,
  });

  /// 현재 Chad 정보
  ChadEvolution get currentChad {
    return ChadEvolution.defaultStages.firstWhere(
      (chad) => chad.stage == currentStage,
      orElse: () => ChadEvolution.defaultStages.first,
    );
  }

  /// 다음 Chad 정보
  ChadEvolution? get nextChad {
    final currentIndex = currentStage.index;
    if (currentIndex < ChadEvolution.defaultStages.length - 1) {
      return ChadEvolution.defaultStages[currentIndex + 1];
    }
    return null;
  }

  /// 진화 진행률 (0.0 ~ 1.0)
  double get evolutionProgress {
    final totalStages = ChadEvolution.defaultStages.length;
    return (currentStage.index + 1) / totalStages;
  }

  /// 최종 진화 완료 여부
  bool get isMaxEvolution => currentStage == ChadEvolutionStage.doubleChad;

  /// JSON으로부터 ChadEvolutionState 생성
  factory ChadEvolutionState.fromJson(Map<String, dynamic> json) {
    return ChadEvolutionState(
      currentStage: ChadEvolutionStage.values.firstWhere(
        (e) => e.toString().split('.').last == json['currentStage'],
        orElse: () => ChadEvolutionStage.sleepCapChad,
      ),
      unlockedStages: (json['unlockedStages'] as List<dynamic>?)
          ?.map((e) => ChadEvolution.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      lastEvolutionAt: json['lastEvolutionAt'] != null 
          ? DateTime.parse(json['lastEvolutionAt'] as String)
          : null,
      totalEvolutions: json['totalEvolutions'] as int? ?? 0,
    );
  }

  /// ChadEvolutionState를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'currentStage': currentStage.toString().split('.').last,
      'unlockedStages': unlockedStages.map((e) => e.toJson()).toList(),
      'lastEvolutionAt': lastEvolutionAt?.toIso8601String(),
      'totalEvolutions': totalEvolutions,
    };
  }

  /// ChadEvolutionState 복사본 생성
  ChadEvolutionState copyWith({
    ChadEvolutionStage? currentStage,
    List<ChadEvolution>? unlockedStages,
    DateTime? lastEvolutionAt,
    int? totalEvolutions,
  }) {
    return ChadEvolutionState(
      currentStage: currentStage ?? this.currentStage,
      unlockedStages: unlockedStages ?? this.unlockedStages,
      lastEvolutionAt: lastEvolutionAt ?? this.lastEvolutionAt,
      totalEvolutions: totalEvolutions ?? this.totalEvolutions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChadEvolutionState &&
        other.currentStage == currentStage &&
        other.unlockedStages.length == unlockedStages.length &&
        other.lastEvolutionAt == lastEvolutionAt &&
        other.totalEvolutions == totalEvolutions;
  }

  @override
  int get hashCode {
    return currentStage.hashCode ^
        unlockedStages.hashCode ^
        lastEvolutionAt.hashCode ^
        totalEvolutions.hashCode;
  }

  @override
  String toString() {
    return 'ChadEvolutionState(currentStage: $currentStage, totalEvolutions: $totalEvolutions)';
  }
} 