import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';
import '../models/chad_evolution.dart';

/// Chad 진화 단계별 이름과 설명을 언어별로 제공하는 헬퍼 클래스
class ChadTranslationHelper {
  
  /// Chad 이름을 현재 언어로 번역
  static String getChadName(BuildContext context, ChadEvolution chad) {
    final isKorean = context.locale.languageCode == 'ko';
    
    switch (chad.stage) {
      case ChadEvolutionStage.sleepCapChad:
        return isKorean ? '수면모자 Chad' : 'Sleepy Hat Chad';
      case ChadEvolutionStage.basicChad:
        return isKorean ? '기본 Chad' : 'Basic Chad';
      case ChadEvolutionStage.coffeeChad:
        return isKorean ? '커피 Chad' : 'Coffee Chad';
      case ChadEvolutionStage.frontFacingChad:
        return isKorean ? '정면 Chad' : 'Front Facing Chad';
      case ChadEvolutionStage.sunglassesChad:
        return isKorean ? '썬글라스 Chad' : 'Sunglasses Chad';
      case ChadEvolutionStage.glowingEyesChad:
        return isKorean ? '빛나는눈 Chad' : 'Glowing Eyes Chad';
      case ChadEvolutionStage.doubleChad:
        return isKorean ? '더블 Chad' : 'Double Chad';
      default:
        return chad.name; // 폴백
    }
  }
  
  /// Chad 설명을 현재 언어로 번역
  static String getChadDescription(BuildContext context, ChadEvolution chad) {
    final isKorean = context.locale.languageCode == 'ko';
    
    switch (chad.stage) {
      case ChadEvolutionStage.sleepCapChad:
        return isKorean 
            ? '여정을 시작하는 Chad입니다.\n아직 잠이 덜 깬 상태지만 곧 깨어날 것입니다!'
            : 'Starting your journey Chad.\nStill a bit sleepy but will wake up soon!';
      case ChadEvolutionStage.basicChad:
        return isKorean 
            ? '첫 번째 진화를 완료한 Chad입니다.\n기초 체력을 다지기 시작했습니다!'
            : 'Chad who completed the first evolution.\nStarted building basic stamina!';
      case ChadEvolutionStage.coffeeChad:
        return isKorean
            ? '에너지가 넘치는 Chad입니다.\n커피의 힘으로 더욱 강해졌습니다!'
            : 'Chad overflowing with energy.\nBecame stronger with the power of coffee!';
      case ChadEvolutionStage.frontFacingChad:
        return isKorean
            ? '자신감이 넘치는 Chad입니다.\n정면을 당당히 바라보며 도전합니다!'
            : 'Chad overflowing with confidence.\nFaces challenges head-on with determination!';
      case ChadEvolutionStage.sunglassesChad:
        return isKorean
            ? '쿨한 매력의 Chad입니다.\n선글라스를 쓰고 멋진 모습을 보여줍니다!'
            : 'Chad with cool charm.\nShows off stylish appearance wearing sunglasses!';
      case ChadEvolutionStage.glowingEyesChad:
        return isKorean
            ? '강력한 힘을 가진 Chad입니다.\n눈에서 빛이 나며 엄청난 파워를 보여줍니다!'
            : 'Chad with incredible power.\nEyes glow with tremendous energy!';
      case ChadEvolutionStage.doubleChad:
        return isKorean
            ? '최종 진화를 완료한 전설의 Chad입니다.\n두 배의 파워로 모든 것을 정복합니다!'
            : 'Legendary Chad who completed final evolution.\nConquers everything with double power!';
      default:
        return chad.description; // 폴백
    }
  }
  
  /// 오늘의 미션 텍스트 번역
  static String getTodayMission(BuildContext context) {
    return context.locale.languageCode == 'ko' ? '오늘의 미션' : 'Today\'s Mission';
  }
  
  /// 오늘의 목표 텍스트 번역
  static String getTodayTarget(BuildContext context) {
    return context.locale.languageCode == 'ko' ? '오늘의 목표:' : 'Today\'s Target:';
  }
  
  /// 세트 형식 번역
  static String getSetFormat(BuildContext context, int setNumber, int reps) {
    return context.locale.languageCode == 'ko' 
        ? '${setNumber}세트: ${reps}회'
        : 'Set $setNumber: $reps reps';
  }
  
  /// 주차/일차 형식 번역
  static String getWeekDayFormat(BuildContext context, int week, int day) {
    return context.locale.languageCode == 'ko'
        ? '${week}주차 - ${day}일차'
        : 'Week $week - Day $day';
  }
  
  /// 완료된 운동 형식 번역
  static String getCompletedFormat(BuildContext context, int reps, int sets) {
    return context.locale.languageCode == 'ko'
        ? '완료됨: ${reps}회 (${sets}세트)'
        : 'Completed: $reps reps ($sets sets)';
  }
  
  /// 총 운동 형식 번역
  static String getTotalFormat(BuildContext context, int reps, int sets) {
    return context.locale.languageCode == 'ko'
        ? '총 ${reps}회 (${sets}세트)'
        : 'Total $reps reps ($sets sets)';
  }
  
  /// 오늘 운동 완료 메시지 번역
  static String getTodayWorkoutCompleted(BuildContext context) {
    return context.locale.languageCode == 'ko'
        ? '오늘 운동 완료됨! 🎉'
        : 'Today\'s workout completed! 🎉';
  }
  
  /// 휴식 방지 메시지 번역
  static String getJustWait(BuildContext context) {
    return context.locale.languageCode == 'ko'
        ? '잠깐! 너 진짜 쉴거야?'
        : 'Wait! Are you really going to rest?';
  }
  
  /// 완벽한 푸시업 자세 번역
  static String getPerfectPushupForm(BuildContext context) {
    return context.locale.languageCode == 'ko'
        ? '완벽한 푸시업 자세'
        : 'Perfect Pushup Form';
  }
  
  /// 진행률 추적 번역
  static String getProgressTracking(BuildContext context) {
    return context.locale.languageCode == 'ko'
        ? '진행률 추적'
        : 'Progress Tracking';
  }
}

/// Locale 확장
extension LocaleExtension on BuildContext {
  Locale get locale => Localizations.localeOf(this);
} 