import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/constants.dart';
import '../models/workout_history.dart';
import '../services/workout_history_service.dart';
import '../services/ad_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<WorkoutHistory>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<WorkoutHistory>> _events = {};
  Map<String, dynamic> _statistics = {};
  int _currentStreak = 0;
  bool _isLoading = true;

  // 월별 데이터 캐싱을 위한 변수 추가
  DateTime? _lastLoadedMonth;
  final Map<String, Map<DateTime, List<WorkoutHistory>>> _monthlyCache = {};

  // 달력 화면 전용 배너 광고
  BannerAd? _calendarBannerAd;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadWorkoutData();
    _createCalendarBannerAd();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _calendarBannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadWorkoutData() async {
    setState(() => _isLoading = true);

    try {
      final currentMonth = DateTime(_focusedDay.year, _focusedDay.month);
      final cacheKey = '${currentMonth.year}-${currentMonth.month}';

      // 캐시된 데이터가 있으면 사용
      if (_monthlyCache.containsKey(cacheKey)) {
        setState(() {
          _events = _monthlyCache[cacheKey]!;
          _isLoading = false;
        });
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
        return;
      }

      // 현재 월의 운동 기록 로드
      final workouts = await WorkoutHistoryService.getWorkoutsByMonth(
        _focusedDay,
      );

      // 통계는 첫 로드시에만 계산 (전체 데이터 기반)
      if (_lastLoadedMonth == null) {
        final statistics = await WorkoutHistoryService.getStatistics();
        final streak = await WorkoutHistoryService.getCurrentStreak();
        _statistics = statistics;
        _currentStreak = streak;
      }

      // 이벤트 맵 생성
      final events = <DateTime, List<WorkoutHistory>>{};
      for (final workout in workouts) {
        final date = DateTime(
          workout.date.year,
          workout.date.month,
          workout.date.day,
        );
        if (events[date] != null) {
          events[date]!.add(workout);
        } else {
          events[date] = [workout];
        }
      }

      // 캐시에 저장
      _monthlyCache[cacheKey] = events;
      _lastLoadedMonth = currentMonth;

      setState(() {
        _events = events;
        _isLoading = false;
      });

      // 선택된 날짜의 이벤트 업데이트
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('운동 기록을 불러오는데 실패했습니다: $e')));
      }
    }
  }

  List<WorkoutHistory> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Color(
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      body: Column(
        children: [
          // 메인 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 통계 카드
                  _buildStatisticsCard(),

                  const SizedBox(height: AppConstants.paddingM),

                  // 달력
                  _buildCalendar(),

                  const SizedBox(height: AppConstants.paddingM),

                  // 선택된 날짜의 운동 기록
                  _buildSelectedDayEvents(),

                  // 배너 광고를 위한 여분 공간
                  const SizedBox(height: 80),
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

  Widget _buildStatisticsCard() {
    final theme = Theme.of(context);
    // // final l10n = AppLocalizations.of(context); // unused - commented out

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: Color(AppColors.primaryColor).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: Color(AppColors.primaryColor).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            '🏆 운동 통계',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Color(AppColors.primaryColor),
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppConstants.paddingM),

          if (_isLoading) ...[
            const CircularProgressIndicator(),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.fitness_center,
                    label: '총 운동',
                    value: '${_statistics['totalWorkouts'] ?? 0}일',
                    color: Color(AppColors.primaryColor),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.local_fire_department,
                    label: '연속 일수',
                    value: '$_currentStreak일',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingS),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.trending_up,
                    label: '평균 달성률',
                    value:
                        '${((_statistics['averageCompletion'] ?? 0.0) * 100).toInt()}%',
                    color: Color(AppColors.successColor),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.sports_gymnastics,
                    label: '총 푸시업',
                    value: '${_statistics['totalReps'] ?? 0}개',
                    color: Color(AppColors.secondaryColor),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingS,
        vertical: AppConstants.paddingS / 2,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppConstants.paddingS / 2),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<WorkoutHistory>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,

        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: Colors.red[400]),
          holidayTextStyle: TextStyle(color: Colors.red[400]),

          // 마커 스타일
          markerDecoration: BoxDecoration(
            color: Color(AppColors.primaryColor),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,

          // 선택된 날짜 스타일
          selectedDecoration: BoxDecoration(
            color: Color(AppColors.primaryColor),
            shape: BoxShape.circle,
          ),

          // 오늘 날짜 스타일
          todayDecoration: BoxDecoration(
            color: Color(AppColors.secondaryColor),
            shape: BoxShape.circle,
          ),
        ),

        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: Color(AppColors.primaryColor),
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          formatButtonTextStyle: TextStyle(color: Colors.white, fontSize: 12),
        ),

        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _selectedEvents.value = _getEventsForDay(selectedDay);
          }
        },

        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },

        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
          _loadWorkoutData(); // 새로운 월의 데이터 로드
        },

        // 커스텀 마커 빌더
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isNotEmpty) {
              final workout = events.first;
              return Positioned(
                right: 1,
                bottom: 1,
                child: _buildWorkoutMarker(workout),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildWorkoutMarker(WorkoutHistory workout) {
    Color markerColor;
    IconData markerIcon;
    double opacity = 1.0;

    // 완료율에 따른 더 세분화된 표시
    if (workout.completionRate >= 1.0) {
      // 100% 완료 - 별 아이콘
      markerColor = Color(AppColors.successColor);
      markerIcon = Icons.star;
    } else if (workout.completionRate >= 0.8) {
      // 80% 이상 - 따봉 아이콘
      markerColor = Color(AppColors.primaryColor);
      markerIcon = Icons.thumb_up;
    } else if (workout.completionRate >= 0.5) {
      // 50% 이상 - 원형 아이콘
      markerColor = Colors.orange;
      markerIcon = Icons.circle;
    } else if (workout.completionRate > 0) {
      // 조금이라도 했음 - 시작 아이콘, 투명도 조정
      markerColor = Colors.amber;
      markerIcon = Icons.play_circle_outline;
    } else {
      // 기록만 있고 실제 운동은 안함
      markerColor = Colors.grey;
      markerIcon = Icons.circle_outlined;
      opacity = 0.6;
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: markerColor.withValues(alpha: opacity),
        shape: BoxShape.circle,
        border: workout.completionRate < 0.5 && workout.completionRate > 0
            ? Border.all(color: markerColor, width: 1.5)
            : null,
      ),
      child: Icon(markerIcon, size: 10, color: Colors.white),
    );
  }

  Widget _buildSelectedDayEvents() {
    final theme = Theme.of(context);

    return ValueListenableBuilder<List<WorkoutHistory>>(
      valueListenable: _selectedEvents,
      builder: (context, value, _) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: Color(AppColors.primaryColor).withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusM),
                    topRight: Radius.circular(AppConstants.radiusM),
                  ),
                ),
                child: Text(
                  _selectedDay != null
                      ? '${_selectedDay?.month}월 ${_selectedDay?.day}일 운동 기록'
                      : '운동 기록',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Color(AppColors.primaryColor),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              if (value.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: AppConstants.paddingS),
                      Text(
                        '이 날은 운동 기록이 없습니다',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingS / 2),
                      Text(
                        '💪 오늘부터 시작해보세요!',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...value.map((workout) => _buildWorkoutSummary(workout)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutSummary(WorkoutHistory workout) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildWorkoutMarker(workout),
              const SizedBox(width: AppConstants.paddingS),
              Expanded(
                child: Text(
                  workout.workoutTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingS,
                  vertical: AppConstants.paddingS / 2,
                ),
                decoration: BoxDecoration(
                  color: _getPerformanceColor(
                    workout.completionRate,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  border: Border.all(
                    color: _getPerformanceColor(workout.completionRate),
                  ),
                ),
                child: Text(
                  '${(workout.completionRate * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getPerformanceColor(workout.completionRate),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingS),

          Row(
            children: [
              Icon(Icons.fitness_center, size: 16, color: Colors.grey[600]),
              const SizedBox(width: AppConstants.paddingS / 2),
              Text(
                '총 ${workout.totalReps}개 완료',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Icon(Icons.military_tech, size: 16, color: Colors.grey[600]),
              const SizedBox(width: AppConstants.paddingS / 2),
              Text(
                workout.level,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingS),

          // 세트별 상세 정보
          Wrap(
            spacing: AppConstants.paddingS / 2,
            children: List.generate(workout.targetReps.length, (index) {
              final target = workout.targetReps[index];
              final completed = workout.completedReps[index];
              final percentage = (completed / target * 100).round();

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingS / 2,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(AppConstants.radiusS / 2),
                ),
                child: Text(
                  '${index + 1}세트: $completed/$target ($percentage%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Colors.grey[700],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getPerformanceColor(double completionRate) {
    if (completionRate >= 1.0) return Color(AppColors.successColor);
    if (completionRate >= 0.8) return Color(AppColors.primaryColor);
    if (completionRate >= 0.5) return Colors.orange;
    return Colors.grey;
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
      child: _calendarBannerAd != null
          ? AdWidget(ad: _calendarBannerAd!)
          : Container(
              height: 60,
              color: Color(0xFF1A1A1A),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Color(AppColors.primaryColor),
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '꾸준함이 차드의 힘! 📅',
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

  /// 달력 화면 전용 배너 광고 생성
  void _createCalendarBannerAd() {
    _calendarBannerAd = AdService.createBannerAd();
    _calendarBannerAd?.load();
  }
}
