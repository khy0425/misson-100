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
import '../models/chad_evolution.dart';
import '../models/user_profile.dart';
import '../utils/workout_data.dart';
import '../widgets/ad_banner_widget.dart';
import 'workout_screen.dart';
import 'pushup_tutorial_screen.dart';
import 'pushup_form_guide_screen.dart';
import 'youtube_shorts_screen.dart';
import 'progress_tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final WorkoutProgramService _workoutProgramService = WorkoutProgramService();
  
  UserProfile? _userProfile;
  TodayWorkout? _todayWorkout;
  ProgramProgress? _programProgress;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
                        
                        // Chad 진화 테스트 버튼 (디버그용)
                        if (kDebugMode)
                          _buildDebugEvolutionButton(context, theme),
                        
                        const SizedBox(height: AppConstants.paddingL),
                        
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
                    color: const Color(AppColors.primaryColor),
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
                  Icons.fitness_center,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: AppConstants.paddingS),
                Text(
                  '총 ${_todayWorkout!.totalReps}회 (${_todayWorkout!.setCount}세트)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingL),
            
            // 시작 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.celebration,
                    color: Colors.grey,
                    size: 48,
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Text(
                    '오늘은 휴식일입니다!',
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
              todayWorkout: _todayWorkout!,
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

  void _openTutorial(BuildContext context) async {
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

  Widget _buildDebugEvolutionButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _debugEvolution(context),
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
              'Chad 진화 테스트',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _debugEvolution(BuildContext context) {
    final chadService = Provider.of<ChadEvolutionService>(context, listen: false);
    
    // 현재 Chad와 다음 Chad 가져오기
    final currentChad = chadService.currentChad;
    final currentStage = chadService.evolutionState.currentStage;
    
    // 다음 단계 찾기
    final nextStageIndex = currentStage.index + 1;
    if (nextStageIndex < ChadEvolutionStage.values.length) {
      final nextStage = ChadEvolutionStage.values[nextStageIndex];
      final nextChad = ChadEvolution.defaultStages.firstWhere(
        (chad) => chad.stage == nextStage,
      );
      
      // 진화 애니메이션 시작
      chadService.startEvolutionAnimation(currentChad, nextChad);
      
      // 실제 진화도 실행 (3초 후)
      Future.delayed(const Duration(seconds: 3), () {
        chadService.evolveToNextStage();
      });
    } else {
      // 이미 최고 단계인 경우 첫 번째 단계로 리셋
      final firstChad = ChadEvolution.defaultStages.first;
      chadService.resetEvolution();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최고 단계입니다. 첫 번째 단계로 리셋했습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
