import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../generated/app_localizations.dart';
import '../utils/constants.dart';
import '../services/ad_service.dart';
import '../models/user_profile.dart';
import '../services/workout_program_service.dart';
import '../services/workout_history_service.dart';
import '../models/workout_history.dart';
import '../services/achievement_service.dart';
import '../services/social_share_service.dart';
import '../services/motivational_message_service.dart';
import '../services/streak_service.dart';
import '../services/challenge_service.dart';
import '../widgets/ad_banner_widget.dart';
import '../services/notification_service.dart';
import '../services/database_service.dart';
import '../models/workout_session.dart';


class WorkoutScreen extends StatefulWidget {
  final UserProfile userProfile;
  final TodayWorkout workoutData;
  final bool isResuming;
  final Map<String, dynamic>? resumptionData;

  const WorkoutScreen({
    super.key,
    required this.userProfile,
    required this.workoutData,
    this.isResuming = false,
    this.resumptionData,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // 워크아웃 상태
  int _currentSet = 0;
  int _currentReps = 0;
  List<int> _completedReps = [];
  bool _isSetCompleted = false;
  bool _isRestTime = false;
  int _restTimeRemaining = 0;
  Timer? _restTimer;
  
  // 세션 관리
  String? _sessionId;
  bool _isRecoveredSession = false;

  // 스크롤 컨트롤러
  late ScrollController _scrollController;

  // 워크아웃 데이터
  late List<int> _targetReps;
  late int _restTimeSeconds;

  // 동기부여 메시지 서비스
  final MotivationalMessageService _messageService = MotivationalMessageService();
  final StreakService _streakService = StreakService();
  String _currentMotivationalMessage = '';
  bool _showMotivationalMessage = false;

  // 워크아웃 프로그램 서비스
  final WorkoutProgramService _workoutProgramService = WorkoutProgramService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _initializeWorkout();
    _initializeSession();
    _showWorkoutStartMessage();
  }

  void _initializeWorkout() {
    _targetReps = widget.workoutData.workout;
    _restTimeSeconds = widget.workoutData.restTimeSeconds;
    _completedReps = List.filled(_targetReps.length, 0);
  }
  
  /// 세션 초기화 (복구 또는 새 세션 시작)
  void _initializeSession() async {
    try {
      debugPrint('🔄 세션 초기화 시작 (재개 모드: ${widget.isResuming})');
      
      if (widget.isResuming && widget.resumptionData != null) {
        // 재개 모드: 전달받은 데이터로 복원
        await _resumeFromData(widget.resumptionData!);
      } else {
        // 일반 모드: 미완료 세션 확인 후 새 세션 시작
        final incompleteSession = await WorkoutHistoryService.recoverIncompleteSession();
        
        if (incompleteSession != null) {
          // 미완료 세션 복구
          await _recoverSession(incompleteSession);
        } else {
          // 새 세션 시작
          await _startNewSession();
        }
      }
      
    } catch (e) {
      debugPrint('❌ 세션 초기화 오류: $e');
      // 오류 발생 시 기본 새 세션 시작
      await _startNewSession();
    }
  }
  
  /// 미완료 세션 복구
  Future<void> _recoverSession(Map<String, dynamic> sessionData) async {
    try {
      debugPrint('🔄 미완료 세션 복구 시작');
      
      _sessionId = sessionData['id'] as String;
      _isRecoveredSession = true;
      
      // 세션 데이터에서 진행 상황 복구
      final completedRepsStr = sessionData['completedReps'] as String;
      final completedRepsList = completedRepsStr.split(',').map(int.parse).toList();
      final currentSet = sessionData['currentSet'] as int;
      
      setState(() {
        _completedReps = completedRepsList;
        _currentSet = currentSet;
        _currentReps = 0;
        _isSetCompleted = false;
        _isRestTime = false;
      });
      
      debugPrint('✅ 세션 복구 완료: $_sessionId (세트 ${currentSet + 1}/${_totalSets})');
      
      // 복구 메시지 표시
      setState(() {
        _currentMotivationalMessage = '💪 이전 운동을 이어서 계속하겠습니다!';
        _showMotivationalMessage = true;
      });
      
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showMotivationalMessage = false;
          });
        }
      });
      
    } catch (e) {
      debugPrint('❌ 세션 복구 오류: $e');
      // 복구 실패 시 새 세션 시작
      await _startNewSession();
    }
  }
  
  /// 새 세션 시작
  Future<void> _startNewSession() async {
    try {
      debugPrint('🆕 새 세션 시작');
      
      _sessionId = await WorkoutHistoryService.startWorkoutSession(
        workoutTitle: widget.workoutData.title,
        targetReps: _targetReps,
        totalSets: _totalSets,
        level: widget.userProfile.level.toString(),
      );
      
      _isRecoveredSession = false;
      
      debugPrint('✅ 새 세션 생성 완료: $_sessionId');
      
    } catch (e) {
      debugPrint('❌ 새 세션 생성 오류: $e');
      // 세션 ID 없이도 진행할 수 있도록 함
      _sessionId = null;
    }
  }

  /// 재개 데이터에서 운동 상태 복원
  Future<void> _resumeFromData(Map<String, dynamic> resumptionData) async {
    try {
      debugPrint('🔄 재개 데이터로부터 상태 복원 시작');
      
      // 세션 ID 설정
      _sessionId = resumptionData['sessionId'] as String?;
      _isRecoveredSession = true;
      
      // 운동 상태 복원
      final completedRepsStr = resumptionData['completedReps'] as String? ?? '';
      final completedReps = completedRepsStr.isNotEmpty 
          ? completedRepsStr.split(',').map(int.parse).toList()
          : List.filled(_targetReps.length, 0);
      
      final currentSet = resumptionData['currentSet'] as int? ?? 0;
      final currentReps = resumptionData['currentReps'] as int? ?? 0;
      
      setState(() {
        _completedReps = [...completedReps];
        _currentSet = currentSet;
        _currentReps = currentReps;
        _isSetCompleted = false;
        _isRestTime = false;
      });
      
      debugPrint('✅ 재개 데이터 복원 완료: 세트 ${currentSet + 1}/${_totalSets}, 완료된 운동: ${completedReps}');
      
      // 재개 메시지 표시
      setState(() {
        _currentMotivationalMessage = '💪 저장된 운동을 이어서 계속하겠습니다!';
        _showMotivationalMessage = true;
      });
      
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showMotivationalMessage = false;
          });
        }
      });
      
    } catch (e) {
      debugPrint('❌ 재개 데이터 복원 오류: $e');
      // 복원 실패 시 새 세션 시작
      await _startNewSession();
    }
  }

  void _showWorkoutStartMessage() {
    final message = _messageService.getWorkoutStartMessage(
      userLevel: widget.userProfile.level.levelValue,
    );
    
    setState(() {
      _currentMotivationalMessage = message;
      _showMotivationalMessage = true;
    });

    // 3초 후 메시지 숨기기
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showMotivationalMessage = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  /// 앱 수명 주기 상태 변화 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint('📱 앱 상태 변화: $state');
    
    switch (state) {
      case AppLifecycleState.paused:
        // 앱이 백그라운드로 갈 때 현재 상태 백업
        _handleAppPaused();
        break;
        
      case AppLifecycleState.detached:
        // 앱이 종료될 때 긴급 데이터 저장
        _handleAppDetached();
        break;
        
      case AppLifecycleState.resumed:
        // 앱이 다시 활성화될 때 필요시 복원
        _handleAppResumed();
        break;
        
      case AppLifecycleState.inactive:
        // 일시적으로 비활성화 (전화 수신 등)
        debugPrint('📱 앱 일시 비활성화');
        break;
        
      case AppLifecycleState.hidden:
        // 앱이 숨겨짐 (iOS)
        debugPrint('📱 앱 숨김');
        break;
    }
  }
  
  /// 앱이 백그라운드로 갈 때 처리
  void _handleAppPaused() async {
    debugPrint('⏸️ 앱 백그라운드 진입 - 현재 상태 백업');
    
    try {
      // 현재 진행 중인 세션 상태 백업
      await _backupCurrentSessionState();
      
      // SharedPreferences에 현재 상태 저장
      await _saveStateToSharedPreferences();
      
      debugPrint('✅ 백그라운드 백업 완료');
      
    } catch (e) {
      debugPrint('❌ 백그라운드 백업 오류: $e');
    }
  }
  
  /// 앱이 종료될 때 처리
  void _handleAppDetached() async {
    debugPrint('🚪 앱 종료 감지 - 긴급 데이터 저장');
    
    try {
      // 긴급 데이터 저장
      await _saveEmergencyData();
      
      debugPrint('✅ 긴급 데이터 저장 완료');
      
    } catch (e) {
      debugPrint('❌ 긴급 데이터 저장 오류: $e');
    }
  }
  
  /// 앱이 다시 활성화될 때 처리
  void _handleAppResumed() async {
    debugPrint('▶️ 앱 재활성화');
    
    try {
      // 필요시 백업된 상태 복원 확인
      await _checkBackupRestoration();
      
    } catch (e) {
      debugPrint('❌ 복원 확인 오류: $e');
    }
  }

  // 현재 세트의 목표 횟수
  int get _currentTargetReps => _targetReps[_currentSet];

  // 전체 세트 수
  int get _totalSets => _targetReps.length;

  // 전체 진행률
  double get _overallProgress =>
      (_currentSet + (_currentReps / _currentTargetReps)) / _totalSets;

  void _markSetCompleted() {
    // 즉시 UI 업데이트 및 피드백
    HapticFeedback.heavyImpact();

    setState(() {
      _isSetCompleted = true;
      _completedReps[_currentSet] = _currentReps;
    });

    // 즉시 데이터베이스에 세트 진행 상황 저장
    _saveSetProgressImmediately();

    // 세트 완료 동기부여 메시지 표시
    final message = _messageService.getSetCompletionMessage(
      userLevel: widget.userProfile.level.levelValue,
    );
    
    setState(() {
      _currentMotivationalMessage = message;
      _showMotivationalMessage = true;
    });

    // 2초 후 메시지 숨기기
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showMotivationalMessage = false;
        });
      }
    });

    // 약간의 지연 후 다음 단계 진행
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      // 마지막 세트가 아니면 휴식 시간 시작
      if (_currentSet < _totalSets - 1) {
        _startRestTimer();
      } else {
        _completeWorkout();
      }
    });
  }
  
  /// 세트 진행 상황 즉시 저장
  Future<void> _saveSetProgressImmediately() async {
    if (_sessionId == null) {
      debugPrint('⚠️ 세션 ID가 없어 즉시 저장을 건너뜁니다');
      return;
    }
    
    try {
      await WorkoutHistoryService.saveSetProgress(
        sessionId: _sessionId!,
        setIndex: _currentSet,
        completedReps: _currentReps,
        currentSet: _currentSet + 1,
      );
      
      debugPrint('💾 세트 ${_currentSet + 1} 즉시 저장 성공: $_currentReps회');
      
    } catch (e) {
      debugPrint('❌ 세트 즉시 저장 오류: $e');
      // 저장 실패해도 운동은 계속 진행
    }
  }

  void _startRestTimer() {
    setState(() {
      _isRestTime = true;
      _restTimeRemaining = _restTimeSeconds;
    });

    _restTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _restTimeRemaining--;
      });

      if (_restTimeRemaining <= 0) {
        timer.cancel();
        _moveToNextSet();
      } else if (_restTimeRemaining <= 3) {
        HapticFeedback.heavyImpact(); // 마지막 3초 알림
      }
    });
  }

  void _moveToNextSet() {
    setState(() {
      _isRestTime = false;
      _currentSet++;
      _currentReps = 0;
      _isSetCompleted = false;
    });
    HapticFeedback.mediumImpact();
  }

  void _completeWorkout() async {
    // 워크아웃 완료 처리 (데이터베이스 저장)
    HapticFeedback.heavyImpact();

    // 세션 완료 처리 (즉시 저장된 데이터 기반)
    if (_sessionId != null) {
      try {
        await WorkoutHistoryService.completeWorkoutSession(_sessionId!);
        debugPrint('✅ 세션 완료 처리 성공: $_sessionId');
      } catch (e) {
        debugPrint('❌ 세션 완료 처리 오류: $e');
        // 오류가 있어도 기존 방식으로 계속 진행
      }
    }

    // 운동 완료 동기부여 메시지 표시
    final message = _messageService.getWorkoutCompletionMessage(
      userLevel: widget.userProfile.level.levelValue,
    );
    
    setState(() {
      _currentMotivationalMessage = message;
      _showMotivationalMessage = true;
    });

    try {
      // 세션 기반 저장이 실패했거나 세션 ID가 없는 경우를 위한 백업 저장
      if (_sessionId == null || !_isRecoveredSession) {
        await _saveWorkoutHistoryBackup();
      }

      // 완료된 총 횟수 계산
      final totalCompletedReps = _completedReps.fold(
        0,
        (sum, reps) => sum + reps,
      );
      final completionRate = totalCompletedReps / widget.workoutData.totalReps;

      // 운동 기록 생성
      final workoutHistory = WorkoutHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        workoutTitle: widget.workoutData.title,
        targetReps: _targetReps,
        completedReps: _completedReps,
        totalReps: totalCompletedReps,
        completionRate: completionRate,
        level: widget.userProfile.level.toString(),
      );

      // 데이터베이스에 저장
      await WorkoutHistoryService.saveWorkoutHistory(workoutHistory);
      debugPrint('운동 기록 저장 완료: ${workoutHistory.id}');

      // 워크아웃 세션 업데이트 (오늘의 운동 세션을 직접 가져와서 업데이트)
      try {
        final databaseService = DatabaseService();
        
        // 먼저 오늘의 워크아웃 세션을 가져오기
        final todaySession = await databaseService.getTodayWorkoutSession();
        
        if (todaySession != null) {
          // 기존 세션 업데이트
          final updatedSession = WorkoutSession(
            id: todaySession.id,
            week: todaySession.week,
            day: todaySession.day,
            date: todaySession.date,
            targetReps: todaySession.targetReps,
            completedReps: _completedReps,
            isCompleted: true,
            totalReps: totalCompletedReps,
            totalTime: Duration.zero, // 실제 구현시 운동 시간 추가
          );

          await databaseService.updateWorkoutSession(updatedSession);
          debugPrint('기존 워크아웃 세션 업데이트 완료: Week ${todaySession.week}, Day ${todaySession.day}');
        } else {
          // 오늘의 세션이 없으면 새로 생성
          final newSession = WorkoutSession(
            id: null,
            week: widget.workoutData.week,
            day: widget.workoutData.day,
            date: DateTime.now(),
            targetReps: _targetReps,
            completedReps: _completedReps,
            isCompleted: true,
            totalReps: totalCompletedReps,
            totalTime: Duration.zero,
          );

          await databaseService.insertWorkoutSession(newSession);
          debugPrint('새 워크아웃 세션 생성 완료: Week ${widget.workoutData.week}, Day ${widget.workoutData.day}');
        }
      } catch (e) {
        debugPrint('워크아웃 세션 업데이트 오류: $e');
      }

      // 오늘의 운동 완료 알림 취소
      try {
        await NotificationService.cancelTodayWorkoutReminder();
        debugPrint('오늘의 운동 알림 취소 완료');
      } catch (e) {
        debugPrint('알림 취소 오류: $e');
      }

      // 업적 체크 및 업데이트
      try {
        debugPrint('🏆 업적 체크 시작 - 워크아웃 완료 후');
        
        // WorkoutHistoryService에 데이터가 제대로 저장되었는지 확인
        final allWorkouts = await WorkoutHistoryService.getAllWorkouts();
        debugPrint('📊 현재 WorkoutHistory 레코드 개수: ${allWorkouts.length}');
        
        if (allWorkouts.isNotEmpty) {
          final latestWorkout = allWorkouts.last;
          debugPrint('📅 최신 워크아웃: ${latestWorkout.date} - ${latestWorkout.completedReps}개');
        }
        
        // 업적 데이터베이스 초기화 상태 확인
        final totalAchievements = await AchievementService.getTotalCount();
        final unlockedAchievements = await AchievementService.getUnlockedCount();
        debugPrint('🎯 업적 현황: ${unlockedAchievements}/${totalAchievements} 잠금해제');
        
        // 업적 체크 실행
        final newlyUnlocked = await AchievementService.checkAndUpdateAchievements();
        debugPrint('🎉 새로 잠금해제된 업적: ${newlyUnlocked.length}개');
        
        for (final achievement in newlyUnlocked) {
          debugPrint('✨ 새 업적: ${achievement.titleKey}');
        }
        
        debugPrint('✅ 업적 업데이트 완료');
      } catch (e, stackTrace) {
        debugPrint('❌ 업적 업데이트 오류: $e');
        debugPrint('스택 트레이스: $stackTrace');
      }

      // 스트릭 업데이트
      try {
        await _streakService.updateStreak(DateTime.now());
        debugPrint('스트릭 업데이트 완료');
      } catch (e) {
        debugPrint('스트릭 업데이트 오류: $e');
      }

      // 챌린지 업데이트
      try {
        final challengeService = ChallengeService();
        await challengeService.initialize();
        await challengeService.updateChallengesOnWorkoutComplete(totalCompletedReps, _totalSets);
        debugPrint('챌린지 업데이트 완료');
      } catch (e) {
        debugPrint('챌린지 업데이트 오류: $e');
      }

    } catch (e) {
      debugPrint('운동 완료 처리 실패: $e');
    }

    // 워크아웃 완료 시 전면 광고 표시 (50% 확률)
    if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
      await AdService.instance.showInterstitialAd();
    }

    // 3초 후 완료 다이얼로그 표시
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showMotivationalMessage = false;
        });
        _showWorkoutCompleteDialog();
      }
    });
  }

  /// 백업 운동 기록 저장 (세션 저장 실패 시)
  Future<void> _saveWorkoutHistoryBackup() async {
    try {
      debugPrint('💾 백업 운동 기록 저장 시작');
      
      // 완료된 총 횟수 계산
      final totalCompletedReps = _completedReps.fold(
        0,
        (sum, reps) => sum + reps,
      );
      final completionRate = totalCompletedReps / widget.workoutData.totalReps;

      // 운동 기록 생성 (기존 로직 유지)
      final workoutHistory = WorkoutHistory(
        id: _sessionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        workoutTitle: widget.workoutData.title,
        targetReps: _targetReps,
        completedReps: _completedReps,
        totalReps: totalCompletedReps,
        completionRate: completionRate,
        level: widget.userProfile.level.toString(),
      );

      // 데이터베이스에 저장
      await WorkoutHistoryService.saveWorkoutHistory(workoutHistory);
      debugPrint('✅ 백업 운동 기록 저장 완료: ${workoutHistory.id}');
      
    } catch (e) {
      debugPrint('❌ 백업 운동 기록 저장 오류: $e');
      rethrow;
    }
  }

  void _showWorkoutCompleteDialog() {
    final l10n = AppLocalizations.of(context);
    final totalCompletedReps = _completedReps.fold(0, (sum, reps) => sum + reps);
    
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.celebration,
              color: Color(AppColors.primaryColor),
              size: 28,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.workoutCompleteTitle,
                style: const TextStyle(
                  color: Color(AppColors.primaryColor),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.workoutCompleteMessage(
                widget.workoutData.title,
                totalCompletedReps,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        '💪',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        '${totalCompletedReps}개',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        '완료',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        '🏆',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        '${_totalSets}세트',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        '달성',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _shareWorkoutResult(),
            icon: const Icon(Icons.share),
            label: const Text('공유하기'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(AppColors.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // 홈으로 돌아가기
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.workoutCompleteButton),
          ),
        ],
      ),
    );
  }

  void _shareWorkoutResult() async {
    try {
      final totalCompletedReps = _completedReps.fold(0, (sum, reps) => sum + reps);
      
      // 현재 날짜를 기준으로 운동 일차 계산 (임시)
      final currentDay = DateTime.now().difference(DateTime(2024, 1, 1)).inDays + 1;
      
      await SocialShareService.shareDailyWorkout(
        context: context,
        pushupCount: totalCompletedReps,
        currentDay: currentDay,
        level: widget.userProfile.level,
      );
    } catch (e) {
      debugPrint('공유 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('공유 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    // 화면 크기별 동적 값 계산
    final isSmallScreen = screenHeight < 700;
    final isMediumScreen = screenHeight >= 700 && screenHeight < 900;

    // 반응형 패딩 값 (더 컴팩트하게)
    final responsivePadding = isSmallScreen
        ? AppConstants.paddingS
        : isMediumScreen
        ? AppConstants.paddingM
        : AppConstants.paddingL;

    // 반응형 여백 값
    final responsiveSpacing = isSmallScreen
        ? AppConstants.paddingS
        : isMediumScreen
        ? AppConstants.paddingM
        : AppConstants.paddingL;

    // 배너 광고 높이
    final adHeight = isSmallScreen ? 50.0 : 60.0;

    return Scaffold(
      backgroundColor: Color(
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 스크롤 가능한 메인 콘텐츠
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(responsivePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 헤더 (화면 크기에 따라 조정)
                      _buildResponsiveHeader(context, isSmallScreen),

                      SizedBox(height: responsiveSpacing),

                      // 메인 컨텐츠 (반응형)
                      _buildResponsiveContent(
                        context,
                        isSmallScreen,
                        responsiveSpacing,
                      ),

                      SizedBox(height: responsiveSpacing),

                      // 하단 컨트롤 (반응형)
                      _buildResponsiveControls(context, isSmallScreen),

                      // 추가 여백 (광고 공간 확보)
                      SizedBox(height: adHeight + responsivePadding),
                    ],
                  ),
                ),
              ),

              // 하단 배너 광고
              _buildBannerAd(),
            ],
          ),

          // 동기부여 메시지 오버레이
          if (_showMotivationalMessage)
            _buildMotivationalMessageOverlay(context),
        ],
      ),
    );
  }

  /// 반응형 헤더 위젯
  Widget _buildResponsiveHeader(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final titleFontSize = isSmallScreen ? 18.0 : 20.0;
    final padding = isSmallScreen
        ? AppConstants.paddingS
        : AppConstants.paddingM;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Color(AppColors.primaryColor).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        children: [
          Text(
            widget.workoutData.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Color(AppColors.primaryColor),
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: padding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).setFormat(_currentSet + 1, _totalSets),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Color(AppColors.primaryColor),
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 14.0 : 16.0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: padding / 2,
                ),
                decoration: BoxDecoration(
                  color: Color(AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).targetRepsLabel(_currentTargetReps),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 12.0 : 14.0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: padding),
          LinearProgressIndicator(
            value: _overallProgress,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  /// 반응형 메인 컨텐츠 위젯
  Widget _buildResponsiveContent(
    BuildContext context,
    bool isSmallScreen,
    double spacing,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? double.infinity : 400,
        ),
        child: _buildRepCounter(),
      ),
    );
  }

  /// 반응형 컨트롤 위젯
  Widget _buildResponsiveControls(BuildContext context, bool isSmallScreen) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isSmallScreen ? double.infinity : 400,
      ),
      child: _buildControls(),
    );
  }

  Widget _buildRepCounter() {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenHeight < 700;

    // 더 컴팩트한 패딩과 여백
    final padding = AppConstants.paddingM;
    final spacing = AppConstants.paddingS;
    final fontSize = isSmallScreen ? 40.0 : 48.0;

    if (_isRestTime) {
      return _buildRestTimer();
    }

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: _getPerformanceColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: _isSetCompleted
              ? Color(AppColors.successColor)
              : Color(AppColors.primaryColor),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 목표 횟수와 현재 횟수를 한 줄에 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 목표 횟수
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.target,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Color(AppColors.primaryColor),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$_currentTargetReps',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Color(AppColors.primaryColor),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // 구분선
              Container(
                height: 40,
                width: 2,
                color: Colors.grey[300],
              ),
              
              // 현재 횟수
              Column(
                children: [
                  Text(
                    _isSetCompleted ? AppLocalizations.of(context)!.completed : AppLocalizations.of(context)!.current,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getPerformanceColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$_currentReps',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: _getPerformanceColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (!_isSetCompleted) ...[
            SizedBox(height: spacing),
            
            // 성과 메시지
            Text(
              _getPerformanceMessage(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getPerformanceColor(),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: spacing),

            // 빠른 입력 버튼들 (2줄로 배치)
            Column(
              children: [
                // 첫 번째 줄: 주요 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildQuickInputButton(
                        (_currentTargetReps * 0.6).round(),
                        '60%',
                        Colors.orange[700]!,
                        true,
                      ),
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: _buildQuickInputButton(
                        (_currentTargetReps * 0.8).round(),
                        '80%',
                        Colors.orange,
                        true,
                      ),
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: _buildQuickInputButton(
                        _currentTargetReps,
                        '100%',
                        Color(AppColors.successColor),
                        true,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: spacing / 2),
                
                // 두 번째 줄: 추가 옵션
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildQuickInputButton(
                        _currentTargetReps ~/ 2,
                        AppLocalizations.of(context)!.half,
                        Colors.grey[600]!,
                        true,
                      ),
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: _buildQuickInputButton(
                        _currentTargetReps + 2,
                        AppLocalizations.of(context)!.exceed,
                        Color(AppColors.primaryColor),
                        true,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: spacing / 2),

            // 수동 조정 버튼들 (반응형)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // -1 버튼
                ElevatedButton(
                  onPressed: _currentReps > 0
                      ? () {
                          setState(() {
                            _currentReps--;
                          });
                          HapticFeedback.lightImpact();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    shape: const CircleBorder(),
                    padding: EdgeInsets.all(
                      isSmallScreen
                          ? AppConstants.paddingS
                          : AppConstants.paddingM,
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: isSmallScreen ? 16 : 20,
                  ),
                ),

                SizedBox(width: spacing),

                // +1 버튼
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentReps++;
                    });
                    HapticFeedback.lightImpact();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColors.primaryColor),
                    shape: const CircleBorder(),
                    padding: EdgeInsets.all(
                      isSmallScreen
                          ? AppConstants.paddingS
                          : AppConstants.paddingM,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: isSmallScreen ? 16 : 20,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getPerformanceColor() {
    if (_currentReps >= _currentTargetReps) {
      return Color(AppColors.successColor); // 목표 달성
    } else if (_currentReps >= _currentTargetReps * 0.8) {
      return Color(AppColors.primaryColor); // 80% 이상
    } else if (_currentReps >= _currentTargetReps * 0.5) {
      return Colors.orange; // 50% 이상
    } else {
      return Colors.grey[600]!; // 50% 미만
    }
  }

  String _getPerformanceMessage() {
    if (_currentReps >= _currentTargetReps) {
      return AppLocalizations.of(context).performanceGodTier;
    } else if (_currentReps >= _currentTargetReps * 0.8) {
      return AppLocalizations.of(context).performanceStrong;
    } else if (_currentReps >= _currentTargetReps * 0.5) {
      return AppLocalizations.of(context).performanceMedium;
    } else if (_currentReps > 0) {
      return AppLocalizations.of(context).performanceStart;
    } else {
      return AppLocalizations.of(context).performanceMotivation;
    }
  }

  String _getMotivationalMessage() {
    if (_currentReps >= _currentTargetReps) {
      return AppLocalizations.of(context).motivationGod;
    } else if (_currentReps >= _currentTargetReps * 0.8) {
      return AppLocalizations.of(context).motivationStrong;
    } else if (_currentReps >= _currentTargetReps * 0.5) {
      return AppLocalizations.of(context).motivationMedium;
    } else {
      return AppLocalizations.of(context).motivationGeneral;
    }
  }

  Widget _buildQuickInputButton(
    int value,
    String label,
    Color color,
    bool isSmallScreen,
  ) {
    final theme = Theme.of(context);
    final padding = isSmallScreen
        ? EdgeInsets.symmetric(
            horizontal: AppConstants.paddingS,
            vertical: AppConstants.paddingS / 2,
          )
        : EdgeInsets.symmetric(
            horizontal: AppConstants.paddingM,
            vertical: AppConstants.paddingS,
          );

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentReps = value;
        });
        HapticFeedback.lightImpact();
        
        // 횟수를 설정한 후 자동으로 세트 완료 처리
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && !_isSetCompleted) {
            _markSetCompleted();
          }
        });
      },
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14.0 : 16.0,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 10.0 : 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestTimer() {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenHeight < 700;

    final padding = isSmallScreen
        ? AppConstants.paddingL
        : AppConstants.paddingXL;
    final iconSize = isSmallScreen ? 40.0 : 48.0;
    final timerFontSize = isSmallScreen ? 48.0 : 60.0;
    final progressSize = isSmallScreen ? 100.0 : 120.0;

    final minutes = _restTimeRemaining ~/ 60;
    final seconds = _restTimeRemaining % 60;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Color(AppColors.secondaryColor).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: Color(AppColors.secondaryColor),
          width: 3,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: Color(AppColors.secondaryColor),
            size: iconSize,
          ),
          SizedBox(height: padding / 2),
          Text(
            AppLocalizations.of(context).restTimeTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Color(AppColors.secondaryColor),
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16.0 : 20.0,
            ),
          ),
          SizedBox(height: padding),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: theme.textTheme.displayLarge?.copyWith(
              color: Color(AppColors.secondaryColor),
              fontWeight: FontWeight.bold,
              fontSize: timerFontSize,
            ),
          ),
          SizedBox(height: padding),
          SizedBox(
            width: progressSize,
            height: progressSize,
            child: CircularProgressIndicator(
              value: 1 - (_restTimeRemaining / _restTimeSeconds),
              strokeWidth: isSmallScreen ? 6 : 8,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(AppColors.secondaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenHeight < 700;

    final padding = isSmallScreen
        ? AppConstants.paddingM
        : AppConstants.paddingL;
    final buttonHeight = isSmallScreen ? 50.0 : 60.0;
    final fontSize = isSmallScreen ? 16.0 : 18.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;

    if (_isRestTime) {
      return Column(
        children: [
          // 휴식 상태 메시지
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Color(
                AppColors.secondaryColor,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Text(
              AppLocalizations.of(context).restMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Color(AppColors.secondaryColor),
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14.0 : 16.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: padding),

          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: () {
                _restTimer?.cancel();
                _moveToNextSet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.secondaryColor),
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: padding / 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).skipRestButton,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_isSetCompleted) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: _currentSet < _totalSets - 1
              ? () => _startRestTimer()
              : _completeWorkout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(AppColors.successColor),
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: padding / 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _currentSet == _totalSets - 1
                    ? Icons.celebration
                    : Icons.arrow_forward,
                color: Colors.white,
                size: iconSize,
              ),
              SizedBox(width: padding / 2),
              Text(
                _currentSet == _totalSets - 1
                    ? AppLocalizations.of(context).completeSetButton
                    : AppLocalizations.of(context).completeSetContinue,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 세트 진행 중 - 완료 버튼만 표시
    return Column(
      children: [
        // 안내 메시지
        Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Color(AppColors.primaryColor).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Text(
            AppLocalizations.of(context).guidanceMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Color(AppColors.primaryColor),
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 12.0 : 14.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: padding),

        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: _currentReps > 0 ? _markSetCompleted : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentReps > 0
                  ? Color(AppColors.primaryColor)
                  : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: iconSize + 4,
                ),
                SizedBox(width: padding / 2),
                Text(
                  _currentSet == _totalSets - 1
                      ? AppLocalizations.of(context).workoutButtonUltimate
                      : AppLocalizations.of(context).workoutButtonConquer,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerAd() {
    // 테스트 환경에서는 광고 위젯을 표시하지 않음
    if (kDebugMode) {
      return const SizedBox.shrink();
    }
    
    return const AdBannerWidget(
      adSize: AdSize.banner,
      margin: EdgeInsets.all(8.0),
    );
  }

  Widget _buildMotivationalMessageOverlay(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chad 아이콘
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(AppColors.primaryColor),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 동기부여 메시지
              Text(
                _currentMotivationalMessage,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(AppColors.primaryColor),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // 닫기 버튼
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showMotivationalMessage = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppColors.primaryColor),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('확인'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === 앱 수명 주기 백업 및 복원 시스템 ===
  
  /// 현재 세션 상태 백업
  Future<void> _backupCurrentSessionState() async {
    if (_sessionId == null) {
      debugPrint('⚠️ 세션 ID가 없어 백업을 건너뜁니다');
      return;
    }
    
    try {
      // 현재 진행 중인 세트만 즉시 저장
      if (_currentReps > 0 && !_isSetCompleted) {
        await WorkoutHistoryService.saveSetProgress(
          sessionId: _sessionId!,
          setIndex: _currentSet,
          completedReps: _currentReps,
          currentSet: _currentSet,
        );
        debugPrint('💾 백그라운드 진입 시 현재 세트 백업: $_currentReps회');
      }
      
    } catch (e) {
      debugPrint('❌ 세션 상태 백업 오류: $e');
    }
  }
  
  /// SharedPreferences에 현재 상태 저장
  Future<void> _saveStateToSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final backupData = {
        'sessionId': _sessionId,
        'currentSet': _currentSet,
        'currentReps': _currentReps,
        'completedReps': _completedReps,
        'targetReps': _targetReps,
        'isSetCompleted': _isSetCompleted,
        'isRestTime': _isRestTime,
        'restTimeRemaining': _restTimeRemaining,
        'workoutTitle': widget.workoutData.title,
        'level': widget.userProfile.level.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString('workout_backup', jsonEncode(backupData));
      debugPrint('💾 SharedPreferences 백업 완료');
      
    } catch (e) {
      debugPrint('❌ SharedPreferences 백업 오류: $e');
    }
  }
  
  /// 긴급 데이터 저장 (앱 종료 시)
  Future<void> _saveEmergencyData() async {
    try {
      // 1. 현재 진행 중인 세트 즉시 저장
      await _backupCurrentSessionState();
      
      // 2. SharedPreferences에 긴급 백업
      await _saveStateToSharedPreferences();
      
      // 3. 세션이 있다면 강제로 완료 처리
      if (_sessionId != null) {
        // 현재까지의 진행 상황으로 운동 기록 생성
        final totalCompletedReps = _completedReps.fold(0, (sum, reps) => sum + reps) + _currentReps;
        final completionRate = totalCompletedReps / widget.workoutData.totalReps;
        
        if (totalCompletedReps > 0) { // 최소 1개라도 완료했다면 저장
          final emergencyHistory = WorkoutHistory(
            id: _sessionId!,
            date: DateTime.now(),
            workoutTitle: widget.workoutData.title + ' (긴급 저장)',
            targetReps: _targetReps,
            completedReps: [..._completedReps]..addAll([_currentReps]),
            totalReps: totalCompletedReps,
            completionRate: completionRate,
            level: widget.userProfile.level.toString(),
          );
          
          await WorkoutHistoryService.saveWorkoutHistory(emergencyHistory);
          debugPrint('🚨 긴급 운동 기록 저장 완료: ${totalCompletedReps}회');
        }
      }
      
    } catch (e) {
      debugPrint('❌ 긴급 데이터 저장 오류: $e');
    }
  }
  
  /// 백업 복원 확인
  Future<void> _checkBackupRestoration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupString = prefs.getString('workout_backup');
      
      if (backupString != null) {
        final backupData = jsonDecode(backupString) as Map<String, dynamic>;
        final backupTime = DateTime.parse(backupData['timestamp'] as String);
        
        // 백업이 24시간 이내인지 확인
        if (DateTime.now().difference(backupTime).inHours < 24) {
          debugPrint('📁 백업 데이터 발견: ${backupTime.toString()}');
          
          // 사용자에게 복원 여부 묻기 (선택사항)
          // 현재는 자동으로 정리만 수행
        }
        
        // 백업 데이터 정리
        await prefs.remove('workout_backup');
        debugPrint('🧹 백업 데이터 정리 완료');
      }
      
    } catch (e) {
      debugPrint('❌ 백업 복원 확인 오류: $e');
    }
  }
}
