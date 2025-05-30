import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';
import '../models/progress.dart';
import '../models/chad_evolution.dart';
import '../services/notification_service.dart';

/// 차드 레벨 통합 관리 서비스
/// 기존의 분산된 차드 시스템을 하나로 통합하여 관리
class ChadLevelManager extends ChangeNotifier {
  static final ChadLevelManager _instance = ChadLevelManager._internal();
  factory ChadLevelManager() => _instance;
  ChadLevelManager._internal();

  static const String _chadLevelDataKey = 'chad_level_data';
  
  // 차드 레벨 데이터 모델
  ChadLevelData _levelData = const ChadLevelData();
  bool _isInitialized = false;

  /// 현재 차드 레벨 데이터
  ChadLevelData get levelData => _levelData;

  /// 현재 차드 단계
  ChadStageInfo get currentStage => ChadStageInfo.allStages[_levelData.currentStageIndex];

  /// 다음 차드 단계
  ChadStageInfo? get nextStage {
    final nextIndex = _levelData.currentStageIndex + 1;
    if (nextIndex < ChadStageInfo.allStages.length) {
      return ChadStageInfo.allStages[nextIndex];
    }
    return null;
  }

  /// 최종 진화 완료 여부
  bool get isMaxLevel => _levelData.currentStageIndex >= ChadStageInfo.allStages.length - 1;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataJson = prefs.getString(_chadLevelDataKey);
      
      if (dataJson != null) {
        final dataMap = jsonDecode(dataJson) as Map<String, dynamic>;
        _levelData = ChadLevelData.fromJson(dataMap);
      }
      
      _isInitialized = true;
      debugPrint('✅ ChadLevelManager 초기화 완료: ${currentStage.name}');
    } catch (e) {
      debugPrint('❌ ChadLevelManager 초기화 실패: $e');
      _levelData = const ChadLevelData(); // 기본값
      _isInitialized = true;
    }
  }

  /// 진행 상황 업데이트 및 레벨업 확인
  Future<ChadLevelUpResult> updateProgress(Progress progress) async {
    await _ensureInitialized();
    
    final completedWeeks = _calculateCompletedWeeks(progress);
    final previousStage = _levelData.currentStageIndex;
    
    // 새로운 단계 확인
    int newStageIndex = _levelData.currentStageIndex;
    for (int i = _levelData.currentStageIndex + 1; i < ChadStageInfo.allStages.length; i++) {
      final stage = ChadStageInfo.allStages[i];
      if (completedWeeks >= stage.requiredWeeks) {
        newStageIndex = i;
      } else {
        break;
      }
    }
    
    // 레벨업 발생
    if (newStageIndex > previousStage) {
      await _levelUp(newStageIndex);
      
      return ChadLevelUpResult(
        leveledUp: true,
        previousStage: ChadStageInfo.allStages[previousStage],
        newStage: ChadStageInfo.allStages[newStageIndex],
        completedWeeks: completedWeeks,
      );
    }
    
    // 진행률만 업데이트
    await _updateProgressOnly(completedWeeks);
    
    return ChadLevelUpResult(
      leveledUp: false,
      previousStage: currentStage,
      newStage: currentStage,
      completedWeeks: completedWeeks,
    );
  }

  /// 레벨업 실행
  Future<void> _levelUp(int newStageIndex) async {
    final previousStageIndex = _levelData.currentStageIndex;
    final newStage = ChadStageInfo.allStages[newStageIndex];
    
    _levelData = _levelData.copyWith(
      currentStageIndex: newStageIndex,
      lastLevelUpAt: DateTime.now(),
      totalLevelUps: _levelData.totalLevelUps + (newStageIndex - previousStageIndex),
    );
    
    await _saveLevelData();
    notifyListeners();
    
    // 레벨업 알림
    await _sendLevelUpNotification(newStage);
    
    debugPrint('🎉 차드 레벨업: ${ChadStageInfo.allStages[previousStageIndex].name} → ${newStage.name}');
  }

  /// 진행률만 업데이트
  Future<void> _updateProgressOnly(int completedWeeks) async {
    _levelData = _levelData.copyWith(
      lastUpdatedAt: DateTime.now(),
    );
    
    await _saveLevelData();
    notifyListeners();
  }

  /// 완료된 주차 수 계산
  int _calculateCompletedWeeks(Progress progress) {
    int completedWeeks = 0;
    
    for (int week = 1; week <= 6; week++) {
      final weekProgress = progress.weeklyProgress.firstWhere(
        (wp) => wp.week == week,
        orElse: () => WeeklyProgress(week: week),
      );
      
      if (weekProgress.isWeekCompleted) {
        completedWeeks = week;
      } else {
        break; // 연속으로 완료되지 않은 주차가 있으면 중단
      }
    }
    
    return completedWeeks;
  }

  /// 현재 진화 진행률 계산 (0.0 ~ 1.0)
  double getEvolutionProgress(Progress progress) {
    if (isMaxLevel) return 1.0;
    
    final completedWeeks = _calculateCompletedWeeks(progress);
    final currentStageWeeks = currentStage.requiredWeeks;
    final nextStageWeeks = nextStage?.requiredWeeks ?? currentStageWeeks;
    
    // 현재 단계가 이미 완료되었는지 확인
    if (completedWeeks <= currentStageWeeks) {
      // 현재 단계도 완료하지 못한 경우 0.0
      return 0.0;
    }
    
    if (nextStageWeeks <= currentStageWeeks) return 1.0;
    
    final progressInCurrentStage = completedWeeks - currentStageWeeks;
    final weeksNeededForNext = nextStageWeeks - currentStageWeeks;
    
    return (progressInCurrentStage / weeksNeededForNext).clamp(0.0, 1.0);
  }

  /// 다음 레벨까지 남은 주차 수
  int getWeeksUntilNextLevel(Progress progress) {
    if (isMaxLevel) return 0;
    
    final completedWeeks = _calculateCompletedWeeks(progress);
    final nextStageWeeks = nextStage?.requiredWeeks ?? completedWeeks;
    
    return (nextStageWeeks - completedWeeks).clamp(0, 6);
  }

  /// 차드 이미지 경로 가져오기
  String getCurrentChadImagePath() {
    return currentStage.imagePath;
  }

  /// 특정 단계의 이미지 경로 가져오기
  String getChadImagePath(int stageIndex) {
    if (stageIndex < 0 || stageIndex >= ChadStageInfo.allStages.length) {
      return ChadStageInfo.allStages[0].imagePath;
    }
    return ChadStageInfo.allStages[stageIndex].imagePath;
  }

  /// 레벨업 알림 전송
  Future<void> _sendLevelUpNotification(ChadStageInfo newStage) async {
    try {
      await NotificationService.showChadEvolutionNotification(
        chadName: newStage.name,
        evolutionMessage: newStage.unlockMessage,
        stageNumber: newStage.stageIndex,
      );
    } catch (e) {
      debugPrint('차드 레벨업 알림 전송 실패: $e');
    }
  }

  /// 레벨 데이터 저장
  Future<void> _saveLevelData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataJson = jsonEncode(_levelData.toJson());
      await prefs.setString(_chadLevelDataKey, dataJson);
    } catch (e) {
      debugPrint('차드 레벨 데이터 저장 실패: $e');
    }
  }

  /// 초기화 확인
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// 레벨 리셋 (디버그/테스트용)
  Future<void> resetLevel() async {
    _levelData = const ChadLevelData();
    await _saveLevelData();
    notifyListeners();
    debugPrint('🔄 차드 레벨 리셋 완료');
  }

  /// 특정 레벨로 설정 (디버그/테스트용)
  Future<void> setLevel(int stageIndex) async {
    if (stageIndex < 0 || stageIndex >= ChadStageInfo.allStages.length) return;
    
    _levelData = _levelData.copyWith(
      currentStageIndex: stageIndex,
      lastLevelUpAt: DateTime.now(),
    );
    
    await _saveLevelData();
    notifyListeners();
    debugPrint('🎯 차드 레벨 설정: ${currentStage.name}');
  }

  /// 레벨 통계 정보
  Map<String, dynamic> getLevelStats() {
    return {
      'currentStageIndex': _levelData.currentStageIndex,
      'currentStageName': currentStage.name,
      'totalLevelUps': _levelData.totalLevelUps,
      'isMaxLevel': isMaxLevel,
      'lastLevelUpAt': _levelData.lastLevelUpAt?.toIso8601String(),
      'lastUpdatedAt': _levelData.lastUpdatedAt?.toIso8601String(),
    };
  }
}

/// 차드 레벨 데이터 모델
class ChadLevelData {
  final int currentStageIndex;
  final int totalLevelUps;
  final DateTime? lastLevelUpAt;
  final DateTime? lastUpdatedAt;

  const ChadLevelData({
    this.currentStageIndex = 0,
    this.totalLevelUps = 0,
    this.lastLevelUpAt,
    this.lastUpdatedAt,
  });

  factory ChadLevelData.fromJson(Map<String, dynamic> json) {
    return ChadLevelData(
      currentStageIndex: json['currentStageIndex'] as int? ?? 0,
      totalLevelUps: json['totalLevelUps'] as int? ?? 0,
      lastLevelUpAt: json['lastLevelUpAt'] != null 
          ? DateTime.parse(json['lastLevelUpAt'] as String)
          : null,
      lastUpdatedAt: json['lastUpdatedAt'] != null 
          ? DateTime.parse(json['lastUpdatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStageIndex': currentStageIndex,
      'totalLevelUps': totalLevelUps,
      'lastLevelUpAt': lastLevelUpAt?.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }

  ChadLevelData copyWith({
    int? currentStageIndex,
    int? totalLevelUps,
    DateTime? lastLevelUpAt,
    DateTime? lastUpdatedAt,
  }) {
    return ChadLevelData(
      currentStageIndex: currentStageIndex ?? this.currentStageIndex,
      totalLevelUps: totalLevelUps ?? this.totalLevelUps,
      lastLevelUpAt: lastLevelUpAt ?? this.lastLevelUpAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

/// 차드 단계 정보 모델
class ChadStageInfo {
  final int stageIndex;
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final int requiredWeeks;
  final String unlockMessage;
  final Color themeColor;

  const ChadStageInfo({
    required this.stageIndex,
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.requiredWeeks,
    required this.unlockMessage,
    required this.themeColor,
  });

  /// 모든 차드 단계 정의 (통합된 순서)
  static final List<ChadStageInfo> allStages = [
    ChadStageInfo(
      stageIndex: 0,
      id: 'sleep_cap_chad',
      name: '수면모자 Chad',
      description: '여정을 시작하는 Chad입니다.\n아직 잠이 덜 깬 상태지만 곧 깨어날 것입니다!',
      imagePath: 'assets/images/수면모자차드.jpg',
      requiredWeeks: 0,
      unlockMessage: 'Mission 100에 오신 것을 환영합니다!',
      themeColor: const Color(0xFF9C88FF), // 보라색
    ),
    ChadStageInfo(
      stageIndex: 1,
      id: 'basic_chad',
      name: '기본 Chad',
      description: '첫 번째 진화를 완료한 Chad입니다.\n기초 체력을 다지기 시작했습니다!',
      imagePath: 'assets/images/기본차드.jpg',
      requiredWeeks: 1,
      unlockMessage: '축하합니다! 1주차를 완료하여 기본 Chad로 진화했습니다!',
      themeColor: const Color(0xFF4DABF7), // 파란색
    ),
    ChadStageInfo(
      stageIndex: 2,
      id: 'coffee_chad',
      name: '커피 Chad',
      description: '에너지가 넘치는 Chad입니다.\n커피의 힘으로 더욱 강해졌습니다!',
      imagePath: 'assets/images/커피차드.png',
      requiredWeeks: 2,
      unlockMessage: '대단합니다! 2주차를 완료하여 커피 Chad로 진화했습니다!',
      themeColor: const Color(0xFF8B4513), // 갈색
    ),
    ChadStageInfo(
      stageIndex: 3,
      id: 'front_facing_chad',
      name: '정면 Chad',
      description: '자신감이 넘치는 Chad입니다.\n정면을 당당히 바라보며 도전합니다!',
      imagePath: 'assets/images/정면차드.jpg',
      requiredWeeks: 3,
      unlockMessage: '놀랍습니다! 3주차를 완료하여 정면 Chad로 진화했습니다!',
      themeColor: const Color(0xFF51CF66), // 초록색
    ),
    ChadStageInfo(
      stageIndex: 4,
      id: 'sunglasses_chad',
      name: '썬글라스 Chad',
      description: '쿨한 매력의 Chad입니다.\n선글라스를 쓰고 멋진 모습을 보여줍니다!',
      imagePath: 'assets/images/썬글차드.jpg',
      requiredWeeks: 4,
      unlockMessage: '멋집니다! 4주차를 완료하여 썬글라스 Chad로 진화했습니다!',
      themeColor: const Color(0xFF000000), // 검은색
    ),
    ChadStageInfo(
      stageIndex: 5,
      id: 'glowing_eyes_chad',
      name: '빛나는눈 Chad',
      description: '강력한 힘을 가진 Chad입니다.\n눈에서 빛이 나며 엄청난 파워를 보여줍니다!',
      imagePath: 'assets/images/눈빔차드.jpg',
      requiredWeeks: 5,
      unlockMessage: '경이롭습니다! 5주차를 완료하여 빛나는눈 Chad로 진화했습니다!',
      themeColor: const Color(0xFFFF6B6B), // 빨간색
    ),
    ChadStageInfo(
      stageIndex: 6,
      id: 'double_chad',
      name: '더블 Chad',
      description: '최종 진화를 완료한 전설의 Chad입니다.\n두 배의 파워로 모든 것을 정복합니다!',
      imagePath: 'assets/images/더블차드.jpg',
      requiredWeeks: 6,
      unlockMessage: '전설입니다! 6주차를 완료하여 더블 Chad로 진화했습니다!',
      themeColor: const Color(0xFFFFD43B), // 금색
    ),
  ];

  /// 최종 단계 여부
  bool get isFinalStage => stageIndex == allStages.length - 1;

  /// 다음 단계 존재 여부
  bool get hasNextStage => stageIndex < allStages.length - 1;
}

/// 차드 레벨업 결과 모델
class ChadLevelUpResult {
  final bool leveledUp;
  final ChadStageInfo previousStage;
  final ChadStageInfo newStage;
  final int completedWeeks;

  const ChadLevelUpResult({
    required this.leveledUp,
    required this.previousStage,
    required this.newStage,
    required this.completedWeeks,
  });
} 