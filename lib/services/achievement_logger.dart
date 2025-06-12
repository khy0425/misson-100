import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';

// 로그 레벨
enum LogLevel { debug, info, warning, error, critical }

// 로그 카테고리
enum LogCategory { 
  achievement, 
  performance, 
  database, 
  cache, 
  notification, 
  ui, 
  analytics 
}

/// 업적 시스템 전용 로거
/// 업적 달성, 진행률 변경, 성능 이슈 등을 상세히 기록
class AchievementLogger {
  
  // 설정
  static LogLevel _currentLogLevel = LogLevel.info;
  static bool _isFileLoggingEnabled = true;
  static bool _isAnalyticsEnabled = true;
  static const int _maxLogFileSize = 5 * 1024 * 1024; // 5MB
  static const int _maxLogFiles = 5;
  
  // 로그 파일
  static File? _logFile;
  static final List<String> _memoryBuffer = [];
  static const int _maxMemoryBuffer = 1000;
  
  // 분석 데이터
  static final Map<String, int> _achievementEvents = {};
  static final Map<String, int> _errorCounts = {};
  static final Map<String, double> _performanceMetrics = {};
  
  /// 로거 초기화
  static Future<void> initialize() async {
    try {
      // 로그 디렉토리 생성
      await _initializeLogFile();
      
      // 기존 로그 데이터 로드
      await _loadLogAnalytics();
      
      // 로그 로테이션 확인
      await _checkLogRotation();
      
      await log(
        LogLevel.info, 
        LogCategory.achievement, 
        'AchievementLogger 초기화 완료',
        metadata: {'version': '1.0.0'},
      );
      
    } catch (e) {
      debugPrint('❌ AchievementLogger 초기화 실패: $e');
    }
  }

  /// 로그 기록
  static Future<void> log(
    LogLevel level,
    LogCategory category,
    String message, {
    Map<String, dynamic>? metadata,
    dynamic error,
    StackTrace? stackTrace,
    String? userId,
    String? achievementId,
  }) async {
    // 로그 레벨 필터링
    if (level.index < _currentLogLevel.index) return;
    
    try {
      final logEntry = _createLogEntry(
        level,
        category,
        message,
        metadata: metadata,
        error: error,
        stackTrace: stackTrace,
        userId: userId,
        achievementId: achievementId,
      );
      
      // 콘솔 출력
      _printToConsole(level, category, message, error);
      
      // 메모리 버퍼에 추가
      _addToMemoryBuffer(logEntry);
      
      // 파일에 기록
      if (_isFileLoggingEnabled) {
        await _writeToFile(logEntry);
      }
      
      // 분석 데이터 업데이트
      if (_isAnalyticsEnabled) {
        _updateAnalytics(level, category, message, achievementId);
      }
      
    } catch (e) {
      debugPrint('❌ 로그 기록 실패: $e');
    }
  }

  /// 업적 달성 로그
  static Future<void> logAchievementUnlock(
    Achievement achievement, {
    Map<String, dynamic>? context,
    String? userId,
  }) async {
    await log(
      LogLevel.info,
      LogCategory.achievement,
      '업적 달성: ${achievement.titleKey}',
      metadata: {
        'achievementId': achievement.id,
        'rarity': achievement.rarity.toString(),
        'category': achievement.category.toString(),
        'xpReward': achievement.xpReward,
        'currentValue': achievement.currentValue,
        'targetValue': achievement.targetValue,
        'unlockTime': DateTime.now().toIso8601String(),
        ...?context,
      },
      userId: userId,
      achievementId: achievement.id,
    );
  }

  /// 업적 진행률 변경 로그
  static Future<void> logAchievementProgress(
    Achievement achievement,
    int previousValue,
    int newValue, {
    String? trigger,
    String? userId,
  }) async {
    final progressPercent = (newValue / achievement.targetValue * 100).clamp(0, 100);
    
    await log(
      LogLevel.debug,
      LogCategory.achievement,
      '업적 진행률 변경: ${achievement.titleKey}',
      metadata: {
        'achievementId': achievement.id,
        'previousValue': previousValue,
        'newValue': newValue,
        'targetValue': achievement.targetValue,
        'progressPercent': progressPercent.toStringAsFixed(1),
        'progressDelta': newValue - previousValue,
        'trigger': trigger,
        'timestamp': DateTime.now().toIso8601String(),
      },
      userId: userId,
      achievementId: achievement.id,
    );
  }

  /// 성능 이슈 로그
  static Future<void> logPerformanceIssue(
    String operation,
    Duration duration, {
    Map<String, dynamic>? details,
    String? severity,
  }) async {
    await log(
      duration.inMilliseconds > 500 ? LogLevel.warning : LogLevel.info,
      LogCategory.performance,
      '성능 이슈: $operation took ${duration.inMilliseconds}ms',
      metadata: {
        'operation': operation,
        'durationMs': duration.inMilliseconds,
        'severity': severity ?? 'medium',
        'timestamp': DateTime.now().toIso8601String(),
        ...?details,
      },
    );
  }

  /// 데이터베이스 작업 로그
  static Future<void> logDatabaseOperation(
    String operation,
    bool success, {
    Duration? duration,
    dynamic error,
    Map<String, dynamic>? details,
  }) async {
    await log(
      success ? LogLevel.debug : LogLevel.error,
      LogCategory.database,
      '데이터베이스 $operation: ${success ? '성공' : '실패'}',
      metadata: {
        'operation': operation,
        'success': success,
        'durationMs': duration?.inMilliseconds,
        'timestamp': DateTime.now().toIso8601String(),
        ...?details,
      },
      error: error,
    );
  }

  /// 캐시 작업 로그
  static Future<void> logCacheOperation(
    String operation,
    bool isHit, {
    String? cacheKey,
    int? cacheSize,
    Map<String, dynamic>? details,
  }) async {
    await log(
      LogLevel.debug,
      LogCategory.cache,
      '캐시 $operation: ${isHit ? 'HIT' : 'MISS'}',
      metadata: {
        'operation': operation,
        'isHit': isHit,
        'cacheKey': cacheKey,
        'cacheSize': cacheSize,
        'timestamp': DateTime.now().toIso8601String(),
        ...?details,
      },
    );
  }

  /// 알림 로그
  static Future<void> logNotification(
    String type,
    bool success, {
    String? notificationId,
    String? achievementId,
    dynamic error,
    Map<String, dynamic>? details,
  }) async {
    await log(
      success ? LogLevel.info : LogLevel.error,
      LogCategory.notification,
      '알림 $type: ${success ? '성공' : '실패'}',
      metadata: {
        'type': type,
        'success': success,
        'notificationId': notificationId,
        'achievementId': achievementId,
        'timestamp': DateTime.now().toIso8601String(),
        ...?details,
      },
      error: error,
      achievementId: achievementId,
    );
  }

  /// UI 이벤트 로그
  static Future<void> logUIEvent(
    String event,
    String screen, {
    String? action,
    Map<String, dynamic>? details,
    String? userId,
  }) async {
    await log(
      LogLevel.debug,
      LogCategory.ui,
      'UI 이벤트: $event on $screen',
      metadata: {
        'event': event,
        'screen': screen,
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
        ...?details,
      },
      userId: userId,
    );
  }

  /// 간편 로그 메서드들
  static Future<void> logDebug(
    String message, {
    LogCategory category = LogCategory.achievement,
    Map<String, dynamic>? metadata,
    String? userId,
    String? achievementId,
  }) async {
    await log(
      LogLevel.debug,
      category,
      message,
      metadata: metadata,
      userId: userId,
      achievementId: achievementId,
    );
  }

  static Future<void> logInfo(
    String message, {
    LogCategory category = LogCategory.achievement,
    Map<String, dynamic>? metadata,
    String? userId,
    String? achievementId,
  }) async {
    await log(
      LogLevel.info,
      category,
      message,
      metadata: metadata,
      userId: userId,
      achievementId: achievementId,
    );
  }

  static Future<void> logWarning(
    String message, {
    LogCategory category = LogCategory.achievement,
    Map<String, dynamic>? metadata,
    dynamic error,
    String? userId,
    String? achievementId,
  }) async {
    await log(
      LogLevel.warning,
      category,
      message,
      metadata: metadata,
      error: error,
      userId: userId,
      achievementId: achievementId,
    );
  }

  static Future<void> logError(
    String message, {
    LogCategory category = LogCategory.achievement,
    Map<String, dynamic>? metadata,
    dynamic error,
    StackTrace? stackTrace,
    String? userId,
    String? achievementId,
  }) async {
    await log(
      LogLevel.error,
      category,
      message,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
      userId: userId,
      achievementId: achievementId,
    );
  }

  static Future<void> logCritical(
    String message, {
    LogCategory category = LogCategory.achievement,
    Map<String, dynamic>? metadata,
    dynamic error,
    StackTrace? stackTrace,
    String? userId,
    String? achievementId,
  }) async {
    await log(
      LogLevel.critical,
      category,
      message,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
      userId: userId,
      achievementId: achievementId,
    );
  }

  /// 로그 엔트리 생성
  static Map<String, dynamic> _createLogEntry(
    LogLevel level,
    LogCategory category,
    String message, {
    Map<String, dynamic>? metadata,
    dynamic error,
    StackTrace? stackTrace,
    String? userId,
    String? achievementId,
  }) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.toString().split('.').last.toUpperCase(),
      'category': category.toString().split('.').last.toUpperCase(),
      'message': message,
      'userId': userId,
      'achievementId': achievementId,
      'metadata': metadata,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
      'platform': Platform.operatingSystem,
      'version': '1.0.0', // 앱 버전
    };
  }

  /// 콘솔에 출력
  static void _printToConsole(
    LogLevel level,
    LogCategory category,
    String message,
    dynamic error,
  ) {
    final emoji = _getEmojiForLevel(level);
    final timestamp = DateTime.now().toString().substring(11, 19);
    final categoryStr = category.toString().split('.').last.toUpperCase();
    
    debugPrint('$emoji [$timestamp][$categoryStr] $message');
    
    if (error != null) {
      debugPrint('   Error: $error');
    }
  }

  /// 레벨별 이모지
  static String _getEmojiForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug: return '🐛';
      case LogLevel.info: return 'ℹ️';
      case LogLevel.warning: return '⚠️';
      case LogLevel.error: return '❌';
      case LogLevel.critical: return '🚨';
    }
  }

  /// 메모리 버퍼에 추가
  static void _addToMemoryBuffer(Map<String, dynamic> logEntry) {
    _memoryBuffer.add(jsonEncode(logEntry));
    
    // 버퍼 크기 제한
    while (_memoryBuffer.length > _maxMemoryBuffer) {
      _memoryBuffer.removeAt(0);
    }
  }

  /// 파일에 기록
  static Future<void> _writeToFile(Map<String, dynamic> logEntry) async {
    try {
      if (_logFile == null) return;
      
      final jsonLine = '${jsonEncode(logEntry)}\n';
      await _logFile!.writeAsString(jsonLine, mode: FileMode.append);
      
      // 파일 크기 확인
      final fileSize = await _logFile!.length();
      if (fileSize > _maxLogFileSize) {
        await _rotateLogFile();
      }
      
    } catch (e) {
      debugPrint('❌ 로그 파일 쓰기 실패: $e');
    }
  }

  /// 분석 데이터 업데이트
  static void _updateAnalytics(
    LogLevel level,
    LogCategory category,
    String message,
    String? achievementId,
  ) {
    final key = '${category.toString().split('.').last}_${level.toString().split('.').last}';
    _achievementEvents[key] = (_achievementEvents[key] ?? 0) + 1;
    
    if (level == LogLevel.error || level == LogLevel.critical) {
      _errorCounts[message] = (_errorCounts[message] ?? 0) + 1;
    }
    
    if (achievementId != null) {
      _achievementEvents['achievement_$achievementId'] = 
          (_achievementEvents['achievement_$achievementId'] ?? 0) + 1;
    }
  }

  /// 로그 파일 초기화
  static Future<void> _initializeLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      
      final today = DateTime.now().toString().substring(0, 10);
      _logFile = File('${logDir.path}/achievements_$today.log');
      
    } catch (e) {
      debugPrint('❌ 로그 파일 초기화 실패: $e');
      _isFileLoggingEnabled = false;
    }
  }

  /// 로그 로테이션
  static Future<void> _rotateLogFile() async {
    try {
      if (_logFile == null) return;
      
      final directory = _logFile!.parent;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final rotatedName = '${_logFile!.path}.$timestamp.old';
      
      await _logFile!.rename(rotatedName);
      
      // 새 로그 파일 생성
      await _initializeLogFile();
      
      // 오래된 로그 파일 정리
      await _cleanupOldLogFiles(directory);
      
    } catch (e) {
      debugPrint('❌ 로그 로테이션 실패: $e');
    }
  }

  /// 로그 로테이션 확인
  static Future<void> _checkLogRotation() async {
    try {
      if (_logFile != null && await _logFile!.exists()) {
        final fileSize = await _logFile!.length();
        if (fileSize > _maxLogFileSize) {
          await _rotateLogFile();
        }
      }
    } catch (e) {
      debugPrint('❌ 로그 로테이션 확인 실패: $e');
    }
  }

  /// 오래된 로그 파일 정리
  static Future<void> _cleanupOldLogFiles(Directory directory) async {
    try {
      final files = await directory.list().toList();
      final logFiles = files
          .where((f) => f is File && f.path.contains('achievements_') && f.path.endsWith('.old'))
          .cast<File>()
          .toList();
      
      if (logFiles.length > _maxLogFiles) {
        // 생성 시간 순으로 정렬
        logFiles.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
        
        // 오래된 파일 삭제
        for (int i = 0; i < logFiles.length - _maxLogFiles; i++) {
          await logFiles[i].delete();
        }
      }
      
    } catch (e) {
      debugPrint('❌ 오래된 로그 파일 정리 실패: $e');
    }
  }

  /// 분석 데이터 로드
  static Future<void> _loadLogAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final eventsJson = prefs.getString('achievement_log_events');
      if (eventsJson != null) {
        final events = Map<String, dynamic>.from(jsonDecode(eventsJson));
        _achievementEvents.addAll(events.cast<String, int>());
      }
      
      final errorsJson = prefs.getString('achievement_log_errors');
      if (errorsJson != null) {
        final errors = Map<String, dynamic>.from(jsonDecode(errorsJson));
        _errorCounts.addAll(errors.cast<String, int>());
      }
      
    } catch (e) {
      debugPrint('❌ 로그 분석 데이터 로드 실패: $e');
    }
  }

  /// 분석 데이터 저장
  static Future<void> saveAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('achievement_log_events', jsonEncode(_achievementEvents));
      await prefs.setString('achievement_log_errors', jsonEncode(_errorCounts));
      
    } catch (e) {
      debugPrint('❌ 로그 분석 데이터 저장 실패: $e');
    }
  }

  /// 분석 리포트 생성
  static Map<String, dynamic> generateAnalyticsReport() {
    final totalEvents = _achievementEvents.values.fold(0, (sum, count) => sum + count);
    final totalErrors = _errorCounts.values.fold(0, (sum, count) => sum + count);
    
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'summary': {
        'totalEvents': totalEvents,
        'totalErrors': totalErrors,
        'errorRate': totalEvents > 0 ? (totalErrors / totalEvents * 100).toStringAsFixed(2) : '0.00',
      },
      'events': _achievementEvents,
      'errors': _errorCounts,
      'performance': _performanceMetrics,
      'memoryBufferSize': _memoryBuffer.length,
    };
  }

  /// 로그 레벨 설정
  static void setLogLevel(LogLevel level) {
    _currentLogLevel = level;
  }

  /// 파일 로깅 활성화/비활성화
  static void setFileLogging(bool enabled) {
    _isFileLoggingEnabled = enabled;
  }

  /// 분석 활성화/비활성화
  static void setAnalytics(bool enabled) {
    _isAnalyticsEnabled = enabled;
  }

  /// 메모리 버퍼의 로그 가져오기
  static List<Map<String, dynamic>> getRecentLogs({int? limit}) {
    final logs = _memoryBuffer.map((jsonStr) {
      try {
        return Map<String, dynamic>.from(jsonDecode(jsonStr));
      } catch (e) {
        return <String, dynamic>{'error': 'Failed to parse log: $e'};
      }
    }).toList();
    
    if (limit != null && limit < logs.length) {
      return logs.sublist(logs.length - limit);
    }
    
    return logs;
  }

  /// 분석 데이터 초기화
  static void clearAnalytics() {
    _achievementEvents.clear();
    _errorCounts.clear();
    _performanceMetrics.clear();
  }
} 