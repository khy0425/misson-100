import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';
import '../generated/app_localizations.dart';

/// 사용자 레벨 분류 유틸리티 클래스
class LevelClassifier {
  /// 푸시업 개수에 따라 사용자 레벨을 분류합니다.
  ///
  /// 분류 기준:
  /// - Rookie Chad: 5개 이하
  /// - Rising Chad: 6-10개
  /// - Alpha Chad: 11-20개
  /// - Giga Chad: 21개 이상
  static UserLevel classifyUserLevel(int pushUpCount) {
    if (pushUpCount <= 5) {
      return UserLevel.rookie;
    } else if (pushUpCount <= 10) {
      return UserLevel.rising;
    } else if (pushUpCount <= 20) {
      return UserLevel.alpha;
    } else {
      return UserLevel.giga;
    }
  }

  /// 사용자 레벨에 따른 이름을 반환합니다.
  static String getLevelName(BuildContext context, UserLevel level) {
    switch (level) {
      case UserLevel.rookie:
        return AppLocalizations.of(context).levelNameRookie;
      case UserLevel.rising:
        return AppLocalizations.of(context).levelNameRising;
      case UserLevel.alpha:
        return AppLocalizations.of(context).levelNameAlpha;
      case UserLevel.giga:
        return AppLocalizations.of(context).levelNameGiga;
    }
  }

  /// 사용자 레벨에 따른 설명을 반환합니다.
  static String getLevelDescription(BuildContext context, UserLevel level) {
    switch (level) {
      case UserLevel.rookie:
        return AppLocalizations.of(context).levelDescRookie;
      case UserLevel.rising:
        return AppLocalizations.of(context).levelDescRising;
      case UserLevel.alpha:
        return AppLocalizations.of(context).levelDescAlpha;
      case UserLevel.giga:
        return AppLocalizations.of(context).levelDescGiga;
    }
  }

  /// 사용자 레벨에 따른 색상을 반환합니다.
  static int getLevelColor(UserLevel level) {
    switch (level) {
      case UserLevel.rookie:
        return AppColors.rookieColor;
      case UserLevel.rising:
        return AppColors.risingColor;
      case UserLevel.alpha:
        return AppColors.alphaColor;
      case UserLevel.giga:
        return AppColors.gigaColor;
    }
  }

  /// 사용자 레벨에 따른 아이콘을 반환합니다.
  static String getLevelIcon(UserLevel level) {
    switch (level) {
      case UserLevel.rookie:
        return '🌱'; // 새싹
      case UserLevel.rising:
        return '⚡'; // 번개
      case UserLevel.alpha:
        return '🔥'; // 불꽃
      case UserLevel.giga:
        return '💪'; // 근육
    }
  }

  /// 사용자 레벨에 따른 격려 메시지를 반환합니다.
  static String getLevelMotivationMessage(
    BuildContext context,
    UserLevel level,
  ) {
    switch (level) {
      case UserLevel.rookie:
        return AppLocalizations.of(context).levelMotivationRookie;
      case UserLevel.rising:
        return AppLocalizations.of(context).levelMotivationRising;
      case UserLevel.alpha:
        return AppLocalizations.of(context).levelMotivationAlpha;
      case UserLevel.giga:
        return AppLocalizations.of(context).levelMotivationGiga;
    }
  }

  /// 레벨별 목표 메시지를 반환합니다.
  static String getLevelGoalMessage(BuildContext context, UserLevel level) {
    switch (level) {
      case UserLevel.rookie:
        return AppLocalizations.of(context).levelGoalRookie;
      case UserLevel.rising:
        return AppLocalizations.of(context).levelGoalRising;
      case UserLevel.alpha:
        return AppLocalizations.of(context).levelGoalAlpha;
      case UserLevel.giga:
        return AppLocalizations.of(context).levelGoalGiga;
    }
  }

  /// 레벨 분류 결과를 포함한 완전한 정보를 반환합니다.
  static LevelClassificationResult classifyWithDetails(
    BuildContext context,
    int pushUpCount,
  ) {
    final level = classifyUserLevel(pushUpCount);

    return LevelClassificationResult(
      level: level,
      pushUpCount: pushUpCount,
      levelName: getLevelName(context, level),
      description: getLevelDescription(context, level),
      color: getLevelColor(level),
      icon: getLevelIcon(level),
      motivationMessage: getLevelMotivationMessage(context, level),
      goalMessage: getLevelGoalMessage(context, level),
    );
  }
}

/// 레벨 분류 결과를 담는 클래스
class LevelClassificationResult {
  final UserLevel level;
  final int pushUpCount;
  final String levelName;
  final String description;
  final int color;
  final String icon;
  final String motivationMessage;
  final String goalMessage;

  const LevelClassificationResult({
    required this.level,
    required this.pushUpCount,
    required this.levelName,
    required this.description,
    required this.color,
    required this.icon,
    required this.motivationMessage,
    required this.goalMessage,
  });

  @override
  String toString() {
    return 'LevelClassificationResult(level: $level, pushUpCount: $pushUpCount, levelName: $levelName)';
  }
}
