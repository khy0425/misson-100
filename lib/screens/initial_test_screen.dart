import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../generated/app_localizations.dart';
import '../utils/constants.dart';
import '../utils/workout_data.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../services/workout_program_service.dart';

class InitialTestScreen extends StatefulWidget {
  const InitialTestScreen({super.key});

  @override
  State<InitialTestScreen> createState() => _InitialTestScreenState();
}

class _InitialTestScreenState extends State<InitialTestScreen>
    with TickerProviderStateMixin {
  UserLevel? _selectedLevel;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;
  Timer? _scrollHintTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _setupAnimations();
    _startScrollHintAnimation();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _slideController.forward();
  }

  void _startScrollHintAnimation() {
    // 화면 로드 완료 후 1.5초 뒤에 스크롤 힌트 애니메이션 시작
    _scrollHintTimer = Timer(Duration(milliseconds: 1500), () {
      if (_scrollController.hasClients) {
        _performScrollHint();
      }
    });
  }

  void _performScrollHint() async {
    if (!_scrollController.hasClients) return;

    try {
      // 현재 위치 저장
      final currentPosition = _scrollController.offset;

      // 살짝 아래로 스크롤 (100px 정도)
      _scrollController.animateTo(
        currentPosition + 100,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      // 0.8초 대기 (사용자가 인지할 시간)
      Future<void>.delayed(Duration(milliseconds: 800));

      // 원래 위치로 부드럽게 돌아가기
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          currentPosition,
          duration: Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
        );
      }
    } catch (e) {
      // 애니메이션 중 에러 발생 시 무시 (사용자가 스크롤하는 경우 등)
      debugPrint('스크롤 힌트 애니메이션 에러: $e');
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scrollController.dispose();
    _scrollHintTimer?.cancel();
    super.dispose();
  }

  void _selectLevel(UserLevel level) {
    setState(() {
      _selectedLevel = level;
    });
    HapticFeedback.mediumImpact();
  }

  void _onSubmit() {
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).selectLevelButton),
          backgroundColor: Color(AppColors.errorColor),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    _saveUserProfile();
  }

  Future<void> _saveUserProfile() async {
    final databaseService = DatabaseService();
    final workoutProgramService = WorkoutProgramService();

    try {
      // 난이도별 초기 푸시업 개수 설정
      final initialMaxReps = _getInitialMaxReps(_selectedLevel!);

      // 사용자 프로필 생성
      final userProfile = UserProfile(
        level: _selectedLevel!,
        initialMaxReps: initialMaxReps,
        startDate: DateTime.now(),
        chadLevel: 0, // 시작 레벨
        reminderEnabled: false,
      );

      // 데이터베이스에 사용자 프로필 저장
      final userId = await databaseService.insertUserProfile(userProfile);

      // 사용자 워크아웃 프로그램 초기화
      final sessionsCreated = await workoutProgramService.initializeUserProgram(
        userProfile.copyWith(id: userId),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).profileCreated(sessionsCreated),
            ),
            backgroundColor: Color(AppColors.successColor),
            duration: Duration(seconds: 2),
          ),
        );

        // 홈 화면으로 이동
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).profileCreationError(e.toString()),
            ),
            backgroundColor: Color(AppColors.errorColor),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  int _getInitialMaxReps(UserLevel level) {
    switch (level) {
      case UserLevel.rookie:
        return 3; // 초급 - 6개 미만 할 수 있는 사람 (시작은 3개 정도)
      case UserLevel.rising:
        return 8; // 중급 - 6-10개 할 수 있는 사람 (평균 8개)
      case UserLevel.alpha:
        return 15; // 고급 - 11개 이상 할 수 있는 사람 (여유 있게 15개)
      case UserLevel.giga:
        return 25; // 최고급 - 추후 확장용 (25개)
    }
  }

  Widget _buildLevelCard(
    UserLevel level,
    String title,
    String subtitle,
    String description,
    List<String> features,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedLevel == level;
    final levelColor = Color(
      WorkoutData.levelColors[level] ?? AppColors.primaryColor,
    );

    return GestureDetector(
      onTap: () => _selectLevel(level),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: AppConstants.paddingL),
        padding: EdgeInsets.all(AppConstants.paddingL),
        decoration: BoxDecoration(
          color: isSelected
              ? levelColor.withValues(alpha: 0.15)
              : Color(isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: isSelected ? levelColor : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: levelColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppConstants.paddingM),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Icon(icon, color: levelColor, size: 32),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: levelColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: levelColor, size: 28),
              ],
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            ...features.map(
              (feature) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.fiber_manual_record, color: levelColor, size: 8),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: Text(
                        feature,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Color(
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).levelSelectionTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 상단 설명
                Container(
                  padding: EdgeInsets.all(AppConstants.paddingL),
                  decoration: BoxDecoration(
                    color: Color(AppColors.primaryColor).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context).levelSelectionHeader,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Color(AppColors.primaryColor),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      Text(
                        AppLocalizations.of(context).levelSelectionDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.paddingXL),

                // 난이도 선택 카드들
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildLevelCard(
                          UserLevel.rookie,
                          AppLocalizations.of(context).rookieLevelTitle,
                          AppLocalizations.of(context).rookieLevelSubtitle,
                          AppLocalizations.of(context).rookieLevelDescription,
                          [
                            AppLocalizations.of(context).rookieFeature1,
                            AppLocalizations.of(context).rookieFeature2,
                            AppLocalizations.of(context).rookieFeature3,
                            AppLocalizations.of(context).rookieFeature4,
                          ],
                          Icons.directions_walk,
                        ),

                        _buildLevelCard(
                          UserLevel.rising,
                          AppLocalizations.of(context).risingLevelTitle,
                          AppLocalizations.of(context).risingLevelSubtitle,
                          AppLocalizations.of(context).risingLevelDescription,
                          [
                            AppLocalizations.of(context).risingFeature1,
                            AppLocalizations.of(context).risingFeature2,
                            AppLocalizations.of(context).risingFeature3,
                            AppLocalizations.of(context).risingFeature4,
                          ],
                          Icons.directions_run,
                        ),

                        _buildLevelCard(
                          UserLevel.alpha,
                          AppLocalizations.of(context).alphaLevelTitle,
                          AppLocalizations.of(context).alphaLevelSubtitle,
                          AppLocalizations.of(context).alphaLevelDescription,
                          [
                            AppLocalizations.of(context).alphaFeature1,
                            AppLocalizations.of(context).alphaFeature2,
                            AppLocalizations.of(context).alphaFeature3,
                            AppLocalizations.of(context).alphaFeature4,
                          ],
                          Icons.flash_on,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingL),

                // 시작 버튼
                SizedBox(
                  height: AppConstants.buttonHeightL,
                  child: ElevatedButton(
                    onPressed: _selectedLevel != null ? _onSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.primaryColor),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusM,
                        ),
                      ),
                      elevation: AppConstants.elevationM,
                    ),
                    child: Text(
                      _selectedLevel != null
                          ? AppLocalizations.of(
                              context,
                            ).startWithLevel(_getLevelTitle(_selectedLevel!))
                          : AppLocalizations.of(context).selectLevelButton,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLevelTitle(UserLevel level) {
    switch (level) {
      case UserLevel.rookie:
        return AppLocalizations.of(context).rookieShort;
      case UserLevel.rising:
        return AppLocalizations.of(context).risingShort;
      case UserLevel.alpha:
        return AppLocalizations.of(context).alphaShort;
      case UserLevel.giga:
        return AppLocalizations.of(context).gigaShort;
    }
  }
}
