import 'package:shared_preferences/shared_preferences.dart';

enum DifficultyLevel {
  beginner('초보자', '천천히 시작하는 차드'),
  intermediate('중급자', '꾸준한 차드'),
  advanced('고급자', '진정한 차드'),
  expert('전문가', '차드의 전설');

  const DifficultyLevel(this.displayName, this.description);
  final String displayName;
  final String description;
}

class DifficultyService {
  static const String _difficultyKey = 'difficulty_level';

  /// 현재 난이도 가져오기
  static Future<DifficultyLevel> getCurrentDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    final difficultyIndex = prefs.getInt(_difficultyKey) ?? 0;
    
    if (difficultyIndex >= 0 && difficultyIndex < DifficultyLevel.values.length) {
      return DifficultyLevel.values[difficultyIndex];
    }
    
    return DifficultyLevel.beginner; // 기본값
  }

  /// 난이도 설정하기
  static Future<void> setDifficulty(DifficultyLevel difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_difficultyKey, difficulty.index);
  }

  /// 난이도에 따른 목표 푸쉬업 수 계산
  static int getTargetPushups(DifficultyLevel difficulty, int currentLevel) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return (currentLevel * 5).clamp(5, 50);
      case DifficultyLevel.intermediate:
        return (currentLevel * 8).clamp(10, 80);
      case DifficultyLevel.advanced:
        return (currentLevel * 12).clamp(15, 120);
      case DifficultyLevel.expert:
        return (currentLevel * 15).clamp(20, 150);
    }
  }

  /// 난이도에 따른 세트 수 계산
  static int getTargetSets(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 3;
      case DifficultyLevel.intermediate:
        return 4;
      case DifficultyLevel.advanced:
        return 5;
      case DifficultyLevel.expert:
        return 6;
    }
  }

  /// 난이도에 따른 휴식 시간 (초)
  static int getRestTime(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 90; // 1분 30초
      case DifficultyLevel.intermediate:
        return 75; // 1분 15초
      case DifficultyLevel.advanced:
        return 60; // 1분
      case DifficultyLevel.expert:
        return 45; // 45초
    }
  }
} 