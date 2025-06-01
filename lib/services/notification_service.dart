import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'workout_history_service.dart';
import 'dart:convert';
import 'dart:typed_data';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;
  
  // Android 12+ SCHEDULE_EXACT_ALARM 권한 확인을 위한 MethodChannel
  static const MethodChannel _channel = MethodChannel('com.misson100.notification_permissions');

  /// Android 12+에서 SCHEDULE_EXACT_ALARM 권한이 있는지 확인
  static Future<bool> canScheduleExactAlarms() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true; // iOS는 권한 필요 없음
    }
    
    try {
      final bool? canSchedule = await _channel.invokeMethod('canScheduleExactAlarms');
      debugPrint('🔔 SCHEDULE_EXACT_ALARM 권한 상태: $canSchedule');
      return canSchedule ?? false;
    } on PlatformException catch (e) {
      debugPrint('❌ SCHEDULE_EXACT_ALARM 권한 확인 오류: ${e.message}');
      // Android 12 미만이면 true 반환 (권한 필요 없음)
      return true;
    }
  }

  /// Android 12+에서 SCHEDULE_EXACT_ALARM 권한 요청
  static Future<bool> requestExactAlarmPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true; // iOS는 권한 필요 없음
    }
    
    try {
      debugPrint('🔔 SCHEDULE_EXACT_ALARM 권한 요청 시작...');
      final bool? granted = await _channel.invokeMethod('requestExactAlarmPermission');
      debugPrint('🔔 SCHEDULE_EXACT_ALARM 권한 요청 결과: $granted');
      
      // 설정 화면으로 이동한 후 충분한 시간 대기
      await Future.delayed(const Duration(seconds: 2));
      
      // 실제 권한 상태를 다시 확인 (사용자가 허용했는지 확인)
      final actualPermission = await canScheduleExactAlarms();
      debugPrint('🔔 SCHEDULE_EXACT_ALARM 실제 권한 상태: $actualPermission');
      
      return actualPermission;
    } on PlatformException catch (e) {
      debugPrint('❌ SCHEDULE_EXACT_ALARM 권한 요청 오류: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ SCHEDULE_EXACT_ALARM 권한 요청 일반 오류: $e');
      return false;
    }
  }

  /// 안전한 알림 스케줄링 (권한 확인 포함)
  static Future<bool> _safeScheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationDetails notificationDetails,
  }) async {
    try {
      // Android 12+에서 정확한 알람 권한 확인
      if (defaultTargetPlatform == TargetPlatform.android) {
        final canSchedule = await canScheduleExactAlarms();
        
        if (!canSchedule) {
          debugPrint('⚠️ SCHEDULE_EXACT_ALARM 권한이 없어 부정확한 알림 방식 사용');
          // 권한이 없으면 부정확한 알림 스케줄링 사용
          return await scheduleInexactNotification(
            id: id,
            title: title,
            body: body,
            scheduledDate: scheduledDate,
            notificationDetails: notificationDetails,
          );
        }
      }

      // 권한이 있으면 정확한 시간에 스케줄링
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        uiLocalNotificationDateInterpretation: 
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      debugPrint('✅ 정확한 알림 스케줄링 성공: $title (${scheduledDate.toString()})');
      return true;
    } catch (e) {
      debugPrint('❌ 정확한 알림 스케줄링 실패: $e');
      
      // 실패 시 부정확한 알림으로 대체
      try {
        return await scheduleInexactNotification(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
        );
      } catch (fallbackError) {
        debugPrint('❌ 부정확한 알림 대체도 실패: $fallbackError');
        
        // 최후 수단: 즉시 알림 표시
        try {
          await _notifications.show(id, title, body, notificationDetails);
          debugPrint('🔄 최후 수단으로 즉시 알림 표시');
          return false;
        } catch (immediateError) {
          debugPrint('❌ 즉시 알림도 실패: $immediateError');
          return false;
        }
      }
    }
  }

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

  /// 알림 권한 요청 (Android 12+ SCHEDULE_EXACT_ALARM 권한 포함)
  static Future<bool> requestPermissions() async {
    await initialize();
    
    bool notificationPermissionGranted = false;
    bool exactAlarmPermissionGranted = true; // iOS는 기본 true
    
    // 1. 기본 알림 권한 요청 (Android 13+)
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      notificationPermissionGranted = granted ?? false;
      debugPrint('📱 기본 알림 권한: $notificationPermissionGranted');
      
      // 권한 상태를 SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_permission_granted', notificationPermissionGranted);
    }
    
    // 2. iOS 권한 요청
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      notificationPermissionGranted = granted ?? false;
      debugPrint('🍎 iOS 알림 권한: $notificationPermissionGranted');
      
      // iOS 권한 상태도 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_permission_granted', notificationPermissionGranted);
    }
    
    // 3. Android 12+ SCHEDULE_EXACT_ALARM 권한 확인 및 요청
    if (defaultTargetPlatform == TargetPlatform.android) {
      final canSchedule = await canScheduleExactAlarms();
      
      if (!canSchedule) {
        debugPrint('⚠️ SCHEDULE_EXACT_ALARM 권한이 없음, 요청 시도');
        exactAlarmPermissionGranted = await requestExactAlarmPermission();
      } else {
        exactAlarmPermissionGranted = true;
        debugPrint('✅ SCHEDULE_EXACT_ALARM 권한 이미 있음');
      }
      
      // 정확한 알람 권한 상태 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('exact_alarm_permission_granted', exactAlarmPermissionGranted);
    }
    
    final allPermissionsGranted = notificationPermissionGranted && exactAlarmPermissionGranted;
    debugPrint('🔔 전체 권한 상태 - 알림: $notificationPermissionGranted, 정확한 알람: $exactAlarmPermissionGranted, 전체: $allPermissionsGranted');
    
    // 전체 권한 상태 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('all_notification_permissions_granted', allPermissionsGranted);
    
    return allPermissionsGranted;
  }

  /// 앱이 포그라운드로 돌아왔을 때 권한 상태 재확인
  static Future<void> recheckPermissionsOnResume() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    
    try {
      debugPrint('🔄 앱 복귀 후 권한 상태 재확인...');
      
      // 기본 알림 권한 확인
      bool hasNotificationPermission = false;
      try {
        hasNotificationPermission = await areNotificationsEnabled();
      } catch (e) {
        debugPrint('⚠️ 기본 알림 권한 확인 실패: $e');
        hasNotificationPermission = false;
      }
      
      // 정확한 알람 권한 확인
      bool hasExactAlarmPermission = false;
      try {
        hasExactAlarmPermission = await canScheduleExactAlarms();
      } catch (e) {
        debugPrint('⚠️ 정확한 알람 권한 확인 실패: $e');
        hasExactAlarmPermission = false;
      }
      
      // SharedPreferences에 최신 상태 저장
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notification_permission_granted', hasNotificationPermission);
        await prefs.setBool('exact_alarm_permission_granted', hasExactAlarmPermission);
        
        final allPermissionsGranted = hasNotificationPermission && hasExactAlarmPermission;
        await prefs.setBool('all_notification_permissions_granted', allPermissionsGranted);
        
        debugPrint('🔄 권한 재확인 완료 - 알림: $hasNotificationPermission, 정확한 알람: $hasExactAlarmPermission');
        
        // 권한이 새로 허용되었고 운동 리마인더가 활성화되어 있다면 재설정
        if (allPermissionsGranted) {
          final workoutReminderActive = prefs.getBool('workout_reminder_active') ?? false;
          if (workoutReminderActive) {
            final hour = prefs.getInt('workout_reminder_hour') ?? 20;
            final minute = prefs.getInt('workout_reminder_minute') ?? 0;
            
            debugPrint('🔄 권한 허용 확인됨, 운동 리마인더 재설정...');
            try {
              await scheduleWorkoutReminder(
                hour: hour,
                minute: minute,
                enabled: true,
              );
            } catch (e) {
              debugPrint('⚠️ 운동 리마인더 재설정 실패: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ SharedPreferences 저장 실패: $e');
      }
    } catch (e) {
      debugPrint('❌ 권한 재확인 전체 오류: $e');
      // 권한 재확인이 실패해도 앱은 계속 실행되어야 함
    }
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
      
      await _safeScheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_workout',
            'Daily Workout Reminder',
            channelDescription: '매일 운동 알림',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            sound: RawResourceAndroidNotificationSound('notification_sound'),
            playSound: true,
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
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
    
    await _safeScheduleNotification(
      id: 9999, // 재스케줄링용 특별 ID
      title: 'Reschedule',
      body: 'Rescheduling workout reminders',
      scheduledDate: rescheduleTime,
      notificationDetails: NotificationDetails(
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
    await _safeScheduleNotification(
      id: 1, // 알림 ID
      title: '💪 운동 시간이에요!',
      body: '오늘도 차드가 되기 위한 푸쉬업 시간입니다! 🔥',
      scheduledDate: DateTime.now(),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_workout',
          'Daily Workout Reminder',
          channelDescription: '매일 운동 알림',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
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
    await _safeScheduleNotification(
      id: 3, // 업적 알림 ID
      title: '🏆 업적 달성!',
      body: '$title: $description',
      scheduledDate: DateTime.now(),
      notificationDetails: NotificationDetails(
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

  /// Chad 진화 알림 (특별한 스타일)
  static Future<void> showChadEvolutionNotification({
    required String chadName,
    required String evolutionMessage,
    required int stageNumber,
  }) async {
    await initialize();
    
    String title = '🎉 Chad 진화 완료!';
    String body = '$chadName으로 진화했습니다!\n$evolutionMessage';
    
    // 단계별 특별한 메시지
    switch (stageNumber) {
      case 1:
        title = '🌟 첫 번째 진화!';
        break;
      case 2:
        title = '☕ 에너지 충전 완료!';
        break;
      case 3:
        title = '💪 자신감 폭발!';
        break;
      case 4:
        title = '😎 쿨한 매력 획득!';
        break;
      case 5:
        title = '⚡ 강력한 파워 각성!';
        break;
      case 6:
        title = '👑 전설의 Chad 탄생!';
        break;
    }
    
    await _safeScheduleNotification(
      id: 4, // Chad 진화 알림 ID
      title: title,
      body: body,
      scheduledDate: DateTime.now(),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'chad_evolution',
          'Chad Evolution',
          channelDescription: 'Chad 진화 알림',
          importance: Importance.max,
          priority: Priority.max,
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

  /// Chad 진화 예고 알림 (다음 진화까지 1주 남았을 때)
  static Future<void> showChadEvolutionPreview({
    required String nextChadName,
    required int weeksLeft,
  }) async {
    await initialize();
    
    String title = '🔮 진화 예고!';
    String body = '$weeksLeft주 후 $nextChadName으로 진화할 수 있습니다!\n계속 운동해서 진화를 완성하세요! ';
    
    await _safeScheduleNotification(
      id: 5, // Chad 진화 예고 알림 ID
      title: title,
      body: body,
      scheduledDate: DateTime.now(),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'chad_evolution_preview',
          'Chad Evolution Preview',
          channelDescription: 'Chad 진화 예고 알림',
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

  /// Chad 진화 격려 알림 (진화 조건에 가까워졌을 때)
  static Future<void> showChadEvolutionEncouragement({
    required String currentChadName,
    required String nextChadName,
    required int daysLeft,
  }) async {
    await initialize();
    
    String title = '🚀 진화가 가까워졌어요!';
    String body = '$currentChadName에서 $nextChadName까지 $daysLeft일 남았습니다!\n조금만 더 힘내세요! ';
    
    await _safeScheduleNotification(
      id: 6, // Chad 진화 격려 알림 ID
      title: title,
      body: body,
      scheduledDate: DateTime.now(),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'chad_evolution_encouragement',
          'Chad Evolution Encouragement',
          channelDescription: 'Chad 진화 격려 알림',
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

  /// Chad 최종 진화 완료 알림 (더블 Chad 달성)
  static Future<void> showChadFinalEvolutionNotification() async {
    await initialize();
    
    String title = '🏆 전설 달성!';
    String body = '축하합니다! 더블 Chad로 최종 진화를 완료했습니다!\n당신은 진정한 전설의 Chad입니다! 👑✨';
    
    await _safeScheduleNotification(
      id: 7, // Chad 최종 진화 알림 ID
      title: title,
      body: body,
      scheduledDate: DateTime.now(),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'chad_final_evolution',
          'Chad Final Evolution',
          channelDescription: 'Chad 최종 진화 알림',
          importance: Importance.max,
          priority: Priority.max,
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
    
    await _safeScheduleNotification(
      id: 2, // 알림 ID
      title: title,
      body: body,
      scheduledDate: DateTime.now(),
      notificationDetails: NotificationDetails(
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
    
    await _safeScheduleNotification(
      id: 3, // 알림 ID
      title: title,
      body: body,
      scheduledDate: DateTime.now(),
      notificationDetails: NotificationDetails(
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

  /// 알림 권한이 있는지 확인 (기존 호환성 메소드)
  static Future<bool> hasPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('all_notification_permissions_granted') ?? false;
  }

  /// 스마트 운동 리마인더 스케줄링 (권한 상태에 따라 자동 선택)
  static Future<bool> scheduleWorkoutReminder({
    required int hour,
    required int minute,
    required bool enabled,
  }) async {
    if (!enabled) {
      await cancelWorkoutReminder();
      return true;
    }

    try {
      // 권한 상태 확인
      final hasNotificationPermission = await _hasNotificationPermission();
      final hasExactAlarmPermission = await canScheduleExactAlarms();
      
      // 운동일 전용 알림 설정 확인
      final prefs = await SharedPreferences.getInstance();
      final workoutDaysOnly = prefs.getBool('workout_days_only_notifications') ?? false;
      
      debugPrint('📊 운동 리마인더 스케줄링 권한 상태:');
      debugPrint('  - 기본 알림: $hasNotificationPermission');
      debugPrint('  - 정확한 알람: $hasExactAlarmPermission');
      debugPrint('  - 운동일 전용 모드: $workoutDaysOnly');
      
      if (!hasNotificationPermission) {
        debugPrint('❌ 기본 알림 권한이 없어 운동 리마인더를 설정할 수 없습니다');
        return false;
      }

      // 다음 알림 시간들 계산 (운동일 전용 모드에 따라)
      final now = DateTime.now();
      List<DateTime> scheduledDates = [];
      
      if (workoutDaysOnly) {
        // 운동일(월,수,금)에만 알림 설정
        for (int i = 0; i < 14; i++) { // 2주간 설정
          final targetDate = now.add(Duration(days: i));
          // 월요일(1), 수요일(3), 금요일(5)인지 확인
          if (targetDate.weekday == DateTime.monday ||
              targetDate.weekday == DateTime.wednesday ||
              targetDate.weekday == DateTime.friday) {
            var scheduledTime = DateTime(
              targetDate.year,
              targetDate.month,
              targetDate.day,
              hour,
              minute,
            );
            
            // 오늘 시간이 이미 지났으면 건너뛰기
            if (scheduledTime.isAfter(now)) {
              scheduledDates.add(scheduledTime);
            }
          }
        }
        debugPrint('💪 운동일 전용 모드: ${scheduledDates.length}개 알림 예약됨');
      } else {
        // 매일 알림 (기존 방식)
        for (int i = 0; i < 7; i++) {
          final targetDate = now.add(Duration(days: i));
          var scheduledTime = DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
            hour,
            minute,
          );
          
          // 오늘 시간이 이미 지났으면 내일부터 시작
          if (i == 0 && scheduledTime.isBefore(now)) {
            continue;
          }
          
          scheduledDates.add(scheduledTime);
        }
        debugPrint('📅 매일 알림 모드: ${scheduledDates.length}개 알림 예약됨');
      }

      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_reminder',
          'Workout Reminder',
          channelDescription: workoutDaysOnly 
            ? '운동일(월,수,금) 운동 리마인더 알림'
            : '매일 운동 리마인더 알림',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'notification_sound.aiff',
        ),
      );

      // 기존 알림 모두 취소
      await cancelWorkoutReminder();

      // 운동일 기반 알림 메시지
      String title = workoutDaysOnly 
        ? '💪 운동일이에요! 오늘도 도전!'
        : '💪 운동할 시간이에요!';
      String body = workoutDaysOnly
        ? '월수금 챔피언! 오늘의 푸시업 도전을 시작해보세요! 🔥'
        : '오늘의 푸시업 도전을 시작해보세요. 당신의 Chad가 기다리고 있어요!';

      // 각 예정된 날짜에 알림 설정
      bool allSchedulingSuccess = true;
      String schedulingMethod = '';
      
      for (int i = 0; i < scheduledDates.length; i++) {
        final scheduledDate = scheduledDates[i];
        final notificationId = 1000 + i; // 고유 ID
        
        bool schedulingSuccess = false;
        
        if (hasExactAlarmPermission) {
          // 정확한 알람 권한이 있으면 정확한 스케줄링 시도
          schedulingSuccess = await _safeScheduleNotification(
            id: notificationId,
            title: title,
            body: body,
            scheduledDate: scheduledDate,
            notificationDetails: notificationDetails,
          );
          schedulingMethod = '정확한 알람';
        } else {
          // 정확한 알람 권한이 없으면 부정확한 스케줄링 사용
          schedulingSuccess = await scheduleInexactNotification(
            id: notificationId,
            title: title,
            body: body,
            scheduledDate: scheduledDate,
            notificationDetails: notificationDetails,
          );
          schedulingMethod = '부정확한 알람';
        }
        
        if (!schedulingSuccess) {
          allSchedulingSuccess = false;
          debugPrint('❌ 알림 설정 실패: ${scheduledDate.toString()}');
        }
      }

      if (allSchedulingSuccess && scheduledDates.isNotEmpty) {
        debugPrint('✅ 운동 리마인더 설정 완료 ($schedulingMethod)');
        debugPrint('   설정된 알림 수: ${scheduledDates.length}개');
        debugPrint('   운동일 전용 모드: $workoutDaysOnly');
        
        // 설정 성공을 SharedPreferences에 저장
        await prefs.setBool('workout_reminder_active', true);
        await prefs.setInt('workout_reminder_hour', hour);
        await prefs.setInt('workout_reminder_minute', minute);
        await prefs.setString('workout_reminder_method', schedulingMethod);
        await prefs.setBool('workout_days_only_active', workoutDaysOnly);
        if (scheduledDates.isNotEmpty) {
          await prefs.setString('workout_reminder_next', scheduledDates.first.toIso8601String());
        }
        
        return true;
      } else {
        debugPrint('❌ 운동 리마인더 설정 실패');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 운동 리마인더 스케줄링 오류: $e');
      return false;
    }
  }

  /// 운동 리마인더 상태 확인
  static Future<Map<String, dynamic>> getWorkoutReminderStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final isActive = prefs.getBool('workout_reminder_active') ?? false;
      final hour = prefs.getInt('workout_reminder_hour') ?? 20;
      final minute = prefs.getInt('workout_reminder_minute') ?? 0;
      final method = prefs.getString('workout_reminder_method') ?? '미설정';
      final nextString = prefs.getString('workout_reminder_next');
      
      DateTime? nextNotification;
      if (nextString != null) {
        try {
          nextNotification = DateTime.parse(nextString);
        } catch (e) {
          debugPrint('다음 알림 시간 파싱 오류: $e');
        }
      }
      
      return {
        'isActive': isActive,
        'hour': hour,
        'minute': minute,
        'method': method,
        'nextNotification': nextNotification,
        'timeString': '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      };
    } catch (e) {
      debugPrint('운동 리마인더 상태 확인 오류: $e');
      return {
        'isActive': false,
        'hour': 20,
        'minute': 0,
        'method': '미설정',
        'nextNotification': null,
        'timeString': '20:00',
      };
    }
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
      
      // 업적 달성 알림 채널
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'achievement',
          'Achievement Notifications',
          description: '업적 달성 알림',
          importance: Importance.high,
        ),
      );
      
      // Chad 진화 알림 채널
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'chad_evolution',
          'Chad Evolution',
          description: 'Chad 진화 알림',
          importance: Importance.max,
        ),
      );
      
      // Chad 진화 예고 알림 채널
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'chad_evolution_preview',
          'Chad Evolution Preview',
          description: 'Chad 진화 예고 알림',
          importance: Importance.high,
        ),
      );
      
      // Chad 진화 격려 알림 채널
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'chad_evolution_encouragement',
          'Chad Evolution Encouragement',
          description: 'Chad 진화 격려 알림',
          importance: Importance.high,
        ),
      );
      
      // Chad 최종 진화 알림 채널
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'chad_final_evolution',
          'Chad Final Evolution',
          description: 'Chad 최종 진화 알림',
          importance: Importance.max,
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

  /// 챌린지 완료 알림
  Future<void> showChallengeCompletedNotification(String title, String description) async {
    await initialize();
    
    await _safeScheduleNotification(
      id: 2000, // 챌린지 완료 알림 ID
      title: '🎉 챌린지 완료!',
      body: '축하합니다! $title 챌린지를 완료했습니다!',
      scheduledDate: DateTime.now(),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'challenge_completion',
          'Challenge Completion',
          channelDescription: '챌린지 완료 알림',
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

  /// 챌린지 실패 알림
  Future<void> showChallengeFailedNotification(String title, String description) async {
    await initialize();
    
    await _safeScheduleNotification(
      id: 2001, // 챌린지 실패 알림 ID
      title: '😢 챌린지 실패',
      body: '$title 챌린지가 실패했습니다. 다시 도전해보세요!',
      scheduledDate: DateTime.now(),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'challenge_failed',
          'Challenge Failed',
          channelDescription: '챌린지 실패 알림',
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

  /// 일일 챌린지 리마인더
  Future<void> scheduleDailyReminder(String title, String body) async {
    await initialize();
    
    // 매일 저녁 8시에 알림
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      20, // 8 PM
      0,
    );
    
    // 오늘 시간이 이미 지났다면 내일로 설정
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    await _safeScheduleNotification(
      id: 2002, // 일일 챌린지 리마인더 ID
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'challenge_reminder',
          'Challenge Reminder',
          channelDescription: '챌린지 리마인더',
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

  /// 권한 요청 다이얼로그 표시 (사용자 친화적)
  static Future<bool> showPermissionRequestDialog(BuildContext context) async {
    if (!context.mounted) return false;
    
    // 현재 권한 상태 확인
    final hasNotificationPermission = await _hasNotificationPermission();
    final hasExactAlarmPermission = await canScheduleExactAlarms();
    
    if (hasNotificationPermission && hasExactAlarmPermission) {
      return true; // 모든 권한이 이미 있음
    }
    
    // 권한 요청 다이얼로그 표시
    final shouldRequest = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.orange),
              SizedBox(width: 8),
              Text('🔔 알림 권한이 필요해요'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mission 100에서 정시에 운동 알림을 받으려면 다음 권한들이 필요합니다:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                
                if (!hasNotificationPermission) ...[
                  const Row(
                    children: [
                      Icon(Icons.notification_important, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '기본 알림 권한',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 28),
                    child: Text('알림을 받기 위한 기본 권한입니다.'),
                  ),
                  const SizedBox(height: 12),
                ],
                
                if (!hasExactAlarmPermission) ...[
                  const Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '정확한 알람 권한 (Android 12+)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 28),
                    child: Text('정확한 시간에 운동 알림을 받기 위한 권한입니다.'),
                  ),
                  const SizedBox(height: 12),
                ],
                
                const Divider(),
                const Text(
                  '💡 권한을 허용하지 않으면 알림이 정확한 시간에 오지 않을 수 있어요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '나중에',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('권한 허용'),
            ),
          ],
        );
      },
    );
    
    if (shouldRequest != true) return false;
    
    // 실제 권한 요청 수행
    return await requestPermissions();
  }

  /// 기본 알림 권한이 있는지 확인
  static Future<bool> _hasNotificationPermission() async {
    await initialize();
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        // Android에서는 권한 상태를 직접 확인하기 어려우므로
        // SharedPreferences에 저장된 상태를 확인
        final prefs = await SharedPreferences.getInstance();
        return prefs.getBool('notification_permission_granted') ?? false;
      }
    }
    
    return true; // iOS는 기본적으로 true로 가정
  }

  /// 부정확한 알림 스케줄링 (SCHEDULE_EXACT_ALARM 권한이 없을 때 사용)
  static Future<bool> scheduleInexactNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationDetails notificationDetails,
  }) async {
    try {
      debugPrint('📅 부정확한 알림 스케줄링 시도: $title');
      
      // 예약 시간까지의 지연 시간 계산
      final now = DateTime.now();
      final delay = scheduledDate.difference(now);
      
      if (delay.isNegative) {
        // 과거 시간이면 즉시 표시
        await _notifications.show(id, title, body, notificationDetails);
        debugPrint('⚡ 과거 시간이므로 즉시 알림 표시');
        return true;
      }
      
      // 30분 이내면 정확한 스케줄링 시도 (시스템이 허용할 가능성 높음)
      if (delay.inMinutes <= 30) {
        try {
          await _notifications.zonedSchedule(
            id,
            title,
            body,
            tz.TZDateTime.from(scheduledDate, tz.local),
            notificationDetails,
            uiLocalNotificationDateInterpretation: 
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          debugPrint('✅ 30분 이내 정확한 스케줄링 성공');
          return true;
        } catch (e) {
          debugPrint('⚠️ 30분 이내 정확한 스케줄링 실패, 부정확한 방법 사용: $e');
        }
      }
      
      // 긴 지연시간의 경우 Flutter의 periodic 알림 사용
      // 목표 시간 30분 전부터 5분마다 체크하여 알림 표시
      await _schedulePeriodicCheck(id, title, body, scheduledDate, notificationDetails);
      
      return true;
    } catch (e) {
      debugPrint('❌ 부정확한 알림 스케줄링 실패: $e');
      
      // 최후 수단: 즉시 알림 표시
      try {
        await _notifications.show(id, title, body, notificationDetails);
        debugPrint('🔄 최후 수단으로 즉시 알림 표시');
        return false;
      } catch (fallbackError) {
        debugPrint('❌ 최후 수단 즉시 알림도 실패: $fallbackError');
        return false;
      }
    }
  }

  /// 주기적 체크를 통한 알림 스케줄링 (부정확한 방법)
  static Future<void> _schedulePeriodicCheck(
    int id,
    String title,
    String body,
    DateTime targetTime,
    NotificationDetails notificationDetails,
  ) async {
    // 목표 시간 30분 전부터 시작
    final checkStartTime = targetTime.subtract(const Duration(minutes: 30));
    final now = DateTime.now();
    
    // 체크 시작 시간이 아직 오지 않았다면 그 시간에 첫 체크 스케줄링
    if (checkStartTime.isAfter(now)) {
      final checkId = id + 10000; // 체크용 고유 ID
      
      try {
        await _notifications.zonedSchedule(
          checkId,
          'Check Notification', // 사용자에게 보이지 않는 내부 알림
          'Internal check for scheduled notification',
          tz.TZDateTime.from(checkStartTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'system_check',
              'System Check',
              channelDescription: '시스템 체크용 알림',
              importance: Importance.min,
              priority: Priority.min,
              playSound: false,
              enableVibration: false,
              showWhen: false,
              ongoing: false,
              autoCancel: true,
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
        
        debugPrint('⏰ 주기적 체크 알림 스케줄링 완료: ${checkStartTime.toString()}');
      } catch (e) {
        debugPrint('⚠️ 주기적 체크 스케줄링 실패, SharedPreferences 체크 방식 사용: $e');
        await _scheduleSharedPreferencesCheck(id, title, body, targetTime, notificationDetails);
      }
    } else {
      // 이미 체크 시간이 지났다면 즉시 확인
      await _checkAndShowNotification(id, title, body, targetTime, notificationDetails);
    }
  }

  /// SharedPreferences를 이용한 알림 체크 (최후 수단)
  static Future<void> _scheduleSharedPreferencesCheck(
    int id,
    String title,
    String body,
    DateTime targetTime,
    NotificationDetails notificationDetails,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationKey = 'pending_notification_$id';
    
    // 알림 정보를 SharedPreferences에 저장
    final notificationData = {
      'id': id,
      'title': title,
      'body': body,
      'targetTime': targetTime.millisecondsSinceEpoch,
      'created': DateTime.now().millisecondsSinceEpoch,
    };
    
    await prefs.setString(notificationKey, jsonEncode(notificationData));
    debugPrint('💾 SharedPreferences에 알림 정보 저장: $notificationKey');
    
    // 앱이 활성화될 때 체크하도록 플래그 설정
    final pendingNotifications = prefs.getStringList('pending_notifications') ?? [];
    if (!pendingNotifications.contains(notificationKey)) {
      pendingNotifications.add(notificationKey);
      await prefs.setStringList('pending_notifications', pendingNotifications);
    }
  }

  /// 저장된 알림 확인 및 표시 (앱 시작/활성화 시 호출)
  static Future<void> checkPendingNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingNotifications = prefs.getStringList('pending_notifications') ?? [];
      
      if (pendingNotifications.isEmpty) return;
      
      final now = DateTime.now();
      final toRemove = <String>[];
      
      for (final notificationKey in pendingNotifications) {
        final dataString = prefs.getString(notificationKey);
        if (dataString == null) {
          toRemove.add(notificationKey);
          continue;
        }
        
        try {
          final data = jsonDecode(dataString) as Map<String, dynamic>;
          final targetTime = DateTime.fromMillisecondsSinceEpoch(data['targetTime'] as int);
          final created = DateTime.fromMillisecondsSinceEpoch(data['created'] as int);
          
          // 7일 이상 된 알림은 삭제
          if (now.difference(created).inDays > 7) {
            toRemove.add(notificationKey);
            continue;
          }
          
          // 목표 시간이 지났거나 30분 이내면 알림 표시
          if (now.isAfter(targetTime) || now.difference(targetTime).abs().inMinutes <= 30) {
            await _notifications.show(
              data['id'] as int,
              data['title'] as String,
              data['body'] as String,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  'delayed_workout',
                  'Delayed Workout Reminder',
                  channelDescription: '지연된 운동 알림',
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
            
            toRemove.add(notificationKey);
            debugPrint('⏰ 지연된 알림 표시: ${data['title']}');
          }
        } catch (e) {
          debugPrint('⚠️ 알림 데이터 파싱 오류: $e');
          toRemove.add(notificationKey);
        }
      }
      
      // 처리된 알림들 정리
      if (toRemove.isNotEmpty) {
        for (final key in toRemove) {
          await prefs.remove(key);
          pendingNotifications.remove(key);
        }
        await prefs.setStringList('pending_notifications', pendingNotifications);
        debugPrint('🧹 ${toRemove.length}개의 처리된 알림 정리 완료');
      }
    } catch (e) {
      debugPrint('❌ 보류 중인 알림 확인 오류: $e');
    }
  }

  /// 특정 알림을 확인하고 표시할지 결정
  static Future<void> _checkAndShowNotification(
    int id,
    String title,
    String body,
    DateTime targetTime,
    NotificationDetails notificationDetails,
  ) async {
    final now = DateTime.now();
    
    // 목표 시간이 지났거나 5분 이내면 알림 표시
    if (now.isAfter(targetTime) || now.difference(targetTime).abs().inMinutes <= 5) {
      await _notifications.show(id, title, body, notificationDetails);
      debugPrint('⏰ 시간 확인 후 알림 표시: $title');
    } else {
      debugPrint('⏳ 아직 알림 시간이 아님: ${targetTime.toString()}');
    }
  }
}
