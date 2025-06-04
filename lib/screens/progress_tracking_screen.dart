import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import '../generated/app_localizations.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';
import '../services/workout_program_service.dart';
import '../services/database_service.dart';
import '../widgets/ad_banner_widget.dart';

class ProgressTrackingScreen extends StatefulWidget {
  final UserProfile userProfile;

  const ProgressTrackingScreen({
    super.key,
    required this.userProfile,
  });

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen>
    with TickerProviderStateMixin {
  final WorkoutProgramService _workoutService = WorkoutProgramService();
  final DatabaseService _databaseService = DatabaseService();


  late TabController _tabController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  
  ProgramProgress? _programProgress;
  List<WeeklyProgressData> _weeklyData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // 캘린더 관련 상태
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<WorkoutSession>> _workoutEvents = {};
  List<WorkoutSession> _selectedDayWorkouts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // 애니메이션 컨트롤러 초기화
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _loadProgressData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadProgressData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '데이터를 불러오는 중 오류가 발생했습니다';
      });

      // 전체 프로그램 진행률 로드
      _programProgress = await _workoutService.getProgramProgress(widget.userProfile);

      // 주간별 데이터 로드
      await _loadWeeklyData();
      
      // 캘린더 데이터 로드
      await _loadCalendarData();

      setState(() {
        _isLoading = false;
      });
      
      // 데이터 로딩 완료 후 페이드인 애니메이션 시작
      _fadeAnimationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '데이터를 불러오는 중 오류가 발생했습니다';
      });
    }
  }

  Future<void> _loadWeeklyData() async {
    final weeklyData = <WeeklyProgressData>[];
    
    for (int week = 1; week <= 6; week++) {
      final sessions = await _databaseService.getWorkoutSessionsByWeek(week);
      final completedSessions = sessions.where((s) => s.isCompleted).length;
      const totalSessions = 3; // 주당 3회 운동
      final completionRate = completedSessions / totalSessions;
      
      final totalReps = sessions
          .where((s) => s.isCompleted)
          .fold<int>(0, (sum, session) => sum + session.totalReps);
      
      weeklyData.add(WeeklyProgressData(
        week: week,
        completionRate: completionRate,
        completedSessions: completedSessions,
        totalSessions: totalSessions,
        totalReps: totalReps,
      ));
    }
    
    _weeklyData = weeklyData;
  }

  Future<void> _loadCalendarData() async {
    try {
      // 모든 워크아웃 세션 로드
      final allSessions = await _databaseService.getAllWorkoutSessions();
      
      // 날짜별로 그룹화
      final Map<DateTime, List<WorkoutSession>> events = {};
      
      for (final session in allSessions) {
        final date = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        
        if (events[date] == null) {
          events[date] = [];
        }
        events[date]!.add(session);
      }
      
      _workoutEvents = events;
      
      // 오늘 날짜가 선택되어 있다면 해당 날짜의 워크아웃 로드
      if (_selectedDay != null) {
        _selectedDayWorkouts = _getWorkoutsForDay(_selectedDay!);
      }
    } catch (e) {
      debugPrint('캘린더 데이터 로드 오류: $e');
    }
  }

  List<WorkoutSession> _getWorkoutsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _workoutEvents[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedDayWorkouts = _getWorkoutsForDay(selectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.progressTracking,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4DABF7),
          labelColor: const Color(0xFF4DABF7),
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          tabs: [
            Tab(text: AppLocalizations.of(context)!.weekly),
            Tab(text: AppLocalizations.of(context)!.calendar),
            Tab(text: AppLocalizations.of(context)!.statistics),
            Tab(text: AppLocalizations.of(context)!.chadEvolution),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildWeeklyGrowthTab(),
                      _buildCalendarTab(),
                      _buildStatisticsTab(),
                      _buildChadEvolutionTab(),
                    ],
                  ),
                ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(0xFFFF6B6B),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFFF6B6B),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadProgressData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DABF7),
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.retryButton),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGrowthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressSummaryCard(),
          const SizedBox(height: 20),
          _buildWeeklyGrowthChart(),
          const SizedBox(height: 20),
          _buildWeeklyBreakdown(),
          const SizedBox(height: 80), // 광고 공간
        ],
      ),
    );
  }

  Widget _buildProgressSummaryCard() {
    if (_programProgress == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      child: Card(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF4DABF7).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: Color(0xFF4DABF7),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.overallProgress,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4DABF7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _programProgress!.progressPercentage,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4DABF7)),
                minHeight: 8,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(_programProgress!.progressPercentage * 100).toStringAsFixed(1)}% ${AppLocalizations.of(context)!.completed}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_programProgress!.completedSessions}/${_programProgress!.totalSessions} ${AppLocalizations.of(context)!.sessions}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      AppLocalizations.of(context)!.completedCount,
                      '${_programProgress!.totalCompletedReps}회',
                      Icons.fitness_center,
                      const Color(0xFF51CF66),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      AppLocalizations.of(context)!.remainingCount,
                      '${_programProgress!.remainingReps}회',
                      Icons.schedule,
                      const Color(0xFFFFD43B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGrowthChart() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      child: Card(
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF1A1A1A) 
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.weeklyGrowthChart,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4DABF7),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: WeeklyGrowthChart(weeklyData: _weeklyData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyBreakdown() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      child: Card(
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF1A1A1A) 
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.weeklyDetails,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4DABF7),
                ),
              ),
              const SizedBox(height: 16),
              ..._weeklyData.map((data) => _buildWeeklyBreakdownItem(data)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyBreakdownItem(WeeklyProgressData data) {
    final completionPercentage = (data.completionRate * 100).toInt();
    final isCompleted = data.completionRate >= 1.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted 
            ? const Color(0xFF51CF66).withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted 
              ? const Color(0xFF51CF66).withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFF51CF66) : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${data.week}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.week}주차',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.completedSessions}/${data.totalSessions} ${AppLocalizations.of(context)!.sessionsCompleted} • ${data.totalReps}회',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$completionPercentage%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isCompleted ? const Color(0xFF51CF66) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 캘린더 위젯
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            child: Card(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.workoutCalendar,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4DABF7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TableCalendar<WorkoutSession>(
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2025, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      eventLoader: _getWorkoutsForDay,
                      onDaySelected: _onDaySelected,
                      locale: Localizations.localeOf(context).toString(),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: TextStyle(
                          color: isDark ? Colors.red[300] : Colors.red[700],
                        ),
                        holidayTextStyle: TextStyle(
                          color: isDark ? Colors.red[300] : Colors.red[700],
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF4DABF7),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFF4DABF7).withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Color(0xFF51CF66),
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 1,
                        canMarkersOverflow: false,
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                        weekendStyle: TextStyle(
                          color: isDark ? Colors.red[300] : Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 선택된 날짜의 워크아웃 정보
          if (_selectedDay != null) _buildSelectedDayWorkouts(),
          
          const SizedBox(height: 80), // 광고 공간
        ],
      ),
    );
  }

  Widget _buildSelectedDayWorkouts() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      child: Card(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF4DABF7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedDay!.month}월 ${_selectedDay!.day}일 워크아웃',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4DABF7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_selectedDayWorkouts.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '이 날에는 워크아웃이 없습니다.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ..._selectedDayWorkouts.map((workout) => _buildWorkoutSessionCard(workout)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutSessionCard(WorkoutSession session) {
    final isCompleted = session.isCompleted;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted 
            ? const Color(0xFF51CF66).withValues(alpha: 0.1)
            : const Color(0xFFFFD43B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted 
              ? const Color(0xFF51CF66).withValues(alpha: 0.3)
              : const Color(0xFFFFD43B).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF51CF66) : const Color(0xFFFFD43B),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.schedule,
                  color: isCompleted ? Colors.white : Colors.black,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${session.week}주차 - ${session.day}일차',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isCompleted 
                        ? AppLocalizations.of(context)!.completed
                        : AppLocalizations.of(context)!.inProgress,
                      style: TextStyle(
                        fontSize: 14,
                        color: isCompleted ? const Color(0xFF51CF66) : const Color(0xFFFFD43B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${session.totalReps}회',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF51CF66),
                      ),
                    ),
                    Text(
                      '${session.totalSets}세트',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          
          if (isCompleted && session.completedReps.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              '세트별 기록:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: session.completedReps.asMap().entries.map((entry) {
                final setIndex = entry.key + 1;
                final reps = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF51CF66),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                                         '$setIndex세트: $reps회',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 통계 요약
          _buildOverallStatsCard(),
          
          const SizedBox(height: 20),
          
          // Chad 진화 단계
          _buildChadEvolutionCard(),
          
          const SizedBox(height: 20),
          
          // 주간별 성과
          _buildWeeklyPerformanceCard(),
          
          const SizedBox(height: 20),
          
          // 개인 기록
          _buildPersonalRecordsCard(),
          
          const SizedBox(height: 80), // 광고 공간
        ],
      ),
    );
  }

  Widget _buildOverallStatsCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (_programProgress == null) return const SizedBox.shrink();

    // 전체 통계 계산
    final averageRepsPerDay = _programProgress!.totalCompletedReps / 
        (_programProgress!.completedSessions > 0 ? _programProgress!.completedSessions : 1);
    final completionRate = _programProgress!.progressPercentage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      child: Card(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.analytics,
                    color: Color(0xFF4DABF7),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.overallStats,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4DABF7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 통계 그리드
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(
                    AppLocalizations.of(context)!.totalPushups,
                    '${_programProgress!.totalCompletedReps}회',
                    Icons.fitness_center,
                    const Color(0xFF51CF66),
                  ),
                  _buildStatCard(
                    AppLocalizations.of(context)!.completedSessions,
                    '${_programProgress!.completedSessions}회',
                    Icons.check_circle,
                    const Color(0xFF4DABF7),
                  ),
                  _buildStatCard(
                    AppLocalizations.of(context)!.averagePerSession,
                    '${averageRepsPerDay.toStringAsFixed(1)}회',
                    Icons.trending_up,
                    const Color(0xFFFFD43B),
                  ),
                  _buildStatCard(
                    Localizations.localeOf(context).languageCode == 'ko'
                      ? AppLocalizations.of(context)!.completionRate
                      : 'Completion',
                    '${(completionRate * 100).toStringAsFixed(1)}%',
                    Icons.pie_chart,
                    const Color(0xFFFF6B6B),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChadEvolutionCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      child: Card(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Color(0xFFFFD43B),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Chad 진화 단계',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD43B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  // Chad 이미지
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD43B).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/기본차드.jpg', // 현재 Chad 레벨에 맞는 이미지
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chad 레벨 ${widget.userProfile.chadLevel + 1}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD43B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '기가차드로 진화 중...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // 다음 레벨까지의 진행률
                        LinearProgressIndicator(
                          value: 0.7, // 임시 값, 실제로는 계산 필요
                          backgroundColor: Colors.grey.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFD43B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '다음 레벨까지 30% 남음',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyPerformanceCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      child: Card(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_view_week,
                    color: Color(0xFF51CF66),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.weeklyPerformance,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF51CF66),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 주간별 성과 리스트
              ..._weeklyData.take(3).map((data) => _buildWeeklyPerformanceItem(data)),
              
              if (_weeklyData.length > 3) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // 전체 주간 데이터 보기
                      _tabController.animateTo(0); // 주간 성장 탭으로 이동
                    },
                    child: const Text(
                      '전체 보기',
                      style: TextStyle(
                        color: Color(0xFF51CF66),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyPerformanceItem(WeeklyProgressData data) {
    final completionPercentage = (data.completionRate * 100).toInt();
    final isExcellent = completionPercentage >= 100;
    final isGood = completionPercentage >= 80;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    if (isExcellent) {
      statusColor = const Color(0xFF51CF66);
      statusIcon = Icons.star;
      statusText = AppLocalizations.of(context)!.perfect;
    } else if (isGood) {
      statusColor = const Color(0xFF4DABF7);
      statusIcon = Icons.thumb_up;
      statusText = AppLocalizations.of(context)!.good;
    } else {
      statusColor = const Color(0xFFFFD43B);
      statusIcon = Icons.trending_up;
      statusText = AppLocalizations.of(context)!.improvement;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.week}주차',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${data.totalReps}회 완료',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completionPercentage%',
                style: TextStyle(
                  fontSize: 14,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalRecordsCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // 개인 기록 계산 (임시 데이터)
    final maxRepsInSession = _weeklyData.isNotEmpty 
        ? _weeklyData.map((w) => w.totalReps).reduce((a, b) => a > b ? a : b)
        : 0;
    final bestWeek = _weeklyData.isNotEmpty
        ? _weeklyData.reduce((a, b) => a.completionRate > b.completionRate ? a : b)
        : null;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      child: Card(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.military_tech,
                    color: Color(0xFFFF6B6B),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '개인 기록',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildRecordItem(
                      '최고 기록',
                      '$maxRepsInSession회',
                      Icons.emoji_events,
                      const Color(0xFFFFD43B),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRecordItem(
                      '최고 주차',
                      bestWeek != null ? '${bestWeek.week}주차' : '-',
                      Icons.star,
                      const Color(0xFF51CF66),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildRecordItem(
                      '연속 일수',
                      '7일', // 임시 값
                      Icons.local_fire_department,
                      const Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRecordItem(
                      '평균 점수',
                      '85점', // 임시 값
                      Icons.grade,
                      const Color(0xFF4DABF7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChadEvolutionTab() {

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 현재 Chad 상태
          _buildCurrentChadCard(),
          
          const SizedBox(height: 20),
          
          // Chad 진화 단계
          _buildChadEvolutionStages(),
          
          const SizedBox(height: 20),
          
          // Chad 업적
          _buildChadAchievements(),
          
          const SizedBox(height: 80), // 광고 공간
        ],
      ),
    );
  }

  Widget _buildCurrentChadCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Chad 레벨에 따른 이미지 및 정보
    final chadImages = [
      'assets/images/기본차드.jpg',
      'assets/images/정면차드.jpg', 
      'assets/images/썬글차드.jpg',
      'assets/images/커피차드.png',
      'assets/images/더블차드.jpg',
      'assets/images/눈빔차드.jpg',
      'assets/images/수면모자차드.jpg',
    ];
    
    final chadTitles = [
      'Rookie Chad',
      'Rising Chad', 
      'Alpha Chad',
      'Sigma Chad',
      'Giga Chad',
      'Ultra Chad',
      'Legendary Chad',
    ];
    
    final currentLevel = widget.userProfile.chadLevel.clamp(0, chadImages.length - 1);
    final nextLevel = (currentLevel + 1).clamp(0, chadImages.length - 1);
    
    // 진행률 계산 (임시 로직)
    final progressToNext = _programProgress != null 
        ? (_programProgress!.progressPercentage * 100) % 100 / 100
        : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      child: Card(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Color(0xFFFFD43B),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '현재 Chad 상태',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD43B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  // 현재 Chad 이미지
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD43B).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        chadImages[currentLevel],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chadTitles[currentLevel],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD43B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.userProfile.level.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 다음 레벨 진행률
                        if (currentLevel < chadImages.length - 1) ...[
                          Text(
                            '다음 레벨: ${chadTitles[nextLevel]}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progressToNext,
                            backgroundColor: Colors.grey.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFD43B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(progressToNext * 100).toInt()}% 완료',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD43B).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFFD43B).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Color(0xFFFFD43B),
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '최고 레벨 달성!',
                                  style: TextStyle(
                                    color: Color(0xFFFFD43B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChadEvolutionStages() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final chadStages = [
      {'name': 'Rookie Chad', 'image': 'assets/images/기본차드.jpg', 'requirement': '프로그램 시작'},
      {'name': 'Rising Chad', 'image': 'assets/images/정면차드.jpg', 'requirement': '1주차 완료'},
      {'name': 'Alpha Chad', 'image': 'assets/images/썬글차드.jpg', 'requirement': '2주차 완료'},
      {'name': 'Sigma Chad', 'image': 'assets/images/커피차드.png', 'requirement': '3주차 완료'},
      {'name': 'Giga Chad', 'image': 'assets/images/더블차드.jpg', 'requirement': '4주차 완료'},
      {'name': 'Ultra Chad', 'image': 'assets/images/눈빔차드.jpg', 'requirement': '5주차 완료'},
      {'name': 'Legendary Chad', 'image': 'assets/images/수면모자차드.jpg', 'requirement': '6주차 완료'},
    ];

    return Card(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.timeline,
                  color: Color(0xFF4DABF7),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.chadEvolutionStages,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4DABF7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            ...chadStages.asMap().entries.map((entry) {
              final index = entry.key;
              final stage = entry.value;
              final isUnlocked = index <= widget.userProfile.chadLevel;
              final isCurrent = index == widget.userProfile.chadLevel;
              
              return _buildChadStageItem(
                stage['name']!,
                stage['image']!,
                stage['requirement']!,
                isUnlocked,
                isCurrent,
                index < chadStages.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChadStageItem(
    String name,
    String imagePath,
    String requirement,
    bool isUnlocked,
    bool isCurrent,
    bool showConnector,
  ) {
    return Column(
      children: [
        Row(
          children: [
            // Chad 이미지
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent 
                      ? const Color(0xFFFFD43B)
                      : isUnlocked 
                          ? const Color(0xFF51CF66)
                          : Colors.grey,
                  width: 3,
                ),
                boxShadow: isUnlocked ? [
                  BoxShadow(
                    color: (isCurrent ? const Color(0xFFFFD43B) : const Color(0xFF51CF66))
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: ColorFiltered(
                  colorFilter: isUnlocked 
                      ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                      : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCurrent 
                              ? const Color(0xFFFFD43B)
                              : isUnlocked 
                                  ? const Color(0xFF51CF66)
                                  : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isCurrent) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD43B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            Localizations.localeOf(context).languageCode == 'ko'
                              ? '현재'
                              : 'Current',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ] else if (isUnlocked) ...[
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF51CF66),
                          size: 16,
                        ),
                      ] else ...[
                        const Icon(
                          Icons.lock,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    requirement,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        if (showConnector) ...[
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(left: 30),
            width: 2,
            height: 20,
            color: isUnlocked 
                ? const Color(0xFF51CF66).withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
        ] else ...[
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildChadAchievements() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // 업적 데이터 (임시)
    final achievements = [
      {
        'title': '첫 걸음',
        'description': '첫 번째 워크아웃 완료',
        'icon': Icons.play_arrow,
        'color': const Color(0xFF51CF66),
        'isUnlocked': true,
      },
      {
        'title': '일주일 챌린지',
        'description': '7일 연속 운동',
        'icon': Icons.calendar_view_week,
        'color': const Color(0xFF4DABF7),
        'isUnlocked': true,
      },
      {
        'title': '백 푸시업',
        'description': '한 세션에 100회 달성',
        'icon': Icons.fitness_center,
        'color': const Color(0xFFFFD43B),
        'isUnlocked': false,
      },
      {
        'title': '완벽주의자',
        'description': '한 주 100% 완료',
        'icon': Icons.star,
        'color': const Color(0xFFFF6B6B),
        'isUnlocked': false,
      },
    ];

    return Card(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.military_tech,
                  color: Color(0xFFFF6B6B),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.chadAchievements,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: achievements.map((achievement) => _buildAchievementCard(
                achievement['title'] as String,
                achievement['description'] as String,
                achievement['icon'] as IconData,
                achievement['color'] as Color,
                achievement['isUnlocked'] as bool,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
    String title,
    String description,
    IconData icon,
    Color color,
    bool isUnlocked,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked 
            ? color.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked 
              ? color.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isUnlocked ? color : Colors.grey,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? color : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isUnlocked) ...[
            const SizedBox(height: 4),
            const Icon(
              Icons.lock,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }
}

/// 주간 진행률 데이터 모델
class WeeklyProgressData {
  final int week;
  final double completionRate;
  final int completedSessions;
  final int totalSessions;
  final int totalReps;

  const WeeklyProgressData({
    required this.week,
    required this.completionRate,
    required this.completedSessions,
    required this.totalSessions,
    required this.totalReps,
  });
}

/// 주간 성장 차트 위젯
class WeeklyGrowthChart extends StatefulWidget {
  final List<WeeklyProgressData> weeklyData;

  const WeeklyGrowthChart({
    super.key,
    required this.weeklyData,
  });

  @override
  State<WeeklyGrowthChart> createState() => _WeeklyGrowthChartState();
}

class _WeeklyGrowthChartState extends State<WeeklyGrowthChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // 차트 애니메이션 시작
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.weeklyData.isEmpty) {
      return const Center(
        child: Text(
          '데이터가 없습니다',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * _animation.value),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 0.2,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text('${value.toInt()}주', style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 0.2,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        return Text('${(value * 100).toInt()}%', style: style);
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                minX: 1,
                maxX: 6,
                minY: 0,
                maxY: 1,
                lineBarsData: [
                  LineChartBarData(
                    spots: widget.weeklyData
                        .map((data) => FlSpot(data.week.toDouble(), data.completionRate))
                        .toList(),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4DABF7), Color(0xFF51CF66)],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: const Color(0xFF4DABF7),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4DABF7).withValues(alpha: 0.3),
                          const Color(0xFF51CF66).withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: const Color(0xFF1A1A1A),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final weekData = widget.weeklyData.firstWhere(
                          (data) => data.week == barSpot.x.toInt(),
                        );
                        return LineTooltipItem(
                          '${weekData.week}주차\n${(weekData.completionRate * 100).toInt()}% 완료\n${weekData.completedSessions}/${weekData.totalSessions} 세션',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 