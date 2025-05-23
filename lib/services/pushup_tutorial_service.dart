import '../models/pushup_type.dart';

/// 푸시업 튜토리얼 서비스
class PushupTutorialService {
  static final PushupTutorialService _instance =
      PushupTutorialService._internal();
  factory PushupTutorialService() => _instance;
  PushupTutorialService._internal();

  /// 모든 푸시업 타입 데이터
  static const List<PushupType> _pushupTypes = [
    // 초급 (Beginner)
    PushupType(
      id: 'standard',
      nameKey: 'pushupStandardName',
      descriptionKey: 'pushupStandardDesc',
      difficulty: PushupDifficulty.beginner,
      targetMuscles: [
        TargetMuscle.chest,
        TargetMuscle.triceps,
        TargetMuscle.shoulders,
      ],
      benefitsKey: 'pushupStandardBenefits',
      instructionsKey: 'pushupStandardInstructions',
      mistakesKey: 'pushupStandardMistakes',
      breathingKey: 'pushupStandardBreathing',
      chadMessageKey: 'pushupStandardChad',
      imageAsset: 'assets/pushups/standard.png',
      estimatedCaloriesPerRep: 1,
      youtubeVideoId: 'qeK3LrNRN2o', // 기본 푸시업 쇼츠
    ),

    PushupType(
      id: 'knee',
      nameKey: 'pushupKneeName',
      descriptionKey: 'pushupKneeDesc',
      difficulty: PushupDifficulty.beginner,
      targetMuscles: [TargetMuscle.chest, TargetMuscle.triceps],
      benefitsKey: 'pushupKneeBenefits',
      instructionsKey: 'pushupKneeInstructions',
      mistakesKey: 'pushupKneeMistakes',
      breathingKey: 'pushupKneeBreathing',
      chadMessageKey: 'pushupKneeChad',
      imageAsset: 'assets/pushups/knee.png',
      estimatedCaloriesPerRep: 1,
      youtubeVideoId: 'y0guq2nkGBU', // 무릎 푸시업 쇼츠
    ),

    PushupType(
      id: 'incline',
      nameKey: 'pushupInclineName',
      descriptionKey: 'pushupInclineDesc',
      difficulty: PushupDifficulty.beginner,
      targetMuscles: [TargetMuscle.chest, TargetMuscle.triceps],
      benefitsKey: 'pushupInclineBenefits',
      instructionsKey: 'pushupInclineInstructions',
      mistakesKey: 'pushupInclineMistakes',
      breathingKey: 'pushupInclineBreathing',
      chadMessageKey: 'pushupInclineChad',
      imageAsset: 'assets/pushups/incline.png',
      estimatedCaloriesPerRep: 1,
      youtubeVideoId: 'DORUKQ3zLIo', // 인클라인 푸시업 쇼츠
    ),

    // 중급 (Intermediate)
    PushupType(
      id: 'wide_grip',
      nameKey: 'pushupWideGripName',
      descriptionKey: 'pushupWideGripDesc',
      difficulty: PushupDifficulty.intermediate,
      targetMuscles: [TargetMuscle.chest, TargetMuscle.shoulders],
      benefitsKey: 'pushupWideGripBenefits',
      instructionsKey: 'pushupWideGripInstructions',
      mistakesKey: 'pushupWideGripMistakes',
      breathingKey: 'pushupWideGripBreathing',
      chadMessageKey: 'pushupWideGripChad',
      imageAsset: 'assets/pushups/wide_grip.png',
      estimatedCaloriesPerRep: 1,
      youtubeVideoId: '5VcUrU_Yn9A', // 와이드 푸시업 쇼츠
    ),

    PushupType(
      id: 'diamond',
      nameKey: 'pushupDiamondName',
      descriptionKey: 'pushupDiamondDesc',
      difficulty: PushupDifficulty.intermediate,
      targetMuscles: [TargetMuscle.triceps, TargetMuscle.chest],
      benefitsKey: 'pushupDiamondBenefits',
      instructionsKey: 'pushupDiamondInstructions',
      mistakesKey: 'pushupDiamondMistakes',
      breathingKey: 'pushupDiamondBreathing',
      chadMessageKey: 'pushupDiamondChad',
      imageAsset: 'assets/pushups/diamond.png',
      estimatedCaloriesPerRep: 2,
      youtubeVideoId: 'PPTj-MW2tcs', // 다이아몬드 푸시업 쇼츠
    ),

    // 고급 (Advanced)
    PushupType(
      id: 'decline',
      nameKey: 'pushupDeclineName',
      descriptionKey: 'pushupDeclineDesc',
      difficulty: PushupDifficulty.advanced,
      targetMuscles: [
        TargetMuscle.shoulders,
        TargetMuscle.chest,
        TargetMuscle.core,
      ],
      benefitsKey: 'pushupDeclineBenefits',
      instructionsKey: 'pushupDeclineInstructions',
      mistakesKey: 'pushupDeclineMistakes',
      breathingKey: 'pushupDeclineBreathing',
      chadMessageKey: 'pushupDeclineChad',
      imageAsset: 'assets/pushups/decline.png',
      estimatedCaloriesPerRep: 2,
      youtubeVideoId: 'Onjh7RMqggY', // 디클라인 푸시업 쇼츠
    ),

    PushupType(
      id: 'archer',
      nameKey: 'pushupArcherName',
      descriptionKey: 'pushupArcherDesc',
      difficulty: PushupDifficulty.advanced,
      targetMuscles: [
        TargetMuscle.chest,
        TargetMuscle.triceps,
        TargetMuscle.core,
      ],
      benefitsKey: 'pushupArcherBenefits',
      instructionsKey: 'pushupArcherInstructions',
      mistakesKey: 'pushupArcherMistakes',
      breathingKey: 'pushupArcherBreathing',
      chadMessageKey: 'pushupArcherChad',
      imageAsset: 'assets/pushups/archer.png',
      estimatedCaloriesPerRep: 3,
      youtubeVideoId: 'vwMIA4BVvYc', // 아처 푸시업 쇼츠
    ),

    PushupType(
      id: 'pike',
      nameKey: 'pushupPikeName',
      descriptionKey: 'pushupPikeDesc',
      difficulty: PushupDifficulty.advanced,
      targetMuscles: [
        TargetMuscle.shoulders,
        TargetMuscle.triceps,
        TargetMuscle.core,
      ],
      benefitsKey: 'pushupPikeBenefits',
      instructionsKey: 'pushupPikeInstructions',
      mistakesKey: 'pushupPikeMistakes',
      breathingKey: 'pushupPikeBreathing',
      chadMessageKey: 'pushupPikeChad',
      imageAsset: 'assets/pushups/pike.png',
      estimatedCaloriesPerRep: 2,
      youtubeVideoId: 'xvOSkm3CGGk', // 파이크 푸시업 쇼츠
    ),

    // 극한 (Extreme)
    PushupType(
      id: 'clap',
      nameKey: 'pushupClapName',
      descriptionKey: 'pushupClapDesc',
      difficulty: PushupDifficulty.extreme,
      targetMuscles: [
        TargetMuscle.chest,
        TargetMuscle.triceps,
        TargetMuscle.full,
      ],
      benefitsKey: 'pushupClapBenefits',
      instructionsKey: 'pushupClapInstructions',
      mistakesKey: 'pushupClapMistakes',
      breathingKey: 'pushupClapBreathing',
      chadMessageKey: 'pushupClapChad',
      imageAsset: 'assets/pushups/clap.png',
      estimatedCaloriesPerRep: 3,
      youtubeVideoId: 'JX9YCBaeCoo', // 박수 푸시업 쇼츠
    ),

    PushupType(
      id: 'one_arm',
      nameKey: 'pushupOneArmName',
      descriptionKey: 'pushupOneArmDesc',
      difficulty: PushupDifficulty.extreme,
      targetMuscles: [TargetMuscle.full],
      benefitsKey: 'pushupOneArmBenefits',
      instructionsKey: 'pushupOneArmInstructions',
      mistakesKey: 'pushupOneArmMistakes',
      breathingKey: 'pushupOneArmBreathing',
      chadMessageKey: 'pushupOneArmChad',
      imageAsset: 'assets/pushups/one_arm.png',
      estimatedCaloriesPerRep: 5,
      youtubeVideoId: '_BMXPbAGYfw', // 한 손 푸시업 쇼츠
    ),
  ];

  /// 모든 푸시업 타입 조회
  List<PushupType> getAllPushupTypes() {
    return List.unmodifiable(_pushupTypes);
  }

  /// 난이도별 푸시업 타입 조회
  List<PushupType> getPushupTypesByDifficulty(PushupDifficulty difficulty) {
    return _pushupTypes.where((type) => type.difficulty == difficulty).toList();
  }

  /// ID로 특정 푸시업 타입 조회
  PushupType? getPushupTypeById(String id) {
    try {
      return _pushupTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 초급자 추천 푸시업 조회
  List<PushupType> getBeginnerPushups() {
    return getPushupTypesByDifficulty(PushupDifficulty.beginner);
  }

  /// 특정 근육을 타겟하는 푸시업 타입 조회
  List<PushupType> getPushupsByTargetMuscle(TargetMuscle muscle) {
    return _pushupTypes
        .where((type) => type.targetMuscles.contains(muscle))
        .toList();
  }

  /// 사용자 레벨에 맞는 추천 푸시업 조회
  List<PushupType> getRecommendedPushups(int userMaxPushups) {
    if (userMaxPushups <= 10) {
      return getPushupTypesByDifficulty(PushupDifficulty.beginner);
    } else if (userMaxPushups <= 25) {
      return [
        ...getPushupTypesByDifficulty(PushupDifficulty.beginner),
        ...getPushupTypesByDifficulty(PushupDifficulty.intermediate),
      ];
    } else if (userMaxPushups <= 50) {
      return [
        ...getPushupTypesByDifficulty(PushupDifficulty.intermediate),
        ...getPushupTypesByDifficulty(PushupDifficulty.advanced),
      ];
    } else {
      return getAllPushupTypes(); // 모든 레벨 추천
    }
  }

  /// 난이도별 색상 반환 (UI 표시용)
  static int getDifficultyColor(PushupDifficulty difficulty) {
    switch (difficulty) {
      case PushupDifficulty.beginner:
        return 0xFF4DABF7; // 파란색
      case PushupDifficulty.intermediate:
        return 0xFF51CF66; // 초록색
      case PushupDifficulty.advanced:
        return 0xFFFFB000; // 금색
      case PushupDifficulty.extreme:
        return 0xFFE53E3E; // 빨간색
    }
  }

  /// 근육별 색상 반환 (UI 표시용)
  static int getTargetMuscleColor(TargetMuscle muscle) {
    switch (muscle) {
      case TargetMuscle.chest:
        return 0xFFE53E3E; // 빨간색
      case TargetMuscle.triceps:
        return 0xFFFFB000; // 금색
      case TargetMuscle.shoulders:
        return 0xFF51CF66; // 초록색
      case TargetMuscle.core:
        return 0xFFFF6B35; // 주황색
      case TargetMuscle.full:
        return 0xFF9C27B0; // 보라색
    }
  }
}
