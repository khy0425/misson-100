import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 연속 운동 스트릭 추적 서비스
class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  /// 현재 스트릭 정보
  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastWorkoutDate;
  Set<int> _unlockedMilestones = {};
  int _recoveryCredits = 0;
  DateTime? _lastRecoveryDate;
  bool _isInitialized = false;

  // SharedPreferences 키
  static const String _currentStreakKey = 'current_streak';
  static const String _longestStreakKey = 'longest_streak';
  static const String _lastWorkoutDateKey = 'last_workout_date';
  static const String _unlockedMilestonesKey = 'unlocked_milestones';
  static const String _recoveryCreditsKey = 'recovery_credits';
  static const String _lastRecoveryDateKey = 'last_recovery_date';

  // 마일스톤 임계값
  static const List<int> _milestoneThresholds = [3, 7, 14, 30, 50, 100, 200, 365];
  
  // 복구 설정
  static const int _maxRecoveryCredits = 3;
  static const int _gracePeriodDays = 2;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 저장된 스트릭 데이터 로드
      _currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
      _longestStreak = prefs.getInt(_longestStreakKey) ?? 0;
      
      final lastWorkoutDateString = prefs.getString(_lastWorkoutDateKey);
      if (lastWorkoutDateString != null) {
        _lastWorkoutDate = DateTime.parse(lastWorkoutDateString);
      }

      final unlockedMilestones = prefs.getStringList(_unlockedMilestonesKey);
      if (unlockedMilestones != null) {
        _unlockedMilestones = unlockedMilestones.map(int.parse).toSet();
      }

      _recoveryCredits = prefs.getInt(_recoveryCreditsKey) ?? 0;
      final lastRecoveryDateString = prefs.getString(_lastRecoveryDateKey);
      if (lastRecoveryDateString != null) {
        _lastRecoveryDate = DateTime.parse(lastRecoveryDateString);
      }

      _isInitialized = true;
      debugPrint('StreakService 초기화 완료: 현재 스트릭 $_currentStreak일, 최고 스트릭 $_longestStreak일');
    } catch (e) {
      debugPrint('StreakService 초기화 오류: $e');
      // 기본값으로 초기화
      _currentStreak = 0;
      _longestStreak = 0;
      _lastWorkoutDate = null;
      _unlockedMilestones = {};
      _recoveryCredits = 0;
      _lastRecoveryDate = null;
      _isInitialized = true;
    }
  }

  /// 운동 완료 시 스트릭 업데이트
  Future<void> updateStreak(DateTime workoutDate) async {
    await initialize();

    try {
      // 날짜를 일 단위로 정규화 (시간 제거)
      final normalizedWorkoutDate = DateTime(
        workoutDate.year,
        workoutDate.month,
        workoutDate.day,
      );

      // 첫 운동인 경우
      if (_lastWorkoutDate == null) {
        _currentStreak = 1;
        _lastWorkoutDate = normalizedWorkoutDate;
        await _saveStreakData();
        debugPrint('첫 운동 완료: 스트릭 1일 시작');
        return;
      }

      final normalizedLastDate = DateTime(
        _lastWorkoutDate!.year,
        _lastWorkoutDate!.month,
        _lastWorkoutDate!.day,
      );

      final daysDifference = normalizedWorkoutDate.difference(normalizedLastDate).inDays;

      if (daysDifference == 0) {
        // 같은 날 운동 - 스트릭 유지
        debugPrint('같은 날 운동: 스트릭 유지 ($_currentStreak일)');
        return;
      } else if (daysDifference == 1) {
        // 연속된 날 운동 - 스트릭 증가
        _currentStreak++;
        _lastWorkoutDate = normalizedWorkoutDate;
        
        // 최고 스트릭 업데이트
        if (_currentStreak > _longestStreak) {
          _longestStreak = _currentStreak;
        }
        
        await _saveStreakData();
        debugPrint('연속 운동 완료: 스트릭 $_currentStreak일 (최고: $_longestStreak일)');
        
        // 마일스톤 체크
        await _checkMilestones();
      } else {
        // 스트릭 중단 - 새로운 스트릭 시작
        _currentStreak = 1;
        _lastWorkoutDate = normalizedWorkoutDate;
        await _saveStreakData();
        debugPrint('스트릭 중단: 새로운 스트릭 1일 시작 (최고: $_longestStreak일)');
      }
    } catch (e) {
      debugPrint('스트릭 업데이트 오류: $e');
    }
  }

  /// 현재 스트릭 가져오기
  Future<int> getCurrentStreak() async {
    await initialize();
    return _currentStreak;
  }

  /// 최고 스트릭 가져오기
  Future<int> getLongestStreak() async {
    await initialize();
    return _longestStreak;
  }

  /// 마지막 운동 날짜 가져오기
  Future<DateTime?> getLastWorkoutDate() async {
    await initialize();
    return _lastWorkoutDate;
  }

  /// 스트릭이 위험한지 확인 (오늘 운동하지 않으면 스트릭 중단)
  Future<bool> isStreakAtRisk() async {
    await initialize();

    if (_currentStreak == 0 || _lastWorkoutDate == null) {
      return false; // 스트릭이 없으면 위험하지 않음
    }

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedLastDate = DateTime(
      _lastWorkoutDate!.year,
      _lastWorkoutDate!.month,
      _lastWorkoutDate!.day,
    );

    final daysSinceLastWorkout = normalizedToday.difference(normalizedLastDate).inDays;

    // 마지막 운동이 어제였다면 오늘 운동해야 스트릭 유지
    return daysSinceLastWorkout == 1;
  }

  /// 스트릭 상태 정보 가져오기
  Future<Map<String, dynamic>> getStreakStatus() async {
    await initialize();

    final isAtRisk = await isStreakAtRisk();
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    
    bool isActive = false;
    int daysSinceLastWorkout = 0;

    if (_lastWorkoutDate != null) {
      final normalizedLastDate = DateTime(
        _lastWorkoutDate!.year,
        _lastWorkoutDate!.month,
        _lastWorkoutDate!.day,
      );
      daysSinceLastWorkout = normalizedToday.difference(normalizedLastDate).inDays;
      isActive = daysSinceLastWorkout <= 1; // 오늘 또는 어제 운동했으면 활성
    }

    return {
      'currentStreak': _currentStreak,
      'longestStreak': _longestStreak,
      'isActive': isActive,
      'isAtRisk': isAtRisk,
      'daysSinceLastWorkout': daysSinceLastWorkout,
      'lastWorkoutDate': _lastWorkoutDate?.toIso8601String(),
    };
  }

  /// 스트릭 데이터 저장
  Future<void> _saveStreakData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt(_currentStreakKey, _currentStreak);
      await prefs.setInt(_longestStreakKey, _longestStreak);
      
      if (_lastWorkoutDate != null) {
        await prefs.setString(_lastWorkoutDateKey, _lastWorkoutDate!.toIso8601String());
      } else {
        await prefs.remove(_lastWorkoutDateKey);
      }

      await prefs.setStringList(_unlockedMilestonesKey, _unlockedMilestones.map((e) => e.toString()).toList());
      await prefs.setInt(_recoveryCreditsKey, _recoveryCredits);
      
      if (_lastRecoveryDate != null) {
        await prefs.setString(_lastRecoveryDateKey, _lastRecoveryDate!.toIso8601String());
      } else {
        await prefs.remove(_lastRecoveryDateKey);
      }
    } catch (e) {
      debugPrint('스트릭 데이터 저장 오류: $e');
    }
  }

  /// 스트릭 리셋 (테스트용)
  @visibleForTesting
  Future<void> resetStreak() async {
    _currentStreak = 0;
    _longestStreak = 0;
    _lastWorkoutDate = null;
    _unlockedMilestones = {};
    _recoveryCredits = 0;
    _lastRecoveryDate = null;
    await _saveStreakData();
  }

  /// 스트릭 데이터 강제 설정 (테스트용)
  @visibleForTesting
  Future<void> setStreakData({
    required int currentStreak,
    required int longestStreak,
    DateTime? lastWorkoutDate,
  }) async {
    _currentStreak = currentStreak;
    _longestStreak = longestStreak;
    _lastWorkoutDate = lastWorkoutDate;
    await _saveStreakData();
  }

  /// 마일스톤 체크
  Future<void> _checkMilestones() async {
    for (final threshold in _milestoneThresholds) {
      if (_currentStreak >= threshold && !_unlockedMilestones.contains(threshold)) {
        _unlockedMilestones.add(threshold);
        await _saveStreakData();
        debugPrint('스트릭 마일스톤 달성: $threshold일');
        
        // 마일스톤 달성 알림 (추후 구현)
        // await _notifyMilestoneAchieved(threshold);
      }
    }
  }

  /// 달성한 마일스톤 목록 가져오기
  Future<Set<int>> getUnlockedMilestones() async {
    await initialize();
    return Set.from(_unlockedMilestones);
  }

  /// 다음 마일스톤까지 남은 일수
  Future<int?> getDaysToNextMilestone() async {
    await initialize();
    
    for (final threshold in _milestoneThresholds) {
      if (_currentStreak < threshold) {
        return threshold - _currentStreak;
      }
    }
    
    return null; // 모든 마일스톤 달성
  }

  /// 마일스톤 진행률 (0.0 ~ 1.0)
  Future<double> getMilestoneProgress() async {
    await initialize();
    
    int? nextMilestone;
    int? previousMilestone;
    
    for (final threshold in _milestoneThresholds) {
      if (_currentStreak < threshold) {
        nextMilestone = threshold;
        break;
      }
      previousMilestone = threshold;
    }
    
    if (nextMilestone == null) {
      return 1.0; // 모든 마일스톤 달성
    }
    
    final start = previousMilestone ?? 0;
    final range = nextMilestone - start;
    final progress = (_currentStreak - start) / range;
    
    return progress.clamp(0.0, 1.0);
  }

  /// 마일스톤 보상 정보 가져오기
  Map<String, dynamic> getMilestoneReward(int milestone) {
    switch (milestone) {
      case 3:
        return {
          'title': '첫 걸음 Chad',
          'description': '3일 연속 운동 달성!',
          'icon': '🔥',
          'reward': 'Chad 레벨 +1',
        };
      case 7:
        return {
          'title': '일주일 Chad',
          'description': '7일 연속 운동 달성!',
          'icon': '💪',
          'reward': 'Chad 레벨 +2',
        };
      case 14:
        return {
          'title': '2주 Chad',
          'description': '14일 연속 운동 달성!',
          'icon': '🏆',
          'reward': 'Chad 레벨 +3',
        };
      case 30:
        return {
          'title': '한 달 Chad',
          'description': '30일 연속 운동 달성!',
          'icon': '👑',
          'reward': 'Chad 레벨 +5',
        };
      case 50:
        return {
          'title': '50일 Chad',
          'description': '50일 연속 운동 달성!',
          'icon': '⭐',
          'reward': 'Chad 레벨 +7',
        };
      case 100:
        return {
          'title': '100일 Chad',
          'description': '100일 연속 운동 달성!',
          'icon': '💎',
          'reward': 'Chad 레벨 +10',
        };
      case 200:
        return {
          'title': '200일 Chad',
          'description': '200일 연속 운동 달성!',
          'icon': '🚀',
          'reward': 'Chad 레벨 +15',
        };
      case 365:
        return {
          'title': '1년 Chad',
          'description': '365일 연속 운동 달성!',
          'icon': '🌟',
          'reward': 'Chad 레벨 +25',
        };
      default:
        return {
          'title': '스트릭 마스터',
          'description': '$milestone일 연속 운동 달성!',
          'icon': '🎯',
          'reward': 'Chad 레벨 +1',
        };
    }
  }

  /// 스트릭 복구 가능 여부 확인
  Future<bool> canRecoverStreak() async {
    await initialize();
    
    if (_recoveryCredits <= 0 || _lastWorkoutDate == null) {
      return false;
    }
    
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedLastDate = DateTime(
      _lastWorkoutDate!.year,
      _lastWorkoutDate!.month,
      _lastWorkoutDate!.day,
    );
    
    final daysSinceLastWorkout = normalizedToday.difference(normalizedLastDate).inDays;
    
    // 유예 기간 내에서만 복구 가능
    return daysSinceLastWorkout > 1 && daysSinceLastWorkout <= _gracePeriodDays;
  }

  /// 스트릭 복구 실행
  Future<bool> recoverStreak() async {
    await initialize();
    
    if (!await canRecoverStreak()) {
      return false;
    }
    
    try {
      // 복구 크레딧 사용
      _recoveryCredits--;
      _lastRecoveryDate = DateTime.now();
      
      // 마지막 운동 날짜를 어제로 설정하여 스트릭 유지
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      _lastWorkoutDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
      
      await _saveStreakData();
      debugPrint('스트릭 복구 완료: 남은 크레딧 $_recoveryCredits개');
      
      return true;
    } catch (e) {
      debugPrint('스트릭 복구 오류: $e');
      return false;
    }
  }

  /// 복구 크레딧 추가 (마일스톤 달성 시)
  Future<void> addRecoveryCredit() async {
    await initialize();
    
    if (_recoveryCredits < _maxRecoveryCredits) {
      _recoveryCredits++;
      await _saveStreakData();
      debugPrint('복구 크레딧 획득: 현재 $_recoveryCredits개');
    }
  }

  /// 복구 상태 정보 가져오기
  Future<Map<String, dynamic>> getRecoveryStatus() async {
    await initialize();
    
    final canRecover = await canRecoverStreak();
    int? daysUntilExpiry;
    
    if (_lastWorkoutDate != null) {
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final normalizedLastDate = DateTime(
        _lastWorkoutDate!.year,
        _lastWorkoutDate!.month,
        _lastWorkoutDate!.day,
      );
      
      final daysSinceLastWorkout = normalizedToday.difference(normalizedLastDate).inDays;
      
      if (daysSinceLastWorkout > 1 && daysSinceLastWorkout <= _gracePeriodDays) {
        daysUntilExpiry = _gracePeriodDays - daysSinceLastWorkout + 1;
      }
    }
    
    return {
      'canRecover': canRecover,
      'recoveryCredits': _recoveryCredits,
      'maxRecoveryCredits': _maxRecoveryCredits,
      'gracePeriodDays': _gracePeriodDays,
      'daysUntilExpiry': daysUntilExpiry,
      'lastRecoveryDate': _lastRecoveryDate?.toIso8601String(),
    };
  }
} 