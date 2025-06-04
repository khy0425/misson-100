import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/challenge.dart';
import '../models/user_profile.dart';
import 'achievement_service.dart';
import '../services/notification_service.dart';

/// 챌린지 관리 서비스
class ChallengeService {
  static final ChallengeService _instance = ChallengeService._internal();
  factory ChallengeService() => _instance;
  ChallengeService._internal();

  List<Challenge> _activeChallenges = [];
  List<Challenge> _completedChallenges = [];
  List<Challenge> _allChallenges = [];
  final String _activeChallengesKey = 'active_challenges';
  final String _completedChallengesKey = 'completed_challenges';

  /// 서비스 초기화
  Future<void> initialize() async {
    await _loadChallengesFromStorage();
    _initializeDefaultChallenges();
    debugPrint('ChallengeService 초기화 완료');
  }

  /// 기본 챌린지들 초기화
  void _initializeDefaultChallenges() {
    if (_allChallenges.isEmpty) {
      _allChallenges = [
        Challenge(
          id: 'cumulative_100_pushups',
          titleKey: 'cumulative_100_pushups_title',
          descriptionKey: 'cumulative_100_pushups_desc',
          difficultyKey: 'medium',
          duration: 30,
          targetCount: 100,
          milestones: [],
          rewardKey: 'cumulative_100_pushups_reward',
          isActive: false,
          currentProgress: 0,
          title: '100개 푸시업 도전',
          description: '총 100개의 푸시업을 완성하세요',
          type: ChallengeType.cumulative,
          targetValue: 100,
          status: ChallengeStatus.available,
          lastUpdatedAt: DateTime.now(),
        ),
        Challenge(
          id: 'cumulative_200_pushups',
          titleKey: 'cumulative_200_pushups_title',
          descriptionKey: 'cumulative_200_pushups_desc',
          difficultyKey: 'hard',
          duration: 60,
          targetCount: 200,
          milestones: [],
          rewardKey: 'cumulative_200_pushups_reward',
          isActive: false,
          currentProgress: 0,
          title: '200개 푸시업 도전',
          description: '총 200개의 푸시업을 완성하세요',
          type: ChallengeType.cumulative,
          targetValue: 200,
          status: ChallengeStatus.locked,
          lastUpdatedAt: DateTime.now(),
          prerequisites: ['cumulative_100_pushups'],
        ),
        Challenge(
          id: 'consecutive_7_days',
          titleKey: 'consecutive_7_days_title',
          descriptionKey: 'consecutive_7_days_desc',
          difficultyKey: 'medium',
          duration: 7,
          targetCount: 7,
          milestones: [],
          rewardKey: 'consecutive_7_days_reward',
          isActive: false,
          currentProgress: 0,
          title: '7일 연속 운동',
          description: '7일 연속으로 운동하세요',
          type: ChallengeType.consecutiveDays,
          targetValue: 7,
          status: ChallengeStatus.available,
          lastUpdatedAt: DateTime.now(),
        ),
        Challenge(
          id: 'consecutive_14_days',
          titleKey: 'consecutive_14_days_title',
          descriptionKey: 'consecutive_14_days_desc',
          difficultyKey: 'hard',
          duration: 14,
          targetCount: 14,
          milestones: [],
          rewardKey: 'consecutive_14_days_reward',
          isActive: false,
          currentProgress: 0,
          title: '14일 연속 운동',
          description: '14일 연속으로 운동하세요',
          type: ChallengeType.consecutiveDays,
          targetValue: 14,
          status: ChallengeStatus.locked,
          lastUpdatedAt: DateTime.now(),
          prerequisites: ['consecutive_7_days'],
        ),
        Challenge(
          id: 'single_50_pushups',
          titleKey: 'single_50_pushups_title',
          descriptionKey: 'single_50_pushups_desc',
          difficultyKey: 'medium',
          duration: 1,
          targetCount: 50,
          milestones: [],
          rewardKey: 'single_50_pushups_reward',
          isActive: false,
          currentProgress: 0,
          title: '한 번에 50개 푸시업',
          description: '한 세션에서 50개 푸시업을 달성하세요',
          type: ChallengeType.singleSession,
          targetValue: 50,
          status: ChallengeStatus.available,
          lastUpdatedAt: DateTime.now(),
        ),
      ];
    }
  }

  /// 저장소에서 챌린지 로드
  Future<void> _loadChallengesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 활성 챌린지 로드
      final activeData = prefs.getString(_activeChallengesKey);
      if (activeData != null) {
        final activeJson = jsonDecode(activeData) as List<dynamic>;
        _activeChallenges = activeJson.map((json) => Challenge.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      // 완료된 챌린지 로드
      final completedData = prefs.getString(_completedChallengesKey);
      if (completedData != null) {
        final completedJson = jsonDecode(completedData) as List<dynamic>;
        _completedChallenges = completedJson.map((json) => Challenge.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('챌린지 로드 오류: $e');
    }
  }

  /// 저장소에 챌린지 저장
  Future<void> _saveChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 활성 챌린지 저장
      final activeJson = _activeChallenges.map((c) => c.toJson()).toList();
      await prefs.setString(_activeChallengesKey, jsonEncode(activeJson));
      
      // 완료된 챌린지 저장
      final completedJson = _completedChallenges.map((c) => c.toJson()).toList();
      await prefs.setString(_completedChallengesKey, jsonEncode(completedJson));
    } catch (e) {
      debugPrint('챌린지 저장 오류: $e');
    }
  }

  /// 사용자에게 사용 가능한 챌린지 목록 반환
  Future<List<Challenge>> getAvailableChallenges(UserProfile userProfile) async {
    _unlockChallenges();
    return _allChallenges.where((c) => 
      c.status == ChallengeStatus.available || 
      c.status == ChallengeStatus.active
    ).toList();
  }

  /// 의존성 기반 챌린지 해제
  void _unlockChallenges() {
    for (int i = 0; i < _allChallenges.length; i++) {
      final challenge = _allChallenges[i];
      if (challenge.status == ChallengeStatus.locked && challenge.prerequisites != null) {
        final allDepsCompleted = challenge.prerequisites!.every((depId) =>
          _completedChallenges.any((c) => c.id == depId)
        );
        if (allDepsCompleted) {
          _allChallenges[i] = challenge.copyWith(status: ChallengeStatus.available);
        }
      }
    }
  }

  /// 활성 챌린지 목록 반환
  List<Challenge> getActiveChallenges() {
    return List.from(_activeChallenges);
  }

  /// 완료된 챌린지 목록 반환
  List<Challenge> getCompletedChallenges() {
    return List.from(_completedChallenges);
  }

  /// 특정 챌린지 조회
  Challenge? getChallengeById(String challengeId) {
    for (final challenge in _allChallenges) {
      if (challenge.id == challengeId) return challenge;
    }
    for (final challenge in _activeChallenges) {
      if (challenge.id == challengeId) return challenge;
    }
    for (final challenge in _completedChallenges) {
      if (challenge.id == challengeId) return challenge;
    }
    return null;
  }

  /// 챌린지 힌트 반환
  String getChallengeHint(ChallengeType type) {
    switch (type) {
      case ChallengeType.cumulative:
        return '누적 방식 챌린지입니다. 여러 세션에 걸쳐 목표를 달성하세요.';
      case ChallengeType.consecutiveDays:
        return '연속 일수 챌린지입니다. 매일 운동하여 연속 기록을 유지하세요.';
      case ChallengeType.singleSession:
        return '한 번의 운동으로 목표를 달성해야 하는 챌린지입니다.';
      default:
        return '챌린지를 완료하여 보상을 획득하세요!';
    }
  }

  /// 운동 완료시 챌린지 진행도 업데이트
  Future<void> updateProgressAfterWorkout(int repsCompleted, DateTime workoutDate) async {
    await updateChallengesOnWorkoutComplete(repsCompleted, 1);
  }

  /// 모든 챌린지 다시 로드
  Future<void> reloadChallenges() async {
    await _loadChallengesFromStorage();
    _unlockChallenges();
  }

  /// 챌린지 참여 시작
  Future<bool> startChallenge(String challengeId) async {
    final challengeIndex = _allChallenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex == -1) return false;
    
    final challenge = _allChallenges[challengeIndex];
    if (challenge.status != ChallengeStatus.available) {
      return false;
    }

    // 이미 활성 목록에 있는지 확인
    if (_activeChallenges.any((c) => c.id == challengeId)) {
      return false;
    }

    // 활성 목록에 추가 - copyWith 사용
    final activeChallenge = challenge.copyWith(
      status: ChallengeStatus.active,
      startDate: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
      currentProgress: 0,
    );

    _activeChallenges.add(activeChallenge);
    _allChallenges[challengeIndex] = challenge.copyWith(status: ChallengeStatus.active);
    
    await _saveChallenges();
    return true;
  }

  /// 챌린지 포기
  Future<bool> quitChallenge(String challengeId) async {
    return await abandonChallenge(challengeId);
  }

  /// 챌린지 진행도 업데이트 (int 버전)
  Future<void> updateChallengeProgress(String challengeId, int progress) async {
    final challengeIndex = _activeChallenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex != -1) {
      final challenge = _activeChallenges[challengeIndex];
      final updatedChallenge = challenge.copyWith(
        currentProgress: progress,
        lastUpdatedAt: DateTime.now(),
      );
      _activeChallenges[challengeIndex] = updatedChallenge;
      
      // 완료 체크
      if (updatedChallenge.currentProgress >= (updatedChallenge.targetValue ?? updatedChallenge.targetCount)) {
        _completeChallengeAt(challengeIndex);
      }
      
      await _saveChallenges();
    }
  }

  /// 챌린지 완료 처리
  void _completeChallengeAt(int index) {
    final challenge = _activeChallenges[index];
    final completedChallenge = challenge.copyWith(
      status: ChallengeStatus.completed,
      completionDate: DateTime.now(),
      endDate: DateTime.now(),
    );
    
    _completedChallenges.add(completedChallenge);
    _activeChallenges.removeAt(index);
    
    // 전체 목록에서도 상태 업데이트
    final allChallengeIndex = _allChallenges.indexWhere((c) => c.id == completedChallenge.id);
    if (allChallengeIndex != -1) {
      _allChallenges[allChallengeIndex] = _allChallenges[allChallengeIndex].copyWith(
        status: ChallengeStatus.completed,
      );
    }
  }

  /// 운동 완료 시 챌린지 업데이트 (수정된 서명)
  Future<List<Challenge>> updateChallengesOnWorkoutComplete(int repsCompleted, int sessionsCompleted) async {
    final updatedChallenges = <Challenge>[];
    
    for (int i = _activeChallenges.length - 1; i >= 0; i--) {
      final challenge = _activeChallenges[i];
      bool updated = false;
      int newProgress = challenge.currentProgress;
      
      switch (challenge.type) {
        case ChallengeType.cumulative:
          newProgress += repsCompleted;
          updated = true;
          break;
          
        case ChallengeType.consecutiveDays:
          final today = DateTime.now();
          final lastUpdate = challenge.lastUpdatedAt;
          
          // 오늘 이미 업데이트했는지 확인
          if (lastUpdate == null || !_isSameDay(today, lastUpdate)) {
            newProgress += 1;
            updated = true;
          }
          break;
          
        case ChallengeType.singleSession:
          final targetValue = challenge.targetValue ?? challenge.targetCount;
          if (repsCompleted >= targetValue) {
            newProgress = repsCompleted;
            updated = true;
          }
          break;
          
        default:
          break;
      }
      
      if (updated) {
        final updatedChallenge = challenge.copyWith(
          currentProgress: newProgress,
          lastUpdatedAt: DateTime.now(),
        );
        _activeChallenges[i] = updatedChallenge;
        updatedChallenges.add(updatedChallenge);
        
        // 완료 체크
        final targetValue = updatedChallenge.targetValue ?? updatedChallenge.targetCount;
        if (updatedChallenge.currentProgress >= targetValue) {
          _completeChallengeAt(i);
        }
      }
    }
    
    await _saveChallenges();
    return updatedChallenges;
  }

  /// 같은 날인지 확인
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 챌린지 포기 (abandon)
  Future<bool> abandonChallenge(String challengeId) async {
    final challengeIndex = _activeChallenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex == -1) return false;
    
    _activeChallenges.removeAt(challengeIndex);
    
    // 전체 목록에서 상태를 다시 available로 변경
    final allChallengeIndex = _allChallenges.indexWhere((c) => c.id == challengeId);
    if (allChallengeIndex != -1) {
      _allChallenges[allChallengeIndex] = _allChallenges[allChallengeIndex].copyWith(
        status: ChallengeStatus.available,
        currentProgress: 0,
        startDate: null,
      );
    }
    
    await _saveChallenges();
    return true;
  }

  /// 챌린지 실패 처리
  Future<void> failChallenge(String challengeId) async {
    await abandonChallenge(challengeId);
  }

  /// 오늘의 챌린지 요약
  Future<Map<String, dynamic>> getTodayChallengesSummary() async {
    return {
      'activeCount': _activeChallenges.length,
      'completedToday': _completedChallenges.where((c) =>
        c.completionDate != null && _isSameDay(c.completionDate!, DateTime.now())
      ).length,
      'totalCompleted': _completedChallenges.length,
    };
  }

  /// 서비스 정리
  void dispose() {
    _activeChallenges.clear();
    _completedChallenges.clear();
    _allChallenges.clear();
  }
} 