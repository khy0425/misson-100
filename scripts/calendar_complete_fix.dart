// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';
import '../models/workout_history.dart';
import '../services/workout_history_service.dart';
import '../services/ad_service.dart';

void main() async {
  print('📅 CALENDAR SCREEN 완전 복구 작전! 📅');

  await fixCalendarScreenCompletely();

  print('✅ CALENDAR SCREEN 완전 복구 완료! ✅');
}

Future<void> fixCalendarScreenCompletely() async {
  print('📅 Calendar Screen 완전 재작성 중...');

  final file = File('lib/screens/calendar_screen.dart');

  // 완전히 새로운 내용으로 교체
  const content = '''
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  bool _isLoading = true;

  BannerAd? _calendarBannerAd;

  @override
  void initState() {
    super.initState();

    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadWorkoutHistory();
    _createCalendarBannerAd();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _calendarBannerAd?.dispose();
    super.dispose();
  }

  List<WorkoutHistory> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _loadWorkoutHistory() async {
    setState(() => _isLoading = true);

    try {
      final history = await WorkoutHistoryService.getAllWorkouts();
      final Map<DateTime, List<WorkoutHistory>> events = {};

      for (final workout in history) {
        final date = DateTime(workout.date.year, workout.date.month, workout.date.day);
        if (events[date] != null) {
          events[date]!.add(workout);
        } else {
          events[date] = [workout];
        }
      }

      setState(() {
        _events = events;
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('운동 기록을 불러오는 중 오류가 발생했습니다: \$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
      body: Column(
        children: [
          // 메인 콘텐츠
          Expanded(
            child: Column(
              children: [
                // 달력
                Container(
                  margin: EdgeInsets.all(AppConstants.paddingM),
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
                    locale: Localizations.localeOf(context).toString(),
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                        setState(() => _calendarFormat = format);
                      }
                    },
                    onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: Colors.red[400]),
                      holidayTextStyle: TextStyle(color: Colors.red[400]),
                      todayDecoration: BoxDecoration(
                        color: Color(AppColors.primaryColor).withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(AppColors.primaryColor),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Color(AppColors.successColor),
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
                      formatButtonTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                // 선택된 날짜의 운동 기록
                Expanded(child: _buildSelectedDayEvents()),
              ],
            ),
          ),

          // 하단 배너 광고
          _buildBannerAd(),
        ],
      ),
    );
  }

  Widget _buildSelectedDayEvents() {
    final theme = Theme.of(context);

    return ValueListenableBuilder<List<WorkoutHistory>>(
      valueListenable: _selectedEvents,
      builder: (context, value, _) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
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
                padding: EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: Color(AppColors.primaryColor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusM),
                    topRight: Radius.circular(AppConstants.radiusM),
                  ),
                ),
                child: Text(
                  '\${_selectedDay?.month}/\${_selectedDay?.day} 운동 기록',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              if (value.isEmpty) ...[
                Padding(
                  padding: EdgeInsets.all(AppConstants.paddingL),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '이 날에는 운동 기록이 없습니다',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return _buildWorkoutSummary(value[index]);
                    },
                  ),
                ),
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
      padding: EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getPerformanceColor(workout.completionRate),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  workout.workoutTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getPerformanceColor(workout.completionRate).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  '\${(workout.completionRate * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getPerformanceColor(workout.completionRate),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.fitness_center, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                workout.pushupType,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Icon(Icons.military_tech, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                workout.level,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
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
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Color(AppColors.primaryColor), width: 1),
        ),
      ),
      child: _calendarBannerAd != null
          ? AdWidget(ad: _calendarBannerAd!)
          : Container(
              height: 60,
              color: const Color(0xFF1A1A1A),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Color(AppColors.primaryColor),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    const Text(
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
''';

  await file.writeAsString(content);
  print('  ✅ Calendar Screen 완전 재작성 완료');
}
