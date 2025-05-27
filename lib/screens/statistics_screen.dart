import 'package:flutter/material.dart';
 // kDebugMode 사용
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';
import '../models/workout_history.dart';
import '../services/workout_history_service.dart';
import '../services/achievement_service.dart';
import '../services/ad_service.dart';
import '../generated/app_localizations.dart';

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
  late Animation<double> _chartAnimation;

  // 데이터
  List<WorkoutHistory> _workoutHistory = [];
  bool _isLoading = true;

  // 통계 데이터
  int _totalWorkouts = 0;
  int _totalPushups = 0;
  double _averageCompletionRate = 0.0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _thisMonthWorkouts = 0;
  Duration _totalWorkoutTime = Duration.zero;

  // 새로운 진행률 관련 변수들
  int _weeklyGoal = 5; // 주간 목표 운동 횟수
  int _monthlyGoal = 20; // 월간 목표 운동 횟수
  int _thisWeekWorkouts = 0;
  double _weeklyProgress = 0.0;
  double _monthlyProgress = 0.0;
  int _targetStreak = 7; // 목표 연속 운동일

  // 광고
  BannerAd? _statisticsBannerAd;

  // 차트 관련 변수
  String _selectedPeriod = 'week'; // 'week', 'month', 'year'
  List<FlSpot> _chartData = [];
  Map<String, double> _pieChartData = {};
  
  // 차트 필터링 옵션
  final List<String> _periodOptions = ['week', 'month', 'year'];

  // 테스트 환경 감지 - 더 확실한 방법 사용
  bool get _isTestEnvironment {
    try {
      // 테스트 환경에서는 TestWidgetsFlutterBinding이 있음
      return WidgetsBinding.instance.runtimeType.toString().contains('Test');
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadBannerAd();
    _loadStatistics();
    
    // 업적 달성 시 통계 데이터 새로고침을 위한 콜백 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AchievementService.setOnStatsUpdated(() {
        if (mounted) {
          _loadStatistics();
        }
      });
    });
  }

  void _initializeAnimations() {
    _counterController = AnimationController(
      duration: _isTestEnvironment
          ? const Duration(milliseconds: 1) // 테스트에서는 즉시 완료
          : const Duration(milliseconds: 2000),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: _isTestEnvironment
          ? const Duration(milliseconds: 1) // 테스트에서는 즉시 완료
          : const Duration(milliseconds: 1500),
      vsync: this,
    );

    _counterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _counterController, curve: Curves.easeOutBack),
    );
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeOutCubic),
    );
  }

  void _loadBannerAd() {
    _statisticsBannerAd = AdService.createBannerAd();
  }

  Future<void> _loadStatistics() async {
    try {
      final history = await WorkoutHistoryService.getAllWorkouts();

      if (!mounted) return;

      setState(() {
        _workoutHistory = history;
        _calculateStatistics();
        _isLoading = false;
      });

      if (mounted) {
        if (_isTestEnvironment) {
          _counterController.value = 1.0;
          _chartController.value = 1.0;
        } else {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            _counterController.forward();
            _chartController.forward();
          }
        }
      }
    } catch (e) {
      if (!mounted) return;

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
    _averageCompletionRate =
        _workoutHistory.fold(
          0.0,
          (sum, workout) => sum + workout.completionRate,
        ) /
        _totalWorkouts;
    _totalWorkoutTime = _workoutHistory.fold(Duration.zero, (sum, workout) => sum + workout.duration);

    // 연속 운동일 계산
    _calculateStreaks();

    // 이번 주/월 운동 횟수 계산
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    _thisMonthWorkouts = _workoutHistory
        .where(
          (w) => w.date.isAfter(monthStart.subtract(const Duration(days: 1))),
        )
        .length;

    _thisWeekWorkouts = _workoutHistory
        .where(
          (w) => w.date.isAfter(weekStart.subtract(const Duration(days: 1))),
        )
        .length;

    // 진행률 계산
    _weeklyProgress = (_thisWeekWorkouts / _weeklyGoal).clamp(0.0, 1.0);
    _monthlyProgress = (_thisMonthWorkouts / _monthlyGoal).clamp(0.0, 1.0);
    
    // 차트 데이터 생성
    _generateChartData();
    _generatePieChartData();
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

  void _generateChartData() {
    _chartData.clear();
    
    if (_workoutHistory.isEmpty) return;

    final now = DateTime.now();
    final Map<DateTime, int> dailyReps = {};

    // 선택된 기간에 따라 데이터 생성
    int daysToShow = _selectedPeriod == 'week' ? 7 : _selectedPeriod == 'month' ? 30 : 365;
    
    for (int i = daysToShow - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      dailyReps[date] = 0;
    }

    // 운동 기록에서 데이터 추출
    for (final workout in _workoutHistory) {
      final workoutDate = DateTime(workout.date.year, workout.date.month, workout.date.day);
      if (dailyReps.containsKey(workoutDate)) {
        dailyReps[workoutDate] = dailyReps[workoutDate]! + workout.totalReps;
      }
    }

    // FlSpot 데이터로 변환
    int index = 0;
    dailyReps.forEach((date, reps) {
      _chartData.add(FlSpot(index.toDouble(), reps.toDouble()));
      index++;
    });
  }

  void _generatePieChartData() {
    _pieChartData.clear();
    
    if (_workoutHistory.isEmpty) return;

    final Map<String, int> workoutTypes = {};
    
    for (final workout in _workoutHistory) {
      final type = workout.pushupType;
      workoutTypes[type] = (workoutTypes[type] ?? 0) + workout.totalReps;
    }

    final total = workoutTypes.values.fold(0, (sum, count) => sum + count);
    
    workoutTypes.forEach((type, count) {
      _pieChartData[type] = (count / total) * 100;
    });
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.statistics,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 진행률 시각화 섹션 추가
                    _buildProgressVisualizationSection(),
                    const SizedBox(height: 24),
                    
                    // 기존 통계 카드들
                    _buildStatisticsCards(),
                    const SizedBox(height: 24),
                    _buildChartSection(),
                    const SizedBox(height: 24),
                    _buildStreakProgressBar(),
                    const SizedBox(height: 24),
                    _buildMonthlyProgressSection(),
                  ],
                ),
              ),
            ),
    );
  }

  // 새로운 진행률 시각화 섹션
  Widget _buildProgressVisualizationSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.progressVisualization,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // 원형 진행률 표시기들
            Row(
              children: [
                Expanded(
                  child: _buildCircularProgress(
                    title: AppLocalizations.of(context)!.weeklyGoal,
                    progress: _weeklyProgress,
                    current: _thisWeekWorkouts,
                    target: _weeklyGoal,
                    color: Colors.blue,
                    icon: Icons.calendar_view_week,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCircularProgress(
                    title: AppLocalizations.of(context)!.monthlyGoal,
                    progress: _monthlyProgress,
                    current: _thisMonthWorkouts,
                    target: _monthlyGoal,
                    color: Colors.green,
                    icon: Icons.calendar_month,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 스트릭 진행 바
            _buildStreakProgressBar(),
          ],
        ),
      ),
    );
  }

  // 원형 진행률 위젯
  Widget _buildCircularProgress({
    required String title,
    required double progress,
    required int current,
    required int target,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 4),
                Text(
                  '$current',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '/$target',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 스트릭 진행 바
  Widget _buildStreakProgressBar() {
    double streakProgress = _currentStreak / _targetStreak;
    if (streakProgress > 1.0) streakProgress = 1.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.streakProgress,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$_currentStreak / $_targetStreak ${AppLocalizations.of(context)!.days}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 스트릭 진행 바
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey[300],
          ),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.grey[300],
                ),
              ),
              FractionallySizedBox(
                widthFactor: streakProgress,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.red.shade400,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 스트릭 아이콘들
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_targetStreak, (index) {
            bool isCompleted = index < _currentStreak;
            return Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted 
                    ? Colors.orange.shade400 
                    : Colors.grey[300],
              ),
              child: Icon(
                Icons.local_fire_department,
                size: 16,
                color: isCompleted ? Colors.white : Colors.grey[500],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
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
              AppLocalizations.of(context)!.totalWorkouts,
              '${(_totalWorkouts * _counterAnimation.value).toInt()}${AppLocalizations.of(context)!.times}',
              Icons.fitness_center,
              const Color(AppColors.primaryColor),
              AppLocalizations.of(context)!.chadDays,
            ),
            _buildStatCard(
              AppLocalizations.of(context)!.totalPushups,
              '${(_totalPushups * _counterAnimation.value).toInt()}${AppLocalizations.of(context)!.count}',
              Icons.trending_up,
              const Color(AppColors.secondaryColor),
              AppLocalizations.of(context)!.realChadPower,
            ),
            _buildStatCard(
              AppLocalizations.of(context)!.averageCompletion,
              '${(_averageCompletionRate * _counterAnimation.value * 100).toInt()}%',
              Icons.track_changes,
              const Color(AppColors.successColor),
              AppLocalizations.of(context)!.perfectExecution,
            ),
            _buildStatCard(
              AppLocalizations.of(context)!.thisMonthWorkouts,
              '${(_thisMonthWorkouts * _counterAnimation.value).toInt()}${AppLocalizations.of(context)!.times}',
              Icons.calendar_today,
              Colors.orange,
              AppLocalizations.of(context)!.consistentChad,
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

  Widget _buildChartSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.workoutChart,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 기간 선택 버튼들
                Row(
                  children: [
                    _buildPeriodButton('week', AppLocalizations.of(context)!.weekly),
                    const SizedBox(width: 8),
                    _buildPeriodButton('month', AppLocalizations.of(context)!.monthly),
                    const SizedBox(width: 8),
                    _buildPeriodButton('year', AppLocalizations.of(context)!.yearly),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    bool isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
          _generateChartData(); // 차트 데이터 재생성
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 200,
          child: _workoutHistory.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.noWorkoutHistory))
              : _buildLineChart(),
        );
      },
    );
  }

  Widget _buildLineChart() {
    if (_chartData.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noChartData));
    }

    final maxY = _chartData.isEmpty 
        ? 100.0 
        : _chartData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 10;

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: _chartData,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
                              color: Colors.blue.withValues(alpha: 0.1),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
        ],
        minY: 0,
        maxY: maxY,
        minX: 0,
        maxX: _chartData.length > 1 ? _chartData.length.toDouble() - 1 : 1,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: leftTitleWidgets,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
                              color: Colors.grey.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
                          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              left: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Colors.grey[500],
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text = value.toString();
    if (value % 1 != 0) {
      text = value.toStringAsFixed(2);
    }
    return Text(text, style: style);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Colors.grey[500],
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    
    int index = value.floor();
    if (index < 0 || index >= _chartData.length) {
      return Text('', style: style);
    }
    
    // 기간에 따라 다른 라벨 표시
    String text = '';
    final now = DateTime.now();
    
    if (_selectedPeriod == 'week') {
      final date = now.subtract(Duration(days: 6 - index));
      text = '${date.month}/${date.day}';
    } else if (_selectedPeriod == 'month') {
      final date = now.subtract(Duration(days: 29 - index));
      text = '${date.day}';
    } else {
      final date = now.subtract(Duration(days: 364 - index));
                    text = '${date.month}${AppLocalizations.of(context)!.month}';
    }
    
    // 너무 많은 라벨이 표시되지 않도록 간격 조정
    if (_selectedPeriod == 'month' && index % 5 != 0) {
      return Text('', style: style);
    } else if (_selectedPeriod == 'year' && index % 30 != 0) {
      return Text('', style: style);
    }
    
    return Text(text, style: style);
  }

  Widget _buildMonthlyProgressSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.monthlyProgress,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildMonthlyProgressChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyProgressChart() {
    return SizedBox(
      height: 200,
                child: _workoutHistory.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.noWorkoutHistory))
              : _buildPieChart(),
    );
  }

  Widget _buildPieChart() {
    if (_pieChartData.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noPieChartData));
    }

    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
    ];

    int colorIndex = 0;
    
    return PieChart(
      PieChartData(
        sections: _pieChartData.entries.map((entry) {
          final color = colors[colorIndex % colors.length];
          colorIndex++;
          
          return PieChartSectionData(
            value: entry.value,
            color: color,
            title: '${entry.value.toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        startDegreeOffset: -90,
      ),
    );
  }


}
