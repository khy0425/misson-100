
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'workout_history_service.dart';


class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;

  /// 알림 서비스 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // 타임존 초기화
    tz.initializeTimeZones();
    
    // Android 초기화 설정
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 초기화 설정
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    _isInitialized = true;
  }

  /// 알림 권한 요청
  static Future<bool> requestPermissions() async {
    await initialize();
    
    // Android 13+ 알림 권한 요청
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    
    // iOS 권한 요청
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    
    return true;
  }

  /// 일일 운동 알림 설정 (스마트 버전)
  static Future<void> scheduleDailyWorkoutReminder({
    required TimeOfDay time,
    String title = '💪 운동 시간이에요!',
    String body = '오늘도 차드가 되기 위한 푸쉬업 시간입니다! 🔥',
  }) async {
    await initialize();
    
    // 기존 일일 알림 취소
    await _notifications.cancel(1);
    
    // 다음 7일간의 알림을 개별적으로 스케줄링
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final targetDate = now.add(Duration(days: i));
      var scheduledDate = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        time.hour,
        time.minute,
      );
      
      // 오늘 시간이 이미 지났다면 내일부터 시작
      if (i == 0 && scheduledDate.isBefore(now)) {
        continue;
      }
      
      // 각 날짜별로 고유한 알림 ID 사용 (1000 + 일수)
      final notificationId = 1000 + i;
      
      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_workout',
            'Daily Workout Reminder',
            channelDescription: '매일 운동 알림',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation: 
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
    
    // 설정된 시간 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', time.hour);
    await prefs.setInt('notification_minute', time.minute);
    await prefs.setBool('daily_notification_enabled', true);
    
    // 일주일 후에 다시 스케줄링하도록 설정
    await _scheduleRescheduling(time);
  }

  /// 일주일 후 알림 재스케줄링
  static Future<void> _scheduleRescheduling(TimeOfDay time) async {
    final now = DateTime.now();
    final rescheduleDate = now.add(const Duration(days: 7));
    final rescheduleTime = DateTime(
      rescheduleDate.year,
      rescheduleDate.month,
      rescheduleDate.day,
      2, // 새벽 2시에 재스케줄링
      0,
    );
    
    await _notifications.zonedSchedule(
      9999, // 재스케줄링용 특별 ID
      'Reschedule',
      'Rescheduling workout reminders',
      tz.TZDateTime.from(rescheduleTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'system',
          'System',
          channelDescription: '시스템 알림',
          importance: Importance.low,
          priority: Priority.low,
          playSound: false,
          enableVibration: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: false,
          presentSound: false,
        ),
      ),
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 오늘의 운동 리마인더 취소 (운동 완료 시 호출)
  static Future<void> cancelTodayWorkoutReminder() async {
    await initialize();
    
    // 오늘의 일일 알림만 취소 (내일부터는 다시 알림이 울림)
    // 하지만 flutter_local_notifications에서는 특정 날짜만 취소하기 어려우므로
    // 운동 완료 시 플래그를 설정하여 다음 알림 시 확인하도록 함
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await prefs.setBool('workout_completed_$todayKey', true);
    
    print('📅 오늘($todayKey) 운동 완료 플래그 설정됨');
  }

  /// 오늘 운동을 완료했는지 확인
  static Future<bool> isWorkoutCompletedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return prefs.getBool('workout_completed_$todayKey') ?? false;
  }

  /// 스마트 운동 리마인더 (운동 완료 여부 확인 후 알림)
  static Future<void> showSmartWorkoutReminder() async {
    await initialize();
    
    // 오늘 운동을 이미 완료했는지 확인
    if (await isWorkoutCompletedToday()) {
      print('📅 오늘 이미 운동을 완료했으므로 리마인더를 표시하지 않습니다.');
      return;
    }
    
    // 데이터베이스에서도 한 번 더 확인
    final today = DateTime.now();
    final todayWorkout = await WorkoutHistoryService.getWorkoutByDate(today);
    
    if (todayWorkout != null) {
      // 데이터베이스에 기록이 있다면 플래그도 업데이트
      await cancelTodayWorkoutReminder();
      print('📅 데이터베이스에서 오늘 운동 기록 발견, 리마인더 취소');
      return;
    }
    
    // 운동을 하지 않았다면 리마인더 표시
    await _notifications.show(
      1, // 알림 ID
      '💪 운동 시간이에요!',
      '오늘도 차드가 되기 위한 푸쉬업 시간입니다! 🔥',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_workout',
          'Daily Workout Reminder',
          channelDescription: '매일 운동 알림',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// 연속 운동 격려 알림 설정
  static Future<void> scheduleStreakEncouragement() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('streak_notification_enabled', true);
  }

  /// 업적 달성 알림
  static Future<void> showAchievementNotification(
    String title,
    String description,
  ) async {
    await _notifications.show(
      3, // 업적 알림 ID
      '🏆 업적 달성!',
      '$title: $description',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievement',
          'Achievement Notifications',
          channelDescription: '업적 달성 알림',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// 연속 운동 격려 알림 (3일 연속 시)
  static Future<void> showStreakEncouragement(int streakDays) async {
    await initialize();
    
    String title = '🔥 연속 운동 달성!';
    String body = '$streakDays일 연속 운동 완료! 진정한 차드의 길을 걷고 있습니다! 💪';
    
    if (streakDays >= 7) {
      title = '👑 일주일 연속 달성!';
      body = '와우! $streakDays일 연속! 당신은 이미 차드 제국의 황제입니다! 🚀';
    } else if (streakDays >= 30) {
      title = '🚀 한 달 연속 달성!';
      body = '믿을 수 없는 $streakDays일 연속! 전설적인 울트라 기가 차드 탄생! ⚡';
    }
    
    await _notifications.show(
      2, // 알림 ID
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_encouragement',
          'Streak Encouragement',
          channelDescription: '연속 운동 격려 알림',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// 운동 완료 축하 알림
  static Future<void> showWorkoutCompletionCelebration({
    required int totalReps,
    required double completionRate,
  }) async {
    await initialize();
    
    String title = '🎉 운동 완료!';
    String body = '$totalReps개 완료! (${(completionRate * 100).toInt()}% 달성)';
    
    if (completionRate >= 1.0) {
      title = '🚀 완벽한 운동!';
      body = '목표 100% 달성! 당신은 진정한 차드입니다! 💪';
    } else if (completionRate >= 0.8) {
      title = '⚡ 훌륭한 운동!';
      body = '목표의 ${(completionRate * 100).toInt()}% 달성! 차드의 길을 걷고 있습니다! 🔥';
    }
    
    await _notifications.show(
      3, // 알림 ID
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_completion',
          'Workout Completion',
          channelDescription: '운동 완료 축하 알림',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// 일일 알림 취소
  static Future<void> cancelDailyReminder() async {
    await _notifications.cancel(1);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_notification_enabled', false);
  }

  /// 모든 알림 취소
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_notification_enabled', false);
  }

  /// 저장된 알림 설정 가져오기
  static Future<Map<String, dynamic>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'daily_enabled': prefs.getBool('daily_notification_enabled') ?? false,
      'hour': prefs.getInt('notification_hour') ?? 20,
      'minute': prefs.getInt('notification_minute') ?? 0,
    };
  }

  /// 알림 탭 시 처리
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('알림 탭됨: ${response.payload}');
    // 필요시 특정 화면으로 네비게이션 처리
  }

  /// 알림 권한 상태 확인
  static Future<bool> areNotificationsEnabled() async {
    await initialize();
    
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final enabled = await androidPlugin.areNotificationsEnabled();
      return enabled ?? false;
    }
    
    return true; // iOS는 기본적으로 true 반환
  }

  /// 알림 권한 확인 (hasPermission 별칭)
  static Future<bool> hasPermission() async {
    return await areNotificationsEnabled();
  }

  /// 운동 리마인더 스케줄링 (settings_screen.dart용)
  static Future<void> scheduleWorkoutReminder({
    required int hour,
    required int minute,
    required bool enabled,
  }) async {
    if (!enabled) {
      await cancelWorkoutReminder();
      return;
    }

    await scheduleDailyWorkoutReminder(
      time: TimeOfDay(hour: hour, minute: minute),
    );
  }

  /// 운동 리마인더 취소
  static Future<void> cancelWorkoutReminder() async {
    await initialize();
    
    // 모든 일일 알림 취소 (1000-1006)
    for (int i = 0; i < 7; i++) {
      await _notifications.cancel(1000 + i);
    }
    
    // 재스케줄링 알림도 취소
    await _notifications.cancel(9999);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_notification_enabled', false);
  }



  /// 알림 채널 생성 (Android용)
  static Future<void> createNotificationChannels() async {
    await initialize();
    
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // 일일 운동 알림 채널
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_workout',
          'Daily Workout Reminder',
          description: '매일 운동 알림',
          importance: Importance.high,
        ),
      );
      
      // 연속 운동 격려 알림 채널
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'streak_encouragement',
          'Streak Encouragement',
          description: '연속 운동 격려 알림',
          importance: Importance.high,
        ),
      );
      
      // 운동 완료 축하 알림 채널
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'workout_completion',
          'Workout Completion',
          description: '운동 완료 축하 알림',
          importance: Importance.high,
        ),
      );
    }
  }



  /// 알림 설정 화면 열기 (Android 설정 앱으로 이동)
  static Future<bool> openNotificationSettings() async {
    // 이 기능은 플러그인에서 직접 지원하지 않으므로
    // 사용자에게 수동으로 설정하도록 안내
    return false;
  }


}
