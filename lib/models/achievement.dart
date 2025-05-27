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
      case 'achievementPerfect3Title':
        return l10n.achievementPerfect3Title;
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
      case 'achievementTotal50Title':
        return l10n.achievementTotal50Title;
      case 'achievementPerfect10Title':
        return l10n.achievementPerfect10Title;
      case 'achievementPerfect20Title':
        return l10n.achievementPerfect20Title;
      case 'achievementStreak30Title':
        return l10n.achievementStreak30Title;
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
      case 'achievementStreak60Title':
        return l10n.achievementStreak60Title;
      case 'achievementStreak100Title':
        return l10n.achievementStreak100Title;
      default:
        return titleKey;
    }
  }

  String getDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (descriptionKey) {
      case 'achievementTutorialExplorerDesc':
        return l10n.achievementTutorialExplorerDesc;
      case 'achievementPerfect3Desc':
        return l10n.achievementPerfect3Desc;
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
      case 'achievementTotal50Desc':
        return l10n.achievementTotal50Desc;
      case 'achievementPerfect10Desc':
        return l10n.achievementPerfect10Desc;
      case 'achievementPerfect20Desc':
        return l10n.achievementPerfect20Desc;
      case 'achievementStreak30Desc':
        return l10n.achievementStreak30Desc;
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
      case 'achievementStreak60Desc':
        return l10n.achievementStreak60Desc;
      case 'achievementStreak100Desc':
        return l10n.achievementStreak100Desc;
      default:
        return descriptionKey;
    }
  }

  String getMotivation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (motivationKey) {
      case 'achievementTutorialExplorerMotivation':
        return l10n.achievementTutorialExplorerMotivation;
      case 'achievementPerfect3Motivation':
        return l10n.achievementPerfect3Motivation;
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
      case 'achievementTotal50Motivation':
        return l10n.achievementTotal50Motivation;
      case 'achievementPerfect10Motivation':
        return l10n.achievementPerfect10Motivation;
      case 'achievementPerfect20Motivation':
        return l10n.achievementPerfect20Motivation;
      case 'achievementStreak30Motivation':
        return l10n.achievementStreak30Motivation;
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
      case 'achievementStreak60Motivation':
        return l10n.achievementStreak60Motivation;
      case 'achievementStreak100Motivation':
        return l10n.achievementStreak100Motivation;
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
      titleKey: 'achievementMasterTitle',
      descriptionKey: 'achievementMasterDesc',
      motivationKey: 'achievementMasterMotivation',
      type: AchievementType.streak,
      rarity: AchievementRarity.legendary,
      targetValue: 60,
      xpReward: 2500,
      icon: Icons.military_tech,
    ),

    Achievement(
      id: 'streak_100_days',
      titleKey: 'achievementPerfectLegendTitle',
      descriptionKey: 'achievementPerfectLegendDesc',
      motivationKey: 'achievementPerfectLegendMotivation',
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
      titleKey: 'achievementFirst100Title',
      descriptionKey: 'achievementFirst100Desc',
      motivationKey: 'achievementFirst100Motivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.common,
      targetValue: 100,
      xpReward: 200,
      icon: Icons.sports_score,
    ),

    Achievement(
      id: 'total_250_pushups',
      titleKey: 'achievementMasterTitle',
      descriptionKey: 'achievementMasterDesc',
      motivationKey: 'achievementMasterMotivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.common,
      targetValue: 250,
      xpReward: 300,
      icon: Icons.gps_fixed,
    ),

    Achievement(
      id: 'total_500_pushups',
      titleKey: 'achievementUltimateTitle',
      descriptionKey: 'achievementUltimateDesc',
      motivationKey: 'achievementUltimateMotivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.rare,
      targetValue: 500,
      xpReward: 500,
      icon: Icons.rocket_launch,
    ),

    Achievement(
      id: 'total_1000_pushups',
      titleKey: 'achievementPerfectLegendTitle',
      descriptionKey: 'achievementPerfectLegendDesc',
      motivationKey: 'achievementPerfectLegendMotivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.epic,
      targetValue: 1000,
      xpReward: 1000,
      icon: Icons.bolt,
    ),

    Achievement(
      id: 'total_2500_pushups',
      titleKey: 'achievementMasterTitle',
      descriptionKey: 'achievementMasterDesc',
      motivationKey: 'achievementMasterMotivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.epic,
      targetValue: 2500,
      xpReward: 1500,
      icon: Icons.local_fire_department,
    ),

    Achievement(
      id: 'total_5000_pushups',
      titleKey: 'achievementUltimateTitle',
      descriptionKey: 'achievementUltimateDesc',
      motivationKey: 'achievementUltimateMotivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.legendary,
      targetValue: 5000,
      xpReward: 2000,
      icon: Icons.stars,
    ),

    Achievement(
      id: 'total_10000_pushups',
      titleKey: 'achievementPerfectLegendTitle',
      descriptionKey: 'achievementPerfectLegendDesc',
      motivationKey: 'achievementPerfectLegendMotivation',
      type: AchievementType.volume,
      rarity: AchievementRarity.legendary,
      targetValue: 10000,
      xpReward: 5000,
      icon: Icons.emoji_events,
    ),

    // 완벽 수행 시리즈
    Achievement(
      id: 'perfect_workout_3',
      titleKey: 'achievementPerfectSetTitle',
      descriptionKey: 'achievementPerfectSetDesc',
      motivationKey: 'achievementPerfectSetMotivation',
      type: AchievementType.perfect,
      rarity: AchievementRarity.common,
      targetValue: 3,
      xpReward: 250,
      icon: Icons.gps_fixed,
    ),

    Achievement(
      id: 'perfect_workout_5',
      titleKey: 'achievementMasterTitle',
      descriptionKey: 'achievementMasterDesc',
      motivationKey: 'achievementMasterMotivation',
      type: AchievementType.perfect,
      rarity: AchievementRarity.rare,
      targetValue: 5,
      xpReward: 400,
      icon: Icons.verified,
    ),

    Achievement(
      id: 'perfect_workout_10',
      titleKey: 'achievementPerfectLegendTitle',
      descriptionKey: 'achievementPerfectLegendDesc',
      motivationKey: 'achievementPerfectLegendMotivation',
      type: AchievementType.perfect,
      rarity: AchievementRarity.epic,
      targetValue: 10,
      xpReward: 750,
      icon: Icons.workspace_premium,
    ),

    Achievement(
      id: 'perfect_workout_20',
      titleKey: 'achievementUltimateTitle',
      descriptionKey: 'achievementUltimateDesc',
      motivationKey: 'achievementUltimateMotivation',
      type: AchievementType.perfect,
      rarity: AchievementRarity.legendary,
      targetValue: 20,
      xpReward: 1200,
      icon: Icons.diamond,
    ),

    // 특별한 조건 시리즈
    Achievement(
      id: 'explorer_achievement',
      titleKey: 'achievementExplorerTitle',
      descriptionKey: 'achievementExplorerDesc',
      motivationKey: 'achievementExplorerMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.common,
      targetValue: 1,
      xpReward: 200,
      icon: Icons.explore,
    ),

    Achievement(
      id: 'learner_achievement',
      titleKey: 'achievementMasterTitle',
      descriptionKey: 'achievementMasterDesc',
      motivationKey: 'achievementMasterMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 300,
      icon: Icons.school,
    ),

    Achievement(
      id: 'master_achievement',
      titleKey: 'achievementPerfectLegendTitle',
      descriptionKey: 'achievementPerfectLegendDesc',
      motivationKey: 'achievementPerfectLegendMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.legendary,
      targetValue: 1,
      xpReward: 1000,
      icon: Icons.psychology,
    ),

    // 시간대별 특별 업적
    Achievement(
      id: 'early_bird',
      titleKey: 'achievementExplorerTitle',
      descriptionKey: 'achievementExplorerDesc',
      motivationKey: 'achievementExplorerMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 300,
      icon: Icons.wb_sunny,
    ),

    Achievement(
      id: 'night_owl',
      titleKey: 'achievementMasterTitle',
      descriptionKey: 'achievementMasterDesc',
      motivationKey: 'achievementMasterMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 300,
      icon: Icons.nightlight,
    ),

    Achievement(
      id: 'weekend_warrior',
      titleKey: 'achievementUltimateTitle',
      descriptionKey: 'achievementUltimateDesc',
      motivationKey: 'achievementUltimateMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.common,
      targetValue: 1,
      xpReward: 200,
      icon: Icons.weekend,
    ),

    Achievement(
      id: 'lunch_break_chad',
      titleKey: 'achievementPerfectSetTitle',
      descriptionKey: 'achievementPerfectSetDesc',
      motivationKey: 'achievementPerfectSetMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.common,
      targetValue: 1,
      xpReward: 150,
      icon: Icons.lunch_dining,
    ),

    // 성능 기반 업적
    Achievement(
      id: 'speed_demon',
      titleKey: 'achievementMasterTitle',
      descriptionKey: 'achievementMasterDesc',
      motivationKey: 'achievementMasterMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.epic,
      targetValue: 1,
      xpReward: 500,
      icon: Icons.speed,
    ),

    Achievement(
      id: 'endurance_king',
      titleKey: 'achievementUltimateTitle',
      descriptionKey: 'achievementUltimateDesc',
      motivationKey: 'achievementUltimateMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.epic,
      targetValue: 1,
      xpReward: 500,
      icon: Icons.timer,
    ),

    Achievement(
      id: 'comeback_kid',
      titleKey: 'achievementExplorerTitle',
      descriptionKey: 'achievementExplorerDesc',
      motivationKey: 'achievementExplorerMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 400,
      icon: Icons.refresh,
    ),

    // 목표 달성 업적
    Achievement(
      id: 'goal_crusher',
      titleKey: 'achievementPerfectLegendTitle',
      descriptionKey: 'achievementPerfectLegendDesc',
      motivationKey: 'achievementPerfectLegendMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.epic,
      targetValue: 1,
      xpReward: 600,
      icon: Icons.flag,
    ),

    Achievement(
      id: 'double_trouble',
      titleKey: 'achievementMasterTitle',
      descriptionKey: 'achievementMasterDesc',
      motivationKey: 'achievementMasterMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 350,
      icon: Icons.double_arrow,
    ),

    Achievement(
      id: 'consistency_master',
      titleKey: 'achievementUltimateTitle',
      descriptionKey: 'achievementUltimateDesc',
      motivationKey: 'achievementUltimateMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.legendary,
      targetValue: 1,
      xpReward: 1000,
      icon: Icons.trending_up,
    ),

    // 레벨 기반 업적
    Achievement(
      id: 'level_5_chad',
      titleKey: 'achievementLevelUpTitle',
      descriptionKey: 'achievementLevelUpDesc',
      motivationKey: 'achievementLevelUpMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.common,
      targetValue: 1,
      xpReward: 250,
      icon: Icons.looks_5,
    ),

    Achievement(
      id: 'level_10_chad',
      titleKey: 'achievementMasterTitle',
      descriptionKey: 'achievementMasterDesc',
      motivationKey: 'achievementMasterMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 500,
      icon: Icons.filter_1,
    ),

    Achievement(
      id: 'level_20_chad',
      titleKey: 'achievementUltimateTitle',
      descriptionKey: 'achievementUltimateDesc',
      motivationKey: 'achievementUltimateMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.epic,
      targetValue: 1,
      xpReward: 1000,
      icon: Icons.filter_2,
    ),

    // 월간/계절 업적
    Achievement(
      id: 'monthly_warrior',
      titleKey: 'achievementMonthStreakTitle',
      descriptionKey: 'achievementMonthStreakDesc',
      motivationKey: 'achievementMonthStreakMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.epic,
      targetValue: 1,
      xpReward: 800,
      icon: Icons.calendar_month,
    ),

    Achievement(
      id: 'season_champion',
      titleKey: 'achievementPerfectLegendTitle',
      descriptionKey: 'achievementPerfectLegendDesc',
      motivationKey: 'achievementPerfectLegendMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.legendary,
      targetValue: 1,
      xpReward: 1500,
      icon: Icons.emoji_events,
    ),

    // 다양성 업적
    Achievement(
      id: 'variety_seeker',
      titleKey: 'achievementExplorerTitle',
      descriptionKey: 'achievementExplorerDesc',
      motivationKey: 'achievementExplorerMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 400,
      icon: Icons.shuffle,
    ),

    Achievement(
      id: 'all_rounder',
      titleKey: 'achievementMasterTitle',
      descriptionKey: 'achievementMasterDesc',
      motivationKey: 'achievementMasterMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.epic,
      targetValue: 1,
      xpReward: 600,
      icon: Icons.all_inclusive,
    ),

    // 의지력 업적
    Achievement(
      id: 'iron_will',
      titleKey: 'achievementUltimateTitle',
      descriptionKey: 'achievementUltimateDesc',
      motivationKey: 'achievementUltimateMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.legendary,
      targetValue: 1,
      xpReward: 1200,
      icon: Icons.security,
    ),

    Achievement(
      id: 'unstoppable_force',
      titleKey: 'achievementPerfectLegendTitle',
      descriptionKey: 'achievementPerfectLegendDesc',
      motivationKey: 'achievementPerfectLegendMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.legendary,
      targetValue: 1,
      xpReward: 1500,
      icon: Icons.flash_on,
    ),

    Achievement(
      id: 'legendary_beast',
      titleKey: 'achievementUltimateTitle',
      descriptionKey: 'achievementUltimateDesc',
      motivationKey: 'achievementUltimateMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.legendary,
      targetValue: 1,
      xpReward: 2000,
      icon: Icons.pets,
    ),

    // 동기부여 업적
    Achievement(
      id: 'motivator',
      titleKey: 'achievementMasterTitle',
      descriptionKey: 'achievementMasterDesc',
      motivationKey: 'achievementMasterMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.rare,
      targetValue: 1,
      xpReward: 350,
      icon: Icons.campaign,
    ),

    Achievement(
      id: 'dedication_master',
      titleKey: 'achievementPerfectLegendTitle',
      descriptionKey: 'achievementPerfectLegendDesc',
      motivationKey: 'achievementPerfectLegendMotivation',
      type: AchievementType.special,
      rarity: AchievementRarity.legendary,
      targetValue: 1,
      xpReward: 1000,
      icon: Icons.favorite,
    ),
  ];
}
