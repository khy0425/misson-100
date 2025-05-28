import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../generated/app_localizations.dart';

class WorkoutData {
  // 6주 워크아웃 프로그램 데이터
  static Map<UserLevel, Map<int, Map<int, List<int>>>> get workoutPrograms => {
    // 초급 레벨 (Rookie Chad)
    UserLevel.rookie: {
      1: {
        // Week 1
        1: [2, 3, 2, 2, 3], // Day 1: 5세트
        2: [6, 6, 4, 4, 5], // Day 2: 5세트
        3: [8, 10, 7, 7, 8], // Day 3: 5세트
      },
      2: {
        // Week 2
        1: [6, 8, 6, 6, 7],
        2: [7, 9, 7, 7, 8],
        3: [8, 10, 8, 8, 9],
      },
      3: {
        // Week 3
        1: [10, 12, 7, 7, 9],
        2: [12, 17, 8, 8, 10],
        3: [11, 15, 9, 9, 11],
      },
      4: {
        // Week 4
        1: [12, 18, 11, 10, 12],
        2: [14, 20, 12, 12, 14],
        3: [16, 23, 13, 13, 15],
      },
      5: {
        // Week 5
        1: [17, 28, 15, 15, 20],
        2: [10, 18, 13, 13, 16, 18], // 6세트
        3: [13, 18, 15, 15, 17, 20], // 6세트
      },
      6: {
        // Week 6
        1: [25, 40, 20, 15, 25],
        2: [14, 20, 15, 15, 16, 18, 20], // 7세트
        3: [13, 22, 17, 17, 18, 20, 22], // 7세트
      },
    },

    // 중급 레벨 (Rising Chad)
    UserLevel.rising: {
      1: {
        // Week 1
        1: [4, 6, 4, 4, 6],
        2: [5, 6, 4, 4, 7],
        3: [5, 7, 5, 5, 8],
      },
      2: {
        // Week 2
        1: [6, 8, 6, 6, 8],
        2: [7, 9, 7, 7, 9],
        3: [8, 10, 8, 8, 10],
      },
      3: {
        // Week 3
        1: [10, 12, 7, 7, 10],
        2: [12, 17, 8, 8, 12],
        3: [11, 15, 9, 9, 13],
      },
      4: {
        // Week 4
        1: [12, 18, 11, 10, 14],
        2: [14, 20, 12, 12, 16],
        3: [16, 23, 13, 13, 18],
      },
      5: {
        // Week 5
        1: [17, 28, 15, 15, 22],
        2: [10, 18, 13, 13, 18, 20], // 6세트
        3: [13, 18, 15, 15, 19, 22], // 6세트
      },
      6: {
        // Week 6
        1: [25, 40, 20, 15, 28],
        2: [14, 20, 15, 15, 18, 20, 22], // 7세트
        3: [13, 22, 17, 17, 20, 22, 25], // 7세트
      },
    },

    // 고급 레벨 (Alpha Chad)
    UserLevel.alpha: {
      1: {
        // Week 1
        1: [9, 11, 8, 8, 11],
        2: [10, 12, 9, 9, 12],
        3: [12, 13, 10, 10, 15],
      },
      2: {
        // Week 2
        1: [14, 16, 12, 12, 16],
        2: [14, 16, 12, 12, 17],
        3: [16, 17, 14, 14, 19],
      },
      3: {
        // Week 3
        1: [14, 18, 13, 13, 18],
        2: [18, 25, 15, 15, 22],
        3: [20, 28, 20, 20, 25],
      },
      4: {
        // Week 4
        1: [18, 22, 16, 16, 22],
        2: [20, 25, 20, 20, 25],
        3: [23, 28, 23, 23, 28],
      },
      5: {
        // Week 5
        1: [35, 40, 25, 22, 40],
        2: [18, 18, 20, 20, 22, 25], // 6세트
        3: [18, 18, 20, 20, 24, 27], // 6세트
      },
      6: {
        // Week 6
        1: [40, 50, 25, 25, 50],
        2: [20, 20, 23, 23, 25, 27, 30], // 7세트
        3: [22, 22, 30, 30, 32, 35, 40], // 7세트
      },
    },

    // 마스터 레벨 (Giga Chad)
    UserLevel.giga: {
      1: {
        // Week 1
        1: [15, 20, 15, 15, 20],
        2: [18, 22, 18, 18, 22],
        3: [20, 25, 20, 20, 25],
      },
      2: {
        // Week 2
        1: [20, 25, 20, 20, 25],
        2: [22, 27, 22, 22, 27],
        3: [25, 30, 25, 25, 30],
      },
      3: {
        // Week 3
        1: [25, 35, 25, 25, 30],
        2: [30, 40, 30, 30, 35],
        3: [35, 45, 35, 35, 40],
      },
      4: {
        // Week 4
        1: [30, 40, 30, 30, 35],
        2: [35, 45, 35, 35, 40],
        3: [40, 50, 40, 40, 45],
      },
      5: {
        // Week 5
        1: [50, 60, 40, 35, 50],
        2: [25, 30, 30, 30, 35, 40], // 6세트
        3: [30, 35, 35, 35, 40, 45], // 6세트
      },
      6: {
        // Week 6
        1: [60, 70, 50, 45, 60],
        2: [35, 40, 40, 40, 45, 50, 55], // 7세트
        3: [40, 45, 50, 50, 55, 60, 70], // 7세트
      },
    },
  };

  // 레벨별 총 목표 (6주차 마지막 날 기준)
  static Map<UserLevel, int> get targetTotals => {
    UserLevel.rookie: 100,
    UserLevel.rising: 115,
    UserLevel.alpha: 150,
    UserLevel.giga: 200,
  };

  // 특정 레벨, 주차, 일차의 워크아웃 가져오기
  static List<int>? getWorkout(UserLevel level, int week, int day) {
    return workoutPrograms[level]?[week]?[day];
  }

  // 특정 워크아웃의 총 횟수 계산
  static int getTotalReps(List<int> workout) {
    if (workout.isEmpty) return 0;
    return workout.reduce((a, b) => a + b);
  }

  // 주차별 총 운동량 계산
  static int getWeeklyTotal(UserLevel level, int week) {
    int total = 0;
    for (int day = 1; day <= 3; day++) {
      final workout = getWorkout(level, week, day);
      if (workout != null) {
        total += getTotalReps(workout);
      }
    }
    return total;
  }

  // 6주 전체 운동량 계산
  static int getProgramTotal(UserLevel level) {
    int total = 0;
    for (int week = 1; week <= 6; week++) {
      total += getWeeklyTotal(level, week);
    }
    return total;
  }

  // 세트 간 권장 휴식 시간 (초)
  static Map<UserLevel, int> get restTimeSeconds => {
    UserLevel.rookie: 60, // 1분
    UserLevel.rising: 75, // 1분 15초
    UserLevel.alpha: 90, // 1분 30초
    UserLevel.giga: 120, // 2분
  };

  // 난이도별 색상 코드 - Chad 테마에 맞게 업데이트
  static Map<UserLevel, int> get levelColors => {
    UserLevel.rookie: 0xFF4DABF7, // 파란색 (초보)
    UserLevel.rising: 0xFF51CF66, // 초록색 (상승)
    UserLevel.alpha: 0xFFFFB000, // 금색 (알파)
    UserLevel.giga: 0xFFE53E3E, // 빨간색 (기가)
  };

  // 차드 진화 단계별 이미지 경로
  static List<String> get chadImagePaths => [
    'assets/images/수면모자차드.jpg', // 0단계 - 시작
    'assets/images/기본차드.jpg', // 1단계 - 1주차
    'assets/images/커피차드.png', // 2단계 - 2주차
    'assets/images/정면차드.jpg', // 3단계 - 3주차
    'assets/images/썬글차드.jpg', // 4단계 - 4주차
    'assets/images/눈빔차드.jpg', // 5단계 - 5주차
    'assets/images/더블차드.jpg', // 6단계 - 6주차 완료
  ];

  // 차드 레벨에 따른 이미지 경로 반환
  static String getChadImage(int chadLevel) {
    if (chadLevel < 0 || chadLevel >= chadImagePaths.length) {
      return chadImagePaths[0]; // 기본값: 수면모자차드
    }
    return chadImagePaths[chadLevel];
  }

  // 차드 레벨별 메시지 (국제화)
  static List<String> getChadMessages(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      localizations.chadMessage0, // 0단계
      localizations.chadMessage1, // 1단계
      localizations.chadMessage2, // 2단계
      localizations.chadMessage3, // 3단계
      localizations.chadMessage4, // 4단계
      localizations.chadMessage5, // 5단계
      localizations.chadMessage6, // 6단계
    ];
  }

  // 동기부여 메시지들 (국제화)
  static List<String> getMotivationalMessages(BuildContext context) {
    return [
      AppLocalizations.of(context).motivationMessage1,
      AppLocalizations.of(context).motivationMessage2,
      AppLocalizations.of(context).motivationMessage3,
      AppLocalizations.of(context).motivationMessage4,
      AppLocalizations.of(context).motivationMessage5,
      AppLocalizations.of(context).motivationMessage6,
      AppLocalizations.of(context).motivationMessage7,
      AppLocalizations.of(context).motivationMessage8,
      AppLocalizations.of(context).motivationMessage9,
      AppLocalizations.of(context).motivationMessage10,
    ];
  }

  // 운동 완료 시 메시지 (국제화)
  static List<String> getCompletionMessages(BuildContext context) {
    return [
      AppLocalizations.of(context).completionMessage1,
      AppLocalizations.of(context).completionMessage2,
      AppLocalizations.of(context).completionMessage3,
      AppLocalizations.of(context).completionMessage4,
      AppLocalizations.of(context).completionMessage5,
      AppLocalizations.of(context).completionMessage6,
      AppLocalizations.of(context).completionMessage7,
      AppLocalizations.of(context).completionMessage8,
      AppLocalizations.of(context).completionMessage9,
      AppLocalizations.of(context).completionMessage10,
    ];
  }

  // 실패/격려 메시지 (국제화)
  static List<String> getEncouragementMessages(BuildContext context) {
    return [
      AppLocalizations.of(context).encouragementMessage1,
      AppLocalizations.of(context).encouragementMessage2,
      AppLocalizations.of(context).encouragementMessage3,
      AppLocalizations.of(context).encouragementMessage4,
      AppLocalizations.of(context).encouragementMessage5,
      AppLocalizations.of(context).encouragementMessage6,
      AppLocalizations.of(context).encouragementMessage7,
      AppLocalizations.of(context).encouragementMessage8,
      AppLocalizations.of(context).encouragementMessage9,
      AppLocalizations.of(context).encouragementMessage10,
    ];
  }
}
