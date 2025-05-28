import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/challenge.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../services/workout_history_service.dart';
import '../generated/app_localizations.dart';
import 'achievement_service.dart';
import '../services/notification_service.dart';

/// 챌린지 관리 서비스
class ChallengeService {
  static final ChallengeService _instance = ChallengeService._internal();
  factory ChallengeService() => _instance;
  ChallengeService._internal();

  static const String _availableChallengesKey = 'available_challenges';
  static const String _activeChallengesKey = 'active_challenges';
  static const String _completedChallengesKey = 'completed_challenges';

  List<Challenge> _availableChallenges = [];
  List<Challenge> _activeChallenges = [];
  List<Challenge> _completedChallenges = [];

  final AchievementService _achievementService = AchievementService();
  final NotificationService _notificationService = NotificationService();

  /// 서비스 초기화
  Future<void> initialize() async {
    await _loadChallenges();
    if (_availableChallenges.isEmpty) {
      _availableChallenges = _createDefaultChallenges();
      await _saveChallenges();
    }
  }

  /// 기본 챌린지 목록 생성
  List<Challenge> _createDefaultChallenges() {
    return [
      // 7일 연속 운동 챌린지
      Challenge(
        id: 'consecutive_7_days',
        title: '7일 연속 운동',
        description: '7일 동안 연속으로 운동하기',
        detailedDescription: '하루도 빠짐없이 7일 동안 연속으로 운동을 완료하세요. 매일 최소 1세트 이상 운동해야 합니다.',
        type: ChallengeType.consecutiveDays,
        difficulty: ChallengeDifficulty.medium,
        targetValue: 7,
        targetUnit: '일',
        estimatedDuration: 7,
        rewards: [
          ChallengeReward(
            type: 'badge',
            value: 'consecutive_warrior',
            description: '연속 운동 전사 배지',
          ),
          ChallengeReward(
            type: 'points',
            value: '100',
            description: '100 포인트',
          ),
        ],
        iconPath: 'assets/icons/calendar_check.png',
      ),
      
      // 50개 한번에 챌린지
      Challenge(
        id: 'single_50_pushups',
        title: '50개 한번에',
        description: '한 번의 운동에서 50개 팔굽혀펴기',
        detailedDescription: '쉬지 않고 한 번에 50개의 팔굽혀펴기를 완료하세요. 중간에 멈추면 처음부터 다시 시작해야 합니다.',
        type: ChallengeType.singleSession,
        difficulty: ChallengeDifficulty.hard,
        targetValue: 50,
        targetUnit: '개',
        estimatedDuration: 1,
        rewards: [
          ChallengeReward(
            type: 'badge',
            value: 'power_lifter',
            description: '파워 리프터 배지',
          ),
          ChallengeReward(
            type: 'points',
            value: '150',
            description: '150 포인트',
          ),
        ],
        iconPath: 'assets/icons/muscle.png',
      ),
      
      // 200개 누적 챌린지 (100개 완료 후 해금)
      Challenge(
        id: 'cumulative_200_pushups',
        title: '200개 챌린지',
        description: '총 200개 팔굽혀펴기 달성',
        detailedDescription: '여러 세션에 걸쳐 총 200개의 팔굽혀펴기를 완료하세요. 100개 챌린지를 완료한 후에 도전할 수 있습니다.',
        type: ChallengeType.cumulative,
        difficulty: ChallengeDifficulty.extreme,
        targetValue: 200,
        targetUnit: '개',
        prerequisites: ['cumulative_100_pushups'], // 100개 챌린지 완료 필요
        estimatedDuration: 14,
        rewards: [
          ChallengeReward(
            type: 'badge',
            value: 'ultimate_champion',
            description: '궁극의 챔피언 배지',
          ),
          ChallengeReward(
            type: 'points',
            value: '300',
            description: '300 포인트',
          ),
          ChallengeReward(
            type: 'feature',
            value: 'advanced_stats',
            description: '고급 통계 기능 해금',
          ),
        ],
        iconPath: 'assets/icons/trophy.png',
        status: ChallengeStatus.locked, // 초기에는 잠김
      ),
      
      // 100개 누적 챌린지 (200개 챌린지의 전제 조건)
      Challenge(
        id: 'cumulative_100_pushups',
        title: '100개 챌린지',
        description: '총 100개 팔굽혀펴기 달성',
        detailedDescription: '여러 세션에 걸쳐 총 100개의 팔굽혀펴기를 완료하세요.',
        type: ChallengeType.cumulative,
        difficulty: ChallengeDifficulty.medium,
        targetValue: 100,
        targetUnit: '개',
        estimatedDuration: 7,
        rewards: [
          ChallengeReward(
            type: 'badge',
            value: 'century_club',
            description: '센추리 클럽 배지',
          ),
          ChallengeReward(
            type: 'points',
            value: '200',
            description: '200 포인트',
          ),
        ],
        iconPath: 'assets/icons/star.png',
      ),
      
      // 14일 연속 운동 챌린지 (7일 완료 후 해금)
      Challenge(
        id: 'consecutive_14_days',
        title: '14일 연속 운동',
        description: '14일 동안 연속으로 운동하기',
        detailedDescription: '하루도 빠짐없이 14일 동안 연속으로 운동을 완료하세요. 7일 연속 챌린지를 완료한 후에 도전할 수 있습니다.',
        type: ChallengeType.consecutiveDays,
        difficulty: ChallengeDifficulty.hard,
        targetValue: 14,
        targetUnit: '일',
        prerequisites: ['consecutive_7_days'],
        estimatedDuration: 14,
        rewards: [
          ChallengeReward(
            type: 'badge',
            value: 'dedication_master',
            description: '헌신의 마스터 배지',
          ),
          ChallengeReward(
            type: 'points',
            value: '250',
            description: '250 포인트',
          ),
        ],
        iconPath: 'assets/icons/calendar_star.png',
        status: ChallengeStatus.locked,
      ),
    ];
  }

  /// 사용자에게 사용 가능한 챌린지 목록 반환
  Future<List<Challenge>> getAvailableChallenges(UserProfile userProfile) async {
    await _updateChallengeAvailability(userProfile);
    return _availableChallenges.where((challenge) => 
      challenge.status == ChallengeStatus.available || 
      challenge.status == ChallengeStatus.active
    ).toList();
  }

  /// 활성 챌린지 목록 반환
  List<Challenge> getActiveChallenges() {
    return _activeChallenges;
  }

  /// 완료된 챌린지 목록 반환
  List<Challenge> getCompletedChallenges() {
    return _completedChallenges;
  }

  /// 특정 챌린지 조회
  Challenge? getChallengeById(String challengeId) {
    // 모든 챌린지 목록에서 검색
    for (final challenge in [..._availableChallenges, ..._activeChallenges, ..._completedChallenges]) {
      if (challenge.id == challengeId) {
        return challenge;
      }
    }
    return null;
  }

  /// 챌린지 시작
  Future<bool> startChallenge(String challengeId) async {
    final challenge = getChallengeById(challengeId);
    if (challenge == null || !challenge.isAvailable) {
      return false;
    }

    // 이미 활성 상태인 동일한 타입의 챌린지가 있는지 확인
    final existingActiveChallenge = _activeChallenges.where(
      (c) => c.type == challenge.type,
    ).firstOrNull;

    if (existingActiveChallenge != null) {
      return false; // 이미 활성 챌린지가 있음
    }

    // 챌린지를 활성 목록으로 이동
    _availableChallenges.removeWhere((c) => c.id == challengeId);
    
    final activeChallenge = challenge.copyWith(
      status: ChallengeStatus.active,
      startedAt: DateTime.now(),
      currentProgress: 0,
    );
    
    _activeChallenges.add(activeChallenge);
    await _saveChallenges();

    // 알림 스케줄링
    await _scheduleProgressReminders(activeChallenge);

    return true;
  }

  /// 챌린지 진행률 업데이트
  Future<void> updateChallengeProgress(String challengeId, int progress) async {
    final challengeIndex = _activeChallenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex == -1) return;

    final challenge = _activeChallenges[challengeIndex];
    final updatedChallenge = challenge.copyWith(
      currentProgress: progress,
      lastUpdatedAt: DateTime.now(),
    );

    _activeChallenges[challengeIndex] = updatedChallenge;

    // 완료 체크
    if (updatedChallenge.isCompleted) {
      await _completeChallenge(challengeId);
    } else {
      await _saveChallenges();
    }
  }

  /// 챌린지 완료 처리
  Future<void> _completeChallenge(String challengeId) async {
    final challengeIndex = _activeChallenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex == -1) return;

    final challenge = _activeChallenges[challengeIndex];
    final completedChallenge = challenge.copyWith(
      status: ChallengeStatus.completed,
      completedAt: DateTime.now(),
    );

    // 활성 목록에서 제거하고 완료 목록에 추가
    _activeChallenges.removeAt(challengeIndex);
    _completedChallenges.add(completedChallenge);

    // 보상 지급
    await _grantRewards(completedChallenge);

    // 잠긴 챌린지 해제 확인
    await _unlockDependentChallenges(challengeId);

    await _saveChallenges();

    // 완료 알림
    await _notificationService.showChallengeCompletedNotification(
      completedChallenge.title,
      completedChallenge.description,
    );
  }

  /// 챌린지 포기
  Future<bool> abandonChallenge(String challengeId) async {
    final challengeIndex = _activeChallenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex == -1) return false;

    final challenge = _activeChallenges[challengeIndex];
    
    // 활성 목록에서 제거하고 사용 가능 목록으로 되돌림
    _activeChallenges.removeAt(challengeIndex);
    
    final resetChallenge = challenge.copyWith(
      status: ChallengeStatus.available,
      currentProgress: 0,
      startedAt: null,
      lastUpdatedAt: null,
    );
    
    _availableChallenges.add(resetChallenge);
    await _saveChallenges();

    return true;
  }

  /// 운동 완료 시 챌린지 업데이트
  Future<void> updateChallengesOnWorkoutComplete(int repsCompleted, int setsCompleted) async {
    for (final challenge in _activeChallenges) {
      switch (challenge.type) {
        case ChallengeType.consecutiveDays:
          await _updateConsecutiveDaysChallenge(challenge.id);
          break;
        case ChallengeType.singleSession:
          if (repsCompleted >= challenge.targetValue) {
            await updateChallengeProgress(challenge.id, challenge.targetValue);
          }
          break;
        case ChallengeType.cumulative:
          final newProgress = challenge.currentProgress + repsCompleted;
          await updateChallengeProgress(challenge.id, newProgress);
          break;
      }
    }
  }

  /// 연속 일수 챌린지 특별 업데이트
  Future<void> _updateConsecutiveDaysChallenge(String challengeId) async {
    final challengeIndex = _activeChallenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex == -1) return;

    final challenge = _activeChallenges[challengeIndex];
    final today = DateTime.now();
    final lastUpdate = challenge.lastUpdatedAt;

    // 오늘 이미 업데이트했는지 확인
    if (lastUpdate != null && 
        lastUpdate.year == today.year &&
        lastUpdate.month == today.month &&
        lastUpdate.day == today.day) {
      return; // 오늘 이미 업데이트됨
    }

    // 연속성 확인
    if (lastUpdate != null) {
      final daysDifference = today.difference(lastUpdate).inDays;
      if (daysDifference > 1) {
        // 연속성이 깨짐 - 챌린지 실패
        await failChallenge(challengeId);
        return;
      }
    }

    // 진행률 업데이트
    final newProgress = challenge.currentProgress + 1;
    await updateChallengeProgress(challengeId, newProgress);
  }

  /// 챌린지 실패 처리
  Future<void> failChallenge(String challengeId) async {
    final challengeIndex = _activeChallenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex == -1) return;

    final challenge = _activeChallenges[challengeIndex];
    
    // 활성 목록에서 제거하고 사용 가능 목록으로 되돌림
    _activeChallenges.removeAt(challengeIndex);
    
    final resetChallenge = challenge.copyWith(
      status: ChallengeStatus.available,
      currentProgress: 0,
      startedAt: null,
      lastUpdatedAt: null,
    );
    
    _availableChallenges.add(resetChallenge);
    await _saveChallenges();

    // 실패 알림
    await _notificationService.showChallengeFailedNotification(
      challenge.title,
      challenge.description,
    );
  }

  /// 챌린지 재시작
  Future<bool> restartChallenge(String challengeId) async {
    return await startChallenge(challengeId);
  }

  /// 단일 세션 챌린지 최고 기록 조회
  Future<int> getSingleSessionBestRecord() async {
    // 데이터베이스에서 최고 기록 조회
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('single_session_best_record') ?? 0;
  }

  /// 누적 챌린지 진행률 조회
  Future<int> getCumulativeProgress() async {
    // 데이터베이스에서 총 운동 횟수 조회
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('total_pushups_completed') ?? 0;
  }

  /// 연속 일수 챌린지 스트릭 조회
  Future<int> getConsecutiveDaysProgress() async {
    // 스트릭 서비스에서 현재 스트릭 조회
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('current_streak') ?? 0;
  }

  /// 오늘의 챌린지 상태 요약
  Map<String, dynamic> getTodayChallengesSummary() {
    final activeChallenges = _activeChallenges;
    final summary = <String, dynamic>{
      'total_active': activeChallenges.length,
      'consecutive_days': 0,
      'single_session': 0,
      'cumulative': 0,
    };

    for (final challenge in activeChallenges) {
      switch (challenge.type) {
        case ChallengeType.consecutiveDays:
          summary['consecutive_days']++;
          break;
        case ChallengeType.singleSession:
          summary['single_session']++;
          break;
        case ChallengeType.cumulative:
          summary['cumulative']++;
          break;
      }
    }

    return summary;
  }

  /// 챌린지 힌트 및 팁 제공
  String getChallengeHint(ChallengeType type) {
    switch (type) {
      case ChallengeType.consecutiveDays:
        return '매일 꾸준히 운동하여 연속 기록을 유지하세요!';
      case ChallengeType.singleSession:
        return '한 번에 목표 개수를 달성하기 위해 충분히 준비하고 도전하세요!';
      case ChallengeType.cumulative:
        return '꾸준히 운동하여 누적 목표를 달성하세요!';
    }
  }

  /// 보상 지급
  Future<void> _grantRewards(Challenge challenge) async {
    for (final reward in challenge.rewards) {
      switch (reward.type) {
        case 'badge':
          // 배지 업적 해제
          await AchievementService.markChallengeCompleted(challenge.id);
          break;
        case 'points':
          // 포인트 지급 (향후 구현)
          break;
        case 'feature':
          // 기능 해제 (향후 구현)
          break;
      }
    }
  }

  /// 종속 챌린지 해제
  Future<void> _unlockDependentChallenges(String completedChallengeId) async {
    for (int i = 0; i < _availableChallenges.length; i++) {
      final challenge = _availableChallenges[i];
      if (challenge.status == ChallengeStatus.locked &&
          challenge.prerequisites.contains(completedChallengeId)) {
        
        // 모든 전제 조건이 충족되었는지 확인
        final allPrerequisitesMet = challenge.prerequisites.every(
          (prereq) => _completedChallenges.any((c) => c.id == prereq)
        );

        if (allPrerequisitesMet) {
          _availableChallenges[i] = challenge.copyWith(
            status: ChallengeStatus.available,
          );
        }
      }
    }
  }

  /// 챌린지 가용성 업데이트
  Future<void> _updateChallengeAvailability(UserProfile userProfile) async {
    // 사용자 프로필에 따른 챌린지 가용성 업데이트 로직
    // 현재는 기본 구현
  }

  /// 진행률 리마인더 스케줄링
  Future<void> _scheduleProgressReminders(Challenge challenge) async {
    // 챌린지 타입에 따른 리마인더 스케줄링
    switch (challenge.type) {
      case ChallengeType.consecutiveDays:
        await _notificationService.scheduleDailyReminder(
          challenge.title,
          '오늘도 운동을 완료하여 연속 기록을 유지하세요!',
        );
        break;
      case ChallengeType.singleSession:
      case ChallengeType.cumulative:
        // 필요시 구현
        break;
    }
  }

  /// 챌린지 데이터 저장
  Future<void> _saveChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    
    final availableJson = _availableChallenges.map((c) => c.toMap()).toList();
    final activeJson = _activeChallenges.map((c) => c.toMap()).toList();
    final completedJson = _completedChallenges.map((c) => c.toMap()).toList();
    
    await prefs.setString(_availableChallengesKey, jsonEncode(availableJson));
    await prefs.setString(_activeChallengesKey, jsonEncode(activeJson));
    await prefs.setString(_completedChallengesKey, jsonEncode(completedJson));
  }

  /// 챌린지 데이터 로드
  Future<void> _loadChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    
    final availableJson = prefs.getString(_availableChallengesKey);
    final activeJson = prefs.getString(_activeChallengesKey);
    final completedJson = prefs.getString(_completedChallengesKey);
    
    if (availableJson != null) {
      final List<dynamic> availableList = jsonDecode(availableJson) as List<dynamic>;
      _availableChallenges = availableList.map((json) => Challenge.fromMap(json as Map<String, dynamic>)).toList();
    }
    
    if (activeJson != null) {
      final List<dynamic> activeList = jsonDecode(activeJson) as List<dynamic>;
      _activeChallenges = activeList.map((json) => Challenge.fromMap(json as Map<String, dynamic>)).toList();
    }
    
    if (completedJson != null) {
      final List<dynamic> completedList = jsonDecode(completedJson) as List<dynamic>;
      _completedChallenges = completedList.map((json) => Challenge.fromMap(json as Map<String, dynamic>)).toList();
    }
  }
} 