import 'package:flutter/material.dart';
import 'dart:collection';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'achievement_logger.dart';

/// 업적 시스템 성능 모니터링 및 최적화 서비스
class AchievementPerformanceService {
  
  // 성능 메트릭 데이터
  static final Map<String, List<Duration>> _operationTimings = {};
  static final Map<String, int> _operationCounts = {};
  static final Map<String, Duration> _operationDurations = {};
  static final Map<String, DateTime> _lastOperationTimes = {};
  static final Queue<String> _performanceLogs = Queue<String>();
  static const int _maxLogEntries = 1000;
  
  // 캐시 성능 메트릭
  static int _cacheHits = 0;
  static int _cacheMisses = 0;
  static int _cacheEvictions = 0;
  
  // 메모리 사용량 추적
  static final Map<String, int> _memoryUsage = {};
  
  // 임계값 설정
  static const Duration _slowOperationThreshold = Duration(milliseconds: 100);
  static const int _maxCacheSize = 500;
  static const double _cacheHitRateThreshold = 0.8; // 80%
  
  /// 성능 모니터링 초기화
  static Future<void> initialize() async {
    try {
      // 기존 성능 데이터 로드
      await _loadPerformanceData();
      
      // 성능 모니터링 시작
      _startPerformanceMonitoring();
      
      debugPrint('🚀 AchievementPerformanceService 초기화 완료');
    } catch (e) {
      debugPrint('❌ 성능 서비스 초기화 실패: $e');
    }
  }

  /// 성능 모니터링 시작
  static void _startPerformanceMonitoring() {
    // 1분마다 성능 리포트 생성
    Stream.periodic(const Duration(minutes: 1)).listen((_) {
      _generatePerformanceReport();
    });
    
    // 10분마다 캐시 최적화
    Stream.periodic(const Duration(minutes: 10)).listen((_) {
      _optimizeCache();
    });
  }

  /// 작업 시간 측정
  static Future<T> measureOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await operation();
      stopwatch.stop();
      
      _recordOperationTiming(operationName, stopwatch.elapsed);
      _incrementOperationCount(operationName);
      
      // 느린 작업 경고
      if (stopwatch.elapsed > _slowOperationThreshold) {
        _logSlowOperation(operationName, stopwatch.elapsed);
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      _logOperationError(operationName, stopwatch.elapsed, e);
      rethrow;
    }
  }

  /// 동기 작업 시간 측정
  static T measureSyncOperation<T>(
    String operationName,
    T Function() operation,
  ) {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = operation();
      stopwatch.stop();
      
      _recordOperationTiming(operationName, stopwatch.elapsed);
      _incrementOperationCount(operationName);
      
      return result;
    } catch (e) {
      stopwatch.stop();
      _logOperationError(operationName, stopwatch.elapsed, e);
      rethrow;
    }
  }

  /// 캐시 히트 기록
  static void recordCacheHit(String cacheKey) {
    _cacheHits++;
    _logPerformance('CACHE_HIT', 'Cache hit for: $cacheKey');
  }

  /// 캐시 미스 기록
  static void recordCacheMiss(String cacheKey) {
    _cacheMisses++;
    _logPerformance('CACHE_MISS', 'Cache miss for: $cacheKey');
  }

  /// 캐시 제거 기록
  static void recordCacheEviction(String cacheKey) {
    _cacheEvictions++;
    _logPerformance('CACHE_EVICTION', 'Cache eviction for: $cacheKey');
  }

  /// 메모리 사용량 기록
  static void recordMemoryUsage(String component, int bytes) {
    _memoryUsage[component] = bytes;
  }

  /// 작업 타이밍 기록
  static void _recordOperationTiming(String operation, Duration duration) {
    _operationTimings.putIfAbsent(operation, () => <Duration>[]);
    _operationTimings[operation]!.add(duration);
    
    // 최근 100개 기록만 유지
    if (_operationTimings[operation]!.length > 100) {
      _operationTimings[operation]!.removeAt(0);
    }
  }

  /// 작업 카운트 증가
  static void _incrementOperationCount(String operation) {
    _operationCounts[operation] = (_operationCounts[operation] ?? 0) + 1;
  }

  /// 느린 작업 로그
  static void _logSlowOperation(String operation, Duration duration) {
    final message = 'SLOW_OPERATION: $operation took ${duration.inMilliseconds}ms';
    _logPerformance('WARNING', message);
    debugPrint('⚠️ $message');
  }

  /// 작업 오류 로그
  static void _logOperationError(String operation, Duration duration, dynamic error) {
    final message = 'OPERATION_ERROR: $operation failed after ${duration.inMilliseconds}ms - $error';
    _logPerformance('ERROR', message);
    debugPrint('❌ $message');
  }

  /// 성능 로그 기록
  static void _logPerformance(String level, String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp][$level] $message';
    
    _performanceLogs.add(logEntry);
    
    // 로그 크기 제한
    while (_performanceLogs.length > _maxLogEntries) {
      _performanceLogs.removeFirst();
    }
  }

  /// 성능 리포트 생성
  static void _generatePerformanceReport() {
    try {
      final report = _buildPerformanceReport();
      _logPerformance('INFO', 'Performance Report: $report');
      
      // 성능 이슈 감지
      _detectPerformanceIssues();
      
    } catch (e) {
      debugPrint('❌ 성능 리포트 생성 실패: $e');
    }
  }

  /// 성능 리포트 빌드
  static Map<String, dynamic> _buildPerformanceReport() {
    final cacheHitRate = _cacheHits + _cacheMisses > 0 
        ? _cacheHits / (_cacheHits + _cacheMisses)
        : 0.0;
    
    final operationStats = <String, Map<String, dynamic>>{};
    
    _operationTimings.forEach((operation, timings) {
      if (timings.isNotEmpty) {
        final durations = timings.map((d) => d.inMicroseconds).toList()..sort();
        final count = durations.length;
        
        operationStats[operation] = {
          'count': _operationCounts[operation] ?? 0,
          'avgMs': (durations.reduce((a, b) => a + b) / count / 1000).toStringAsFixed(2),
          'medianMs': (durations[count ~/ 2] / 1000).toStringAsFixed(2),
          'maxMs': (durations.last / 1000).toStringAsFixed(2),
          'minMs': (durations.first / 1000).toStringAsFixed(2),
          'p95Ms': (durations[(count * 0.95).floor()] / 1000).toStringAsFixed(2),
        };
      }
    });

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'cache': {
        'hitRate': (cacheHitRate * 100).toStringAsFixed(1),
        'hits': _cacheHits,
        'misses': _cacheMisses,
        'evictions': _cacheEvictions,
      },
      'operations': operationStats,
      'memory': _memoryUsage,
    };
  }

  /// 성능 이슈 감지
  static void _detectPerformanceIssues() {
    // 캐시 히트율 체크
    final cacheHitRate = _cacheHits + _cacheMisses > 0 
        ? _cacheHits / (_cacheHits + _cacheMisses)
        : 1.0;
    
    if (cacheHitRate < _cacheHitRateThreshold) {
      _logPerformance('WARNING', 
          'Low cache hit rate: ${(cacheHitRate * 100).toStringAsFixed(1)}%');
    }
    
    // 느린 작업 평균 체크
    _operationTimings.forEach((operation, timings) {
      if (timings.isNotEmpty) {
        final avgDuration = Duration(
          microseconds: timings
              .map((d) => d.inMicroseconds)
              .reduce((a, b) => a + b) ~/ timings.length,
        );
        
        if (avgDuration > _slowOperationThreshold) {
          _logPerformance('WARNING', 
              'Operation $operation has high average duration: ${avgDuration.inMilliseconds}ms');
        }
      }
    });
  }

  /// 캐시 최적화
  static void _optimizeCache() {
    _logPerformance('INFO', 'Starting cache optimization');
    
    // 여기서 실제 캐시 최적화 로직을 구현할 수 있습니다
    // 예: 오래된 캐시 엔트리 제거, 사용 빈도가 낮은 항목 제거 등
    
    _logPerformance('INFO', 'Cache optimization completed');
  }

  /// 성능 데이터 저장
  static Future<void> savePerformanceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final data = {
        'cacheHits': _cacheHits,
        'cacheMisses': _cacheMisses,
        'cacheEvictions': _cacheEvictions,
        'operationCounts': _operationCounts,
        'logs': _performanceLogs.toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString('achievement_performance_data', jsonEncode(data));
      debugPrint('💾 성능 데이터 저장 완료');
      
    } catch (e) {
      debugPrint('❌ 성능 데이터 저장 실패: $e');
    }
  }

  /// 성능 데이터 로드
  static Future<void> _loadPerformanceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString('achievement_performance_data');
      
      if (dataString != null) {
        final data = jsonDecode(dataString) as Map<String, dynamic>;
        
        _cacheHits = data['cacheHits'] ?? 0;
        _cacheMisses = data['cacheMisses'] ?? 0;
        _cacheEvictions = data['cacheEvictions'] ?? 0;
        
        if (data['operationCounts'] != null) {
          _operationCounts.addAll(
            Map<String, int>.from(data['operationCounts']),
          );
        }
        
        if (data['logs'] != null) {
          _performanceLogs.addAll(
            List<String>.from(data['logs']),
          );
        }
        
        debugPrint('📊 성능 데이터 로드 완료');
      }
      
    } catch (e) {
      debugPrint('❌ 성능 데이터 로드 실패: $e');
    }
  }

  /// 현재 성능 상태 반환
  static Map<String, dynamic> getCurrentPerformanceState() {
    return _buildPerformanceReport();
  }

  /// 성능 로그 반환
  static List<String> getPerformanceLogs({int? limit}) {
    final logs = _performanceLogs.toList();
    if (limit != null && limit < logs.length) {
      return logs.sublist(logs.length - limit);
    }
    return logs;
  }

  /// 성능 통계 초기화
  static void resetPerformanceStats() {
    _operationTimings.clear();
    _operationCounts.clear();
    _performanceLogs.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
    _cacheEvictions = 0;
    _memoryUsage.clear();
    
    _logPerformance('INFO', 'Performance statistics reset');
    debugPrint('🔄 성능 통계 초기화 완료');
  }

  /// 캐시 작업 추적
  static Future<void> trackCacheOperation(
    String operation, {
    bool isHit = false,
    String? cacheKey,
    int? cacheSize,
    Duration? duration,
  }) async {
    try {
      // 작업 횟수 추적
      _operationCounts[operation] = (_operationCounts[operation] ?? 0) + 1;
      
      // 지속시간 추적
      if (duration != null) {
        _operationDurations[operation] = duration;
      }
      
      // 마지막 작업 시간 기록
      _lastOperationTimes[operation] = DateTime.now();
      
      // 로그 기록
      await AchievementLogger.logCacheOperation(
        operation,
        isHit,
        cacheKey: cacheKey,
        cacheSize: cacheSize,
        details: {
          'duration': duration?.inMilliseconds,
          'operationCount': _operationCounts[operation],
        },
      );
      
      // 성능 이슈 감지
      if (duration != null && duration.inMilliseconds > 100) {
        await AchievementLogger.logPerformanceIssue(
          'Cache operation: $operation',
          duration,
          details: {
            'cacheKey': cacheKey,
            'isHit': isHit,
          },
        );
      }
      
    } catch (e) {
      debugPrint('❌ 캐시 작업 추적 실패: $e');
    }
  }

  /// 데이터베이스 작업 추적
  static Future<void> trackDatabaseOperation(
    String operation,
    Duration duration, {
    bool success = true,
    dynamic error,
    Map<String, dynamic>? details,
  }) async {
    try {
      // 작업 횟수 추적
      _operationCounts[operation] = (_operationCounts[operation] ?? 0) + 1;
      
      // 지속시간 추적
      _operationDurations[operation] = duration;
      
      // 마지막 작업 시간 기록
      _lastOperationTimes[operation] = DateTime.now();
      
      // 로그 기록
      await AchievementLogger.logDatabaseOperation(
        operation,
        success,
        duration: duration,
        error: error,
        details: {
          'operationCount': _operationCounts[operation],
          ...?details,
        },
      );
      
      // 성능 이슈 감지
      if (duration.inMilliseconds > 500) {
        await AchievementLogger.logPerformanceIssue(
          'Database operation: $operation',
          duration,
          details: {
            'success': success,
            'error': error?.toString(),
            ...?details,
          },
          severity: duration.inMilliseconds > 1000 ? 'high' : 'medium',
        );
      }
      
    } catch (e) {
      debugPrint('❌ 데이터베이스 작업 추적 실패: $e');
    }
  }

  /// 성능 통계 가져오기
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'operationCounts': Map.from(_operationCounts),
      'operationDurations': _operationDurations.map(
        (key, value) => MapEntry(key, value.inMilliseconds),
      ),
      'lastOperationTimes': _lastOperationTimes.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    };
  }

  /// 성능 통계 초기화
  static void clearStats() {
    _operationCounts.clear();
    _operationDurations.clear();
    _lastOperationTimes.clear();
  }
} 