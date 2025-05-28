import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'data_backup_service.dart';

/// 자동 백업 스케줄링 서비스
/// 정기적인 백업 실행 및 관리를 담당
class BackupScheduler {
  static final BackupScheduler _instance = BackupScheduler._internal();
  factory BackupScheduler() => _instance;
  BackupScheduler._internal();

  static const String _nextBackupTimeKey = 'next_backup_time';
  static const String _backupRetentionCountKey = 'backup_retention_count';
  static const String _lastAutoBackupKey = 'last_auto_backup';
  static const String _backupFailureCountKey = 'backup_failure_count';
  
  Timer? _schedulerTimer;
  final DataBackupService _backupService = DataBackupService();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  /// 스케줄러 초기화
  Future<void> initialize() async {
    debugPrint('🔄 백업 스케줄러 초기화 중...');
    
    // 알림 초기화
    await _initializeNotifications();
    
    // 기존 스케줄 확인 및 재시작
    await _restoreSchedule();
    
    debugPrint('✅ 백업 스케줄러 초기화 완료');
  }

  /// 백업 스케줄 시작
  Future<void> startSchedule() async {
    final settings = await _backupService.getBackupSettings();
    
    if (!settings.autoBackupEnabled) {
      debugPrint('⏸️ 자동 백업이 비활성화되어 있습니다');
      return;
    }
    
    await _scheduleNextBackup(settings.frequency);
    debugPrint('🔄 백업 스케줄 시작: ${settings.frequency.name}');
  }

  /// 백업 스케줄 중지
  Future<void> stopSchedule() async {
    _schedulerTimer?.cancel();
    _schedulerTimer = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nextBackupTimeKey);
    
    debugPrint('⏹️ 백업 스케줄 중지');
  }

  /// 다음 백업 예약
  Future<void> _scheduleNextBackup(BackupFrequency frequency) async {
    _schedulerTimer?.cancel();
    
    final nextBackupTime = _calculateNextBackupTime(frequency);
    final delay = nextBackupTime.difference(DateTime.now());
    
    if (delay.isNegative) {
      // 즉시 백업 실행
      await _performScheduledBackup();
      return;
    }
    
    // 다음 백업 시간 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nextBackupTimeKey, nextBackupTime.toIso8601String());
    
    // 타이머 설정
    _schedulerTimer = Timer(delay, () async {
      await _performScheduledBackup();
    });
    
    debugPrint('⏰ 다음 백업 예약: ${nextBackupTime.toString()}');
  }

  /// 예약된 백업 실행
  Future<void> _performScheduledBackup() async {
    try {
      debugPrint('🔄 예약된 백업 실행 중...');
      
      final settings = await _backupService.getBackupSettings();
      
      // 백업 생성
      final result = await _backupService.createBackup(
        encrypt: settings.encryptionEnabled,
      );
      
      if (result.success) {
        // 성공 처리
        await _handleBackupSuccess(result);
        
        // 백업 보존 정책 적용
        await _applyRetentionPolicy();
        
        // 다음 백업 예약
        await _scheduleNextBackup(settings.frequency);
        
        debugPrint('✅ 예약된 백업 완료');
      } else {
        // 실패 처리
        await _handleBackupFailure(result.error ?? '알 수 없는 오류');
      }
      
    } catch (e) {
      await _handleBackupFailure(e.toString());
    }
  }

  /// 백업 성공 처리
  Future<void> _handleBackupSuccess(BackupResult result) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 마지막 성공 시간 저장
    await prefs.setString(_lastAutoBackupKey, DateTime.now().toIso8601String());
    
    // 실패 카운트 리셋
    await prefs.setInt(_backupFailureCountKey, 0);
    
    // 성공 알림
    await _showBackupNotification(
      title: 'Mission 100 백업 완료',
      body: '데이터가 성공적으로 백업되었습니다 (${_formatFileSize(result.size ?? 0)})',
      isSuccess: true,
    );
  }

  /// 백업 실패 처리
  Future<void> _handleBackupFailure(String error) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 실패 카운트 증가
    final failureCount = (prefs.getInt(_backupFailureCountKey) ?? 0) + 1;
    await prefs.setInt(_backupFailureCountKey, failureCount);
    
    debugPrint('❌ 백업 실패 (${failureCount}회): $error');
    
    // 실패 알림
    await _showBackupNotification(
      title: 'Mission 100 백업 실패',
      body: '백업 중 오류가 발생했습니다. 설정을 확인해주세요.',
      isSuccess: false,
    );
    
    // 연속 실패 시 스케줄 일시 중지
    if (failureCount >= 3) {
      debugPrint('⚠️ 연속 실패로 인한 백업 스케줄 일시 중지');
      await _showBackupNotification(
        title: 'Mission 100 백업 중단',
        body: '연속 실패로 인해 자동 백업이 중단되었습니다.',
        isSuccess: false,
      );
      await stopSchedule();
    } else {
      // 재시도 스케줄링 (1시간 후)
      final settings = await _backupService.getBackupSettings();
      _schedulerTimer = Timer(const Duration(hours: 1), () async {
        await _performScheduledBackup();
      });
    }
  }

  /// 백업 보존 정책 적용
  Future<void> _applyRetentionPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    final retentionCount = prefs.getInt(_backupRetentionCountKey) ?? 5;
    
    // 실제 구현에서는 파일 시스템에서 오래된 백업 파일들을 삭제
    // 현재는 로그만 출력
    debugPrint('🗂️ 백업 보존 정책 적용: 최대 ${retentionCount}개 보관');
  }

  /// 다음 백업 시간 계산
  DateTime _calculateNextBackupTime(BackupFrequency frequency) {
    final now = DateTime.now();
    
    switch (frequency) {
      case BackupFrequency.daily:
        return DateTime(now.year, now.month, now.day + 1, 2, 0); // 매일 새벽 2시
      case BackupFrequency.weekly:
        final daysUntilSunday = 7 - now.weekday;
        return DateTime(now.year, now.month, now.day + daysUntilSunday, 2, 0); // 매주 일요일 새벽 2시
      case BackupFrequency.monthly:
        final nextMonth = now.month == 12 ? 1 : now.month + 1;
        final nextYear = now.month == 12 ? now.year + 1 : now.year;
        return DateTime(nextYear, nextMonth, 1, 2, 0); // 매월 1일 새벽 2시
      case BackupFrequency.manual:
        return now.add(const Duration(days: 365)); // 수동 모드는 1년 후로 설정
    }
  }

  /// 기존 스케줄 복원
  Future<void> _restoreSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final nextBackupTimeString = prefs.getString(_nextBackupTimeKey);
    
    if (nextBackupTimeString != null) {
      final nextBackupTime = DateTime.parse(nextBackupTimeString);
      final now = DateTime.now();
      
      if (nextBackupTime.isAfter(now)) {
        // 예약된 시간이 아직 남아있음
        final delay = nextBackupTime.difference(now);
        _schedulerTimer = Timer(delay, () async {
          await _performScheduledBackup();
        });
        debugPrint('🔄 기존 백업 스케줄 복원: ${nextBackupTime.toString()}');
      } else {
        // 예약된 시간이 지났으므로 즉시 실행
        await _performScheduledBackup();
      }
    }
  }

  /// 알림 초기화
  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(initSettings);
  }

  /// 백업 알림 표시
  Future<void> _showBackupNotification({
    required String title,
    required String body,
    required bool isSuccess,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'backup_channel',
      'Backup Notifications',
      channelDescription: 'Notifications for backup operations',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.show(
      isSuccess ? 1001 : 1002,
      title,
      body,
      details,
    );
  }

  /// 수동 백업 실행
  Future<BackupResult> performManualBackup({
    String? password,
    bool encrypt = false,
  }) async {
    debugPrint('🔄 수동 백업 실행 중...');
    
    final result = await _backupService.createBackup(
      password: password,
      encrypt: encrypt,
    );
    
    if (result.success) {
      await _showBackupNotification(
        title: 'Mission 100 수동 백업 완료',
        body: '백업이 성공적으로 생성되었습니다',
        isSuccess: true,
      );
    } else {
      await _showBackupNotification(
        title: 'Mission 100 수동 백업 실패',
        body: '백업 생성 중 오류가 발생했습니다',
        isSuccess: false,
      );
    }
    
    return result;
  }

  /// 백업 설정 업데이트
  Future<void> updateBackupSettings({
    bool? autoBackupEnabled,
    BackupFrequency? frequency,
    int? retentionCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (retentionCount != null) {
      await prefs.setInt(_backupRetentionCountKey, retentionCount);
    }
    
    // DataBackupService의 설정도 업데이트
    await _backupService.saveBackupSettings(
      autoBackupEnabled: autoBackupEnabled,
      frequency: frequency,
    );
    
    // 스케줄 재시작
    if (autoBackupEnabled == true) {
      await startSchedule();
    } else if (autoBackupEnabled == false) {
      await stopSchedule();
    }
  }

  /// 백업 상태 정보 가져오기
  Future<BackupStatus> getBackupStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = await _backupService.getBackupSettings();
    
    final lastBackupTime = await _backupService.getLastBackupTime();
    final lastAutoBackupString = prefs.getString(_lastAutoBackupKey);
    final nextBackupTimeString = prefs.getString(_nextBackupTimeKey);
    final failureCount = prefs.getInt(_backupFailureCountKey) ?? 0;
    final retentionCount = prefs.getInt(_backupRetentionCountKey) ?? 5;
    
    DateTime? lastAutoBackupTime;
    if (lastAutoBackupString != null) {
      lastAutoBackupTime = DateTime.parse(lastAutoBackupString);
    }
    
    DateTime? nextBackupTime;
    if (nextBackupTimeString != null) {
      nextBackupTime = DateTime.parse(nextBackupTimeString);
    }
    
    return BackupStatus(
      autoBackupEnabled: settings.autoBackupEnabled,
      frequency: settings.frequency,
      encryptionEnabled: settings.encryptionEnabled,
      lastBackupTime: lastBackupTime,
      lastAutoBackupTime: lastAutoBackupTime,
      nextBackupTime: nextBackupTime,
      failureCount: failureCount,
      retentionCount: retentionCount,
      isSchedulerRunning: _schedulerTimer?.isActive ?? false,
    );
  }

  /// 파일 크기 포맷팅
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// 스케줄러 정리
  void dispose() {
    _schedulerTimer?.cancel();
    _schedulerTimer = null;
  }
}

/// 백업 상태 정보 클래스
class BackupStatus {
  final bool autoBackupEnabled;
  final BackupFrequency frequency;
  final bool encryptionEnabled;
  final DateTime? lastBackupTime;
  final DateTime? lastAutoBackupTime;
  final DateTime? nextBackupTime;
  final int failureCount;
  final int retentionCount;
  final bool isSchedulerRunning;

  BackupStatus({
    required this.autoBackupEnabled,
    required this.frequency,
    required this.encryptionEnabled,
    this.lastBackupTime,
    this.lastAutoBackupTime,
    this.nextBackupTime,
    required this.failureCount,
    required this.retentionCount,
    required this.isSchedulerRunning,
  });

  /// 다음 백업까지 남은 시간
  Duration? get timeUntilNextBackup {
    if (nextBackupTime == null) return null;
    final now = DateTime.now();
    final diff = nextBackupTime!.difference(now);
    return diff.isNegative ? null : diff;
  }

  /// 백업 상태 텍스트
  String get statusText {
    if (!autoBackupEnabled) {
      return '자동 백업 비활성화';
    }
    
    if (failureCount >= 3) {
      return '백업 실패로 인한 중단';
    }
    
    if (!isSchedulerRunning) {
      return '스케줄러 중지됨';
    }
    
    final timeUntil = timeUntilNextBackup;
    if (timeUntil == null) {
      return '백업 대기 중';
    }
    
    if (timeUntil.inDays > 0) {
      return '${timeUntil.inDays}일 후 백업 예정';
    } else if (timeUntil.inHours > 0) {
      return '${timeUntil.inHours}시간 후 백업 예정';
    } else {
      return '${timeUntil.inMinutes}분 후 백업 예정';
    }
  }
} 