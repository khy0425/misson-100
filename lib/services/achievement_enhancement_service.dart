import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/achievement.dart';
import 'achievement_service.dart';
import 'achievement_performance_service.dart';
import 'achievement_logger.dart';

/// 업적 시스템의 향상된 기능을 제공하는 서비스
/// 성능 모니터링, 백업/복원, 고급 검색 및 필터링 기능 포함
class AchievementEnhancementService {
  
  // === 성능 모니터링 시스템 ===
  
  static Map<String, List<int>> _performanceMetrics = {};
  static bool _enablePerformanceLogging = kDebugMode;

  /// 성능 타이머 시작
  static Stopwatch _startPerformanceTimer(String operation) {
    final timer = Stopwatch()..start();
    if (_enablePerformanceLogging) {
      debugPrint('⏱️ 성능 측정 시작: $operation');
    }
    return timer;
  }

  /// 성능 타이머 종료 및 기록
  static void _endPerformanceTimer(String operation, Stopwatch timer) {
    timer.stop();
    final elapsedMs = timer.elapsedMilliseconds;
    
    // 성능 메트릭 기록
    _performanceMetrics.putIfAbsent(operation, () => []).add(elapsedMs);
    
    // 메트릭 크기 제한 (최근 100개만 유지)
    if (_performanceMetrics[operation]!.length > 100) {
      _performanceMetrics[operation]!.removeAt(0);
    }
    
    if (_enablePerformanceLogging) {
      debugPrint('⏱️ 성능 측정 완료: $operation - ${elapsedMs}ms');
      
      // 평균 계산
      final metrics = _performanceMetrics[operation]!;
      final avg = metrics.reduce((a, b) => a + b) / metrics.length;
      
      // 성능 경고 (평균의 3배 이상 소요시)
      if (elapsedMs > avg * 3 && metrics.length > 5) {
        debugPrint('⚠️ 성능 경고: $operation 시간 초과 (${elapsedMs}ms > ${avg.toStringAsFixed(1)}ms 평균)');
      }
    }
  }

  /// 성능 메트릭 조회
  static Map<String, Map<String, double>> getPerformanceMetrics() {
    final result = <String, Map<String, double>>{};
    
    for (final entry in _performanceMetrics.entries) {
      final operation = entry.key;
      final times = entry.value;
      
      if (times.isNotEmpty) {
        final sorted = List<int>.from(times)..sort();
        result[operation] = {
          'count': times.length.toDouble(),
          'min': sorted.first.toDouble(),
          'max': sorted.last.toDouble(),
          'avg': times.reduce((a, b) => a + b) / times.length,
          'median': sorted[sorted.length ~/ 2].toDouble(),
          'p95': sorted[(sorted.length * 0.95).floor()].toDouble(),
        };
      }
    }
    
    return result;
  }

  /// 성능 메트릭 리포트 출력
  static void printPerformanceReport() {
    final metrics = getPerformanceMetrics();
    if (metrics.isEmpty) {
      debugPrint('📊 성능 메트릭 없음');
      return;
    }
    
    debugPrint('📊 AchievementService 성능 리포트:');
    for (final entry in metrics.entries) {
      final op = entry.key;
      final stats = entry.value;
      debugPrint('   $op: 평균 ${stats['avg']!.toStringAsFixed(1)}ms, '
          '최대 ${stats['max']!.toStringAsFixed(0)}ms, '
          '호출 ${stats['count']!.toStringAsFixed(0)}회');
    }
  }

  /// 성능 로깅 활성화/비활성화
  static void setPerformanceLogging(bool enabled) {
    _enablePerformanceLogging = enabled;
    debugPrint('📊 성능 로깅 ${enabled ? '활성화' : '비활성화'}');
  }

  /// 성능 메트릭 초기화
  static void clearPerformanceMetrics() {
    _performanceMetrics.clear();
    debugPrint('📊 성능 메트릭 초기화 완료');
  }

  // === 백업 및 복원 시스템 ===

  /// 현재 업적 상태 백업
  static Future<Map<String, dynamic>> backupAchievementData() async {
    final timer = _startPerformanceTimer('backupAchievementData');
    
    try {
      debugPrint('💾 업적 데이터 백업 시작...');
      
      final achievements = await AchievementService.getAllAchievements();
      final achievementMaps = achievements.map((a) => a.toMap()).toList();
      
      final backup = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'count': achievementMaps.length,
        'achievements': achievementMaps,
        'metadata': {
          'app_version': '2.1.1',
          'database_version': 3,
          'backup_source': 'AchievementEnhancementService',
        },
      };
      
      // SharedPreferences에 최신 백업 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('achievement_backup_latest', json.encode(backup));
      
      debugPrint('✅ 업적 데이터 백업 완료: ${achievementMaps.length}개');
      return backup;
      
    } catch (e) {
      debugPrint('❌ 업적 데이터 백업 실패: $e');
      rethrow;
    } finally {
      _endPerformanceTimer('backupAchievementData', timer);
    }
  }

  /// 백업에서 업적 데이터 복원
  static Future<bool> restoreAchievementData(Map<String, dynamic> backup) async {
    final timer = _startPerformanceTimer('restoreAchievementData');
    
    try {
      debugPrint('🔄 업적 데이터 복원 시작...');
      
      // 백업 유효성 검사
      if (!_isValidBackup(backup)) {
        throw Exception('유효하지 않은 백업 데이터');
      }
      
      final achievementMaps = backup['achievements'] as List<dynamic>;
      
      // 각 업적을 개별적으로 복원
      for (final mapDynamic in achievementMaps) {
        try {
          final map = mapDynamic as Map<String, dynamic>;
          final achievement = Achievement.fromMap(map);
          await AchievementService.updateAchievementInDatabase(achievement);
        } catch (e) {
          debugPrint('⚠️ 개별 업적 복원 실패: $e');
          // 개별 실패는 전체 프로세스를 중단하지 않음
        }
      }
      
      // 캐시 무효화
      AchievementService.invalidateCache();
      
      debugPrint('✅ 업적 데이터 복원 완료: ${achievementMaps.length}개');
      return true;
      
    } catch (e) {
      debugPrint('❌ 업적 데이터 복원 실패: $e');
      return false;
    } finally {
      _endPerformanceTimer('restoreAchievementData', timer);
    }
  }

  /// 백업 유효성 검사
  static bool _isValidBackup(Map<String, dynamic> backup) {
    try {
      // 필수 필드 검사
      if (!backup.containsKey('version') || 
          !backup.containsKey('achievements') ||
          !backup.containsKey('timestamp')) {
        return false;
      }
      
      // 버전 검사
      final version = backup['version'] as int?;
      if (version == null || version < 1 || version > 1) {
        return false;
      }
      
      // 업적 데이터 검사
      final achievements = backup['achievements'] as List<dynamic>?;
      if (achievements == null || achievements.isEmpty) {
        return false;
      }
      
      // 첫 번째 업적 구조 검사
      final firstAchievement = achievements.first as Map<String, dynamic>?;
      if (firstAchievement == null || !firstAchievement.containsKey('id')) {
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ 백업 유효성 검사 실패: $e');
      return false;
    }
  }

  /// 최신 백업 조회
  static Future<Map<String, dynamic>?> getLatestBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupString = prefs.getString('achievement_backup_latest');
      
      if (backupString != null) {
        final backup = json.decode(backupString) as Map<String, dynamic>;
        if (_isValidBackup(backup)) {
          return backup;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ 최신 백업 조회 실패: $e');
      return null;
    }
  }

  /// 자동 백업 실행 (조건부)
  static Future<void> performAutoBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastBackupString = prefs.getString('last_auto_backup');
      final now = DateTime.now();
      
      // 마지막 백업으로부터 24시간이 지났는지 확인
      if (lastBackupString != null) {
        final lastBackup = DateTime.parse(lastBackupString);
        if (now.difference(lastBackup).inHours < 24) {
          debugPrint('⏭️ 자동 백업 스킵 (24시간 미경과)');
          return;
        }
      }
      
      // 자동 백업 실행
      debugPrint('🔄 자동 백업 실행...');
      await backupAchievementData();
      await prefs.setString('last_auto_backup', now.toIso8601String());
      
    } catch (e) {
      debugPrint('❌ 자동 백업 실패: $e');
    }
  }

  // === 고급 검색 및 필터링 ===

  /// 업적 검색 (제목, 설명 기반)
  static Future<List<Achievement>> searchAchievements(String query) async {
    final timer = _startPerformanceTimer('searchAchievements');
    
    try {
      if (query.trim().isEmpty) return [];
      
      final allAchievements = await AchievementService.getAllAchievements();
      final lowercaseQuery = query.toLowerCase();
      
      final results = allAchievements.where((achievement) {
        return achievement.titleKey.toLowerCase().contains(lowercaseQuery) ||
               achievement.descriptionKey.toLowerCase().contains(lowercaseQuery) ||
               achievement.id.toLowerCase().contains(lowercaseQuery);
      }).toList();
      
      // 검색 관련성에 따른 정렬
      results.sort((a, b) {
        int scoreA = _calculateSearchScore(a, lowercaseQuery);
        int scoreB = _calculateSearchScore(b, lowercaseQuery);
        return scoreB.compareTo(scoreA);
      });
      
      debugPrint('🔍 업적 검색 완료: "$query" → ${results.length}개 결과');
      return results;
      
    } finally {
      _endPerformanceTimer('searchAchievements', timer);
    }
  }

  /// 검색 점수 계산
  static int _calculateSearchScore(Achievement achievement, String query) {
    int score = 0;
    
    // ID 완전 일치 (가장 높은 점수)
    if (achievement.id.toLowerCase() == query) {
      score += 100;
    } else if (achievement.id.toLowerCase().contains(query)) {
      score += 50;
    }
    
    // 제목 일치
    if (achievement.titleKey.toLowerCase().contains(query)) {
      score += 30;
    }
    
    // 설명 일치
    if (achievement.descriptionKey.toLowerCase().contains(query)) {
      score += 10;
    }
    
    // 잠금 해제된 업적에 보너스 점수
    if (achievement.isUnlocked) {
      score += 5;
    }
    
    return score;
  }

  /// 타입별 업적 필터링
  static Future<List<Achievement>> getAchievementsByType(AchievementType type) async {
    final timer = _startPerformanceTimer('getAchievementsByType');
    
    try {
      final allAchievements = await AchievementService.getAllAchievements();
      final filtered = allAchievements
          .where((a) => a.type == type)
          .toList();
      
      // 희귀도, 잠금해제 상태, 진행률로 정렬
      filtered.sort((a, b) {
        if (a.rarity.index != b.rarity.index) {
          return b.rarity.index.compareTo(a.rarity.index);
        }
        if (a.isUnlocked != b.isUnlocked) {
          return a.isUnlocked ? -1 : 1;
        }
        return b.currentValue.compareTo(a.currentValue);
      });
      
      return filtered;
      
    } finally {
      _endPerformanceTimer('getAchievementsByType', timer);
    }
  }

  /// 희귀도별 업적 필터링
  static Future<List<Achievement>> getAchievementsByRarity(AchievementRarity rarity) async {
    final timer = _startPerformanceTimer('getAchievementsByRarity');
    
    try {
      final allAchievements = await AchievementService.getAllAchievements();
      final filtered = allAchievements
          .where((a) => a.rarity == rarity)
          .toList();
      
      // 잠금해제 상태, 진행률로 정렬
      filtered.sort((a, b) {
        if (a.isUnlocked != b.isUnlocked) {
          return a.isUnlocked ? -1 : 1;
        }
        return b.currentValue.compareTo(a.currentValue);
      });
      
      return filtered;
      
    } finally {
      _endPerformanceTimer('getAchievementsByRarity', timer);
    }
  }

  /// 진행률 범위별 업적 필터링
  static Future<List<Achievement>> getAchievementsByProgress(
    double minProgress, 
    double maxProgress
  ) async {
    final timer = _startPerformanceTimer('getAchievementsByProgress');
    
    try {
      final allAchievements = await AchievementService.getAllAchievements();
      
      final filtered = allAchievements.where((achievement) {
        final progress = achievement.progress;
        return progress >= minProgress && progress <= maxProgress;
      }).toList();
      
      // 진행률 높은 순으로 정렬
      filtered.sort((a, b) => b.progress.compareTo(a.progress));
      
      return filtered;
      
    } finally {
      _endPerformanceTimer('getAchievementsByProgress', timer);
    }
  }

  /// 최근 달성한 업적 조회
  static Future<List<Achievement>> getRecentlyUnlockedAchievements({
    int limit = 10,
  }) async {
    final timer = _startPerformanceTimer('getRecentlyUnlockedAchievements');
    
    try {
      final allAchievements = await AchievementService.getAllAchievements();
      
      final unlocked = allAchievements
          .where((a) => a.isUnlocked && a.unlockedAt != null)
          .toList();
      
      // 달성 시간순으로 정렬 (최근 것부터)
      unlocked.sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));
      
      return unlocked.take(limit).toList();
      
    } finally {
      _endPerformanceTimer('getRecentlyUnlockedAchievements', timer);
    }
  }

  /// 거의 달성한 업적 조회 (90% 이상 진행)
  static Future<List<Achievement>> getNearlyCompletedAchievements({
    double threshold = 0.9,
    int limit = 5,
  }) async {
    final timer = _startPerformanceTimer('getNearlyCompletedAchievements');
    
    try {
      final allAchievements = await AchievementService.getAllAchievements();
      
      final nearlyCompleted = allAchievements
          .where((a) => !a.isUnlocked && a.progress >= threshold)
          .toList();
      
      // 진행률 높은 순으로 정렬
      nearlyCompleted.sort((a, b) => b.progress.compareTo(a.progress));
      
      return nearlyCompleted.take(limit).toList();
      
    } finally {
      _endPerformanceTimer('getNearlyCompletedAchievements', timer);
    }
  }

  /// 업적 통계 조회
  static Future<Map<String, dynamic>> getAchievementStatistics() async {
    final timer = _startPerformanceTimer('getAchievementStatistics');
    
    try {
      final allAchievements = await AchievementService.getAllAchievements();
      
      final unlocked = allAchievements.where((a) => a.isUnlocked).length;
      final total = allAchievements.length;
      final completionRate = total > 0 ? (unlocked / total) * 100 : 0.0;
      
      // 타입별 통계
      final typeStats = <String, Map<String, int>>{};
      for (final type in AchievementType.values) {
        final typeAchievements = allAchievements.where((a) => a.type == type);
        final typeUnlocked = typeAchievements.where((a) => a.isUnlocked).length;
        typeStats[type.toString().split('.').last] = {
          'total': typeAchievements.length,
          'unlocked': typeUnlocked,
          'locked': typeAchievements.length - typeUnlocked,
        };
      }
      
      // 희귀도별 통계
      final rarityStats = <String, Map<String, int>>{};
      for (final rarity in AchievementRarity.values) {
        final rarityAchievements = allAchievements.where((a) => a.rarity == rarity);
        final rarityUnlocked = rarityAchievements.where((a) => a.isUnlocked).length;
        rarityStats[rarity.toString().split('.').last] = {
          'total': rarityAchievements.length,
          'unlocked': rarityUnlocked,
          'locked': rarityAchievements.length - rarityUnlocked,
        };
      }
      
      // 최근 달성 업적
      final recentUnlocked = await getRecentlyUnlockedAchievements(limit: 5);
      
      return {
        'overview': {
          'total': total,
          'unlocked': unlocked,
          'locked': total - unlocked,
          'completionRate': completionRate,
        },
        'byType': typeStats,
        'byRarity': rarityStats,
        'recentUnlocked': recentUnlocked.map((a) => {
          'id': a.id,
          'titleKey': a.titleKey,
          'rarity': a.rarity.toString().split('.').last,
          'unlockedAt': a.unlockedAt?.toIso8601String(),
        }).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
    } finally {
      _endPerformanceTimer('getAchievementStatistics', timer);
    }
  }

  /// 업적 진행률 보고서 생성
  static Future<String> generateProgressReport() async {
    final stats = await getAchievementStatistics();
    final overview = stats['overview'] as Map<String, dynamic>;
    final typeStats = stats['byType'] as Map<String, Map<String, int>>;
    final rarityStats = stats['byRarity'] as Map<String, Map<String, int>>;
    
    final buffer = StringBuffer();
    buffer.writeln('📊 업적 진행률 보고서');
    buffer.writeln('=' * 30);
    buffer.writeln('📈 전체 현황:');
    buffer.writeln('   • 총 업적: ${overview['total']}개');
    buffer.writeln('   • 달성: ${overview['unlocked']}개');
    buffer.writeln('   • 미달성: ${overview['locked']}개');
    buffer.writeln('   • 완료율: ${overview['completionRate'].toStringAsFixed(1)}%');
    buffer.writeln();
    
    buffer.writeln('🎯 타입별 현황:');
    for (final entry in typeStats.entries) {
      final type = entry.key;
      final data = entry.value;
      final rate = data['total']! > 0 ? (data['unlocked']! / data['total']!) * 100 : 0.0;
      buffer.writeln('   • $type: ${data['unlocked']}/${data['total']} (${rate.toStringAsFixed(1)}%)');
    }
    buffer.writeln();
    
    buffer.writeln('💎 희귀도별 현황:');
    for (final entry in rarityStats.entries) {
      final rarity = entry.key;
      final data = entry.value;
      final rate = data['total']! > 0 ? (data['unlocked']! / data['total']!) * 100 : 0.0;
      buffer.writeln('   • $rarity: ${data['unlocked']}/${data['total']} (${rate.toStringAsFixed(1)}%)');
    }
    
    return buffer.toString();
  }
} 