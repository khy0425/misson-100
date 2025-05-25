import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../generated/app_localizations.dart';
import '../utils/constants.dart';
import '../services/ad_service.dart';
import '../models/user_profile.dart';
import '../services/workout_program_service.dart';

class WorkoutScreen extends StatefulWidget {
  final UserProfile userProfile;
  final TodayWorkout todayWorkout;

  const WorkoutScreen({
    super.key,
    required this.userProfile,
    required this.todayWorkout,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with TickerProviderStateMixin {
  // 워크아웃 상태
  int _currentSet = 0;
  int _currentReps = 0;
  List<int> _completedReps = [];
  bool _isSetCompleted = false;
  bool _isRestTime = false;
  int _restTimeRemaining = 0;
  Timer? _restTimer;

  // 스크롤 컨트롤러 및 힌트 애니메이션
  late ScrollController _scrollController;
  Timer? _scrollHintTimer;

  // 워크아웃 데이터
  late List<int> _targetReps;
  late int _restTimeSeconds;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeWorkout();
    _startScrollHintAnimation();
  }

  void _initializeWorkout() {
    _targetReps = widget.todayWorkout.workout;
    _restTimeSeconds = widget.todayWorkout.restTimeSeconds;
    _completedReps = List.filled(_targetReps.length, 0);
  }

  void _startScrollHintAnimation() {
    // 화면 로드 완료 후 2초 뒤에 스크롤 힌트 애니메이션 시작 (워크아웃은 조금 더 늦게)
    _scrollHintTimer = Timer(const Duration(milliseconds: 2000), () {
      if (_scrollController.hasClients && !_isRestTime) {
        _performScrollHint();
      }
    });
  }

  void _performScrollHint() async {
    if (!_scrollController.hasClients) return;

    try {
      // 현재 위치 저장
      final currentPosition = _scrollController.offset;

      // 살짝 아래로 스크롤 (120px 정도 - 워크아웃 화면은 좀 더 많이)
      await _scrollController.animateTo(
        currentPosition + 120,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );

      // 1초 대기 (사용자가 인지할 시간)
      await Future.delayed(const Duration(milliseconds: 1000));

      // 원래 위치로 부드럽게 돌아가기
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          currentPosition,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
        );
      }
    } catch (e) {
      // 애니메이션 중 에러 발생 시 무시 (사용자가 스크롤하는 경우 등)
      debugPrint('워크아웃 스크롤 힌트 애니메이션 에러: $e');
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _scrollHintTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
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

    // 약간의 지연 후 다음 단계 진행
    Future.delayed(const Duration(milliseconds: 500), () {
      // 마지막 세트가 아니면 휴식 시간 시작
      if (_currentSet < _totalSets - 1) {
        _startRestTimer();
      } else {
        _completeWorkout();
      }
    });
  }

  void _startRestTimer() {
    setState(() {
      _isRestTime = true;
      _restTimeRemaining = _restTimeSeconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  void _completeWorkout() {
    // TODO: 워크아웃 완료 처리 (데이터베이스 저장 등)
    HapticFeedback.heavyImpact();

    // 워크아웃 완료 시 전면 광고 표시
    AdService.showWorkoutCompleteAd();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).workoutCompleteTitle),
        content: Text(
          AppLocalizations.of(context).workoutCompleteMessage(
            widget.todayWorkout.title,
            widget.todayWorkout.totalReps,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // 홈으로 돌아가기
            },
            child: Text(AppLocalizations.of(context).workoutCompleteButton),
          ),
        ],
      ),
    );
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
      body: Column(
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
        color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        children: [
          Text(
            widget.todayWorkout.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(AppColors.primaryColor),
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
                    color: const Color(AppColors.primaryColor),
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
                  color: const Color(AppColors.primaryColor),
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

    // 반응형 패딩과 여백
    final padding = isSmallScreen
        ? AppConstants.paddingM
        : AppConstants.paddingXL;
    final spacing = isSmallScreen
        ? AppConstants.paddingM
        : AppConstants.paddingL;
    final fontSize = isSmallScreen ? 48.0 : 64.0;

    if (_isRestTime) {
      return _buildRestTimer();
    }

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: _getPerformanceColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: _isSetCompleted
              ? const Color(AppColors.successColor)
              : const Color(AppColors.primaryColor),
          width: 3,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 목표 횟수 표시 (반응형)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing,
              vertical: spacing / 2,
            ),
            decoration: BoxDecoration(
              color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: const Color(
                  AppColors.primaryColor,
                ).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.track_changes,
                  color: const Color(AppColors.primaryColor),
                  size: isSmallScreen ? 20 : 24,
                ),
                SizedBox(width: spacing / 2),
                Text(
                  AppLocalizations.of(
                    context,
                  ).targetRepsLabel(_currentTargetReps),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(AppColors.primaryColor),
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 16.0 : 20.0,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: spacing),

          if (_isSetCompleted) ...[
            // 세트 완료 상태
            _buildCompletionStatus(),
          ] else ...[
            // 실제 수행 횟수 입력 영역
            Text(
              AppLocalizations.of(context).repLogMessage,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(AppColors.primaryColor),
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14.0 : 16.0,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: spacing),

            // 현재 입력된 횟수 큰 표시 (반응형)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing,
                vertical: spacing,
              ),
              decoration: BoxDecoration(
                color: _getPerformanceColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: Border.all(color: _getPerformanceColor(), width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    '$_currentReps',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: _getPerformanceColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                  Text(
                    _getPerformanceMessage(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _getPerformanceColor(),
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 12.0 : 14.0,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: spacing),

            // 빠른 입력 버튼들 (반응형)
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: isSmallScreen
                      ? AppConstants.paddingS / 2
                      : AppConstants.paddingS,
                  runSpacing: isSmallScreen
                      ? AppConstants.paddingS / 2
                      : AppConstants.paddingS,
                  alignment: WrapAlignment.center,
                  children: [
                    // 목표 달성 버튼
                    _buildQuickInputButton(
                      _currentTargetReps,
                      AppLocalizations.of(context).quickInputPerfect,
                      const Color(AppColors.successColor),
                      isSmallScreen,
                    ),

                    // 목표 -1~3 버튼들 (현실적인 범위)
                    if (_currentTargetReps > 1)
                      _buildQuickInputButton(
                        (_currentTargetReps * 0.8).round(),
                        AppLocalizations.of(context).quickInputStrong,
                        Colors.orange,
                        isSmallScreen,
                      ),

                    if (_currentTargetReps > 2)
                      _buildQuickInputButton(
                        (_currentTargetReps * 0.6).round(),
                        AppLocalizations.of(context).quickInputMedium,
                        Colors.orange[700]!,
                        isSmallScreen,
                      ),

                    // 절반 버튼
                    if (_currentTargetReps > 2)
                      _buildQuickInputButton(
                        _currentTargetReps ~/ 2,
                        AppLocalizations.of(context).quickInputStart,
                        Colors.grey[600]!,
                        isSmallScreen,
                      ),

                    // 목표 초과 버튼
                    _buildQuickInputButton(
                      _currentTargetReps + 2,
                      AppLocalizations.of(context).quickInputBeast,
                      const Color(AppColors.primaryColor),
                      isSmallScreen,
                    ),
                  ],
                );
              },
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
                    backgroundColor: const Color(AppColors.primaryColor),
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

  Widget _buildCompletionStatus() {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenHeight < 700;

    final iconSize = isSmallScreen ? 60.0 : 80.0;
    final spacing = isSmallScreen
        ? AppConstants.paddingS
        : AppConstants.paddingM;

    final achievedGoal = _currentReps >= _currentTargetReps;
    final percentage = (_currentReps / _currentTargetReps * 100).round();

    return Column(
      children: [
        // 성취 아이콘
        Icon(
          achievedGoal ? Icons.celebration : Icons.thumb_up,
          color: _getPerformanceColor(),
          size: iconSize,
        ),

        SizedBox(height: spacing),

        // 완료 메시지
        Text(
          achievedGoal
              ? AppLocalizations.of(context).setCompletedSuccess
              : AppLocalizations.of(context).setCompletedGood,
          style: theme.textTheme.displaySmall?.copyWith(
            color: _getPerformanceColor(),
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 24.0 : 32.0,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: spacing / 2),

        // 수행 결과
        Text(
          AppLocalizations.of(context).resultFormat(_currentReps, percentage),
          style: theme.textTheme.titleLarge?.copyWith(
            color: _getPerformanceColor(),
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 16.0 : 20.0,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: spacing / 2),

        // 격려 메시지
        Text(
          _getMotivationalMessage(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 12.0 : 14.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getPerformanceColor() {
    if (_currentReps >= _currentTargetReps) {
      return const Color(AppColors.successColor); // 목표 달성
    } else if (_currentReps >= _currentTargetReps * 0.8) {
      return const Color(AppColors.primaryColor); // 80% 이상
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
        color: const Color(AppColors.secondaryColor).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: const Color(AppColors.secondaryColor),
          width: 3,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: const Color(AppColors.secondaryColor),
            size: iconSize,
          ),
          SizedBox(height: padding / 2),
          Text(
            AppLocalizations.of(context).restTimeTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(AppColors.secondaryColor),
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16.0 : 20.0,
            ),
          ),
          SizedBox(height: padding),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: theme.textTheme.displayLarge?.copyWith(
              color: const Color(AppColors.secondaryColor),
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
              color: const Color(
                AppColors.secondaryColor,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Text(
              AppLocalizations.of(context).restMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(AppColors.secondaryColor),
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
                backgroundColor: const Color(AppColors.secondaryColor),
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
            backgroundColor: const Color(AppColors.successColor),
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
            color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Text(
            AppLocalizations.of(context).guidanceMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(AppColors.primaryColor),
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
                  ? const Color(AppColors.primaryColor)
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
    final bannerAd = AdService.getBannerAd();

    return Container(
      height: 60,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Color(AppColors.primaryColor), width: 1),
        ),
      ),
      child: bannerAd != null
          ? AdWidget(ad: bannerAd)
          : Container(
              height: 60,
              color: const Color(0xFF1A1A1A),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: Color(AppColors.primaryColor),
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '차드의 힘을 느껴라! 💪',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
