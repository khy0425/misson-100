import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class NotificationService {
  static final _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// 알림 시스템 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // 타임존 초기화
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    debugPrint('✅ NotificationService 초기화 완료');
  }

  /// 알림 권한 요청
  static Future<bool> requestPermissions() async {
    final plugin = _notificationsPlugin;

    // Android에서는 기본적으로 허용된 것으로 처리 (targetSdk < 33)
    if (defaultTargetPlatform == TargetPlatform.android) {
      return true;
    }

    // iOS 권한 요청
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin = plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// 알림 클릭 시 처리
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('알림 클릭됨: ${response.payload}');
    // TODO: 알림 타입에 따른 네비게이션 처리
  }

  /// 일일 운동 리마인더 예약
  static Future<void> scheduleWorkoutReminder({
    required int hour,
    required int minute,
    bool enabled = true,
  }) async {
    if (!enabled) {
      await cancelWorkoutReminder();
      return;
    }

    const notificationId = 1;
    const title = '💪 차드 타임이다!';
    const body = '오늘의 푸시업으로 차드의 길을 걸어보자! 강함은 선택이야! 🔥';

    // 매일 같은 시간에 반복
    await _notificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_reminder',
          '운동 리마인더',
          channelDescription: '일일 운동 리마인더 알림',
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'workout_reminder',
    );

    debugPrint('💪 운동 리마인더 예약됨: $hour:${minute.toString().padLeft(2, '0')}');
  }

  /// 운동 리마인더 취소
  static Future<void> cancelWorkoutReminder() async {
    await _notificationsPlugin.cancel(1);
    debugPrint('🚫 운동 리마인더 취소됨');
  }

  /// 동기부여 알림 보내기
  static Future<void> sendMotivationalNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('push_notifications') ?? true;
    if (!enabled) return;

    const notificationId = 2;
    final message = _getRandomMotivationalMessage();

    await _notificationsPlugin.show(
      notificationId,
      '🔥 차드의 한마디',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivational',
          '동기부여 메시지',
          channelDescription: '랜덤 동기부여 메시지',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'motivational',
    );

    debugPrint('💬 동기부여 알림 전송: $message');
  }

  /// 업적 달성 알림
  static Future<void> sendAchievementNotification({
    required String title,
    required String description,
    required int xpReward,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('achievement_notifications') ?? true;
    if (!enabled) return;

    const notificationId = 3;

    await _notificationsPlugin.show(
      notificationId,
      '🏆 업적 달성!',
      '$title - $description (+$xpReward XP)',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          '업적 알림',
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
      payload: 'achievement:$title',
    );

    debugPrint('🏆 업적 알림 전송: $title');
  }

  /// 연속 운동일 리마인더
  static Future<void> sendStreakReminder(int currentStreak) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('push_notifications') ?? true;
    if (!enabled) return;

    const notificationId = 4;
    final title = '🔥 연속 $currentStreak일!';
    final body = currentStreak >= 7
        ? '와! $currentStreak일 연속 운동! 진정한 차드의 모습이야! 오늘도 계속하자! 💪'
        : '$currentStreak일 연속 운동 중! 연속 기록을 이어가자! 차드는 포기하지 않아! 🚀';

    await _notificationsPlugin.show(
      notificationId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminder',
          '연속 운동일 알림',
          channelDescription: '연속 운동일 리마인더',
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
      payload: 'streak:$currentStreak',
    );

    debugPrint('🔥 연속 운동일 알림 전송: $currentStreak일');
  }

  /// 특정 시간의 다음 인스턴스 계산
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 이미 지난 시간이면 다음 날로
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// 랜덤 동기부여 메시지 가져오기
  static String _getRandomMotivationalMessage() {
    final messages = [
      '강함은 선택이야. 오늘도 차드의 길을 선택하자! 💪',
      '포기는 약자의 변명일 뿐. 너는 차드야! 🔥',
      '오늘 흘린 땀은 내일의 영광이다. 계속 가자! ⚡',
      '한계는 너의 생각 속에만 존재해. 뛰어넘어! 🚀',
      '차드는 매일매일 성장한다. 오늘도 한 단계 앞으로! 📈',
      '운동은 몸을 단련하고, 정신을 강하게 만든다! 🧠',
      '약속한다. 고통은 일시적이야. 영광은 영원해! 👑',
      '네 몸은 네가 명령하는 대로 따를 뿐이야! 💯',
      '오늘의 선택이 내일의 너를 만든다! 🌟',
      '차드의 하루는 운동으로 시작한다! 가자! 🏃‍♂️',
      '강해지기 위해선 도전이 필요해. 오늘도 도전하자! ⚔️',
      '성공은 매일의 작은 노력이 쌓인 결과야! 🎯',
    ];

    final random = Random();
    return messages[random.nextInt(messages.length)];
  }

  /// 예약된 알림 목록 확인
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// 모든 알림 취소
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('🚫 모든 알림 취소됨');
  }

  /// 알림 채널 생성 (Android)
  static Future<void> createNotificationChannels() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // 운동 리마인더 채널
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'workout_reminder',
          '운동 리마인더',
          description: '일일 운동 리마인더 알림',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        ),
      );

      // 동기부여 메시지 채널
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'motivational',
          '동기부여 메시지',
          description: '랜덤 동기부여 메시지',
          importance: Importance.defaultImportance,
          enableVibration: false,
          playSound: true,
        ),
      );

      // 업적 알림 채널
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'achievements',
          '업적 알림',
          description: '업적 달성 알림',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        ),
      );

      // 연속 운동일 채널
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'streak_reminder',
          '연속 운동일 알림',
          description: '연속 운동일 리마인더',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        ),
      );

      debugPrint('📱 Android 알림 채널 생성 완료');
    }
  }
}
