import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chad_evolution.dart';
import '../models/progress.dart';
import '../services/notification_service.dart';
import 'chad_image_service.dart';
import 'package:flutter/material.dart';

/// Chad 진화 시스템을 관리하는 서비스
class ChadEvolutionService extends ChangeNotifier {
  static const String _evolutionStateKey = 'chad_evolution_state';
  static const String _unlockedStagesKey = 'chad_unlocked_stages';

  ChadEvolutionState _evolutionState = const ChadEvolutionState(
    currentStage: ChadEvolutionStage.sleepCapChad,
    unlockedStages: [],
    totalEvolutions: 0,
  );

  bool _isInitialized = false;

  /// 진화 애니메이션 표시 여부
  bool _showEvolutionAnimation = false;
  ChadEvolution? _evolutionFromChad;
  ChadEvolution? _evolutionToChad;

  /// 진화 애니메이션 상태
  bool get showEvolutionAnimation => _showEvolutionAnimation;
  ChadEvolution? get evolutionFromChad => _evolutionFromChad;
  ChadEvolution? get evolutionToChad => _evolutionToChad;

  /// 현재 Chad 진화 상태
  ChadEvolutionState get evolutionState => _evolutionState;

  /// 현재 Chad 정보
  ChadEvolution get currentChad => _evolutionState.currentChad;

  /// 다음 Chad 정보
  ChadEvolution? get nextChad => _evolutionState.nextChad;

  /// 진화 진행률 (0.0 ~ 1.0)
  double get evolutionProgress => _evolutionState.evolutionProgress;

  /// 최종 진화 완료 여부
  bool get isMaxEvolution => _evolutionState.isMaxEvolution;

  /// 해제된 Chad 단계들
  List<ChadEvolution> get unlockedStages => _evolutionState.unlockedStages;

  /// 서비스 초기화
  Future<void> initialize() async {
    await _loadEvolutionState();
    debugPrint('ChadEvolutionService 초기화 완료');
  }

  /// 저장된 진화 상태 로드
  Future<void> _loadEvolutionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 진화 상태 로드
      final stateJson = prefs.getString(_evolutionStateKey);
      if (stateJson != null) {
        final stateData = jsonDecode(stateJson) as Map<String, dynamic>;
        _evolutionState = ChadEvolutionState.fromJson(stateData);
      } else {
        // 초기 상태 설정 (수면모자 Chad 해제)
        await _initializeDefaultState();
      }
    } catch (e) {
      debugPrint('Chad 진화 상태 로드 오류: $e');
      await _initializeDefaultState();
    }
  }

  /// 기본 상태 초기화
  Future<void> _initializeDefaultState() async {
    final initialChad = ChadEvolution.defaultStages.first.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );

    _evolutionState = ChadEvolutionState(
      currentStage: ChadEvolutionStage.sleepCapChad,
      unlockedStages: [initialChad],
      totalEvolutions: 0,
    );

    await _saveEvolutionState();
  }

  /// 진화 상태 저장
  Future<void> _saveEvolutionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final stateJson = jsonEncode(_evolutionState.toJson());
      await prefs.setString(_evolutionStateKey, stateJson);
      
      // 해제된 단계들도 별도 저장 (호환성)
      final unlockedJson = jsonEncode(
        _evolutionState.unlockedStages.map((e) => e.toJson()).toList(),
      );
      await prefs.setString(_unlockedStagesKey, unlockedJson);
    } catch (e) {
      debugPrint('Chad 진화 상태 저장 오류: $e');
    }
  }

  /// Chad 진화 상태 확인 및 업데이트
  Future<bool> checkAndUpdateChadLevel(Progress progress) async {
    try {
      final currentWeek = _calculateCurrentWeek(progress);
      final currentStage = _evolutionState.currentStage;
      
      // 현재 단계에서 진화 가능한지 확인
      ChadEvolution? nextEvolution;
      for (final chad in ChadEvolution.defaultStages) {
        if (chad.requiredWeek <= currentWeek && 
            chad.stage.index > currentStage.index &&
            !_evolutionState.unlockedStages.contains(chad.stage)) {
          nextEvolution = chad;
          break;
        }
      }
      
      if (nextEvolution != null) {
        // 진화 전 Chad 정보 저장
        final fromChad = ChadEvolution.defaultStages.firstWhere(
          (chad) => chad.stage == currentStage,
        );
        
        // 진화 실행
        await _evolveToStage(nextEvolution.stage);
        
        // 애니메이션 트리거
        startEvolutionAnimation(fromChad, nextEvolution);
        
        // 알림 전송
        await _sendEvolutionNotification(nextEvolution);
        
        debugPrint('Chad 진화 완료: ${currentStage.name} → ${nextEvolution.stage.name}');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Chad 진화 확인 오류: $e');
      return false;
    }
  }

  /// 현재 주차 계산
  int _calculateCurrentWeek(Progress progress) {
    // 완료된 주차 수 계산
    int completedWeeks = 0;
    
    for (int week = 1; week <= 6; week++) {
      // weeklyProgress에서 해당 주차 찾기
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

  /// 특정 단계로 진화
  Future<ChadEvolution?> _evolveToStage(ChadEvolutionStage targetStage) async {
    try {
      // 목표 Chad 정보 가져오기
      final targetChad = ChadEvolution.defaultStages.firstWhere(
        (chad) => chad.stage == targetStage,
      );

      // 해제된 Chad 생성
      final unlockedChad = targetChad.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

      // 상태 업데이트
      final updatedUnlockedStages = List<ChadEvolution>.from(_evolutionState.unlockedStages);
      
      // 기존에 해제된 단계인지 확인
      final existingIndex = updatedUnlockedStages.indexWhere(
        (chad) => chad.stage == targetStage,
      );
      
      if (existingIndex >= 0) {
        updatedUnlockedStages[existingIndex] = unlockedChad;
      } else {
        updatedUnlockedStages.add(unlockedChad);
      }

      _evolutionState = _evolutionState.copyWith(
        currentStage: targetStage,
        unlockedStages: updatedUnlockedStages,
        lastEvolutionAt: DateTime.now(),
        totalEvolutions: _evolutionState.totalEvolutions + 1,
      );

      await _saveEvolutionState();
      notifyListeners();

      // 진화 알림 전송
      await _sendEvolutionNotification(unlockedChad);

      return unlockedChad;
    } catch (e) {
      debugPrint('Chad 진화 오류: $e');
      return null;
    }
  }

  /// 진화 알림 전송
  Future<void> _sendEvolutionNotification(ChadEvolution evolvedChad) async {
    try {
      // 알림 설정 확인
      final isEnabled = await isChadEvolutionNotificationEnabled();
      if (!isEnabled) {
        debugPrint('Chad 진화 알림이 비활성화되어 있습니다.');
        return;
      }

      // 최종 진화인지 확인
      if (evolvedChad.stage == ChadEvolutionStage.doubleChad) {
        await NotificationService.showChadFinalEvolutionNotification();
      } else {
        await NotificationService.showChadEvolutionNotification(
          chadName: evolvedChad.name,
          evolutionMessage: evolvedChad.unlockMessage,
          stageNumber: evolvedChad.stageNumber,
        );
      }
    } catch (e) {
      debugPrint('Chad 진화 알림 전송 오류: $e');
    }
  }

  /// 진화 예고 알림 전송 (다음 진화까지 1주 남았을 때)
  Future<void> sendEvolutionPreviewNotification() async {
    try {
      // 알림 설정 확인
      final isEnabled = await isChadEvolutionPreviewNotificationEnabled();
      if (!isEnabled) {
        debugPrint('Chad 진화 예고 알림이 비활성화되어 있습니다.');
        return;
      }

      final nextChad = _evolutionState.nextChad;
      if (nextChad != null) {
        final weeksLeft = getWeeksUntilNextEvolution();
        if (weeksLeft == 1) {
          await NotificationService.showChadEvolutionPreview(
            nextChadName: nextChad.name,
            weeksLeft: weeksLeft,
          );
        }
      }
    } catch (e) {
      debugPrint('Chad 진화 예고 알림 전송 오류: $e');
    }
  }

  /// 진화 격려 알림 전송 (진화 조건에 가까워졌을 때)
  Future<void> sendEvolutionEncouragementNotification() async {
    try {
      // 알림 설정 확인
      final isEnabled = await isChadEvolutionEncouragementNotificationEnabled();
      if (!isEnabled) {
        debugPrint('Chad 진화 격려 알림이 비활성화되어 있습니다.');
        return;
      }

      final currentChad = _evolutionState.currentChad;
      final nextChad = _evolutionState.nextChad;
      
      if (nextChad != null) {
        final weeksLeft = getWeeksUntilNextEvolution();
        final daysLeft = weeksLeft * 7; // 주를 일로 변환
        
        // 3일 남았을 때 격려 알림
        if (daysLeft == 3) {
          await NotificationService.showChadEvolutionEncouragement(
            currentChadName: currentChad.name,
            nextChadName: nextChad.name,
            daysLeft: daysLeft,
          );
        }
      }
    } catch (e) {
      debugPrint('Chad 진화 격려 알림 전송 오류: $e');
    }
  }

  /// 진화 상태 확인 및 알림 전송 (주기적 호출용)
  Future<void> checkAndSendProgressNotifications(Progress progress) async {
    try {
      // 진화 예고 알림 확인
      await sendEvolutionPreviewNotification();
      
      // 진화 격려 알림 확인
      await sendEvolutionEncouragementNotification();
      
      // 실제 진화 확인 및 실행
      await checkAndUpdateChadLevel(progress);
    } catch (e) {
      debugPrint('Chad 진화 진행 상황 확인 오류: $e');
    }
  }

  /// 수동 진화 (테스트/디버그용)
  Future<ChadEvolution?> manualEvolveToStage(ChadEvolutionStage targetStage) async {
    if (!_isInitialized) {
      await initialize();
    }

    return await _evolveToStage(targetStage);
  }

  /// 특정 단계가 해제되었는지 확인
  bool isStageUnlocked(ChadEvolutionStage stage) {
    return _evolutionState.unlockedStages.any((chad) => chad.stage == stage);
  }

  /// 특정 단계의 해제 시간 가져오기
  DateTime? getStageUnlockTime(ChadEvolutionStage stage) {
    final unlockedChad = _evolutionState.unlockedStages.firstWhere(
      (chad) => chad.stage == stage,
      orElse: () => ChadEvolution.defaultStages.first,
    );
    return unlockedChad.unlockedAt;
  }

  /// 진화 상태 리셋 (테스트/디버그용)
  Future<void> resetEvolution() async {
    await _initializeDefaultState();
    notifyListeners();
  }

  /// 모든 단계 해제 (테스트/디버그용)
  Future<void> unlockAllStages() async {
    final allUnlocked = ChadEvolution.defaultStages.map((chad) {
      return chad.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
    }).toList();

    _evolutionState = _evolutionState.copyWith(
      currentStage: ChadEvolutionStage.doubleChad,
      unlockedStages: allUnlocked,
      totalEvolutions: ChadEvolution.defaultStages.length - 1,
      lastEvolutionAt: DateTime.now(),
    );

    await _saveEvolutionState();
    notifyListeners();
  }

  /// 진화 통계 정보
  Map<String, dynamic> getEvolutionStats() {
    return {
      'currentStage': _evolutionState.currentStage.toString().split('.').last,
      'currentStageName': currentChad.name,
      'totalEvolutions': _evolutionState.totalEvolutions,
      'unlockedStagesCount': _evolutionState.unlockedStages.length,
      'evolutionProgress': evolutionProgress,
      'isMaxEvolution': isMaxEvolution,
      'lastEvolutionAt': _evolutionState.lastEvolutionAt?.toIso8601String(),
    };
  }

  /// 진화 진행률 계산 (0.0 - 1.0)
  double getEvolutionProgress() {
    if (_evolutionState.currentStage == ChadEvolutionStage.doubleChad) {
      return 1.0; // 최종 단계는 100%
    }
    
    // 임시로 현재 주차를 0으로 설정 (나중에 실제 Progress 데이터와 연동)
    final currentWeek = 0;
    final nextStage = ChadEvolutionStage.values[_evolutionState.currentStage.index + 1];
    final nextEvolution = ChadEvolution.defaultStages.firstWhere(
      (chad) => chad.stage == nextStage,
    );
    
    final currentStageWeek = ChadEvolution.defaultStages.firstWhere(
      (chad) => chad.stage == _evolutionState.currentStage,
    ).requiredWeek;
    
    final progressInCurrentStage = currentWeek - currentStageWeek;
    final weeksNeededForNext = nextEvolution.requiredWeek - currentStageWeek;
    
    if (weeksNeededForNext <= 0) return 1.0;
    
    return (progressInCurrentStage / weeksNeededForNext).clamp(0.0, 1.0);
  }
  
  /// 다음 진화까지 남은 주차 계산
  int getWeeksUntilNextEvolution() {
    if (_evolutionState.currentStage == ChadEvolutionStage.doubleChad) {
      return 0; // 최종 단계
    }
    
    // 임시로 현재 주차를 0으로 설정 (나중에 실제 Progress 데이터와 연동)
    final currentWeek = 0;
    final nextStage = ChadEvolutionStage.values[_evolutionState.currentStage.index + 1];
    final nextEvolution = ChadEvolution.defaultStages.firstWhere(
      (chad) => chad.stage == nextStage,
    );
    
    final weeksLeft = nextEvolution.requiredWeek - currentWeek;
    return weeksLeft > 0 ? weeksLeft : 0;
  }

  /// 진화 애니메이션 시작
  void startEvolutionAnimation(ChadEvolution fromChad, ChadEvolution toChad) {
    _evolutionFromChad = fromChad;
    _evolutionToChad = toChad;
    _showEvolutionAnimation = true;
    notifyListeners();
  }

  /// 진화 애니메이션 완료
  void completeEvolutionAnimation() {
    _showEvolutionAnimation = false;
    _evolutionFromChad = null;
    _evolutionToChad = null;
    notifyListeners();
  }

  /// 다음 단계로 진화 (디버그/테스트용)
  Future<void> evolveToNextStage() async {
    final currentStage = _evolutionState.currentStage;
    final nextStageIndex = currentStage.index + 1;
    
    if (nextStageIndex < ChadEvolutionStage.values.length) {
      final nextStage = ChadEvolutionStage.values[nextStageIndex];
      await _evolveToStage(nextStage);
    }
  }

  /// Chad 진화 알림 설정 저장
  Future<void> setChadEvolutionNotificationEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('chad_evolution_notifications', enabled);
      debugPrint('Chad 진화 알림 설정: $enabled');
    } catch (e) {
      debugPrint('Chad 진화 알림 설정 저장 오류: $e');
    }
  }

  /// Chad 진화 알림 설정 가져오기
  Future<bool> isChadEvolutionNotificationEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('chad_evolution_notifications') ?? true; // 기본값: 활성화
    } catch (e) {
      debugPrint('Chad 진화 알림 설정 로드 오류: $e');
      return true;
    }
  }

  /// Chad 진화 예고 알림 설정 저장
  Future<void> setChadEvolutionPreviewNotificationEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('chad_evolution_preview_notifications', enabled);
      debugPrint('Chad 진화 예고 알림 설정: $enabled');
    } catch (e) {
      debugPrint('Chad 진화 예고 알림 설정 저장 오류: $e');
    }
  }

  /// Chad 진화 예고 알림 설정 가져오기
  Future<bool> isChadEvolutionPreviewNotificationEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('chad_evolution_preview_notifications') ?? true; // 기본값: 활성화
    } catch (e) {
      debugPrint('Chad 진화 예고 알림 설정 로드 오류: $e');
      return true;
    }
  }

  /// Chad 진화 격려 알림 설정 저장
  Future<void> setChadEvolutionEncouragementNotificationEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('chad_evolution_encouragement_notifications', enabled);
      debugPrint('Chad 진화 격려 알림 설정: $enabled');
    } catch (e) {
      debugPrint('Chad 진화 격려 알림 설정 저장 오류: $e');
    }
  }

  /// Chad 진화 격려 알림 설정 가져오기
  Future<bool> isChadEvolutionEncouragementNotificationEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('chad_evolution_encouragement_notifications') ?? true; // 기본값: 활성화
    } catch (e) {
      debugPrint('Chad 진화 격려 알림 설정 로드 오류: $e');
      return true;
    }
  }

  /// 모든 Chad 진화 알림 설정 가져오기
  Future<Map<String, bool>> getAllChadEvolutionNotificationSettings() async {
    return {
      'evolution': await isChadEvolutionNotificationEnabled(),
      'preview': await isChadEvolutionPreviewNotificationEnabled(),
      'encouragement': await isChadEvolutionEncouragementNotificationEnabled(),
    };
  }

  /// Chad 이미지 가져오기 (최적화된 버전)
  Future<ImageProvider> getChadImage(
    ChadEvolutionStage stage, {
    int? targetSize,
  }) async {
    return await ChadImageService().getChadImage(
      stage,
      targetSize: targetSize,
    );
  }

  /// 현재 Chad 이미지 가져오기
  Future<ImageProvider> getCurrentChadImage({int? targetSize}) async {
    return await getChadImage(_evolutionState.currentStage, targetSize: targetSize);
  }

  /// 다음 Chad 이미지 가져오기 (진화 예고용)
  Future<ImageProvider?> getNextChadImage({int? targetSize}) async {
    final nextChad = _evolutionState.nextChad;
    if (nextChad != null) {
      return await getChadImage(nextChad.stage, targetSize: targetSize);
    }
    return null;
  }

  /// 다음 진화 이미지들 프리로드
  Future<void> preloadUpcomingImages({int? targetSize}) async {
    await ChadImageService().preloadUpcomingChadImages(
      _evolutionState.currentStage,
      targetSize: targetSize,
    );
  }

  /// 모든 Chad 이미지 프리로드 (앱 시작 시)
  Future<void> preloadAllImages({int? targetSize}) async {
    await ChadImageService().preloadAllChadImages(targetSize: targetSize);
  }

  /// 이미지 캐시 통계
  Map<String, dynamic> getImageCacheStats() {
    return ChadImageService().getCacheStats();
  }

  /// 이미지 캐시 크기 가져오기
  Future<int> getImageCacheSize() async {
    return await ChadImageService().getCacheSize();
  }

  /// 이미지 캐시 정리
  Future<void> clearImageCache({bool memoryOnly = false}) async {
    await ChadImageService().clearCache(memoryOnly: memoryOnly);
  }

  /// 메모리 압박 시 이미지 캐시 정리
  void onMemoryPressure() {
    ChadImageService().onMemoryPressure();
  }

  @override
  void dispose() {
    super.dispose();
  }
} 