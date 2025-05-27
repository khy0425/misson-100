import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';

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
  final String titleKey;
  final String descriptionKey;
  final String motivationKey;
  final AchievementType type;
  final AchievementRarity rarity;
  final int targetValue; // 달성 목표값
  final int currentValue; // 현재 진행값
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int xpReward; // 경험치 보상
  final IconData icon;

  Achievement({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.motivationKey,
    required this.type,
    required this.rarity,
    required this.targetValue,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.xpReward = 0,
    required this.icon,
  });

  double get progress => currentValue / targetValue;
  bool get isCompleted => currentValue >= targetValue;

  // 이전 버전과의 호환성을 위한 getter들
  String get title => titleKey;
  String get description => descriptionKey;
  String get motivationalMessage => motivationKey;
  int get iconCode => icon.codePoint;

  String getTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (titleKey) {
      case 'achievementTutorialExplorerTitle':
        return l10n.achievementTutorialExplorerTitle;
      case 'achievementTutorialStudentTitle':
        return l10n.achievementTutorialStudentTitle;
      case 'achievementTutorialMasterTitle':
        return l10n.achievementTutorialMasterTitle;
      case 'achievementPerfect3Title':
        return l10n.achievementPerfect3Title;
      case 'achievementPerfect5Title':
        return l10n.achievementPerfect5Title;
      case 'achievementPerfect10Title':
        return l10n.achievementPerfect10Title;
      case 'achievementPerfect20Title':
        return l10n.achievementPerfect20Title;
      case 'achievementLevel5Title':
        return l10n.achievementLevel5Title;
      case 'achievementFirst50Title':
        return l10n.achievementFirst50Title;
      case 'achievementFirst100SingleTitle':
        return l10n.achievementFirst100SingleTitle;
      case 'achievementStreak3Title':
        return l10n.achievementStreak3Title;
      case 'achievementStreak7Title':
        return l10n.achievementStreak7Title;
      case 'achievementStreak14Title':
        return l10n.achievementStreak14Title;
      case 'achievementStreak30Title':
        return l10n.achievementStreak30Title;
      case 'achievementStreak60Title':
        return l10n.achievementStreak60Title;
      case 'achievementStreak100Title':
        return l10n.achievementStreak100Title;
      case 'achievementTotal50Title':
        return l10n.achievementTotal50Title;
      case 'achievementTotal100Title':
        return l10n.achievementTotal100Title;
      case 'achievementTotal250Title':
        return l10n.achievementTotal250Title;
      case 'achievementTotal500Title':
        return l10n.achievementTotal500Title;
      case 'achievementTotal1000Title':
        return l10n.achievementTotal1000Title;
      case 'achievementTotal2500Title':
        return l10n.achievementTotal2500Title;
      case 'achievementTotal5000Title':
        return l10n.achievementTotal5000Title;
      case 'achievementTotal10000Title':
        return l10n.achievementTotal10000Title;
      case 'achievementEarlyBirdTitle':
        return l10n.achievementEarlyBirdTitle;
      case 'achievementNightOwlTitle':
        return l10n.achievementNightOwlTitle;
      case 'achievementWeekendWarriorTitle':
        return l10n.achievementWeekendWarriorTitle;
      case 'achievementLunchBreakTitle':
        return l10n.achievementLunchBreakTitle;
      case 'achievementSpeedDemonTitle':
        return l10n.achievementSpeedDemonTitle;
      case 'achievementEnduranceKingTitle':
        return l10n.achievementEnduranceKingTitle;
      case 'achievementComebackKidTitle':
        return l10n.achievementComebackKidTitle;
      case 'achievementOverachieverTitle':
        return l10n.achievementOverachieverTitle;
      case 'achievementDoubleTroubleTitle':
        return l10n.achievementDoubleTroubleTitle;
      case 'achievementConsistencyMasterTitle':
        return l10n.achievementConsistencyMasterTitle;
      default:
        return titleKey;
    }
  }

  String getDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (descriptionKey) {
      case 'achievementTutorialExplorerDesc':
        return l10n.achievementTutorialExplorerDesc;
      case 'achievementTutorialStudentDesc':
        return l10n.achievementTutorialStudentDesc;
      case 'achievementTutorialMasterDesc':
        return l10n.achievementTutorialMasterDesc;
      case 'achievementPerfect3Desc':
        return l10n.achievementPerfect3Desc;
      case 'achievementPerfect5Desc':
        return l10n.achievementPerfect5Desc;
      case 'achievementPerfect10Desc':
        return l10n.achievementPerfect10Desc;
      case 'achievementPerfect20Desc':
        return l10n.achievementPerfect20Desc;
      case 'achievementLevel5Desc':
        return l10n.achievementLevel5Desc;
      case 'achievementFirst50Desc':
        return l10n.achievementFirst50Desc;
      case 'achievementFirst100SingleDesc':
        return l10n.achievementFirst100SingleDesc;
      case 'achievementStreak3Desc':
        return l10n.achievementStreak3Desc;
      case 'achievementStreak7Desc':
        return l10n.achievementStreak7Desc;
      case 'achievementStreak14Desc':
        return l10n.achievementStreak14Desc;
      case 'achievementStreak30Desc':
        return l10n.achievementStreak30Desc;
      case 'achievementStreak60Desc':
        return l10n.achievementStreak60Desc;
      case 'achievementStreak100Desc':
        return l10n.achievementStreak100Desc;
      case 'achievementTotal50Desc':
        return l10n.achievementTotal50Desc;
      case 'achievementTotal100Desc':
        return l10n.achievementTotal100Desc;
      case 'achievementTotal250Desc':
        return l10n.achievementTotal250Desc;
      case 'achievementTotal500Desc':
        return l10n.achievementTotal500Desc;
      case 'achievementTotal1000Desc':
        return l10n.achievementTotal1000Desc;
      case 'achievementTotal2500Desc':
        return l10n.achievementTotal2500Desc;
      case 'achievementTotal5000Desc':
        return l10n.achievementTotal5000Desc;
      case 'achievementTotal10000Desc':
        return l10n.achievementTotal10000Desc;
      case 'achievementEarlyBirdDesc':
        return l10n.achievementEarlyBirdDesc;
      case 'achievementNightOwlDesc':
        return l10n.achievementNightOwlDesc;
      case 'achievementWeekendWarriorDesc':
        return l10n.achievementWeekendWarriorDesc;
      case 'achievementLunchBreakDesc':
        return l10n.achievementLunchBreakDesc;
      case 'achievementSpeedDemonDesc':
        return l10n.achievementSpeedDemonDesc;
      case 'achievementEnduranceKingDesc':
        return l10n.achievementEnduranceKingDesc;
      case 'achievementComebackKidDesc':
        return l10n.achievementComebackKidDesc;
      case 'achievementOverachieverDesc':
        return l10n.achievementOverachieverDesc;
      case 'achievementDoubleTroubleDesc':
        return l10n.achievementDoubleTroubleDesc;
      case 'achievementConsistencyMasterDesc':
        return l10n.achievementConsistencyMasterDesc;
      default:
        return descriptionKey;
    }
  }

  String getMotivation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (motivationKey) {
      case 'achievementTutorialExplorerMotivation':
        return l10n.achievementTutorialExplorerMotivation;
      case 'achievementTutorialStudentMotivation':
        return l10n.achievementTutorialStudentMotivation;
      case 'achievementTutorialMasterMotivation':
        return l10n.achievementTutorialMasterMotivation;
      case 'achievementPerfect3Motivation':
        return l10n.achievementPerfect3Motivation;
      case 'achievementPerfect5Motivation':
        return l10n.achievementPerfect5Motivation;
      case 'achievementPerfect10Motivation':
        return l10n.achievementPerfect10Motivation;
      case 'achievementPerfect20Motivation':
        return l10n.achievementPerfect20Motivation;
      case 'achievementLevel5Motivation':
        return l10n.achievementLevel5Motivation;
      case 'achievementFirst50Motivation':
        return l10n.achievementFirst50Motivation;
      case 'achievementFirst100SingleMotivation':
        return l10n.achievementFirst100SingleMotivation;
      case 'achievementStreak3Motivation':
        return l10n.achievementStreak3Motivation;
      case 'achievementStreak7Motivation':
        return l10n.achievementStreak7Motivation;
      case 'achievementStreak14Motivation':
        return l10n.achievementStreak14Motivation;
      case 'achievementStreak30Motivation':
        return l10n.achievementStreak30Motivation;
      case 'achievementStreak60Motivation':
        return l10n.achievementStreak60Motivation;
      case 'achievementStreak100Motivation':
        return l10n.achievementStreak100Motivation;
      case 'achievementTotal50Motivation':
        return l10n.achievementTotal50Motivation;
      case 'achievementTotal100Motivation':
        return l10n.achievementTotal100Motivation;
      case 'achievementTotal250Motivation':
        return l10n.achievementTotal250Motivation;
      case 'achievementTotal500Motivation':
        return l10n.achievementTotal500Motivation;
      case 'achievementTotal1000Motivation':
        return l10n.achievementTotal1000Motivation;
      case 'achievementTotal2500Motivation':
        return l10n.achievementTotal2500Motivation;
      case 'achievementTotal5000Motivation':
        return l10n.achievementTotal5000Motivation;
      case 'achievementTotal10000Motivation':
        return l10n.achievementTotal10000Motivation;
      case 'achievementEarlyBirdMotivation':
        return l10n.achievementEarlyBirdMotivation;
      case 'achievementNightOwlMotivation':
        return l10n.achievementNightOwlMotivation;
      case 'achievementWeekendWarriorMotivation':
        return l10n.achievementWeekendWarriorMotivation;
      case 'achievementLunchBreakMotivation':
        return l10n.achievementLunchBreakMotivation;
      case 'achievementSpeedDemonMotivation':
        return l10n.achievementSpeedDemonMotivation;
      case 'achievementEnduranceKingMotivation':
        return l10n.achievementEnduranceKingMotivation;
      case 'achievementComebackKidMotivation':
        return l10n.achievementComebackKidMotivation;
      case 'achievementOverachieverMotivation':
        return l10n.achievementOverachieverMotivation;
      case 'achievementDoubleTroubleMotivation':
        return l10n.achievementDoubleTroubleMotivation;
      case 'achievementConsistencyMasterMotivation':
        return l10n.achievementConsistencyMasterMotivation;
      default:
        return motivationKey;
    }
  }

  String getRarityName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (rarity) {
      case AchievementRarity.common:
        return l10n.rarityCommon;
      case AchievementRarity.rare:
        return l10n.rarityRare;
      case AchievementRarity.epic:
        return l10n.rarityEpic;
      case AchievementRarity.legendary:
        return l10n.rarityLegendary;
    }
  }

  Color getRarityColor() {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  Achievement copyWith({
    String? id,
    String? titleKey,
    String? descriptionKey,
    String? motivationKey,
    AchievementType? type,
    AchievementRarity? rarity,
    int? targetValue,
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? xpReward,
    IconData? icon,
  }) {
    return Achievement(
      id: id ?? this.id,
      titleKey: titleKey ?? this.titleKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      motivationKey: motivationKey ?? this.motivationKey,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      xpReward: xpReward ?? this.xpReward,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleKey': titleKey,
      'descriptionKey': descriptionKey,
      'motivationKey': motivationKey,
      'type': type.name,
      'rarity': rarity.name,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'isUnlocked': isUnlocked ? 1 : 0,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'xpReward': xpReward,
      'icon': icon.codePoint,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      titleKey: map['titleKey'] as String,
      descriptionKey: map['descriptionKey'] as String,
      motivationKey: map['motivationKey'] as String,
      type: AchievementType.values.firstWhere(
        (e) => e.name == map['type'] as String,
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == map['rarity'] as String,
      ),
      targetValue: map['targetValue'] as int,
      currentValue: map['currentValue'] as int? ?? 0,
      isUnlocked: (map['isUnlocked'] as int) == 1,
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'] as String)
          : null,
      xpReward: map['xpReward'] as int? ?? 0,
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
    );
  }
}

// 미리 정의된 업적들
class PredefinedAchievements {
  static List<Achievement> get all => [
    // 첫 번째 달성 시리즈
    Achievement(
      id: 'first_workout',
      titleKey: 'achievementTutorialExplorerTitle',
      descriptionKey: 'achievementTutorialExplorerDesc',
      motivationKey: 'achievementTutorialExplorerMotivation',
      type: AchievementType.first,
      rarity: AchievementRarity.common,
      targetValue: 1,
      xpReward: 100,
      icon: Icons.play_arrow,
    ),

    Achievement(
      id: 'first_perfect_set',
      titleKey: 'achievementPerfect3Title',
      descriptionKey: 'achievementPerfect3Desc',
      motivationKey: 'achievementPerfect3Motivation',
      type: AchievementType.first,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 200,
      icon: Icons.star,
    ),

    Achievement(
      id: 'first_level_up',
      titleKey: 'achievementLevel5Title',
      descriptionKey: 'achievementLevel5Desc',
      motivationKey: 'achievementLevel5Motivation',
      type: AchievementType.first,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 300,
      icon: Icons.trending_up,
    ),

    Achievement(
      id: 'first_50_pushups',
      titleKey: 'achievementFirst50Title',
      descriptionKey: 'achievementFirst50Desc',
      motivationKey: 'achievementFirst50Motivation',
      type: AchievementType.first,
      rarity: AchievementRarity.common,
      targetValue: 1,
      xpReward: 150,
      icon: Icons.fitness_center,
    ),

    Achievement(
      id: 'first_100_single',
      titleKey: 'achievementFirst100SingleTitle',
      descriptionKey: 'achievementFirst100SingleDesc',
      motivationKey: 'achievementFirst100SingleMotivation',
      type: AchievementType.first,
      rarity: AchievementRarity.epic,
      targetValue: 1,
      xpReward: 500,
      icon: Icons.flash_on,
    ),

    // 연속 달성 시리즈
    Achievement(
      id: 'streak_3_days',
      titleKey: 'achievementStreak3Title',
      descriptionKey: 'achievementStreak3Desc',
      motivationKey: 'achievementStreak3Motivation',
      type: AchievementType.streak,
      rarity: AchievementRarity.common,
      targetValue: 3,
      xpReward: 300,
      icon: Icons.local_fire_department,
    ),

    Achievement(
      id: 'streak_7_days',
      titleKey: 'achievementStreak7Title',
      descriptionKey: 'achievementStreak7Desc',
      motivationKey: 'achievementStreak7Motivation',
      type: AchievementType.streak,
      rarity: AchievementRarity.rare,
      targetValue: 7,
      xpReward: 500,
      icon: Icons.fitness_center,
    ),

    Achievement(
      id: 'streak_14_days',
      titleKey: 'achievementStreak14Title',
      descriptionKey: 'achievementStreak14Desc',
      motivationKey: 'achievementStreak14Motivation',
      type: AchievementType.streak,
      rarity: AchievementRarity.epic,
      targetValue: 14,
      xpReward: 800,
      icon: Icons.directions_run,
    ),

    Achievement(
      id: 'streak_30_days',
      titleKey: 'achievementStreak30Title',
      descriptionKey: 'achievementStreak30Desc',
      motivationKey: 'achievementStreak30Motivation',
      type: AchievementType.streak,
      rarity: AchievementRarity.legendary,
      targetValue: 30,
      xpReward: 1500,
      icon: Icons.emoji_events,
    ),

    Achievement(
      id: 'streak_60_days',
      titleKey: 'achievementStreak60Title',
      descriptionKey: 'achievementStreak60Desc',
      motivationKey: 'achievementStreak60Motivation',
      type: AchievementType.streak,
      rarity: AchievementRarity.legendary,
      targetValue: 60,
      xpReward: 2500,
      icon: Icons.military_tech,
    ),

    Achievement(
      id: 'streak_100_days',
      titleKey: 'achievementStreak100Title',
      descriptionKey: 'achievementStreak100Desc',
      motivationKey: 'achievementStreak100Motivation',
      type: AchievementType.streak,
      rarity: AchievementRarity.legendary,
      targetValue: 100,
      xpReward: 5000,
      icon: Icons.stars,
    ),

    // 총량 달성 시리즈
    Achievement(
      id: 'total_50_pushups',
      titleKey: 'achievementTotal50Title',
      descriptionKey: 'achievementTotal50Desc',
      motivationKey: 'achievementTotal50Motivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.common,
      targetValue: 50,
      xpReward: 100,
      icon: Icons.eco,
    ),

    Achievement(
      id: 'total_100_pushups',
      titleKey: 'achievementTotal100Title',
      descriptionKey: 'achievementTotal100Desc',
      motivationKey: 'achievementTotal100Motivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.common,
      targetValue: 100,
      xpReward: 200,
      icon: Icons.sports_score,
    ),

    Achievement(
      id: 'total_250_pushups',
      titleKey: 'achievementTotal250Title',
      descriptionKey: 'achievementTotal250Desc',
      motivationKey: 'achievementTotal250Motivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.common,
      targetValue: 250,
      xpReward: 300,
      icon: Icons.gps_fixed,
    ),

    Achievement(
      id: 'total_500_pushups',
      titleKey: 'achievementTotal500Title',
      descriptionKey: 'achievementTotal500Desc',
      motivationKey: 'achievementTotal500Motivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.rare,
      targetValue: 500,
      xpReward: 500,
      icon: Icons.rocket_launch,
    ),

    Achievement(
      id: 'total_1000_pushups',
      titleKey: 'achievementTotal1000Title',
      descriptionKey: 'achievementTotal1000Desc',
      motivationKey: 'achievementTotal1000Motivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.epic,
      targetValue: 1000,
      xpReward: 1000,
      icon: Icons.bolt,
    ),

    Achievement(
      id: 'total_2500_pushups',
      titleKey: 'achievementTotal2500Title',
      descriptionKey: 'achievementTotal2500Desc',
      motivationKey: 'achievementTotal2500Motivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.epic,
      targetValue: 2500,
      xpReward: 1500,
      icon: Icons.local_fire_department,
    ),

    Achievement(
      id: 'total_5000_pushups',
      titleKey: 'achievementTotal5000Title',
      descriptionKey: 'achievementTotal5000Desc',
      motivationKey: 'achievementTotal5000Motivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.legendary,
      targetValue: 5000,
      xpReward: 2000,
      icon: Icons.stars,
    ),

    Achievement(
      id: 'total_10000_pushups',
      titleKey: 'achievementTotal10000Title',
      descriptionKey: 'achievementTotal10000Desc',
      motivationKey: 'achievementTotal10000Motivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.legendary,
      targetValue: 10000,
      xpReward: 5000,
      icon: Icons.emoji_events,
    ),

    // 완벽 수행 시리즈
    Achievement(
      id: 'perfect_workout_3',
      titleKey: 'achievementPerfect3Title',
      descriptionKey: 'achievementPerfect3Desc',
      motivationKey: 'achievementPerfect3Motivation',
      type: AchievementType.perfect,
      rarity: AchievementRarity.common,
      targetValue: 3,
      xpReward: 250,
      icon: Icons.gps_fixed,
    ),

    Achievement(
      id: 'perfect_workout_5',
      titleKey: 'achievementPerfect5Title',
      descriptionKey: 'achievementPerfect5Desc',
      motivationKey: 'achievementPerfect5Motivation',
      type: AchievementType.perfect,
      rarity: AchievementRarity.rare,
      targetValue: 5,
      xpReward: 400,
      icon: Icons.verified,
    ),

    Achievement(
      id: 'perfect_workout_10',
      titleKey: 'achievementPerfect10Title',
      descriptionKey: 'achievementPerfect10Desc',
      motivationKey: 'achievementPerfect10Motivation',
      type: AchievementType.perfect,
      rarity: AchievementRarity.epic,
      targetValue: 10,
      xpReward: 750,
      icon: Icons.workspace_premium,
    ),

    Achievement(
      id: 'perfect_workout_20',
      titleKey: 'achievementPerfect20Title',
      descriptionKey: 'achievementPerfect20Desc',
      motivationKey: 'achievementPerfect20Motivation',
      type: AchievementType.perfect,
      rarity: AchievementRarity.legendary,
      targetValue: 20,
      xpReward: 1200,
      icon: Icons.diamond,
    ),

    // 특별한 조건 시리즈
    Achievement(
      id: 'tutorial_explorer',
      titleKey: 'achievementTutorialExplorerTitle',
      descriptionKey: 'achievementTutorialExplorerDesc',
      motivationKey: 'achievementTutorialExplorerMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.common,
      targetValue: 1,
      xpReward: 200,
      icon: Icons.explore,
    ),

    Achievement(
      id: 'tutorial_student',
      titleKey: 'achievementTutorialStudentTitle',
      descriptionKey: 'achievementTutorialStudentDesc',
      motivationKey: 'achievementTutorialStudentMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 3,
      xpReward: 300,
      icon: Icons.school,
    ),

    Achievement(
      id: 'tutorial_master',
      titleKey: 'achievementTutorialMasterTitle',
      descriptionKey: 'achievementTutorialMasterDesc',
      motivationKey: 'achievementTutorialMasterMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.legendary,
      targetValue: 5,
      xpReward: 1000,
      icon: Icons.psychology,
    ),

    // 시간대별 특별 업적
    Achievement(
      id: 'early_bird',
      titleKey: 'achievementEarlyBirdTitle',
      descriptionKey: 'achievementEarlyBirdDesc',
      motivationKey: 'achievementEarlyBirdMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 300,
      icon: Icons.wb_sunny,
    ),

    Achievement(
      id: 'night_owl',
      titleKey: 'achievementNightOwlTitle',
      descriptionKey: 'achievementNightOwlDesc',
      motivationKey: 'achievementNightOwlMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 300,
      icon: Icons.nightlight,
    ),

    Achievement(
      id: 'weekend_warrior',
      titleKey: 'achievementWeekendWarriorTitle',
      descriptionKey: 'achievementWeekendWarriorDesc',
      motivationKey: 'achievementWeekendWarriorMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.common,
      targetValue: 1,
      xpReward: 200,
      icon: Icons.weekend,
    ),

    Achievement(
      id: 'lunch_break_chad',
      titleKey: 'achievementLunchBreakTitle',
      descriptionKey: 'achievementLunchBreakDesc',
      motivationKey: 'achievementLunchBreakMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.common,
      targetValue: 1,
      xpReward: 150,
      icon: Icons.lunch_dining,
    ),

    // 성능 기반 업적
    Achievement(
      id: 'speed_demon',
      titleKey: 'achievementSpeedDemonTitle',
      descriptionKey: 'achievementSpeedDemonDesc',
      motivationKey: 'achievementSpeedDemonMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.epic,
      targetValue: 1,
      xpReward: 500,
      icon: Icons.speed,
    ),

    Achievement(
      id: 'endurance_king',
      titleKey: 'achievementEnduranceKingTitle',
      descriptionKey: 'achievementEnduranceKingDesc',
      motivationKey: 'achievementEnduranceKingMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.epic,
      targetValue: 1,
      xpReward: 500,
      icon: Icons.timer,
    ),

    Achievement(
      id: 'comeback_kid',
      titleKey: 'achievementComebackKidTitle',
      descriptionKey: 'achievementComebackKidDesc',
      motivationKey: 'achievementComebackKidMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 400,
      icon: Icons.refresh,
    ),

    Achievement(
      id: 'overachiever',
      titleKey: 'achievementOverachieverTitle',
      descriptionKey: 'achievementOverachieverDesc',
      motivationKey: 'achievementOverachieverMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.epic,
      targetValue: 1,
      xpReward: 600,
      icon: Icons.trending_up,
    ),

    Achievement(
      id: 'double_trouble',
      titleKey: 'achievementDoubleTroubleTitle',
      descriptionKey: 'achievementDoubleTroubleDesc',
      motivationKey: 'achievementDoubleTroubleMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 350,
      icon: Icons.double_arrow,
    ),

    Achievement(
      id: 'consistency_master',
      titleKey: 'achievementConsistencyMasterTitle',
      descriptionKey: 'achievementConsistencyMasterDesc',
      motivationKey: 'achievementConsistencyMasterMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.legendary,
      targetValue: 1,
      xpReward: 1000,
      icon: Icons.timeline,
    ),
  ];
}
