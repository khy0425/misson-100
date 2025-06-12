import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/achievement.dart';
import '../utils/constants.dart';
import 'notification_service.dart';

/// 업적 전용 알림 서비스
/// 업적 달성, 진행률 업데이트, 특별 이벤트 등에 대한 알림을 관리
class AchievementNotificationService {
  
  // 업적 알림 ID 범위: 5000 ~ 5999
  static const int _baseNotificationId = 5000;
  static const int _progressNotificationId = 5500;
  static const int _specialEventNotificationId = 5800;
  
  // 알림 채널 정보
  static const String _channelId = 'achievement_notifications';
  static const String _channelName = '업적 알림';
  static const String _channelDescription = '업적 달성 및 진행률 알림';
  
  // 업적 달성 알림 표시 제한 (스팸 방지)
  static DateTime? _lastNotificationTime;
  static const Duration _minimumNotificationInterval = Duration(seconds: 3);
  
  /// 알림 서비스 초기화
  static Future<void> initialize() async {
    // 기본 NotificationService 초기화
    await NotificationService.initialize();
    
    // 업적 전용 알림 채널 생성 (Android)
    await _createAchievementNotificationChannel();
    
    debugPrint('🏆 업적 알림 서비스 초기화 완료');
  }
  
  /// 업적 전용 알림 채널 생성
  static Future<void> _createAchievementNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    
    final FlutterLocalNotificationsPlugin notifications = 
        FlutterLocalNotificationsPlugin();
        
    final android = notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
        
    if (android != null) {
      await android.createNotificationChannel(channel);
      debugPrint('📱 업적 알림 채널 생성 완료');
    }
  }
  
  /// 업적 달성 알림 발송
  static Future<void> sendAchievementUnlockedNotification(
    Achievement achievement, {
    bool immediate = true,
  }) async {
    try {
      // 알림 스팸 방지
      if (!immediate && _shouldThrottleNotification()) {
        debugPrint('⏭️ 업적 알림 제한: 너무 빈번한 알림 방지');
        return;
      }
      
      final notificationId = _baseNotificationId + achievement.id.hashCode % 500;
      
      // 희귀도별 사운드 및 진동 패턴
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: _getImportanceByRarity(achievement.rarity),
        priority: _getPriorityByRarity(achievement.rarity),
        playSound: true,
        sound: _getSoundByRarity(achievement.rarity),
        enableVibration: true,
        vibrationPattern: _getVibrationPattern(achievement.rarity),
        color: _getColorByRarity(achievement.rarity),
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: _buildBigTextStyle(achievement),
        category: AndroidNotificationCategory.social,
        visibility: NotificationVisibility.public,
        autoCancel: true,
        when: DateTime.now().millisecondsSinceEpoch,
        showWhen: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'achievement_unlock.wav',
        categoryIdentifier: 'ACHIEVEMENT_CATEGORY',
      );
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      // 알림 페이로드 (업적 상세 정보)
      final payload = json.encode({
        'type': 'achievement_unlocked',
        'achievementId': achievement.id,
        'rarity': achievement.rarity.toString(),
        'xpReward': achievement.xpReward,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await NotificationService.showNotification(
        id: notificationId,
        title: _buildNotificationTitle(achievement),
        body: _buildNotificationBody(achievement),
        payload: payload,
        notificationDetails: notificationDetails,
      );
      
      _lastNotificationTime = DateTime.now();
      
      debugPrint('🏆 업적 달성 알림 발송: ${achievement.titleKey} (${achievement.rarity})');
      
    } catch (e) {
      debugPrint('❌ 업적 달성 알림 발송 실패: $e');
    }
  }
  
  /// 업적 진행률 알림 발송 (주요 마일스톤)
  static Future<void> sendProgressMilestoneNotification(
    Achievement achievement,
    double progressPercentage, {
    List<int> milestones = const [25, 50, 75, 90],
  }) async {
    try {
      // 마일스톤 체크
      final milestone = _findReachedMilestone(progressPercentage, milestones);
      if (milestone == null) return;
      
      final notificationId = _progressNotificationId + achievement.id.hashCode % 300;
      
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
        enableVibration: false,
        color: Color(AppColors.primaryColor),
        icon: '@drawable/ic_progress',
        autoCancel: true,
        ongoing: false,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
        sound: 'progress_milestone.wav',
      );
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      final payload = json.encode({
        'type': 'progress_milestone',
        'achievementId': achievement.id,
        'milestone': milestone,
        'progress': progressPercentage,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await NotificationService.showNotification(
        id: notificationId,
        title: '📈 업적 진행률 ${milestone}% 달성!',
        body: '${achievement.titleKey}에 ${milestone}% 도달했습니다. 조금만 더 화이팅!',
        payload: payload,
        notificationDetails: notificationDetails,
      );
      
      debugPrint('📈 업적 진행률 알림 발송: ${achievement.titleKey} (${milestone}%)');
      
    } catch (e) {
      debugPrint('❌ 업적 진행률 알림 발송 실패: $e');
    }
  }
  
  /// 업적 연쇄 달성 알림 (여러 업적 동시 달성)
  static Future<void> sendAchievementComboNotification(
    List<Achievement> achievements,
  ) async {
    try {
      if (achievements.isEmpty) return;
      
      final notificationId = _specialEventNotificationId + 1;
      
      // 가장 높은 희귀도를 기준으로 알림 스타일 결정
      final highestRarity = achievements
          .map((a) => a.rarity)
          .reduce((a, b) => a.index > b.index ? a : b);
      
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('achievement_combo'),
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 800]),
        color: Color(AppColors.secondaryColor),
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          '🔥 연쇄 달성! ${achievements.length}개 업적을 동시에 달성했습니다!\n\n${achievements.map((a) => '• ${a.titleKey}').join('\n')}',
          htmlFormatBigText: false,
          contentTitle: '🏆 업적 연쇄 달성!',
          htmlFormatContentTitle: false,
        ),
        category: AndroidNotificationCategory.social,
        visibility: NotificationVisibility.public,
        autoCancel: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'achievement_combo.wav',
        categoryIdentifier: 'ACHIEVEMENT_COMBO_CATEGORY',
      );
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      final payload = json.encode({
        'type': 'achievement_combo',
        'achievementIds': achievements.map((a) => a.id).toList(),
        'comboSize': achievements.length,
        'highestRarity': highestRarity.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await NotificationService.showNotification(
        id: notificationId,
        title: '🏆 업적 연쇄 달성!',
        body: '${achievements.length}개 업적을 동시에 달성했습니다! 대단해요! 🔥',
        payload: payload,
        notificationDetails: notificationDetails,
      );
      
      debugPrint('🔥 업적 연쇄 달성 알림 발송: ${achievements.length}개');
      
    } catch (e) {
      debugPrint('❌ 업적 연쇄 달성 알림 발송 실패: $e');
    }
  }
  
  /// 특별 이벤트 알림 (희귀 업적, 전체 업적 완료 등)
  static Future<void> sendSpecialEventNotification({
    required String title,
    required String body,
    String? subtitle,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final notificationId = _specialEventNotificationId + 
          (extraData?['eventId']?.hashCode ?? 0) % 100;
      
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('special_event'),
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 300, 100, 300, 100, 300, 100, 1000]),
        color: Color(0xFFFFD700), // 골드 색상
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          body,
          htmlFormatBigText: false,
          contentTitle: title,
          htmlFormatContentTitle: false,
          summaryText: subtitle,
        ),
        category: AndroidNotificationCategory.social,
        visibility: NotificationVisibility.public,
        autoCancel: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'special_event.wav',
        subtitle: subtitle,
        categoryIdentifier: 'SPECIAL_EVENT_CATEGORY',
      );
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      final payload = json.encode({
        'type': 'special_event',
        'eventTitle': title,
        'eventBody': body,
        'timestamp': DateTime.now().toIso8601String(),
        ...?extraData,
      });
      
      await NotificationService.showNotification(
        id: notificationId,
        title: title,
        body: body,
        payload: payload,
        notificationDetails: notificationDetails,
      );
      
      debugPrint('⭐ 특별 이벤트 알림 발송: $title');
      
    } catch (e) {
      debugPrint('❌ 특별 이벤트 알림 발송 실패: $e');
    }
  }
  
  // === Helper Methods ===
  
  /// 알림 제한 확인 (스팸 방지)
  static bool _shouldThrottleNotification() {
    if (_lastNotificationTime == null) return false;
    
    final timeSinceLastNotification = DateTime.now().difference(_lastNotificationTime!);
    return timeSinceLastNotification < _minimumNotificationInterval;
  }
  
  /// 희귀도별 중요도 설정
  static Importance _getImportanceByRarity(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.legendary:
        return Importance.max;
      case AchievementRarity.epic:
        return Importance.high;
      case AchievementRarity.rare:
        return Importance.defaultImportance;
      case AchievementRarity.common:
        return Importance.low;
    }
  }
  
  /// 희귀도별 우선순위 설정
  static Priority _getPriorityByRarity(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.legendary:
        return Priority.max;
      case AchievementRarity.epic:
        return Priority.high;
      case AchievementRarity.rare:
        return Priority.defaultPriority;
      case AchievementRarity.common:
        return Priority.low;
    }
  }
  
  /// 희귀도별 사운드 설정
  static RawResourceAndroidNotificationSound? _getSoundByRarity(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.legendary:
        return const RawResourceAndroidNotificationSound('achievement_legendary');
      case AchievementRarity.epic:
        return const RawResourceAndroidNotificationSound('achievement_epic');
      case AchievementRarity.rare:
        return const RawResourceAndroidNotificationSound('achievement_rare');
      case AchievementRarity.common:
        return const RawResourceAndroidNotificationSound('achievement_common');
    }
  }
  
  /// 희귀도별 진동 패턴 설정
  static Int64List _getVibrationPattern(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.legendary:
        return Int64List.fromList([0, 500, 200, 500, 200, 500, 200, 1000]);
      case AchievementRarity.epic:
        return Int64List.fromList([0, 400, 150, 400, 150, 600]);
      case AchievementRarity.rare:
        return Int64List.fromList([0, 300, 100, 300, 100, 400]);
      case AchievementRarity.common:
        return Int64List.fromList([0, 200, 100, 200]);
    }
  }
  
  /// 희귀도별 색상 설정
  static Color _getColorByRarity(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.legendary:
        return const Color(0xFFFFD700); // 골드
      case AchievementRarity.epic:
        return const Color(0xFF9C27B0); // 보라
      case AchievementRarity.rare:
        return const Color(0xFF2196F3); // 파랑
      case AchievementRarity.common:
        return const Color(0xFF9E9E9E); // 회색
    }
  }
  
  /// 알림 제목 생성
  static String _buildNotificationTitle(Achievement achievement) {
    switch (achievement.rarity) {
      case AchievementRarity.legendary:
        return '🏆 전설적 업적 달성!';
      case AchievementRarity.epic:
        return '💎 에픽 업적 달성!';
      case AchievementRarity.rare:
        return '⭐ 레어 업적 달성!';
      case AchievementRarity.common:
        return '🎯 업적 달성!';
    }
  }
  
  /// 알림 본문 생성
  static String _buildNotificationBody(Achievement achievement) {
    final xpText = achievement.xpReward > 0 ? ' (+${achievement.xpReward} XP)' : '';
    return '${achievement.titleKey}을(를) 달성했습니다!$xpText';
  }
  
  /// 알림 스타일 설정
  static BigTextStyleInformation _buildBigTextStyle(Achievement achievement) {
    final motivationText = achievement.motivationKey.isNotEmpty 
        ? '\n\n💪 ${achievement.motivationKey}' 
        : '';
    
    return BigTextStyleInformation(
      '${achievement.descriptionKey}$motivationText',
      htmlFormatBigText: false,
      contentTitle: _buildNotificationTitle(achievement),
      htmlFormatContentTitle: false,
      summaryText: '업적 시스템',
    );
  }
  
  /// 진행률 마일스톤 확인
  static int? _findReachedMilestone(double progressPercentage, List<int> milestones) {
    for (final milestone in milestones.reversed) {
      if (progressPercentage >= milestone && progressPercentage < milestone + 5) {
        return milestone;
      }
    }
    return null;
  }
  
  /// 모든 업적 알림 취소
  static Future<void> cancelAllAchievementNotifications() async {
    try {
      final notifications = FlutterLocalNotificationsPlugin();
      
      // 업적 알림 ID 범위의 모든 알림 취소
      for (int i = _baseNotificationId; i < _baseNotificationId + 1000; i++) {
        await notifications.cancel(i);
      }
      
      debugPrint('🔕 모든 업적 알림 취소 완료');
    } catch (e) {
      debugPrint('❌ 업적 알림 취소 실패: $e');
    }
  }
  
  /// 특정 업적 알림 취소
  static Future<void> cancelAchievementNotification(String achievementId) async {
    try {
      final notificationId = _baseNotificationId + achievementId.hashCode % 500;
      final notifications = FlutterLocalNotificationsPlugin();
      await notifications.cancel(notificationId);
      
      debugPrint('🔕 업적 알림 취소: $achievementId');
    } catch (e) {
      debugPrint('❌ 업적 알림 취소 실패: $e');
    }
  }
} 