import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';
import '../models/workout_history.dart';
import '../services/workout_history_service.dart';
import '../services/notification_service.dart';
import '../services/achievement_service.dart';
import '../services/ad_service.dart';
import '../generated/app_localizations.dart';

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
  List<WorkoutHistory> _workoutHistory = [];
  Map<DateTime, List<WorkoutHistory>> _workoutEvents = {};
  bool _isLoading = true;

  BannerAd? _calendarBannerAd;

  @override
  void initState() {
    super.initState();

    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    
    // 데이터베이스 상태 확인
    _checkDatabaseStatus();
    
    _loadWorkoutHistory();
    _createCalendarBannerAd();
    
    // 알림 서비스 초기화
    NotificationService.initialize();
    
    // 운동 기록 저장 시 달력 즉시 업데이트 (즉시 등록)
    WorkoutHistoryService.addOnWorkoutSavedCallback(_onWorkoutSaved);
    debugPrint('📅 달력 화면: 운동 기록 콜백 등록 완료');
    
    // 업적 달성 시 달력 데이터 새로고침을 위한 콜백 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AchievementService.setOnStatsUpdated(() {
        if (mounted) {
          _loadWorkoutHistory();
        }
      });
    });
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _calendarBannerAd?.dispose();
    
    // 콜백 제거하여 메모리 누수 방지
    WorkoutHistoryService.removeOnWorkoutSavedCallback(_onWorkoutSaved);
    
    super.dispose();
  }

  Future<void> _loadWorkoutHistory() async {
    try {
      debugPrint('📅 [CalendarScreen] 운동 기록 로딩 시작...');
      final history = await WorkoutHistoryService.getAllWorkouts();
      debugPrint('📅 [CalendarScreen] 로드된 운동 기록 수: ${history.length}개');
      
      // 로드된 데이터 상세 로그
      for (int i = 0; i < history.length && i < 5; i++) {
        final workout = history[i];
        debugPrint('📅 [CalendarScreen] 운동 기록 ${i + 1}: ${workout.date} - ${workout.workoutTitle} (${workout.totalReps}회, ${(workout.completionRate * 100).toStringAsFixed(1)}%)');
      }
      if (history.length > 5) {
        debugPrint('📅 [CalendarScreen] ... 및 ${history.length - 5}개 더');
      }
      
      setState(() {
        _workoutHistory = history;
        _organizeWorkoutEvents();
        _isLoading = false;
      });
      
      debugPrint('📅 [CalendarScreen] 조직화된 이벤트 날짜 수: ${_workoutEvents.keys.length}개');
      debugPrint('📅 [CalendarScreen] 이벤트 날짜들: ${_workoutEvents.keys.take(10).toList()}');
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('❌ [CalendarScreen] 운동 기록 로딩 실패: $e');
    }
  }

  void _organizeWorkoutEvents() {
    _workoutEvents.clear();
    debugPrint('📅 [CalendarScreen] 이벤트 조직화 시작...');
    
    for (final workout in _workoutHistory) {
      final date = DateTime(
        workout.date.year,
        workout.date.month,
        workout.date.day,
      );
      
      debugPrint('📅 [CalendarScreen] 원본 날짜: ${workout.date} -> 정규화된 날짜: $date');
      
      if (_workoutEvents[date] != null) {
        _workoutEvents[date]!.add(workout);
        debugPrint('📅 [CalendarScreen] 기존 날짜에 추가: $date (총 ${_workoutEvents[date]!.length}개)');
      } else {
        _workoutEvents[date] = [workout];
        debugPrint('📅 [CalendarScreen] 새 날짜 추가: $date');
      }
    }
    
    debugPrint('📅 [CalendarScreen] 이벤트 조직화 완료. 총 ${_workoutEvents.length}개 날짜에 운동 기록 존재');
  }

  List<WorkoutHistory> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final events = _workoutEvents[normalizedDay] ?? [];
    
    // 오늘과 며칠 전의 데이터만 로그 출력 (너무 많은 로그 방지)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysDiff = today.difference(normalizedDay).inDays.abs();
    
    if (daysDiff <= 7) {  // 일주일 이내의 날짜만 로그
      debugPrint('📅 [CalendarScreen] _getEventsForDay($day) -> 정규화: $normalizedDay, 이벤트 수: ${events.length}');
      if (events.isNotEmpty) {
        for (final event in events) {
          debugPrint('  📋 이벤트: ${event.workoutTitle} (${event.totalReps}회, ${(event.completionRate * 100).toStringAsFixed(1)}%)');
        }
      }
    }
    
    return events;
  }

  int _getCurrentStreak() {
    if (_workoutHistory.isEmpty) return 0;

    final sortedDates = _workoutEvents.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime currentDate = DateTime(today.year, today.month, today.day);

    for (final date in sortedDates) {
      final daysDiff = currentDate.difference(date).inDays;
      
      if (daysDiff == streak) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  Color _getDayColor(DateTime day) {
    final events = _getEventsForDay(day);
    
    // 오늘과 며칠 전의 데이터만 로그 출력
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysDiff = today.difference(DateTime(day.year, day.month, day.day)).inDays.abs();
    
    if (events.isEmpty) {
      if (daysDiff <= 7) {
        debugPrint('📅 [CalendarScreen] _getDayColor($day): 이벤트 없음 -> 투명');
      }
      return Colors.transparent;
    }

    // 개별 세트 완료도를 체크하여 정확한 완료율 계산
    double totalCompletionRate = 0.0;
    
    for (final event in events) {
      // 개별 세트들이 모두 목표를 달성했는지 확인
      bool allSetsCompleted = true;
      if (event.completedReps.isNotEmpty && event.targetReps.isNotEmpty) {
        for (int i = 0; i < event.completedReps.length; i++) {
          final targetRep = i < event.targetReps.length ? event.targetReps[i] : 0;
          final completedRep = event.completedReps[i];
          if (completedRep < targetRep) {
            allSetsCompleted = false;
            break;
          }
        }
      }
      
      // 모든 세트를 완료했다면 실제 완료율 계산 (100% 이상 가능)
      if (allSetsCompleted) {
        final totalTarget = event.targetReps.fold(0, (sum, reps) => sum + reps);
        final totalCompleted = event.completedReps.fold(0, (sum, reps) => sum + reps);
        totalCompletionRate += totalTarget > 0 ? totalCompleted / totalTarget : 1.0;
      } else {
        // 개별 세트 중 하나라도 목표에 못 미쳤다면 기존 로직 사용
        totalCompletionRate += event.completionRate;
      }
    }
    
    final avgCompletionRate = totalCompletionRate / events.length;
    
    Color resultColor;
    String colorName;
    
    if (avgCompletionRate >= 1.0) {
      resultColor = Colors.green.shade400; // 완벽 완료 (모든 세트 목표 달성)
      colorName = '초록색 (완벽)';
    } else if (avgCompletionRate >= 0.8) {
      resultColor = Colors.blue.shade400; // 좋음 (80% 이상)
      colorName = '파란색 (좋음)';
    } else if (avgCompletionRate >= 0.5) {
      resultColor = Colors.orange.shade400; // 보통 (50% 이상)
      colorName = '주황색 (보통)';
    } else {
      resultColor = Colors.red.shade400; // 부족 (50% 미만)
      colorName = '빨간색 (부족)';
    }
    
    if (daysDiff <= 7) {
      debugPrint('📅 [CalendarScreen] _getDayColor($day): 평균 완료율 ${(avgCompletionRate * 100).toStringAsFixed(1)}% -> $colorName');
    }
    
    return resultColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      body: Column(
        children: [
          // 메인 콘텐츠
          Expanded(
            child: Column(
              children: [
                // 스트릭 정보 카드
                _buildStreakInfoCard(),
                
                // 달력
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildCalendar(),
                        const SizedBox(height: 16),
                        _buildSelectedDayInfo(),
                        const SizedBox(height: 16),
                        _buildLegend(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 하단 배너 광고
          _buildBannerAd(),
        ],
      ),
    );
  }

  Widget _buildStreakInfoCard() {
    final currentStreak = _getCurrentStreak();
    final totalWorkouts = _workoutHistory.length;
    final thisMonthWorkouts = _workoutHistory.where((workout) {
      final now = DateTime.now();
      return workout.date.year == now.year && workout.date.month == now.month;
    }).length;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStreakStat(
              icon: Icons.local_fire_department,
              label: AppLocalizations.of(context)!.currentStreak,
              value: '$currentStreak',
              color: Colors.orange,
            ),
            _buildStreakStat(
              icon: Icons.fitness_center,
              label: AppLocalizations.of(context)!.totalWorkouts,
              value: '$totalWorkouts',
              color: Colors.blue,
            ),
            _buildStreakStat(
              icon: Icons.calendar_month,
              label: AppLocalizations.of(context)!.thisMonth,
              value: '$thisMonthWorkouts',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
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
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TableCalendar<WorkoutHistory>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
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
            _focusedDay = focusedDay;
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              return _buildCalendarDay(day, false);
            },
            selectedBuilder: (context, day, focusedDay) {
              return _buildCalendarDay(day, true);
            },
            todayBuilder: (context, day, focusedDay) {
              return _buildCalendarDay(day, false, isToday: true);
            },
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            formatButtonTextStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: Colors.red),
            holidayTextStyle: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day, bool isSelected, {bool isToday = false}) {
    final events = _getEventsForDay(day);
    final dayColor = _getDayColor(day);
    
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected 
            ? Colors.blue.shade600
            : isToday 
                ? Colors.blue.shade100
                : dayColor,
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(color: Colors.blue.shade600, width: 2)
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: isSelected || dayColor != Colors.transparent
                    ? Colors.white
                    : isToday
                        ? Colors.blue.shade600
                        : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (events.isNotEmpty)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected || dayColor != Colors.transparent
                      ? Colors.white
                      : Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayInfo() {
    if (_selectedDay == null) return const SizedBox.shrink();
    
    final events = _getEventsForDay(_selectedDay!);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (events.isEmpty)
              Text(
                AppLocalizations.of(context)!.noWorkoutThisDay,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              )
            else
              ...events.map((event) => _buildWorkoutEventTile(event)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutEventTile(WorkoutHistory workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            width: 4,
            color: workout.completionRate >= 1.0
                ? Colors.green
                : workout.completionRate >= 0.8
                    ? Colors.blue
                    : workout.completionRate >= 0.5
                        ? Colors.orange
                        : Colors.red,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.workoutTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${workout.totalReps}개 (${(workout.completionRate * 100).toInt()}%)',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            workout.completionRate >= 1.0
                ? Icons.check_circle
                : workout.completionRate >= 0.8
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
            color: workout.completionRate >= 1.0
                ? Colors.green
                : workout.completionRate >= 0.8
                    ? Colors.blue
                    : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.legend,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(Colors.green.shade400, AppLocalizations.of(context)!.perfect),
                _buildLegendItem(Colors.blue.shade400, AppLocalizations.of(context)!.good),
                _buildLegendItem(Colors.orange.shade400, AppLocalizations.of(context)!.okay),
                _buildLegendItem(Colors.red.shade400, AppLocalizations.of(context)!.poor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
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
      child: _calendarBannerAd != null
          ? AdWidget(ad: _calendarBannerAd!)
          : Container(
              height: 60,
              color: const Color(0xFF1A1A1A),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Color(AppColors.primaryColor),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.calendarBannerText,
                      style: const TextStyle(
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
    _calendarBannerAd = AdService.instance.createBannerAd(
      adSize: AdSize.banner,
      onAdLoaded: (Ad ad) {
        debugPrint('달력 배너 광고 로드 완료');
        if (mounted) {
          setState(() {});
        }
      },
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        debugPrint('달력 배너 광고 로드 실패: $error');
        ad.dispose();
        if (mounted) {
          setState(() {
            _calendarBannerAd = null;
          });
        }
      },
    );
    _calendarBannerAd?.load();
  }

  // 운동 저장 시 호출될 콜백 메서드
  void _onWorkoutSaved() {
    if (mounted) {
      debugPrint('📅 달력 화면: 운동 기록 저장 감지, 데이터 새로고침 시작');
      
      // 즉시 UI 업데이트 시작
      setState(() {
        _isLoading = true;
      });
      
      // 비동기로 데이터 로드
      _loadWorkoutHistory().then((_) {
        debugPrint('📅 달력 화면: 데이터 새로고침 완료');
        
        // 선택된 날짜의 이벤트도 업데이트
        if (_selectedDay != null) {
          _selectedEvents.value = _getEventsForDay(_selectedDay!);
          debugPrint('📅 선택된 날짜(${_selectedDay}) 이벤트 업데이트: ${_selectedEvents.value.length}개');
        }
      }).catchError((e) {
        debugPrint('❌ 달력 화면: 데이터 새로고침 실패: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      debugPrint('⚠️ 달력 화면: mounted가 false이므로 콜백 무시');
    }
  }

  /// 데이터베이스 상태 확인 (디버깅용)
  Future<void> _checkDatabaseStatus() async {
    try {
      debugPrint('🔍 [CalendarScreen] 데이터베이스 상태 확인 시작...');
      
      // 전체 운동 기록 수 확인
      final allWorkouts = await WorkoutHistoryService.getAllWorkouts();
      debugPrint('🔍 [CalendarScreen] 총 운동 기록 수: ${allWorkouts.length}개');
      
      // 통계 정보 확인
      final stats = await WorkoutHistoryService.getStatistics();
      debugPrint('🔍 [CalendarScreen] 통계 정보: $stats');
      
      // 최근 5개 운동 기록 상세 확인
      if (allWorkouts.isNotEmpty) {
        debugPrint('🔍 [CalendarScreen] 최근 운동 기록들:');
        for (int i = 0; i < allWorkouts.length && i < 5; i++) {
          final workout = allWorkouts[i];
          debugPrint('  📋 ${i + 1}: ${workout.date.toIso8601String()} - ${workout.workoutTitle}');
          debugPrint('      목표: ${workout.targetReps}, 완료: ${workout.completedReps}');
          debugPrint('      총 ${workout.totalReps}회, 완료율: ${(workout.completionRate * 100).toStringAsFixed(1)}%');
        }
      } else {
        debugPrint('🔍 [CalendarScreen] ⚠️ 운동 기록이 없습니다!');
      }
      
      debugPrint('🔍 [CalendarScreen] 데이터베이스 상태 확인 완료');
    } catch (e) {
      debugPrint('❌ [CalendarScreen] 데이터베이스 상태 확인 실패: $e');
    }
  }
}
