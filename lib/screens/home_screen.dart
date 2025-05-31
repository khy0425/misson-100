import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../generated/app_localizations.dart';
import '../utils/constants.dart';
import '../services/workout_program_service.dart';
import '../services/database_service.dart';
import '../services/social_share_service.dart';
import '../services/chad_evolution_service.dart';
import '../services/onboarding_service.dart';
import '../services/workout_resumption_service.dart';
import '../models/chad_evolution.dart';
import '../models/user_profile.dart';
import '../utils/workout_data.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/workout_resumption_dialog.dart';
import 'workout_screen.dart';
import 'pushup_tutorial_screen.dart';
import 'pushup_form_guide_screen.dart';
import 'youtube_shorts_screen.dart';
import 'progress_tracking_screen.dart';
import 'onboarding_screen.dart';
import '../services/achievement_service.dart';
import '../services/workout_history_service.dart';
import '../services/notification_service.dart';
import '../models/workout_history.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final DatabaseService _databaseService = DatabaseService();
  final WorkoutProgramService _workoutProgramService = WorkoutProgramService();
  
  UserProfile? _userProfile;
  TodayWorkout? _todayWorkout;
  ProgramProgress? _programProgress;
  WorkoutHistory? _todayCompletedWorkout; // 오늘 완료된 운동 기록
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    
    // 운동 기록 저장 시 홈 화면 데이터 즉시 업데이트
    WorkoutHistoryService.addOnWorkoutSavedCallback(_onWorkoutSaved);
    debugPrint('🏠 홈 화면: 운동 기록 콜백 등록 완료');
    
    // 앱 시작 시 운동 재개 체크
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWorkoutResumption();
      // 보류 중인 알림도 체크
      NotificationService.checkPendingNotifications();
    });
  }

  @override
  void dispose() {
    // 콜백 제거하여 메모리 누수 방지
    WorkoutHistoryService.removeOnWorkoutSavedCallback(_onWorkoutSaved);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아왔을 때 데이터 새로고침
      _refreshAllServiceData();
      // 보류 중인 알림 체크
      NotificationService.checkPendingNotifications();
    }
  }

  Future<void> _refreshAllServiceData() async {
    try {
      debugPrint('홈 화면 데이터 새로고침 시작');
      
      // 모든 서비스 데이터 새로고침
      await _loadUserData();
      
      debugPrint('홈 화면 데이터 새로고침 완료');
    } catch (e) {
      debugPrint('홈 화면 데이터 새로고침 오류: $e');
    }
  }

  // 운동 저장 시 호출될 콜백 메서드
  void _onWorkoutSaved() {
    if (mounted) {
      debugPrint('🏠 홈 화면: 운동 기록 저장 감지, 데이터 새로고침 시작');
      _refreshAllServiceData();
    } else {
      debugPrint('⚠️ 홈 화면: mounted가 false이므로 콜백 무시');
    }
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 사용자 프로필 로드
      _userProfile = await _databaseService.getUserProfile();
      
      if (_userProfile != null) {
        // 프로그램이 초기화되지 않았다면 초기화
        final isInitialized = await _workoutProgramService.isProgramInitialized(
          _userProfile!.id ?? 1,
        );
        
        if (!isInitialized) {
          await _workoutProgramService.initializeUserProgram(_userProfile!);
        }

        // 오늘의 워크아웃과 진행 상황 로드
        _todayWorkout = await _workoutProgramService.getTodayWorkout(_userProfile!);
        _programProgress = await _workoutProgramService.getProgramProgress(_userProfile!);
        
        // 오늘 완료된 운동 기록 확인
        _todayCompletedWorkout = await WorkoutHistoryService.getWorkoutByDate(DateTime.now());
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('홈 스크린 데이터 로드 오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  bool _isTestEnvironment() {
    // Flutter 테스트 환경 감지
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (e) {
      // 웹 환경에서는 Platform.environment에 접근할 수 없음
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Color(
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).homeTitle),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          // 메인 콘텐츠 영역
          Expanded(
            child: SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isLoading)
                        _buildLoadingWidget()
                      else if (_errorMessage != null)
                        _buildErrorWidget()
                      else if (_userProfile == null)
                        _buildNoUserWidget()
                      else ...[
                        // Chad 이미지 및 환영 메시지
                        _buildChadSection(context, theme, isDark),
                        
                        const SizedBox(height: AppConstants.paddingXL),
                        
                        // 오늘의 미션 카드
                        _buildTodayMissionCard(context, theme, isDark),
                        
                        const SizedBox(height: AppConstants.paddingL),
                        
                        // 진행 상황 카드
                        _buildProgressCard(context, theme, isDark),
                        
                        const SizedBox(height: AppConstants.paddingL),
                        
                        // 추가 기능 버튼들
                        _buildActionButtons(context, theme),
                        
                        const SizedBox(height: AppConstants.paddingL),
                        
                        // 디버그 섹션 (디버그 모드에서만 표시)
                        if (kDebugMode) ...[
                          _buildDebugSection(context, theme),
                          const SizedBox(height: AppConstants.paddingL),
                        ],
                        
                        // 하단 정보
                        _buildBottomInfo(context, theme),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 하단 배너 광고 (테스트 환경에서는 제외)
          if (!kIsWeb && !kDebugMode)
            const AdBannerWidget(
              adSize: AdSize.banner,
              margin: EdgeInsets.all(8.0),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingXL),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              '데이터를 불러오는 중 오류가 발생했습니다',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              _errorMessage ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingM),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoUserWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          children: [
            const Icon(
              Icons.person_add,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              '사용자 프로필이 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              '초기 테스트를 완료하여 프로필을 생성해주세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChadSection(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<ChadEvolutionService>(
      builder: (context, chadService, child) {
        final currentChad = chadService.currentChad;
        final evolutionState = chadService.evolutionState;
        
        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            color: Color(
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Chad 진화 단계 표시
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingM,
                  vertical: AppConstants.paddingS,
                ),
                decoration: BoxDecoration(
                  color: currentChad.themeColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  currentChad.name,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              
              // Chad 이미지
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: currentChad.themeColor,
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(57),
                  child: FutureBuilder<ImageProvider>(
                    future: chadService.getCurrentChadImage(targetSize: 120),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image(
                          image: snapshot.data!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/수면모자차드.jpg',
                              fit: BoxFit.cover,
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Image.asset(
                          'assets/images/수면모자차드.jpg',
                          fit: BoxFit.cover,
                        );
                      } else {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              
              // Chad 설명
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: currentChad.themeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  currentChad.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: currentChad.themeColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              
              // 진화 진행률 표시
              if (evolutionState.currentStage != ChadEvolutionStage.doubleChad) ...[
                Text(
                  '다음 진화까지',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingS),
                LinearProgressIndicator(
                  value: chadService.getEvolutionProgress(),
                  backgroundColor: Colors.grey.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(currentChad.themeColor),
                ),
                const SizedBox(height: AppConstants.paddingS),
                Text(
                  '${chadService.getWeeksUntilNextEvolution()}주 남음',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: currentChad.themeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingS),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    '🎉 최고 단계 달성! 🎉',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: AppConstants.paddingM),
              
              Text(
                AppLocalizations.of(context).welcomeMessage,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: currentChad.themeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                AppLocalizations.of(context).dailyMotivation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayMissionCard(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: Color(isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.today,
                color: const Color(AppColors.primaryColor),
                size: 24,
              ),
              const SizedBox(width: AppConstants.paddingS),
                             Text(
                 '오늘의 미션',
                 style: theme.textTheme.titleMedium?.copyWith(
                   fontWeight: FontWeight.bold,
                   color: const Color(AppColors.primaryColor),
                 ),
               ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          
          if (_todayWorkout != null) ...[
            // 주차 및 일차 정보
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingM,
                vertical: AppConstants.paddingS,
              ),
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Text(
                '${_todayWorkout!.week}주차 - ${_todayWorkout!.day}일차',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: const Color(AppColors.primaryColor),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            // 세트별 목표 횟수
            Text(
              '오늘의 목표:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.paddingS),
            Wrap(
              spacing: AppConstants.paddingS,
              runSpacing: AppConstants.paddingS,
              children: _todayWorkout!.workout.asMap().entries.map((entry) {
                final setIndex = entry.key + 1;
                final reps = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingM,
                    vertical: AppConstants.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: _todayCompletedWorkout != null 
                        ? Colors.green 
                        : const Color(AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    '$setIndex세트: ${reps}회',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            // 총 횟수 정보
            Row(
              children: [
                Icon(
                  _todayCompletedWorkout != null ? Icons.check_circle : Icons.fitness_center,
                  color: _todayCompletedWorkout != null ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: AppConstants.paddingS),
                Text(
                  _todayCompletedWorkout != null
                      ? '완료됨: ${_todayCompletedWorkout!.totalReps}회 (${_todayWorkout!.setCount}세트)'
                      : '총 ${_todayWorkout!.totalReps}회 (${_todayWorkout!.setCount}세트)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _todayCompletedWorkout != null ? Colors.green[700] : Colors.grey,
                    fontWeight: _todayCompletedWorkout != null ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingL),
            
            // 시작 버튼 또는 완료 버튼
            SizedBox(
              width: double.infinity,
              child: _todayCompletedWorkout != null
                  ? ElevatedButton(
                      onPressed: _showAlreadyCompletedMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.paddingL,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: AppConstants.paddingS),
                          Text(
                            '오늘 운동 완료됨! 🎉',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => _startTodayWorkout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.paddingL,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: AppConstants.paddingS),
                          Text(
                            AppLocalizations.of(context).startTodayWorkout,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ] else ...[
            // 오늘 워크아웃이 없는 경우
            if (_todayCompletedWorkout != null) ...[
              // 오늘 운동을 완료한 경우 - 축하 메시지
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(AppColors.primaryColor).withValues(alpha: 0.1),
                      Colors.green.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    // 축하 아이콘
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    
                    // 축하 메시지
                    Text(
                      '🎉 오늘 운동 완료! 🎉',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    Text(
                      '수고하셨습니다! 정말 멋져요! 💪',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(AppColors.primaryColor),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    
                    // 오늘의 성과
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '오늘의 성과',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingS),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildAchievementStat(
                                context, 
                                '총 푸시업', 
                                '${_todayCompletedWorkout!.totalReps}회',
                                Icons.fitness_center,
                                Colors.blue,
                              ),
                              _buildAchievementStat(
                                context, 
                                '완료율', 
                                '${(_todayCompletedWorkout!.completionRate * 100).toStringAsFixed(1)}%',
                                Icons.check_circle,
                                Colors.green,
                              ),
                              _buildAchievementStat(
                                context, 
                                '운동 시간', 
                                '${_todayCompletedWorkout!.duration.inMinutes}분',
                                Icons.timer,
                                Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    
                    // 격려 메시지
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Text(
                        '내일도 화이팅! 꾸준함이 최고의 힘입니다! 🔥',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.amber[800],
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 실제 휴식일인 경우
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.weekend,
                      color: Colors.grey,
                      size: 48,
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    Text(
                      '오늘은 휴식일입니다! 😴',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    Text(
                      '내일의 워크아웃을 위해 충분히 휴식하세요.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, ThemeData theme, bool isDark) {
    if (_programProgress == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: Color(isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: const Color(AppColors.primaryColor),
                size: 24,
              ),
              const SizedBox(width: AppConstants.paddingS),
              Text(
                AppLocalizations.of(context).weekProgress,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(AppColors.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          
          // 전체 프로그램 진행률
          LinearProgressIndicator(
            value: _programProgress!.progressPercentage,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(AppColors.primaryColor),
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '전체 진행률: ${(_programProgress!.progressPercentage * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_programProgress!.completedSessions}/${_programProgress!.totalSessions} 세션',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingM),
          
          // 이번 주 진행률
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이번 주 (${_programProgress!.weeklyProgress.currentWeek}주차)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    LinearProgressIndicator(
                      value: _programProgress!.weeklyProgress.weeklyCompletionRate,
                      backgroundColor: Colors.grey.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4DABF7),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    Text(
                      '${_programProgress!.weeklyProgress.completedDaysThisWeek}/${_programProgress!.weeklyProgress.totalDaysThisWeek} 일 완료',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingM),
          
          // 통계 정보
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  '총 푸시업',
                  '${_programProgress!.totalCompletedReps}회',
                  Icons.fitness_center,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: _buildStatItem(
                  context,
                  '남은 목표',
                  '${_programProgress!.remainingReps}회',
                  Icons.flag,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(AppColors.primaryColor),
            size: 20,
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(AppColors.primaryColor),
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementStat(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: AppConstants.paddingXS),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // 푸시업 튜토리얼 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _openTutorial(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DABF7),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingL,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.paddingS),
                Text(
                  AppLocalizations.of(context).tutorialButton,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppConstants.paddingM),
        
        // 푸시업 폼 가이드 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _openFormGuide(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF51CF66),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingL,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.paddingS),
                Text(
                  '완벽한 푸시업 자세',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppConstants.paddingM),
        
        // 진행률 추적 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _openProgressTracking(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD43B),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingL,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.analytics,
                  color: Colors.black,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.paddingS),
                Text(
                  '진행률 추적',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppConstants.paddingM),
        
        // 차드 쇼츠 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _openYoutubeShorts(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingL,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.paddingS),
                Text(
                  AppLocalizations.of(context).chadShorts,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppConstants.paddingM),
        
        // 친구 도전장 공유 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              SocialShareService.shareFriendChallenge(
                context: context,
                userName: 'ALPHA EMPEROR',
              );
            },
            icon: const Icon(Icons.share, color: Colors.white),
            label: Text(
              AppLocalizations.of(context).sendFriendChallenge,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo(BuildContext context, ThemeData theme) {
    return Text(
      AppLocalizations.of(context).bottomMotivation,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: const Color(AppColors.primaryColor),
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  void _startTodayWorkout(BuildContext context) async {
    if (_userProfile == null || _todayWorkout == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('워크아웃 정보를 불러올 수 없습니다.'),
          backgroundColor: Color(AppColors.errorColor),
        ),
      );
      return;
    }

    try {
      // 워크아웃 화면으로 이동
      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => WorkoutScreen(
              userProfile: _userProfile!,
              workoutData: _todayWorkout!,
            ),
          ),
        );
        
        // 워크아웃 완료 후 데이터 새로고침
        await _refreshData();
      }
    } catch (e) {
      // 에러 처리
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).workoutStartError(e.toString()),
            ),
            backgroundColor: const Color(AppColors.errorColor),
          ),
        );
      }
    }
  }

  void _showAlreadyCompletedMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.sentiment_satisfied_alt,
              color: Colors.green[600],
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('잠깐! 🛑'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '오늘의 운동은 이미 완료했습니다! 💪',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '충분히 쉬면서 몸이 회복될 시간을 주세요.\n내일 더 강해진 모습으로 돌아오세요! 🌟',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tips_and_updates, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '과훈련은 부상의 원인이 될 수 있어요',
                            style: TextStyle(
                              color: Colors.amber[800],
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '알겠습니다! 😊',
              style: TextStyle(
                color: Colors.green[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openTutorial(BuildContext context) async {
    // 튜토리얼 조회 카운트 증가
    try {
      await AchievementService.incrementTutorialViewCount();
      debugPrint('🎓 튜토리얼 조회 카운트 증가');
    } catch (e) {
      debugPrint('❌ 튜토리얼 카운트 증가 실패: $e');
    }
    
    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (context) => PushupTutorialScreen()),
      );
    }
  }

  void _openFormGuide(BuildContext context) async {
    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const PushupFormGuideScreen(),
        ),
      );
    }
  }

  void _openProgressTracking(BuildContext context) async {
    if (_userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사용자 프로필을 불러올 수 없습니다.'),
          backgroundColor: Color(AppColors.errorColor),
        ),
      );
      return;
    }

    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ProgressTrackingScreen(
            userProfile: _userProfile!,
          ),
        ),
      );
    }
  }

  void _openYoutubeShorts(BuildContext context) async {
    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const YoutubeShortsScreen(),
        ),
      );
    }
  }

  Widget _buildDebugSection(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 디버그 섹션 헤더
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                '🧪 디버그 도구',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          
          // 업적 관리 버튼들
          Text(
            '업적 시스템',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          
          Wrap(
            spacing: AppConstants.paddingS,
            runSpacing: AppConstants.paddingS,
            children: [
              _buildDebugButton(
                context: context,
                icon: Icons.shield_outlined,
                label: '검증',
                color: Colors.blue,
                onPressed: _validateAchievements,
              ),
              _buildDebugButton(
                context: context,
                icon: Icons.build,
                label: '복구',
                color: Colors.green,
                onPressed: _repairAchievements,
              ),
              _buildDebugButton(
                context: context,
                icon: Icons.sync,
                label: '동기화',
                color: Colors.purple,
                onPressed: _synchronizeAchievementProgress,
              ),
              _buildDebugButton(
                context: context,
                icon: Icons.delete_forever,
                label: '초기화',
                color: Colors.red,
                onPressed: _resetAllData,
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingM),
          
          // 데이터베이스 관리 버튼들
          Text(
            '데이터베이스 관리',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          
          Wrap(
            spacing: AppConstants.paddingS,
            runSpacing: AppConstants.paddingS,
            children: [
              _buildDebugButton(
                context: context,
                icon: Icons.storage,
                label: 'DB 재설정',
                color: Colors.orange,
                onPressed: _resetWorkoutDatabase,
              ),
              _buildDebugButton(
                context: context,
                icon: Icons.healing,
                label: 'DB 수정',
                color: Colors.cyan,
                onPressed: _fixDatabaseSchema,
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingM),
          
          // Chad 시스템 버튼들
          Text(
            'Chad 시스템',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          
          Wrap(
            spacing: AppConstants.paddingS,
            runSpacing: AppConstants.paddingS,
            children: [
              _buildDebugButton(
                context: context,
                icon: Icons.trending_up,
                label: 'Chad 진화',
                color: const Color(AppColors.primaryColor),
                onPressed: _testChadEvolution,
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.paddingM),
          
          // 성능 모니터링 버튼들
          Text(
            '성능 모니터링',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          
          Wrap(
            spacing: AppConstants.paddingS,
            runSpacing: AppConstants.paddingS,
            children: [
              _buildDebugButton(
                context: context,
                icon: Icons.analytics,
                label: '성능 통계',
                color: Colors.teal,
                onPressed: _showPerformanceStats,
              ),
              _buildDebugButton(
                context: context,
                icon: Icons.memory,
                label: '캐시 상태',
                color: Colors.indigo,
                onPressed: _showCacheStatus,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebugButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingS,
            vertical: AppConstants.paddingXS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
        ),
      ),
    );
  }

  void _testChadEvolution() async {
    try {
      setState(() {
        _isLoading = true;
      });

      debugPrint('🧪 Chad 진화 테스트 시작');
      
      // Provider에서 ChadEvolutionService 인스턴스 가져오기
      final chadService = Provider.of<ChadEvolutionService>(context, listen: false);
      
      // 현재 레벨 확인
      final currentLevel = await ChadEvolutionService.getCurrentLevel();
      debugPrint('현재 레벨: $currentLevel');
      
      // 레벨업 테스트 (더미 메서드이므로 실제로는 아무것도 하지 않음)
      await ChadEvolutionService.addExperience(100);
      
      // 다음 단계로 진화 테스트
      await chadService.evolveToNextStage();
      
      // 업데이트된 레벨 확인
      final newLevel = await ChadEvolutionService.getCurrentLevel();
      debugPrint('새 레벨: $newLevel');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chad 레벨: $currentLevel → $newLevel')),
        );
        
        // UI 업데이트
        _refreshAllServiceData();
      }
    } catch (e) {
      debugPrint('❌ Chad 진화 테스트 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chad 테스트 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 모든 데이터 재설정 (운동 기록 + 업적)
  Future<void> _resetAllData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      debugPrint('🔄 모든 데이터 재설정 시작...');
      
      // 경고 다이얼로그 표시
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('⚠️ 주의'),
          content: const Text(
            '모든 데이터가 삭제됩니다!\n\n'
            '• 운동 기록\n'
            '• 업적 진행도\n'
            '• 스트릭 정보\n'
            '• 튜토리얼 조회 기록\n\n'
            '정말로 계속하시겠습니까?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('모든 데이터 삭제'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // 1. 운동 기록 데이터베이스 재설정
      try {
        await WorkoutHistoryService.resetDatabase();
        debugPrint('✅ 운동 기록 데이터베이스 재설정 완료');
      } catch (e) {
        debugPrint('⚠️ 운동 기록 재설정 실패: $e');
      }
      
      // 2. 업적 데이터베이스 재설정
      try {
        await AchievementService.resetAchievementDatabase();
        debugPrint('✅ 업적 데이터베이스 재설정 완료');
      } catch (e) {
        debugPrint('⚠️ 업적 재설정 실패: $e');
      }
      
      // 3. 업적 시스템 재초기화
      try {
        await AchievementService.initialize();
        debugPrint('✅ 업적 시스템 재초기화 완료');
      } catch (e) {
        debugPrint('⚠️ 업적 초기화 실패: $e');
      }
      
      debugPrint('✅ 모든 데이터 재설정 완료');
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('🎉 재설정 완료'),
            content: const Text(
              '모든 데이터가 성공적으로 재설정되었습니다!\n\n'
              '변경사항을 완전히 적용하려면 '
              '앱을 완전히 종료한 후 다시 시작해주세요.'
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 앱 종료 (Android)
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  }
                },
                child: const Text('앱 종료'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _refreshAllServiceData();
                },
                child: const Text('계속 사용'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ 모든 데이터 재설정 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 재설정 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 업적 검증
  Future<void> _validateAchievements() async {
    try {
      setState(() {
        _isLoading = true;
      });

      debugPrint('🔍 업적 데이터베이스 검증 시작...');
      
      final validation = await AchievementService.validateAchievementDatabase();
      final isValid = validation['isValid'] as bool? ?? false;
      final issues = validation['issues'] as List<String>? ?? <String>[];
      final stats = validation['stats'] as Map<String, dynamic>? ?? {};
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(isValid ? '✅ 검증 완료' : '⚠️ 문제 발견'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📊 업적 시스템 상태:', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  if (stats.isNotEmpty) ...[
                    Text('총 업적: ${stats['totalCount']}/${stats['expectedCount']}개'),
                    Text('잠금 해제: ${stats['unlockedCount']}개 (${stats['completionRate']}%)'),
                    const SizedBox(height: 12),
                  ],
                  
                  if (issues.isNotEmpty) ...[
                    const Text('🚨 발견된 문제점들:', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 8),
                    ...issues.map((issue) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Text('• $issue', style: const TextStyle(fontSize: 12)),
                    )),
                  ] else ...[
                    const Text('✅ 모든 검증 통과', 
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
            actions: [
              if (!isValid)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _repairAchievements();
                  },
                  child: const Text('🔧 자동 복구'),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ 업적 검증 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 검증 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 업적 복구
  Future<void> _repairAchievements() async {
    try {
      setState(() {
        _isLoading = true;
      });

      debugPrint('🔧 업적 데이터베이스 복구 시작...');
      
      final success = await AchievementService.repairAchievementDatabase();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? '✅ 업적 데이터베이스 복구 완료' 
              : '❌ 복구 실패 - 전체 재설정을 시도하세요'),
            backgroundColor: success ? Colors.green : Colors.orange,
          ),
        );
        
        if (success) {
          // UI 새로고침
          _refreshAllServiceData();
        }
      }
    } catch (e) {
      debugPrint('❌ 업적 복구 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 복구 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 업적 진행도 동기화
  Future<void> _synchronizeAchievementProgress() async {
    try {
      setState(() {
        _isLoading = true;
      });

      debugPrint('🔄 업적 진행도 동기화 시작...');
      
      await AchievementService.synchronizeAchievementProgress();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 업적 진행도 동기화 완료'),
            backgroundColor: Colors.green,
          ),
        );
        
        // UI 새로고침
        _refreshAllServiceData();
      }
    } catch (e) {
      debugPrint('❌ 업적 동기화 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 동기화 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 운동 데이터베이스 재설정
  Future<void> _resetWorkoutDatabase() async {
    try {
      // 확인 대화상자
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('⚠️ 데이터베이스 재설정'),
          content: const Text('운동 기록 데이터베이스를 완전히 재설정합니다.\n스키마 문제를 해결할 수 있지만 모든 운동 기록이 삭제됩니다.\n\n'
            '정말로 진행하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('재설정'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() {
        _isLoading = true;
      });

      debugPrint('🔄 운동 데이터베이스 재설정 시작...');
      
      // 데이터베이스 완전 재설정
      await WorkoutHistoryService.resetDatabase();
      
      debugPrint('✅ 운동 데이터베이스 재설정 완료');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 데이터베이스 재설정 완료'),
            backgroundColor: Colors.green,
          ),
        );
        
        // UI 새로고침
        _refreshAllServiceData();
      }
    } catch (e) {
      debugPrint('❌ 데이터베이스 재설정 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 재설정 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 데이터베이스 스키마 수정
  Future<void> _fixDatabaseSchema() async {
    try {
      setState(() {
        _isLoading = true;
      });

      debugPrint('🔧 데이터베이스 스키마 수정 시작...');
      
      // 스키마 자동 수정 (누락된 컬럼 추가)
      await WorkoutHistoryService.fixSchemaIfNeeded();
      
      debugPrint('✅ 데이터베이스 스키마 수정 완료');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 스키마 수정 완료 - 이제 운동 기록이 정상 저장됩니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ 스키마 수정 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 스키마 수정 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 운동 재개 가능 여부 체크 및 다이얼로그 표시
  Future<void> _checkWorkoutResumption() async {
    if (!mounted) return;
    
    try {
      debugPrint('🔍 운동 재개 체크 시작');
      
      final hasResumableWorkout = await WorkoutResumptionService.hasResumableWorkout();
      
      if (hasResumableWorkout && mounted) {
        debugPrint('📋 재개 가능한 운동 발견, 다이얼로그 표시');
        
        final resumptionData = await WorkoutResumptionService.getResumptionData();
        
        if (resumptionData != null && resumptionData.hasResumableData && mounted) {
          await _showWorkoutResumptionDialog(resumptionData);
        }
      } else {
        debugPrint('✅ 재개할 운동 없음');
      }
    } catch (e) {
      debugPrint('❌ 운동 재개 체크 오류: $e');
    }
  }

  /// 운동 재개 다이얼로그 표시
  Future<void> _showWorkoutResumptionDialog(WorkoutResumptionData resumptionData) async {
    if (!mounted) return;
    
    try {
      final shouldResume = await showWorkoutResumptionDialog(
        context: context,
        resumptionData: resumptionData,
      );

      if (shouldResume == true && mounted) {
        debugPrint('🔄 운동 재개 선택됨');
        await _resumeWorkout(resumptionData);
      } else if (shouldResume == false && mounted) {
        debugPrint('🆕 새 운동 시작 선택됨');
        await _startNewWorkout();
      }
    } catch (e) {
      debugPrint('❌ 운동 재개 다이얼로그 오류: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('운동 재개 처리 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 운동 재개 실행
  Future<void> _resumeWorkout(WorkoutResumptionData resumptionData) async {
    if (!mounted) return;

    try {
      final primaryData = resumptionData.primaryData;
      if (primaryData == null) return;

      // 재개 통계 기록
      final completedRepsStr = primaryData['completedReps'] as String? ?? '';
      final completedReps = completedRepsStr.isNotEmpty 
          ? completedRepsStr.split(',').map(int.parse).toList()
          : <int>[];
      
      final completedSetsCount = completedReps.where((reps) => reps > 0).length;
      final totalCompletedReps = completedReps.fold(0, (sum, reps) => sum + reps);
      
      await WorkoutResumptionService.recordResumptionStats(
        resumptionSource: resumptionData.dataSource,
        recoveredSets: completedSetsCount,
        recoveredReps: totalCompletedReps,
      );

      // 운동 화면으로 이동 (재개 모드)
      if (mounted) {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutScreen(
              userProfile: _userProfile!,
              workoutData: _todayWorkout!,
            ),
          ),
        );

        // 운동 완료 후 데이터 새로고침
        if (result == true && mounted) {
          await _refreshData();
          
          // 백업 데이터 정리
          await WorkoutResumptionService.clearBackupData();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 운동이 성공적으로 재개되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ 운동 재개 실행 오류: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('운동 재개 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 새 운동 시작 (백업 데이터 정리)
  Future<void> _startNewWorkout() async {
    try {
      debugPrint('🧹 새 운동 시작을 위한 백업 데이터 정리');
      
      // 백업 데이터 정리
      await WorkoutResumptionService.clearBackupData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('새로운 운동을 시작할 준비가 되었습니다!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ 새 운동 시작 준비 오류: $e');
    }
  }

  // 성능 통계 표시
  void _showPerformanceStats() async {
    try {
      setState(() {
        _isLoading = true;
      });

      debugPrint('📊 성능 통계 조회 시작');
      
      // AchievementService에서 성능 통계 가져오기
      final stats = AchievementService.getPerformanceStats();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('📊 성능 통계'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (stats.isEmpty) 
                    const Text('아직 수집된 성능 데이터가 없습니다.')
                  else
                    ...stats.entries.map((entry) {
                      final operation = entry.key;
                      final metrics = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              operation.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('평균: ${metrics['average']?.toStringAsFixed(1)}ms'),
                            Text('최소: ${metrics['min']?.toStringAsFixed(1)}ms'),
                            Text('최대: ${metrics['max']?.toStringAsFixed(1)}ms'),
                            Text('실행 횟수: ${metrics['count']?.toInt()}회'),
                            if (metrics['average']! > 500)
                              const Text(
                                '⚠️ 성능 개선 필요',
                                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                              ),
                            const Divider(),
                          ],
                        ),
                      );
                    }).toList(),
                  const SizedBox(height: 8),
                  const Text(
                    '💡 팁: 500ms 이상의 작업은 성능 개선이 필요할 수 있습니다.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ 성능 통계 조회 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 성능 통계 조회 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 캐시 상태 표시
  void _showCacheStatus() async {
    try {
      setState(() {
        _isLoading = true;
      });

      debugPrint('🗂️ 캐시 상태 조회 시작');
      
      // 캐시 정보는 private이므로 getAllAchievements 호출하여 캐시 동작 확인
      final stopwatch = Stopwatch()..start();
      await AchievementService.getAllAchievements();
      stopwatch.stop();
      final firstCallTime = stopwatch.elapsedMilliseconds;
      
      // 두 번째 호출 (캐시 히트 예상)
      stopwatch.reset();
      stopwatch.start();
      final achievements = await AchievementService.getAllAchievements();
      stopwatch.stop();
      final secondCallTime = stopwatch.elapsedMilliseconds;
      
      final cacheHit = secondCallTime < firstCallTime;
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('🗂️ 캐시 상태'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('업적 개수: ${achievements.length}개'),
                const SizedBox(height: 8),
                Text('첫 번째 호출: ${firstCallTime}ms'),
                Text('두 번째 호출: ${secondCallTime}ms'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      cacheHit ? Icons.check_circle : Icons.error,
                      color: cacheHit ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      cacheHit ? '캐시 동작 중' : '캐시 미스',
                      style: TextStyle(
                        color: cacheHit ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (cacheHit)
                  Text(
                    '성능 향상: ${((firstCallTime - secondCallTime) / firstCallTime * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.green),
                  ),
                const SizedBox(height: 8),
                const Text(
                  '💡 캐시는 5분간 유효하며, 데이터 변경 시 자동으로 무효화됩니다.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ 캐시 상태 조회 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 캐시 상태 조회 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
