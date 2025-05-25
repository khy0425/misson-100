import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';
import '../models/workout_history.dart';
import '../services/workout_history_service.dart';
import '../services/ad_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  // 애니메이션 컨트롤러
  late AnimationController _counterController;
  late AnimationController _chartController;
  late Animation<double> _counterAnimation;

  // 데이터
  List<WorkoutHistory> _workoutHistory = [];
  bool _isLoading = true;

  // 통계 데이터
  int _totalWorkouts = 0;
  int _totalPushups = 0;
  double _averageCompletion = 0.0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _thisMonthWorkouts = 0;

  // 광고
  BannerAd? _statisticsBannerAd;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadBannerAd();
    _loadStatistics();
  }

  void _setupAnimations() {
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _counterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _counterController, curve: Curves.easeOutBack),
    );
  }

  void _loadBannerAd() {
    _statisticsBannerAd = AdService.getBannerAd();
  }

  Future<void> _loadStatistics() async {
    try {
      final history = await WorkoutHistoryService.getAllWorkouts();

      setState(() {
        _workoutHistory = history;
        _calculateStatistics();
        _isLoading = false;
      });

      // 애니메이션 시작
      _counterController.forward();
      Future.delayed(const Duration(milliseconds: 500), () {
        _chartController.forward();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('통계 로딩 실패: $e');
    }
  }

  void _calculateStatistics() {
    if (_workoutHistory.isEmpty) return;

    // 기본 통계 계산
    _totalWorkouts = _workoutHistory.length;
    _totalPushups = _workoutHistory.fold(
      0,
      (sum, workout) => sum + workout.totalReps,
    );
    _averageCompletion =
        _workoutHistory.fold(
          0.0,
          (sum, workout) => sum + workout.completionRate,
        ) /
        _totalWorkouts;

    // 연속 운동일 계산
    _calculateStreaks();

    // 이번 주/월 운동 횟수 계산
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    _thisMonthWorkouts = _workoutHistory
        .where(
          (w) => w.date.isAfter(monthStart.subtract(const Duration(days: 1))),
        )
        .length;
  }

  void _calculateStreaks() {
    if (_workoutHistory.isEmpty) return;

    // 날짜별로 정렬 (최신순)
    final sortedHistory = List<WorkoutHistory>.from(_workoutHistory)
      ..sort((a, b) => b.date.compareTo(a.date));

    // 현재 연속일 계산
    _currentStreak = 0;
    final today = DateTime.now();

    for (int i = 0; i < sortedHistory.length; i++) {
      final workoutDate = sortedHistory[i].date;
      final daysDiff = today
          .difference(
            DateTime(workoutDate.year, workoutDate.month, workoutDate.day),
          )
          .inDays;

      if (daysDiff == i) {
        _currentStreak++;
      } else {
        break;
      }
    }

    // 최고 연속일 계산
    _bestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final workout in sortedHistory.reversed) {
      final workoutDate = DateTime(
        workout.date.year,
        workout.date.month,
        workout.date.day,
      );

      if (lastDate == null || workoutDate.difference(lastDate).inDays == 1) {
        currentStreak++;
        _bestStreak = currentStreak > _bestStreak ? currentStreak : _bestStreak;
      } else {
        currentStreak = 1;
      }
      lastDate = workoutDate;
    }
  }

  @override
  void dispose() {
    _counterController.dispose();
    _chartController.dispose();
    _statisticsBannerAd?.dispose();
    super.dispose();
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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.analytics,
              color: Color(AppColors.primaryColor),
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              '차드 통계',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color(AppColors.primaryColor),
            ),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _counterController.reset();
              _chartController.reset();
              _loadStatistics();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _workoutHistory.isEmpty
                ? _buildEmptyState()
                : _buildStatisticsContent(),
          ),
          _buildBannerAd(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(AppColors.primaryColor)),
          SizedBox(height: 16),
          Text(
            '차드의 통계를 불러오는 중...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '아직 운동 기록이 없어!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 운동을 시작하고\\n차드의 전설을 만들어보자! 🔥',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 메인 통계 카드들
          _buildMainStatsCards(),
          const SizedBox(height: AppConstants.paddingL),
          // 연속 운동일 섹션
          _buildStreakSection(),
          const SizedBox(height: AppConstants.paddingL),
          // 최근 운동 기록
          _buildRecentWorkouts(),
          // 광고 공간 확보
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMainStatsCards() {
    return AnimatedBuilder(
      animation: _counterAnimation,
      builder: (context, child) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          crossAxisSpacing: AppConstants.paddingM,
          mainAxisSpacing: AppConstants.paddingM,
          children: [
            _buildStatCard(
              '총 운동 횟수',
              '${(_totalWorkouts * _counterAnimation.value).toInt()}회',
              Icons.fitness_center,
              const Color(AppColors.primaryColor),
              '차드가 된 날들!',
            ),
            _buildStatCard(
              '총 푸시업',
              '${(_totalPushups * _counterAnimation.value).toInt()}개',
              Icons.trending_up,
              const Color(AppColors.secondaryColor),
              '진짜 차드 파워!',
            ),
            _buildStatCard(
              '평균 달성률',
              '${(_averageCompletion * _counterAnimation.value * 100).toInt()}%',
              Icons.track_changes,
              const Color(AppColors.successColor),
              '완벽한 수행!',
            ),
            _buildStatCard(
              '이번 달 운동',
              '${(_thisMonthWorkouts * _counterAnimation.value).toInt()}회',
              Icons.calendar_today,
              Colors.orange,
              '꾸준한 차드!',
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.7),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection() {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _counterAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '현재 연속',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      Text(
                        '${(_currentStreak * _counterAnimation.value).toInt()}일',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  Column(
                    children: [
                      Text(
                        '최고 기록',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      Text(
                        '${(_bestStreak * _counterAnimation.value).toInt()}일',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentWorkouts() {
    if (_workoutHistory.isEmpty) return const SizedBox.shrink();

    final recentWorkouts = _workoutHistory.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 운동 기록',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.paddingM),
        ...recentWorkouts.map((workout) => _buildWorkoutItem(workout)),
      ],
    );
  }

  Widget _buildWorkoutItem(WorkoutHistory workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: const Color(AppColors.primaryColor).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: const Color(AppColors.primaryColor).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(AppColors.primaryColor).withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.radiusM),
                topRight: Radius.circular(AppConstants.radiusM),
              ),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(AppColors.primaryColor),
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.workoutTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${workout.totalReps}개 • ${(workout.completionRate * 100).toInt()}% 달성',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${workout.date.month}/${workout.date.day}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(AppColors.primaryColor),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerAd() {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Color(AppColors.primaryColor), width: 1),
        ),
      ),
      child: _statisticsBannerAd != null
          ? AdWidget(ad: _statisticsBannerAd!)
          : const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics,
                    color: Color(AppColors.primaryColor),
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '차드의 성장을 확인하라! 📊',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
