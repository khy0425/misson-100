import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';
import '../services/workout_program_service.dart';
import '../services/database_service.dart';
import '../widgets/ad_banner_widget.dart';
import '../services/chad_level_manager.dart';
import 'package:provider/provider.dart';
import '../models/progress.dart' as progress_model;

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
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  
  ProgramProgress? _programProgress;
  List<WeeklyProgressData> _weeklyData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // 캘린??관???�태
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<WorkoutSession>> _workoutEvents = {};
  List<WorkoutSession> _selectedDayWorkouts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // ?�니메이??컨트롤러 초기??
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
    
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _loadProgressData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadProgressData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // ?�체 ?�로그램 진행�?로드
      _programProgress = await _workoutService.getProgramProgress(widget.userProfile);

      // 주간�??�이??로드
      await _loadWeeklyData();
      
      // 캘린???�이??로드
      await _loadCalendarData();

      setState(() {
        _isLoading = false;
      });
      
      // ?�이??로딩 ?�료 ???�이?�인 ?�니메이???�작
      _fadeAnimationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '?�이?��? 불러?�는 �??�류가 발생?�습?�다: $e';
      });
    }
  }

  Future<void> _loadWeeklyData() async {
    final weeklyData = <WeeklyProgressData>[];
    
    for (int week = 1; week <= 6; week++) {
      final sessions = await _databaseService.getWorkoutSessionsByWeek(week);
      final completedSessions = sessions.where((s) => s.isCompleted).length;
      const totalSessions = 3; // 주당 3???�동
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
      // 모든 ?�크?�웃 ?�션 로드
      final allSessions = await _databaseService.getAllWorkoutSessions();
      
      // ?�짜별로 그룹??
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
      
      // ?�늘 ?�짜가 ?�택?�어 ?�다�??�당 ?�짜???�크?�웃 로드
      if (_selectedDay != null) {
        _selectedDayWorkouts = _getWorkoutsForDay(_selectedDay!);
      }
    } catch (e) {
      debugPrint('캘린???�이??로드 ?�류: $e');
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
        title: const Text(
          '진행�?추적',
          style: TextStyle(
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
          tabs: const [
            Tab(text: '주간 ?�장'),
            Tab(text: '캘린??),
            Tab(text: '?�계'),
            Tab(text: 'Chad 진화'),
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
            child: const Text('?�시 ?�도'),
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
              const Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Color(0xFF4DABF7),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '?�체 진행�?,
                    style: TextStyle(
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
                    '${(_programProgress!.progressPercentage * 100).toStringAsFixed(1)}% ?�료',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_programProgress!.completedSessions}/${_programProgress!.totalSessions} ?�션',
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
                      '?�료???�수',
                      '${_programProgress!.totalCompletedReps}??,
                      Icons.fitness_center,
                      const Color(0xFF51CF66),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      '?��? ?�수',
                      '${_programProgress!.remainingReps}??,
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
              const Text(
                '주간 ?�장 차트',
                style: TextStyle(
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
              const Text(
                '주차�??�세',
                style: TextStyle(
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
                  '${data.completedSessions}/${data.totalSessions} ?�션 ?�료 ??${data.totalReps}??,
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
          // 캘린???�젯
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
                    const Text(
                      '?�크?�웃 캘린??,
                      style: TextStyle(
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
          
          // ?�택???�짜???�크?�웃 ?�보
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
                    '${_selectedDay!.month}??${_selectedDay!.day}???�크?�웃',
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
                        '???�에???�크?�웃???�습?�다.',
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
                      '${session.week}주차 - ${session.day}?�차',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isCompleted ? '?�료?? : '진행 �?,
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
                      '${session.totalReps}??,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF51CF66),
                      ),
                    ),
                    Text(
                      '${session.totalSets}?�트',
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
              '?�트�?기록:',
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
                                         '$setIndex?�트: $reps??,
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
          // ?�체 ?�계 ?�약
          _buildOverallStatsCard(),
          
          const SizedBox(height: 20),
          
          // Chad 진화 ?�계
          _buildChadEvolutionCard(),
          
          const SizedBox(height: 20),
          
          // 주간�??�과
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

    // ?�체 ?�계 계산
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
              const Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: Color(0xFF4DABF7),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '?�체 ?�계',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4DABF7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // ?�계 그리??
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(
                    '�??�시??,
                    '${_programProgress!.totalCompletedReps}??,
                    Icons.fitness_center,
                    const Color(0xFF51CF66),
                  ),
                  _buildStatCard(
                    '?�료 ?�션',
                    '${_programProgress!.completedSessions}??,
                    Icons.check_circle,
                    const Color(0xFF4DABF7),
                  ),
                  _buildStatCard(
                    '?�균/?�션',
                    '${averageRepsPerDay.toStringAsFixed(1)}??,
                    Icons.trending_up,
                    const Color(0xFFFFD43B),
                  ),
                  _buildStatCard(
                    '?�료??,
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
    
    // ChadLevelManager?�서 ?�바�?차드 ?�보 가?�오�?
    final chadManager = Provider.of<ChadLevelManager>(context);
    final currentStage = chadManager.currentStage;
    final nextStage = chadManager.nextStage;
    final isMaxLevel = chadManager.isMaxLevel;
    
    // 진행�?계산
    double progressToNext = 0.0;
    if (!isMaxLevel && _programProgress != null) {
      // ChadLevelManager???�제 진행�??�용
      progressToNext = chadManager.getEvolutionProgress(_buildDummyProgress());
    }

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
                    'Chad 진화 ?�계',
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
                  // Chad ?��?지
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
                        'assets/images/기본차드.jpg', // ?�재 Chad ?�벨??맞는 ?��?지
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
                          'Chad ?�벨 ${widget.userProfile.chadLevel + 1}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD43B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '기�?차드�?진화 �?..',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // ?�음 ?�벨까�???진행�?
                        LinearProgressIndicator(
                          value: 0.7, // ?�시 �? ?�제로는 계산 ?�요
                          backgroundColor: Colors.grey.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFD43B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '?�음 ?�벨까�? 30% ?�음',
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
              const Row(
                children: [
                  Icon(
                    Icons.calendar_view_week,
                    color: Color(0xFF51CF66),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '주간�??�과',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF51CF66),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 주간�??�과 리스??
              ..._weeklyData.take(3).map((data) => _buildWeeklyPerformanceItem(data)),
              
              if (_weeklyData.length > 3) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // ?�체 주간 ?�이??보기
                      _tabController.animateTo(0); // 주간 ?�장 ??���??�동
                    },
                    child: const Text(
                      '?�체 보기',
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
      statusText = '?�벽!';
    } else if (isGood) {
      statusColor = const Color(0xFF4DABF7);
      statusIcon = Icons.thumb_up;
      statusText = '좋음';
    } else {
      statusColor = const Color(0xFFFFD43B);
      statusIcon = Icons.trending_up;
      statusText = '개선 ?�요';
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
                                       '${data.totalReps}???�료',
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
    
    // 개인 기록 계산 (?�시 ?�이??
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
                      '$maxRepsInSession??,
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
                      '?�속 ?�수',
                      '7??, // ?�시 �?
                      Icons.local_fire_department,
                      const Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRecordItem(
                      '?�균 ?�수',
                      '85??, // ?�시 �?
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
          // ?�재 Chad ?�태
          _buildCurrentChadCard(),
          
          const SizedBox(height: 20),
          
          // Chad 진화 ?�계
          _buildChadEvolutionStages(),
          
          const SizedBox(height: 20),
          
          // Chad ?�적
          _buildChadAchievements(),
          
          const SizedBox(height: 80), // 광고 공간
        ],
      ),
    );
  }

  Widget _buildCurrentChadCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // ChadLevelManager?�서 ?�바�?차드 ?�보 가?�오�?
    final chadManager = Provider.of<ChadLevelManager>(context);
    final currentStage = chadManager.currentStage;
    final nextStage = chadManager.nextStage;
    final isMaxLevel = chadManager.isMaxLevel;
    
    // 진행�?계산
    double progressToNext = 0.0;
    if (!isMaxLevel && _programProgress != null) {
      // ChadLevelManager???�제 진행�??�용
      progressToNext = chadManager.getEvolutionProgress(_buildDummyProgress());
    }

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
                    '?�재 Chad ?�태',
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
                  // ?�재 Chad ?��?지
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: currentStage.themeColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        currentStage.imagePath,
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
                          currentStage.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: currentStage.themeColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentStage.description.split('\n').first,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // ?�음 ?�벨 진행�?
                        if (!isMaxLevel && nextStage != null) ...[
                          Text(
                            '?�음 ?�벨: ${nextStage.name}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progressToNext,
                            backgroundColor: Colors.grey.withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              nextStage.themeColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(progressToNext * 100).toInt()}% ?�료',
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
                                  '최고 ?�벨 ?�성!',
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
    
    // ChadLevelManager?�서 ?�바�?차드 ?�보 가?�오�?
    final chadManager = Provider.of<ChadLevelManager>(context);
    final allStages = ChadStageInfo.allStages;

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
              const Row(
                children: [
                  Icon(
                    Icons.timeline,
                    color: Color(0xFF4DABF7),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Chad 진화 ?�계',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4DABF7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Chad 진화 ?�계??
              ...allStages.asMap().entries.map((entry) {
                final index = entry.key;
                final stage = entry.value;
                final isUnlocked = chadManager.levelData.currentStageIndex >= index;
                final isCurrent = chadManager.levelData.currentStageIndex == index;
                
                return _buildEvolutionStageItem(stage, isUnlocked, isCurrent, index < allStages.length - 1);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvolutionStageItem(ChadStageInfo stage, bool isUnlocked, bool isCurrent, bool hasNext) {
    return Column(
      children: [
        Row(
          children: [
            // Chad ?��?지
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent 
                      ? stage.themeColor 
                      : (isUnlocked ? stage.themeColor.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3)),
                  width: isCurrent ? 3 : 1,
                ),
                boxShadow: isCurrent ? [
                  BoxShadow(
                    color: stage.themeColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColorFiltered(
                  colorFilter: isUnlocked 
                      ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                      : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                  child: Image.asset(
                    stage.imagePath,
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
                        stage.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCurrent 
                              ? stage.themeColor 
                              : (isUnlocked ? stage.themeColor.withValues(alpha: 0.8) : Colors.grey[600]),
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: stage.themeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: stage.themeColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '?�재',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: stage.themeColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stage.requiredWeeks == 0 
                        ? '?�로그램 ?�작'
                        : '${stage.requiredWeeks}주차 ?�료',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (isUnlocked) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: stage.themeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '?�제??,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: stage.themeColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        
        if (hasNext) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Container(
              width: 2,
              height: 20,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 16),
        ] else ...[
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  // ?��? Progress 객체 ?�성 (ChadLevelManager 계산??
  progress_model.Progress _buildDummyProgress() {
    if (_programProgress == null) {
      return progress_model.Progress();
    }
    
    // ?�제 ?�이?��? 기반?�로 Progress 객체 ?�성
    return progress_model.Progress(
      weeklyProgress: List.generate(6, (index) {
        final week = index + 1;
        // ?�재 ?�로그램 진행률을 기반?�로 주차�??�료 ?�태 추정
        final weekProgress = (_programProgress!.progressPercentage * 6);
        final isCompleted = weekProgress >= week;
        
        return progress_model.WeeklyProgress(
          week: week,
          completedDays: isCompleted ? 3 : (weekProgress > week - 1 ? ((weekProgress - (week - 1)) * 3).floor() : 0),
          totalPushups: 0,
        );
      }),
    );
  }

  Widget _buildChadAchievements() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // ?�적 ?�이??(?�시)
    final achievements = [
      {
        'title': '�?걸음',
        'description': '�?번째 ?�크?�웃 ?�료',
        'icon': Icons.play_arrow,
        'color': const Color(0xFF51CF66),
        'isUnlocked': true,
      },
      {
        'title': '?�주??챌린지',
        'description': '7???�속 ?�동',
        'icon': Icons.calendar_view_week,
        'color': const Color(0xFF4DABF7),
        'isUnlocked': true,
      },
      {
        'title': '�??�시??,
        'description': '???�션??100???�성',
        'icon': Icons.fitness_center,
        'color': const Color(0xFFFFD43B),
        'isUnlocked': false,
      },
      {
        'title': '?�벽주의??,
        'description': '??�?100% ?�료',
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
            const Row(
              children: [
                Icon(
                  Icons.military_tech,
                  color: Color(0xFFFF6B6B),
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Chad ?�적',
                  style: TextStyle(
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

/// 주간 진행�??�이??모델
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

/// 주간 ?�장 차트 ?�젯
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
    
    // 차트 ?�니메이???�작
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
          '?�이?��? ?�습?�다',
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
                          child: Text('${value.toInt()}�?, style: style),
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
                          '${weekData.week}주차\n${(weekData.completionRate * 100).toInt()}% ?�료\n${weekData.completedSessions}/${weekData.totalSessions} ?�션',
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
