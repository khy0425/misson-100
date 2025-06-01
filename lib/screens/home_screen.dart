import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/workout_program_service.dart';
import '../services/notification_service.dart';
import '../services/workout_history_service.dart';
import '../services/chad_evolution_service.dart';
import '../screens/workout_screen.dart';
import '../screens/settings_screen.dart';
import '../models/user_profile.dart';
import '../models/chad_evolution.dart';
import '../models/workout_history.dart';
import '../utils/constants.dart';
import '../widgets/ad_banner_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final DatabaseService _databaseService = DatabaseService();
  final WorkoutProgramService _workoutProgramService = WorkoutProgramService();
  
  UserProfile? _userProfile;
  dynamic _todayWorkout; // 서비스에서 가져오는 타입 사용
  dynamic _programProgress; // 서비스에서 가져오는 타입 사용
  WorkoutHistory? _todayCompletedWorkout; // 실제 모델 사용
  bool _isLoading = true;
  String? _errorMessage;
  
  // 반응형 디자인을 위한 변수들
  bool get _isTablet => MediaQuery.of(context).size.width > 600;
  bool get _isLargeTablet => MediaQuery.of(context).size.width > 900;
  
  double get _horizontalPadding {
    if (_isLargeTablet) return 60.0;
    if (_isTablet) return 40.0;
    return 20.0;
  }
  
  double get _chadImageSize {
    if (_isLargeTablet) return 200.0;
    if (_isTablet) return 160.0;
    return 120.0;
  }
  
  double get _titleFontSize {
    if (_isLargeTablet) return 32.0;
    if (_isTablet) return 28.0;
    return 24.0;
  }
  
  double get _subtitleFontSize {
    if (_isLargeTablet) return 18.0;
    if (_isTablet) return 16.0;
    return 14.0;
  }
  
  double get _buttonHeight {
    if (_isLargeTablet) return 60.0;
    if (_isTablet) return 56.0;
    return 52.0;
  }
  
  double get _cardPadding {
    if (_isLargeTablet) return 32.0;
    if (_isTablet) return 24.0;
    return 16.0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
  }

  @override
  void dispose() {
    // 콜백 제거하여 메모리 누수 방지
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

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
              SizedBox(height: _isTablet ? 32 : 16),
              Text(
                Localizations.localeOf(context).languageCode == 'ko' 
                  ? '로딩 중...' 
                  : 'Loading...',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: _subtitleFontSize,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.homeTitle),
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
                        
                        // 디버그 섹션 (비활성화)
                        /*
                        if (kDebugMode) ...[
                          _buildDebugSection(context, theme),
                          const SizedBox(height: AppConstants.paddingL),
                        ],
                        */
                        
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
              child: Text(AppLocalizations.of(context)!.retryButton),
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
              Localizations.localeOf(context).languageCode == 'ko' 
                ? '초기 테스트를 완료하여 프로필을 생성해주세요'
                : 'Please complete the initial test to create your profile',
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
                width: _chadImageSize,
                height: _chadImageSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  border: Border.all(
                    color: currentChad.themeColor,
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  child: FutureBuilder<ImageProvider>(
                    future: chadService.getCurrentChadImage(targetSize: _chadImageSize.toInt()),
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
                  Localizations.localeOf(context).languageCode == 'ko' 
                    ? '${chadService.getWeeksUntilNextEvolution()}주 남음'
                    : '${chadService.getWeeksUntilNextEvolution()} weeks left',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: currentChad.themeColor,
                    fontWeight: FontWeight.w600,
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
                AppLocalizations.of(context)!.welcomeMessage,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: currentChad.themeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                AppLocalizations.of(context)!.dailyMotivation,
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
                AppLocalizations.of(context)!.todayMissionTitle,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryColor).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                Localizations.localeOf(context).languageCode == 'ko'
                  ? '${(_todayWorkout!.week ?? 0)}주차 ${(_todayWorkout!.day ?? 0)}일차'
                  : 'Week ${(_todayWorkout!.week ?? 0)} Day ${(_todayWorkout!.day ?? 0)}',
                style: TextStyle(
                  color: const Color(AppColors.primaryColor),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 세트별 목표 횟수
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Localizations.localeOf(context).languageCode == 'ko'
                  ? '오늘의 목표'
                  : "Today's Goal",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 세트별 목표 표시
            if (_todayWorkout!.sets != null)
              ...(((_todayWorkout!.sets as List<dynamic>?) ?? []).asMap().entries.map((entry) {
                final setIndex = entry.key + 1;
                final reps = (entry.value as Map<String, dynamic>?)?['reps'] as int?;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: _todayCompletedWorkout != null ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Localizations.localeOf(context).languageCode == 'ko'
                          ? '${setIndex}세트: ${reps}개'
                          : 'Set ${setIndex}: ${reps} reps',
                        style: TextStyle(
                          color: _todayCompletedWorkout != null
                              ? Colors.green[700]
                              : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              })),

            const SizedBox(height: 16),

            // 총 횟수 정보
            Row(
              children: [
                Icon(
                  _todayCompletedWorkout != null ? Icons.check_circle : Icons.fitness_center,
                  color: _todayCompletedWorkout != null ? Colors.green : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _todayCompletedWorkout != null
                      ? (Localizations.localeOf(context).languageCode == 'ko'
                          ? '완료: ${_todayCompletedWorkout!.totalReps}개 / ${(_todayWorkout!.sets as List<dynamic>?)?.length ?? 0}세트'
                          : 'Completed: ${_todayCompletedWorkout!.totalReps} reps / ${(_todayWorkout!.sets as List<dynamic>?)?.length ?? 0} sets')
                      : (Localizations.localeOf(context).languageCode == 'ko'
                          ? '목표: ${(_todayWorkout!.sets as List<dynamic>?)?.fold<int>(0, (sum, set) => sum + (set?.reps as int? ?? 0)) ?? 0}개 / ${(_todayWorkout!.sets as List<dynamic>?)?.length ?? 0}세트'
                          : 'Goal: ${(_todayWorkout!.sets as List<dynamic>?)?.fold<int>(0, (sum, set) => sum + (set?.reps as int? ?? 0)) ?? 0} reps / ${(_todayWorkout!.sets as List<dynamic>?)?.length ?? 0} sets'),
                  style: TextStyle(
                    color: _todayCompletedWorkout != null ? Colors.green[700] : Colors.grey,
                    fontWeight: _todayCompletedWorkout != null ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

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
                            AppLocalizations.of(context)!.todayWorkoutCompleted,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            AppLocalizations.of(context)!.startTodayWorkout,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                      Localizations.localeOf(context).languageCode == 'ko'
                        ? '🎉 오늘 운동 완료! 🎉'
                        : '🎉 Today\'s Workout Complete! 🎉',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // 운동 결과 통계
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            Localizations.localeOf(context).languageCode == 'ko'
                              ? '오늘의 성과'
                              : "Today's Achievement",
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    Localizations.localeOf(context).languageCode == 'ko'
                                      ? '총 푸시업'
                                      : 'Total Push-ups',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    '${_todayCompletedWorkout!.totalReps}회',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    Localizations.localeOf(context).languageCode == 'ko'
                                      ? '완료율'
                                      : 'Completion Rate',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    '${(_todayCompletedWorkout!.completionRate * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    Localizations.localeOf(context).languageCode == 'ko'
                                      ? '운동시간'
                                      : 'Duration',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    '${_todayCompletedWorkout!.duration.inMinutes}분',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
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
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withValues(alpha: 0.1),
                      Colors.red.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.sports_mma,
                      color: Colors.orange[700],
                      size: 48,
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    Text(
                      '💪 잠깐! 너 진짜 쉴 거야?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    Text(
                      '오늘은 프로그램상 휴식일이지만...\n진짜 챔피언들은 쉬지 않는다! 🔥\n\n'
                      '몸이 쑤신다고? 그게 바로 성장의 신호야!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    
                    // 도전 버튼
                    ElevatedButton.icon(
                      onPressed: () => _showExtraWorkoutChallenge(),
                      icon: Icon(Icons.whatshot, color: Colors.white),
                      label: Text(
                        '그래도 도전한다! 🔥',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingL,
                          vertical: AppConstants.paddingM,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    
                    // 쉬기 버튼
                    TextButton.icon(
                      onPressed: () => _showRestDayAcceptance(),
                      icon: Icon(Icons.bed, color: Colors.grey[600]),
                      label: Text(
                        '오늘은 쉴래... 😴',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
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
                Localizations.localeOf(context).languageCode == 'ko'
                  ? '프로그램 진행률'
                  : 'Program Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(AppColors.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          
          // 전체 프로그램 진행률
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.track_changes, color: Color(AppColors.primaryColor)),
                    const SizedBox(width: 8),
                    Text(
                      Localizations.localeOf(context).languageCode == 'ko'
                        ? '전체 프로그램 진행도'
                        : 'Overall Program Progress',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  Localizations.localeOf(context).languageCode == 'ko'
                    ? '${_programProgress!.completedWeeks}/${_programProgress!.totalWeeks} 주차'
                    : '${_programProgress!.completedWeeks}/${_programProgress!.totalWeeks} weeks',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_programProgress!.totalWeeks as num? ?? 0) > 0
                      ? ((_programProgress!.completedWeeks ?? 0) as num).toDouble() / (_programProgress!.totalWeeks as num).toDouble()
                      : 0.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(AppColors.primaryColor)),
                ),
                const SizedBox(height: 16),
                Text(
                  Localizations.localeOf(context).languageCode == 'ko'
                    ? '이번 주 (${_programProgress!.completedWeeks}주차)'
                    : 'This Week (Week ${_programProgress!.completedWeeks})',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_programProgress!.completedDaysThisWeek}/${_programProgress!.totalDaysThisWeek}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      Localizations.localeOf(context).languageCode == 'ko'
                        ? '${_programProgress!.completedWeeks}/${_programProgress!.totalWeeks} 주 완료'
                        : '${_programProgress!.completedWeeks}/${_programProgress!.totalWeeks} weeks completed',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 통계 카드들
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  Localizations.localeOf(context).languageCode == 'ko'
                    ? '총 푸시업'
                    : 'Total Push-ups',
                  '${_programProgress!.totalCompletedReps}회',
                  Icons.fitness_center,
                  const Color(AppColors.primaryColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  Localizations.localeOf(context).languageCode == 'ko'
                    ? '남은 목표'
                    : 'Remaining Goal',
                  '${(100 - ((_programProgress!.totalCompletedReps ?? 0) as num)).toInt()}회',
                  Icons.flag,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: AppConstants.paddingS),
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
                  AppLocalizations.of(context)!.tutorialButton,
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
              backgroundColor: const Color(AppColors.secondaryColor), // 앱 테마의 secondaryColor 사용
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
              backgroundColor: const Color(AppColors.primaryColor), // 앱 테마의 primaryColor 사용
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
        
        // 차드 쇼츠 버튼 (비활성화)
        /*
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
        */
        
        // const SizedBox(height: AppConstants.paddingM),
        
        const SizedBox(height: AppConstants.paddingM),
        
        // 친구 도전장 공유 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // SocialShareService.shareFriendChallenge(
              //   context: context,
              //   userName: 'ALPHA EMPEROR',
              // );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('친구 도전장 기능은 준비 중입니다! 🚀'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            icon: const Icon(Icons.share, color: Colors.white),
            label: Text(
              AppLocalizations.of(context)!.sendFriendChallenge,
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
      AppLocalizations.of(context)!.bottomMotivation,
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

    // 워크아웃 시작 전 챌린지 설정 다이얼로그 표시
    await _showPreWorkoutChallengeDialog();

    try {
      // 워크아웃 화면으로 이동
      if (context.mounted) {
        // await Navigator.of(context).push(
        //   MaterialPageRoute<void>(
        //     builder: (context) => WorkoutScreen(
        //       userProfile: _userProfile!,
        //       workoutData: _todayWorkout!,
        //     ),
        //   ),
        // );
        
        // 임시: 워크아웃 화면 기능이 준비될 때까지 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('워크아웃 화면 기능은 준비 중입니다! 🏋️‍♂️'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
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
              AppLocalizations.of(context)!.workoutStartError(e.toString()),
            ),
            backgroundColor: const Color(AppColors.errorColor),
          ),
        );
      }
    }
  }

  /// 워크아웃 시작 전 챌린지 설정 다이얼로그
  Future<void> _showPreWorkoutChallengeDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.orange[700], size: 28),
            const SizedBox(width: 8),
            const Text('🔥 준비됐어?'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withValues(alpha: 0.1),
                      Colors.red.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '이번엔 어떻게 도전할까? 💪',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '그냥 기본 운동? 아니면 진짜 챔피언 모드? 🚀\n'
                      '너의 한계를 시험해볼 시간이다!\n\n'
                      '⚡ 챌린지 모드 ON 하면:\n'
                      '• 더 높은 난이도\\n'
                      '• 보너스 포인트 획득 🏆',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, false),
            icon: Icon(Icons.fitness_center, color: Colors.grey[600]),
            label: Text(
              '그냥 기본만 할래... 😅',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.whatshot, color: Colors.white),
            label: const Text(
              '챌린지 모드 ON! 🔥',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
          ),
        ],
      ),
    );

    // 챌린지 모드 선택에 따른 메시지
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔥 챌린지 모드 활성화! 정신력을 시험해보자! 💪'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// 이미 완료된 운동에 대한 메시지
  void _showAlreadyCompletedMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Localizations.localeOf(context).languageCode == 'ko'
            ? '운동 이미 완료'
            : 'Already Completed',
        ),
        content: Text(
          Localizations.localeOf(context).languageCode == 'ko'
            ? '오늘의 운동은 이미 완료했습니다! 💪'
            : "Today's workout is already completed! 💪",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  /// 휴식일 추가 운동 챌린지 다이얼로그
  void _showExtraWorkoutChallenge() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.orange[700], size: 28),
            const SizedBox(width: 8),
            const Text('🔥 진짜 챔피언의 선택'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withValues(alpha: 0.1),
                    Colors.red.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '💪 오늘 너의 한계를 시험해볼까?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '휴식일이라고? 그런 건 약한 놈들이나 하는 거야!\n'
                    '진짜 챔피언들은 매일이 전쟁이다! 🥊\n\n'
                    '간단한 추가 챌린지로 너의 정신력을 증명해봐!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _startExtraChallenge();
            },
            icon: Icon(Icons.fitness_center, color: Colors.orange[700]),
            label: Text(
              '도전한다! 💪',
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Localizations.localeOf(context).languageCode == 'ko' 
                ? '나중에...' 
                : 'Later...',
            ),
          ),
        ],
      ),
    );
  }

  /// 휴식일 수용 다이얼로그 (살짝 놀리기)
  void _showRestDayAcceptance() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 40,
                color: Colors.orange[700],
              ),
              const SizedBox(height: 8),
              Text(
                Localizations.localeOf(context).languageCode == 'ko'
                  ? '휴식일 챌린지! 💪'
                  : 'Rest Day Challenge! 💪',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'ko'
                      ? '누군가는 100개 푸시업하고 있어! 💪\n\n'
                        '휴식일이지만 가벼운 챌린지는 어때요?\n\n'
                        '✨ 오늘의 보너스 챌린지:\n'
                        '• 푸시업 10개 (완벽한 자세로!)\n\n'
                        '참여하면 특별 포인트를 드려요! 🎁'
                      : 'Someone is doing 100 push-ups! 💪\n\n'
                        'It\'s a rest day, but how about a light challenge?\n\n'
                        '✨ Today\'s Bonus Challenge:\n'
                        '• 10 push-ups (perfect form!)\n\n'
                        'Join and get special points! 🎁',
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'ko'
                        ? '오늘은 진짜 쉴래요'
                        : 'I really want to rest today',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // 여기에 보너스 챌린지 시작 로직 추가
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'ko'
                        ? '챌린지 해볼게요!'
                        : 'Let\'s do the challenge!',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// 추가 챌린지 시작
  void _startExtraChallenge() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔥 보너스 챌린지'),
        content: Text(
          Localizations.localeOf(context).languageCode == 'ko' 
            ? '휴식일 보너스 챌린지! 💪\n\n'
              '• 플랭크 30초 x 3세트\n'
              '• 스쿼트 20개 x 2세트\n'
              '• 푸시업 10개 (완벽한 자세로!)\n\n'
              '준비됐어? 진짜 챔피언만 할 수 있어! 🏆'
            : 'Rest Day Bonus Challenge! 💪\n\n'
              '• Plank 30sec x 3sets\n'
              '• Squat 20reps x 2sets\n'
              '• Push-up 10reps (perfect form!)\n\n'
              'Ready? Only true champions can do this! 🏆'
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔥 훌륭해! 진짜 챔피언의 정신력이야! 💪'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
            child: const Text(
              '시작! 🔥',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('나중에...'),
          ),
        ],
      ),
    );
  }

  void _openTutorial(BuildContext context) async {
    // 튜토리얼 조회 카운트 증가
    try {
      // await AchievementService.incrementTutorialViewCount();
      debugPrint('🎓 튜토리얼 조회 카운트 증가 (임시 비활성화)');
    } catch (e) {
      debugPrint('❌ 튜토리얼 카운트 증가 실패: $e');
    }
    
    if (context.mounted) {
      // await Navigator.of(context).push(
      //   MaterialPageRoute<void>(builder: (context) => PushupTutorialScreen()),
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('푸시업 튜토리얼 기능은 준비 중입니다! 📚'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _openFormGuide(BuildContext context) async {
    if (context.mounted) {
      // await Navigator.of(context).push(
      //   MaterialPageRoute<void>(
      //     builder: (context) => const PushupFormGuideScreen(),
      //   ),
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('푸시업 폼 가이드 기능은 준비 중입니다! 💪'),
          backgroundColor: Colors.orange,
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
      // await Navigator.of(context).push(
      //   MaterialPageRoute<void>(
      //     builder: (context) => ProgressTrackingScreen(
      //       userProfile: _userProfile!,
      //     ),
      //   ),
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('진행률 추적 기능은 준비 중입니다! 📊'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// 운동 재개 가능 여부 체크 및 다이얼로그 표시
  Future<void> _checkWorkoutResumption() async {
    // if (!mounted) return;
    
    // try {
    //   debugPrint('🔍 운동 재개 체크 시작');
      
    //   final hasResumableWorkout = await WorkoutResumptionService.hasResumableWorkout();
      
    //   if (hasResumableWorkout && mounted) {
    //     debugPrint('📋 재개 가능한 운동 발견, 다이얼로그 표시');
        
    //     final resumptionData = await WorkoutResumptionService.getResumptionData();
        
    //     if (resumptionData != null && resumptionData.hasResumableData && mounted) {
    //       await _showWorkoutResumptionDialog(resumptionData);
    //     }
    //   } else {
    //     debugPrint('✅ 재개할 운동 없음');
    //   }
    // } catch (e) {
    //   debugPrint('❌ 운동 재개 체크 오류: $e');
    // }
    debugPrint('운동 재개 기능은 임시 비활성화됨');
  }

  /// 운동 재개 다이얼로그 표시
  Future<void> _showWorkoutResumptionDialog(dynamic resumptionData) async {
    // if (!mounted) return;
    
    // try {
    //   final shouldResume = await showWorkoutResumptionDialog(
    //     context: context,
    //     resumptionData: resumptionData,
    //   );

    //   if (shouldResume == true && mounted) {
    //     debugPrint('🔄 운동 재개 선택됨');
    //     await _resumeWorkout(resumptionData);
    //   } else if (shouldResume == false && mounted) {
    //     debugPrint('🆕 새 운동 시작 선택됨');
    //     await _startNewWorkout();
    //   }
    // } catch (e) {
    //   debugPrint('❌ 운동 재개 다이얼로그 오류: $e');
      
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('운동 재개 처리 중 오류가 발생했습니다.'),
    //         backgroundColor: Colors.red,
    //       ),
    //     );
    //   }
    // }
    debugPrint('운동 재개 다이얼로그 기능은 임시 비활성화됨');
  }

  /// 운동 재개 실행
  Future<void> _resumeWorkout(dynamic resumptionData) async {
    // if (!mounted) return;

    // try {
    //   final primaryData = resumptionData.primaryData;
    //   if (primaryData == null) return;

    //   // 재개 통계 기록
    //   final completedRepsStr = primaryData['completedReps'] as String? ?? '';
    //   final completedReps = completedRepsStr.isNotEmpty 
    //       ? completedRepsStr.split(',').map(int.parse).toList()
    //       : <int>[];
      
    //   final completedSetsCount = completedReps.where((reps) => reps > 0).length;
    //   final totalCompletedReps = completedReps.fold(0, (sum, reps) => sum + reps);
      
    //   await WorkoutResumptionService.recordResumptionStats(
    //     resumptionSource: resumptionData.dataSource,
    //     recoveredSets: completedSetsCount,
    //     recoveredReps: totalCompletedReps,
    //   );

    //   // 운동 화면으로 이동 (재개 모드)
    //   if (mounted) {
    //     final result = await Navigator.push<bool>(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => WorkoutScreen(
    //           userProfile: _userProfile!,
    //           workoutData: _todayWorkout!,
    //         ),
    //       ),
    //     );

    //     // 운동 완료 후 데이터 새로고침
    //     if (result == true && mounted) {
    //       await _refreshData();
          
    //       // 백업 데이터 정리
    //       await WorkoutResumptionService.clearBackupData();
          
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(
    //           content: Text('🎉 운동이 성공적으로 재개되었습니다!'),
    //           backgroundColor: Colors.green,
    //         ),
    //       );
    //     }
    //   }
    // } catch (e) {
    //   debugPrint('❌ 운동 재개 실행 오류: $e');
      
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('운동 재개 중 오류가 발생했습니다.'),
    //         backgroundColor: Colors.red,
    //       ),
    //     );
    //   }
    // }
    debugPrint('운동 재개 실행 기능은 임시 비활성화됨');
  }

  /// 새 운동 시작 (백업 데이터 정리)
  Future<void> _startNewWorkout() async {
    // try {
    //   debugPrint('🧹 새 운동 시작을 위한 백업 데이터 정리');
      
    //   // 백업 데이터 정리
    //   await WorkoutResumptionService.clearBackupData();
      
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('새로운 운동을 시작할 준비가 되었습니다!'),
    //         backgroundColor: Colors.blue,
    //       ),
    //     );
    //   }
    // } catch (e) {
    //   debugPrint('❌ 새 운동 시작 준비 오류: $e');
    // }
    debugPrint('새 운동 시작 기능은 임시 비활성화됨');
  }

  /// 완벽 자세 챌린지 시작
  void _startFormChallenge() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎯 완벽 자세 챌린지 활성화! 대충하면 안 된다! 💪'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// 연속 챌린지 시작
  void _startStreakChallenge() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 7일 연속 챌린지 시작! 하루라도 빠지면 처음부터! 🚀'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
