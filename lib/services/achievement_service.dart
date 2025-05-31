import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/achievement.dart';
import '../models/workout_history.dart';
import 'workout_history_service.dart';
import 'notification_service.dart';
import 'chad_evolution_service.dart';
import 'dart:io';

class AchievementService {
  static const String tableName = 'achievements';
  static Database? _database;
  static Database? _testDatabase; // 테스트용 데이터베이스
  
  // 실시간 업데이트를 위한 콜백들
  static VoidCallback? _onAchievementUnlocked;
  static VoidCallback? _onStatsUpdated;
  static BuildContext? _globalContext;

  // 성능 최적화를 위한 캐싱
  static Map<String, Achievement> _achievementCache = {};
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 5);
  
  // 성능 모니터링
  static final Map<String, List<int>> _performanceMetrics = {};
  static const bool _enablePerformanceLogging = true;
  
  // 배치 처리를 위한 대기열
  static final List<Map<String, dynamic>> _pendingUpdates = [];
  static bool _isBatchProcessing = false;
  static const int _batchSize = 10;
  
  // 오류 복구를 위한 백업
  static Map<String, dynamic>? _lastKnownState;

  // 테스트용 데이터베이스 설정
  static void setTestDatabase(Database testDb) {
    _testDatabase = testDb;
  }
  
  // 전역 컨텍스트 설정 (알림 표시용)
  static void setGlobalContext(BuildContext context) {
    _globalContext = context;
  }
  
  // 업적 달성 콜백 설정
  static void setOnAchievementUnlocked(VoidCallback callback) {
    _onAchievementUnlocked = callback;
  }
  
  // 통계 업데이트 콜백 설정
  static void setOnStatsUpdated(VoidCallback callback) {
    _onStatsUpdated = callback;
  }

  // 데이터베이스 getter (테스트용 데이터베이스가 있으면 우선 사용)
  static Future<Database> get database async {
    if (_testDatabase != null) return _testDatabase!;

    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'achievements.db');
    return await openDatabase(
      path, 
      version: 2, // 버전을 2로 업데이트
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  static Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        titleKey TEXT NOT NULL,
        descriptionKey TEXT NOT NULL,
        motivationKey TEXT NOT NULL,
        type TEXT NOT NULL,
        rarity TEXT NOT NULL,
        targetValue INTEGER NOT NULL,
        currentValue INTEGER DEFAULT 0,
        isUnlocked INTEGER DEFAULT 0,
        unlockedAt TEXT,
        xpReward INTEGER DEFAULT 0,
        icon INTEGER NOT NULL
      )
    ''');
  }

  // 데이터베이스 업그레이드 (기존 데이터 마이그레이션)
  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 기존 테이블 삭제하고 새로 생성 (데이터 손실 방지를 위해 백업 후 복원)
      await db.execute('DROP TABLE IF EXISTS ${tableName}_backup');
      
      // 기존 데이터가 있다면 백업
      try {
        await db.execute('ALTER TABLE $tableName RENAME TO ${tableName}_backup');
      } catch (e) {
        // 테이블이 없으면 무시
        debugPrint('기존 테이블이 없음: $e');
      }
      
      // 새 스키마로 테이블 생성
      await _createDatabase(db, newVersion);
      
      // 백업 테이블 삭제 (새로운 구조로 다시 초기화)
      try {
        await db.execute('DROP TABLE IF EXISTS ${tableName}_backup');
      } catch (e) {
        debugPrint('백업 테이블 삭제 실패: $e');
      }
      
      debugPrint('✅ 업적 데이터베이스 스키마 업그레이드 완료');
    }
  }

  // 초기화 - 미리 정의된 업적들 로드
  static Future<void> initialize() async {
    final db = await database;

    // 이미 초기화되었는지 확인
    final existingAchievements = await db.query(tableName, limit: 1);
    debugPrint('🔍 기존 업적 개수: ${existingAchievements.length}');
    
    if (existingAchievements.isNotEmpty) {
      debugPrint('✅ 업적이 이미 초기화되어 있음');
      return;
    }

    // 미리 정의된 업적들 추가
    debugPrint('🚀 업적 초기화 시작 - 총 ${PredefinedAchievements.all.length}개 업적');
    for (final achievement in PredefinedAchievements.all) {
      try {
        await db.insert(tableName, achievement.toMap());
        debugPrint('✅ 업적 추가: ${achievement.id}');
      } catch (e) {
        debugPrint('❌ 업적 추가 실패: ${achievement.id} - $e');
      }
    }
    debugPrint('🎉 업적 초기화 완료');
  }

  // 모든 업적 조회
  static Future<List<Achievement>> getAllAchievements() async {
    final timer = _startPerformanceTimer('getAllAchievements');
    
    try {
      // 캐시에서 먼저 확인
      if (_isCacheValid() && _achievementCache.isNotEmpty) {
        debugPrint('📂 캐시에서 업적 조회: ${_achievementCache.length}개');
        final achievements = _achievementCache.values.toList();
        _endPerformanceTimer('getAllAchievements_cached', timer);
        return achievements;
      }
      
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: 'rarity DESC, isUnlocked DESC, id ASC',
      );

      debugPrint('📊 데이터베이스에서 조회된 업적 개수: ${maps.length}');
      
      final achievements = List.generate(maps.length, (i) {
        try {
          return Achievement.fromMap(maps[i]);
        } catch (e) {
          debugPrint('❌ 업적 파싱 실패: ${maps[i]} - $e');
          rethrow;
        }
      });
      
      // 캐시 업데이트
      _achievementCache.clear();
      for (final achievement in achievements) {
        _updateCache(achievement);
      }
      
      debugPrint('✅ 성공적으로 파싱된 업적 개수: ${achievements.length}');
      return achievements;
    } finally {
      _endPerformanceTimer('getAllAchievements', timer);
    }
  }

  // 잠금 해제된 업적들만 조회
  static Future<List<Achievement>> getUnlockedAchievements() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'isUnlocked = ?',
      whereArgs: [1],
      orderBy: 'unlockedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Achievement.fromMap(maps[i]);
    });
  }

  // 잠금 해제되지 않은 업적들 조회
  static Future<List<Achievement>> getLockedAchievements() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'isUnlocked = ?',
      whereArgs: [0],
      orderBy: 'rarity DESC, currentValue DESC',
    );

    return List.generate(maps.length, (i) {
      return Achievement.fromMap(maps[i]);
    });
  }

  // 업적 진행도 업데이트 (최적화됨)
  static Future<void> updateAchievementProgress(
    String achievementId,
    int newValue,
  ) async {
    final timer = _startPerformanceTimer('updateAchievementProgress');
    
    try {
      // 캐시에서 현재 값 확인
      final cached = _getFromCache(achievementId);
      if (cached != null && cached.currentValue == newValue) {
        debugPrint('🔄 값 변경 없음, 업데이트 건너뜀: $achievementId');
        return;
      }
      
      final db = await database;
      await db.update(
        tableName,
        {'currentValue': newValue},
        where: 'id = ?',
        whereArgs: [achievementId],
      );
      
      // 캐시 업데이트
      if (cached != null) {
        final updated = cached.copyWith(currentValue: newValue);
        _updateCache(updated);
      }
      
      debugPrint('📈 업적 진행도 업데이트: $achievementId = $newValue');
    } finally {
      _endPerformanceTimer('updateAchievementProgress', timer);
    }
  }

  // 업적 잠금 해제
  static Future<Achievement?> unlockAchievement(String achievementId) async {
    final db = await database;

    // 이미 잠금 해제되었는지 확인
    final existing = await db.query(
      tableName,
      where: 'id = ? AND isUnlocked = ?',
      whereArgs: [achievementId, 1],
    );

    if (existing.isNotEmpty) return null; // 이미 잠금 해제됨

    // 잠금 해제
    await db.update(
      tableName,
      {'isUnlocked': 1, 'unlockedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [achievementId],
    );

    // 업데이트된 업적 반환
    final updated = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [achievementId],
    );

    if (updated.isNotEmpty) {
      final achievement = Achievement.fromMap(updated.first);

      // 🔥 업적 달성 알림 전송
      try {
        debugPrint('🏆 업적 달성: ${achievement.titleKey}');
        
        // 업적 달성 이벤트 저장 (다이얼로그 표시용)
        await _saveAchievementEvent(achievement);
        
        // 실시간 알림 표시 (현지화 키 사용)
        await NotificationService.showAchievementNotification(
          achievement.titleKey,
          achievement.descriptionKey,
        );
        
        // 업적 달성 콜백 호출 (UI 업데이트용)
        _onAchievementUnlocked?.call();
        
        // 통계 업데이트 콜백 호출
        _onStatsUpdated?.call();
        
      } catch (e) {
        debugPrint('⚠️ 업적 알림 전송 실패: $e');
      }

      return achievement;
    }
    return null;
  }

  // 운동 기록 기반으로 업적 진행도 체크 및 업데이트 (최적화됨)
  static Future<List<Achievement>> checkAndUpdateAchievements() async {
    final overallTimer = _startPerformanceTimer('checkAndUpdateAchievements_full');
    debugPrint('🏆 업적 체크 및 업데이트 시작');
    
    final List<Achievement> newlyUnlocked = [];
    
    try {
      // 상태 백업
      await _backupState();
      
      // 데이터 수집 (캐시 활용)
      final dataTimer = _startPerformanceTimer('data_collection');
      final workouts = await WorkoutHistoryService.getAllWorkouts();
      debugPrint('📊 WorkoutHistoryService에서 조회된 운동 기록: ${workouts.length}개');
      
      final statistics = await WorkoutHistoryService.getStatistics();
      debugPrint('📈 운동 통계: $statistics');
      
      final currentStreak = await WorkoutHistoryService.getCurrentStreak();
      debugPrint('🔥 현재 스트릭: $currentStreak일');
      _endPerformanceTimer('data_collection', dataTimer);

      // 캐시된 업적 조회
      final achievementsTimer = _startPerformanceTimer('achievements_loading');
      final currentAchievements = await getAllAchievements();
      final unlockedAchievements = Set<String>.from(
        currentAchievements.where((a) => a.isUnlocked).map((a) => a.id)
      );
      _endPerformanceTimer('achievements_loading', achievementsTimer);

      // 업적 처리 (배치 처리 준비)
      final processingTimer = _startPerformanceTimer('achievements_processing');
      int processedAchievements = 0;
      final List<Map<String, dynamic>> batchUpdates = [];
      
      for (final achievement in PredefinedAchievements.all) {
        try {
          if (unlockedAchievements.contains(achievement.id)) {
            debugPrint('✅ 업적 ${achievement.id}는 이미 잠금 해제됨');
            continue;
          }

          int currentValue = 0;

          // 업적 타입별 계산 (최적화된 메서드 사용)
          switch (achievement.type) {
            case AchievementType.first:
              currentValue = await _checkFirstAchievements(achievement, workouts);
              break;
            case AchievementType.streak:
              currentValue = currentStreak;
              break;
            case AchievementType.volume:
              currentValue = statistics['totalReps'] as int? ?? 0;
              break;
            case AchievementType.perfect:
              currentValue = await _checkPerfectAchievements(workouts);
              break;
            case AchievementType.special:
              currentValue = await _checkSpecialAchievements(achievement, workouts);
              break;
            case AchievementType.challenge:
              currentValue = await _checkChallengeAchievements(achievement);
              break;
            case AchievementType.statistics:
              currentValue = await _checkStatisticsAchievements(achievement, workouts);
              break;
          }

          debugPrint('🎯 업적 ${achievement.id}: 현재 값 = $currentValue, 목표 값 = ${achievement.targetValue}');

          // 배치 업데이트에 추가 (즉시 업데이트 대신)
          batchUpdates.add({
            'id': achievement.id,
            'currentValue': currentValue,
            'targetValue': achievement.targetValue,
          });

          // 달성 조건 체크
          if (currentValue >= achievement.targetValue) {
            debugPrint('🎉 업적 달성! ${achievement.id}');
            final unlockedAchievement = await unlockAchievement(achievement.id);
            if (unlockedAchievement != null) {
              newlyUnlocked.add(unlockedAchievement);
              debugPrint('🔓 업적 잠금 해제 성공: ${achievement.id}');
            } else {
              debugPrint('❌ 업적 잠금 해제 실패: ${achievement.id}');
            }
          }
          
          processedAchievements++;
        } catch (e) {
          debugPrint('❌ 업적 ${achievement.id} 처리 중 오류: $e');
          // 개별 업적 오류는 전체 처리를 중단하지 않음
        }
      }
      _endPerformanceTimer('achievements_processing', processingTimer);

      // 배치 업데이트 실행
      if (batchUpdates.isNotEmpty) {
        final batchTimer = _startPerformanceTimer('batch_updates');
        await _executeBatchUpdates(batchUpdates);
        _endPerformanceTimer('batch_updates', batchTimer);
      }

      debugPrint('✅ 업적 체크 완료: ${processedAchievements}개 처리, ${newlyUnlocked.length}개 새로 잠금 해제');
      
      // 성능 통계 출력
      if (_enablePerformanceLogging) {
        final stats = getPerformanceStats();
        debugPrint('📊 성능 통계: $stats');
      }
      
    } catch (e) {
      debugPrint('❌ 업적 체크 및 업데이트 중 치명적 오류: $e');
      debugPrint('스택 트레이스: ${StackTrace.current}');
      
      // 오류 발생 시 백업 상태로 복구 시도
      final restored = await _restoreState();
      if (restored) {
        debugPrint('✅ 백업 상태로 복구 완료');
      }
    } finally {
      _endPerformanceTimer('checkAndUpdateAchievements_full', overallTimer);
    }

    return newlyUnlocked;
  }

  /// 배치 업데이트 실행
  static Future<void> _executeBatchUpdates(List<Map<String, dynamic>> updates) async {
    if (updates.isEmpty) return;
    
    try {
      final db = await database;
      await db.transaction((txn) async {
        for (final update in updates) {
          await txn.update(
            tableName,
            {'currentValue': update['currentValue']},
            where: 'id = ?',
            whereArgs: [update['id']],
          );
          
          // 캐시 업데이트
          final cached = _getFromCache(update['id'] as String);
          if (cached != null) {
            final updated = cached.copyWith(currentValue: update['currentValue'] as int?);
            _updateCache(updated);
          }
        }
      });
      
      debugPrint('✅ 배치 업데이트 완료: ${updates.length}개 업적');
    } catch (e) {
      debugPrint('❌ 배치 업데이트 실패: $e');
      rethrow;
    }
  }

  // 첫 번째 달성 업적 체크
  static Future<int> _checkFirstAchievements(
    Achievement achievement,
    List<WorkoutHistory> workouts,
  ) async {
    switch (achievement.id) {
      case 'first_workout':
        return workouts.isNotEmpty ? 1 : 0;
        
      case 'first_50_pushups':
        // 한 번의 운동에서 50개 이상 완료했는지 확인
        for (final workout in workouts) {
          final totalReps = workout.completedReps.fold<int>(0, (sum, reps) => sum + reps);
          if (totalReps >= 50) {
            return 1;
          }
        }
        return 0;
        
      case 'first_100_single':
        // 한 번의 운동에서 100개 이상 완료했는지 확인
        for (final workout in workouts) {
          final totalReps = workout.completedReps.fold<int>(0, (sum, reps) => sum + reps);
          if (totalReps >= 100) {
            return 1;
          }
        }
        return 0;
        
      case 'first_level_up':
        // 레벨 5 달성 여부 확인 (Chad Evolution 시스템과 연동)
        try {
          final currentLevel = await ChadEvolutionService.getCurrentLevel();
          return currentLevel >= 5 ? 1 : 0;
        } catch (e) {
          debugPrint('❌ 레벨 확인 중 오류: $e');
          return 0;
        }
        
      default:
        return 0;
    }
  }

  // 완벽 수행 업적 체크
  static Future<int> _checkPerfectAchievements(
    List<WorkoutHistory> workouts,
  ) async {
    int perfectCount = 0;
    for (final workout in workouts) {
      if (workout.completionRate >= 1.0) {
        perfectCount++;
      }
    }
    return perfectCount;
  }

  // 특별 업적 체크 (시간대 고려 개선)
  static Future<int> _checkSpecialAchievements(
    Achievement achievement,
    List<WorkoutHistory> workouts,
  ) async {
    switch (achievement.id) {
      case 'tutorial_explorer':
      case 'tutorial_student':
      case 'tutorial_master':
        // 튜토리얼 조회 횟수는 별도 저장소에서 관리
        return await _getTutorialViewCount();

      case 'weekend_warrior':
        int weekendWorkouts = 0;
        for (final workout in workouts) {
          final weekday = workout.date.weekday;
          if (weekday == 6 || weekday == 7) {
            // 토요일, 일요일
            weekendWorkouts++;
          }
        }
        return weekendWorkouts;

      case 'early_bird':
        int earlyWorkouts = 0;
        for (final workout in workouts) {
          // 로컬 시간으로 7시 전 체크
          final localHour = workout.date.hour;
          if (localHour < 7) {
            earlyWorkouts++;
          }
        }
        return earlyWorkouts;

      case 'night_owl':
        int nightWorkouts = 0;
        for (final workout in workouts) {
          // 로컬 시간으로 22시 이후 체크
          final localHour = workout.date.hour;
          if (localHour >= 22) {
            nightWorkouts++;
          }
        }
        return nightWorkouts;

      case 'lunch_break_chad':
        int lunchWorkouts = 0;
        for (final workout in workouts) {
          // 점심시간 (12시-14시) 체크
          final localHour = workout.date.hour;
          if (localHour >= 12 && localHour < 14) {
            lunchWorkouts++;
          }
        }
        return lunchWorkouts;

      case 'speed_demon':
        // 5분 이내에 50개 이상 완료한 적이 있는지 체크
        for (final workout in workouts) {
          final totalReps = workout.completedReps.fold<int>(0, (sum, reps) => sum + reps);
          // 총 운동 시간이 5분 이하이고 50개 이상 완료했는지 확인
          if (totalReps >= 50 && workout.duration.inMinutes <= 5) {
            return 1;
          }
        }
        return 0;

      case 'endurance_king':
        // 30분 이상 운동한 적이 있는지 체크
        for (final workout in workouts) {
          if (workout.duration.inMinutes >= 30) {
            return 1;
          }
        }
        return 0;

      case 'comeback_kid':
        // 7일 이상 쉬고 다시 운동한 적이 있는지 체크
        if (workouts.length >= 2) {
          final sortedWorkouts = List<WorkoutHistory>.from(workouts)
            ..sort((a, b) => a.date.compareTo(b.date));
          
          for (int i = 1; i < sortedWorkouts.length; i++) {
            final gap = sortedWorkouts[i].date.difference(sortedWorkouts[i-1].date).inDays;
            if (gap >= 7) {
              return 1; // 7일 이상 쉬고 복귀
            }
          }
        }
        return 0;

      case 'overachiever':
        // 목표의 150% 이상을 5번 달성했는지 체크
        int overachieverCount = 0;
        for (final workout in workouts) {
          if (workout.completionRate >= 1.5) {
            overachieverCount++;
          }
        }
        return overachieverCount >= 5 ? 1 : 0;

      case 'double_trouble':
        // 목표의 200% 이상을 달성한 적이 있는지 체크
        for (final workout in workouts) {
          if (workout.completionRate >= 2.0) {
            return 1;
          }
        }
        return 0;

      case 'consistency_master':
        // 연속 10일 동안 정확히 목표 달성했는지 체크
        if (workouts.length >= 10) {
          final sortedWorkouts = List<WorkoutHistory>.from(workouts)
            ..sort((a, b) => b.date.compareTo(a.date)); // 최신순 정렬
          
          int consecutiveExactDays = 0;
          DateTime? lastDate;
          
          for (final workout in sortedWorkouts) {
            // 완료율이 100%~105% 사이인지 체크 (정확한 목표 달성)
            if (workout.completionRate >= 1.0 && workout.completionRate <= 1.05) {
              if (lastDate == null || 
                  lastDate.difference(workout.date).inDays == 1) {
                consecutiveExactDays++;
                lastDate = workout.date;
                
                if (consecutiveExactDays >= 10) {
                  return 1;
                }
              } else {
                consecutiveExactDays = 1; // 연속성이 깨짐, 다시 시작
                lastDate = workout.date;
              }
            } else {
              consecutiveExactDays = 0; // 정확하지 않은 달성
              lastDate = null;
            }
          }
        }
        return 0;

      default:
        return 0;
    }
  }

  // 튜토리얼 조회 횟수 저장 및 조회
  static Future<void> incrementTutorialViewCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt('tutorial_view_count') ?? 0;
    await prefs.setInt('tutorial_view_count', currentCount + 1);
  }

  static Future<int> _getTutorialViewCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('tutorial_view_count') ?? 0;
  }

  // 업적이 이미 잠금 해제되었는지 확인
  static Future<bool> _isAchievementUnlocked(String achievementId) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'id = ? AND isUnlocked = ?',
      whereArgs: [achievementId, 1],
    );
    return result.isNotEmpty;
  }

  // 총 XP 계산
  static Future<int> getTotalXP() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(xpReward) as totalXP 
      FROM $tableName 
      WHERE isUnlocked = 1
    ''');

    if (result.isNotEmpty && result.first['totalXP'] != null) {
      return result.first['totalXP'] as int;
    }
    return 0;
  }

  // 잠금 해제된 업적 개수
  static Future<int> getUnlockedCount() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM $tableName 
      WHERE isUnlocked = 1
    ''');

    if (result.isNotEmpty) {
      return result.first['count'] as int;
    }
    return 0;
  }

  // 전체 업적 개수
  static Future<int> getTotalCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName',
    );

    if (result.isNotEmpty) {
      return result.first['count'] as int;
    }
    return 0;
  }

  // 레어도별 잠금 해제된 업적 개수
  static Future<Map<AchievementRarity, int>> getUnlockedCountByRarity() async {
    final achievements = await getUnlockedAchievements();
    final Map<AchievementRarity, int> rarityCount = {};

    for (final rarity in AchievementRarity.values) {
      rarityCount[rarity] = achievements
          .where((achievement) => achievement.rarity == rarity)
          .length;
    }

    return rarityCount;
  }

  // 업적 달성 이벤트 저장 (다이얼로그 표시용)
  static Future<void> _saveAchievementEvent(Achievement achievement) async {
    final prefs = await SharedPreferences.getInstance();
    final events = prefs.getStringList('pending_achievement_events') ?? [];
    
    // 업적 정보를 JSON 문자열로 저장
    final eventData = {
      'id': achievement.id,
      'titleKey': achievement.titleKey,
      'descriptionKey': achievement.descriptionKey,
      'motivationKey': achievement.motivationKey,
      'icon': achievement.icon.codePoint,
      'rarity': achievement.rarity.name,
      'xpReward': achievement.xpReward,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    events.add(jsonEncode(eventData));
    await prefs.setStringList('pending_achievement_events', events);
    
    debugPrint('💾 업적 달성 이벤트 저장: ${achievement.titleKey}');
  }

  // 대기 중인 업적 달성 이벤트 조회
  static Future<List<Map<String, dynamic>>> getPendingAchievementEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final events = prefs.getStringList('pending_achievement_events') ?? [];
    
    final List<Map<String, dynamic>> parsedEvents = [];
    for (final eventStr in events) {
      try {
        final eventData = jsonDecode(eventStr) as Map<String, dynamic>;
        parsedEvents.add(eventData);
      } catch (e) {
        debugPrint('⚠️ 업적 이벤트 파싱 실패: $e');
      }
    }
    
    return parsedEvents;
  }

  // 업적 달성 이벤트 클리어
  static Future<void> clearPendingAchievementEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_achievement_events');
    debugPrint('🧹 업적 달성 이벤트 클리어');
  }

  // 모든 업적 데이터베이스 초기화 (데이터 초기화용)
  static Future<void> resetAchievementDatabase() async {
    try {
      debugPrint('🔄 업적 데이터베이스 완전 재설정 시작...');
      
      // 1. 모든 static 참조 완전히 초기화
      _database = null;
      _testDatabase = null;
      _achievementCache.clear();
      _lastCacheUpdate = null;
      _pendingUpdates.clear();
      _isBatchProcessing = false;
      _lastKnownState = null;
      debugPrint('📱 모든 static 참조 초기화 완료');
      
      // 2. 데이터베이스 파일 경로 확인
      final String path = join(await getDatabasesPath(), 'achievements.db');
      debugPrint('📂 데이터베이스 경로: $path');
      
      // 3. 파일이 존재하면 삭제 시도
      final file = File(path);
      if (await file.exists()) {
        try {
          await file.delete();
          debugPrint('🗑️ 기존 데이터베이스 파일 삭제 완료');
        } catch (e) {
          debugPrint('⚠️ 파일 삭제 실패, 계속 진행: $e');
        }
      }
      
      // 4. SharedPreferences 정리
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('tutorial_view_count');
      await prefs.remove('pending_achievement_events');
      debugPrint('🧹 SharedPreferences 데이터 정리 완료');
      
      // 5. 새 데이터베이스 생성 및 초기화 (강제)
      debugPrint('🔨 새 데이터베이스 생성 시작...');
      _database = await openDatabase(
        path,
        version: 2,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
      
      // 6. 업적 강제 초기화
      await _forceInitializeAchievements();
      
      debugPrint('✅ 업적 데이터베이스 완전 재설정 완료');
      
    } catch (e) {
      debugPrint('❌ 데이터 재설정 오류: $e');
      
      // 실패 시 대안: 테이블만 삭제하고 재생성
      try {
        debugPrint('🔄 대안 방법: 테이블 재생성 시도...');
        await _fallbackReset();
      } catch (fallbackError) {
        debugPrint('❌ 대안 방법도 실패: $fallbackError');
        rethrow;
      }
    }
  }
  
  // 대안 리셋 방법: 테이블만 재생성
  static Future<void> _fallbackReset() async {
    try {
      final db = await database;
      
      // 테이블 삭제 후 재생성
      await db.execute('DROP TABLE IF EXISTS $tableName');
      await _createDatabase(db, 2);
      await _forceInitializeAchievements();
      
      debugPrint('✅ 대안 방법으로 리셋 완료');
    } catch (e) {
      debugPrint('❌ 대안 방법 실패: $e');
      rethrow;
    }
  }

  // 강제 업적 초기화 (오류 무시)
  static Future<void> _forceInitializeAchievements() async {
    try {
      final db = await database;
      
      debugPrint('🚀 업적 강제 초기화 시작 - 총 ${PredefinedAchievements.all.length}개 업적');
      
      // 트랜잭션으로 일괄 처리
      await db.transaction((txn) async {
        for (final achievement in PredefinedAchievements.all) {
          try {
            await txn.insert(
              tableName, 
              achievement.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace, // 중복 시 교체
            );
            debugPrint('✅ 업적 추가: ${achievement.id}');
          } catch (e) {
            debugPrint('⚠️ 업적 ${achievement.id} 추가 실패 (계속 진행): $e');
          }
        }
      });
      
      // 검증
      final count = await getTotalCount();
      debugPrint('🎉 업적 강제 초기화 완료: $count개 업적 추가됨');
      
    } catch (e) {
      debugPrint('❌ 강제 초기화 실패: $e');
      rethrow;
    }
  }

  // 업적 업데이트 (복원용)
  static Future<void> saveAchievement(Achievement achievement) async {
    final db = await database;
    await db.insert(
      tableName,
      achievement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('💾 업적 저장: ${achievement.id}');
  }

  // 챌린지 업적 체크
  static Future<int> _checkChallengeAchievements(Achievement achievement) async {
    final prefs = await SharedPreferences.getInstance();
    
    switch (achievement.id) {
      case 'challenge_7_days':
        // 7일 연속 챌린지 완료 여부 확인
        return prefs.getBool('challenge_7_days_completed') == true ? 1 : 0;
        
      case 'challenge_50_single':
        // 50개 한번에 챌린지 완료 여부 확인
        return prefs.getBool('challenge_50_single_completed') == true ? 1 : 0;
        
      case 'challenge_100_cumulative':
        // 100개 누적 챌린지 완료 여부 확인
        return prefs.getBool('challenge_100_cumulative_completed') == true ? 1 : 0;
        
      case 'challenge_200_cumulative':
        // 200개 누적 챌린지 완료 여부 확인
        return prefs.getBool('challenge_200_cumulative_completed') == true ? 1 : 0;
        
      case 'challenge_14_days':
        // 14일 연속 챌린지 완료 여부 확인
        return prefs.getBool('challenge_14_days_completed') == true ? 1 : 0;
        
      case 'challenge_master':
        // 모든 챌린지 완료 개수 확인
        int completedCount = 0;
        if (prefs.getBool('challenge_7_days_completed') == true) completedCount++;
        if (prefs.getBool('challenge_50_single_completed') == true) completedCount++;
        if (prefs.getBool('challenge_100_cumulative_completed') == true) completedCount++;
        if (prefs.getBool('challenge_200_cumulative_completed') == true) completedCount++;
        if (prefs.getBool('challenge_14_days_completed') == true) completedCount++;
        return completedCount;
        
      default:
        return 0;
    }
  }

  // 챌린지 완료 시 호출되는 메서드 (ChallengeService에서 사용)
  static Future<void> markChallengeCompleted(String challengeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${challengeId}_completed', true);
    
    // 업적 체크 및 업데이트
    await checkAndUpdateAchievements();
  }

  // 통계 기반 업적 체크
  static Future<int> _checkStatisticsAchievements(
    Achievement achievement,
    List<WorkoutHistory> workouts,
  ) async {
    if (workouts.isEmpty) return 0;

    switch (achievement.id) {
      // 평균 완료율 관련 업적
      case 'completion_rate_80':
      case 'completion_rate_90': 
      case 'completion_rate_95':
        final totalCompletionRate = workouts.fold<double>(0, (sum, workout) => sum + workout.completionRate);
        final averageCompletionRate = (totalCompletionRate / workouts.length * 100);
        debugPrint('평균 완료율: ${averageCompletionRate.round()}%');
        return averageCompletionRate.round();

      // 총 운동 시간 관련 업적 (분 단위)
      case 'total_workout_time_60':
      case 'total_workout_time_300':
      case 'total_workout_time_600':
      case 'total_workout_time_1200':
        final totalMinutes = workouts.fold<int>(0, (sum, workout) => sum + workout.duration.inMinutes);
        debugPrint('총 운동 시간: ${totalMinutes}분');
        return totalMinutes;

      // 주간 운동 횟수 (최근 7일)
      case 'weekly_sessions_5':
      case 'weekly_sessions_7':
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        final weeklyWorkouts = workouts.where((w) => w.date.isAfter(weekAgo)).length;
        debugPrint('주간 운동 횟수: ${weeklyWorkouts}회');
        return weeklyWorkouts;

      // 월간 운동 횟수 (최근 30일)
      case 'monthly_sessions_20':
      case 'monthly_sessions_30':
        final now = DateTime.now();
        final monthAgo = now.subtract(const Duration(days: 30));
        final monthlyWorkouts = workouts.where((w) => w.date.isAfter(monthAgo)).length;
        debugPrint('월간 운동 횟수: ${monthlyWorkouts}회');
        return monthlyWorkouts;

      // 튜토리얼 조회 관련 업적
      case 'weekly_tutorial_views_5':
      case 'weekly_tutorial_views_10':
        return await _getTutorialViewCount();

      default:
        return 0;
    }
  }

  // 업적 데이터베이스 무결성 검증
  static Future<Map<String, dynamic>> validateAchievementDatabase() async {
    final Map<String, dynamic> validation = {
      'isValid': true,
      'issues': <String>[],
      'stats': <String, dynamic>{},
    };

    try {
      final db = await database;
      
      // 1. 테이블 존재 확인
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'"
      );
      if (tables.isEmpty) {
        validation['isValid'] = false;
        (validation['issues'] as List<String>).add('업적 테이블이 존재하지 않습니다');
        return validation;
      }

      // 2. 기본 업적 개수 확인
      final totalCount = await getTotalCount();
      final expectedCount = PredefinedAchievements.all.length;
      validation['stats']['totalCount'] = totalCount;
      validation['stats']['expectedCount'] = expectedCount;
      
      if (totalCount != expectedCount) {
        validation['isValid'] = false;
        (validation['issues'] as List<String>).add('업적 개수 불일치: 예상 ${expectedCount}개, 실제 ${totalCount}개');
      }

      // 3. 중복 ID 확인
      final duplicateIds = await db.rawQuery('''
        SELECT id, COUNT(*) as count 
        FROM $tableName 
        GROUP BY id 
        HAVING COUNT(*) > 1
      ''');
      if (duplicateIds.isNotEmpty) {
        validation['isValid'] = false;
        for (final row in duplicateIds) {
          (validation['issues'] as List<String>).add('중복 ID 발견: ${row['id']} (${row['count']}개)');
        }
      }

      // 4. 필수 필드 검증
      final incompleteAchievements = await db.rawQuery('''
        SELECT id FROM $tableName 
        WHERE titleKey IS NULL OR descriptionKey IS NULL OR targetValue IS NULL OR xpReward IS NULL
      ''');
      if (incompleteAchievements.isNotEmpty) {
        validation['isValid'] = false;
        for (final row in incompleteAchievements) {
          (validation['issues'] as List<String>).add('불완전한 업적 데이터: ${row['id']}');
        }
      }

      // 5. 잠금 해제된 업적 통계
      final unlockedCount = await getUnlockedCount();
      validation['stats']['unlockedCount'] = unlockedCount;
      validation['stats']['completionRate'] = (unlockedCount / totalCount * 100).toStringAsFixed(1);

      // 6. 진행도 값 검증 (음수나 비정상적인 값 확인)
      final invalidProgress = await db.rawQuery('''
        SELECT id, currentValue, targetValue 
        FROM $tableName 
        WHERE currentValue < 0 OR (currentValue > targetValue AND isUnlocked = 0)
      ''');
      if (invalidProgress.isNotEmpty) {
        for (final row in invalidProgress) {
          (validation['issues'] as List<String>).add('비정상적인 진행도: ${row['id']} (${row['currentValue']}/${row['targetValue']})');
        }
      }

      // 7. 타입 및 레어도 검증
      final invalidTypes = await db.rawQuery('''
        SELECT id, type, rarity 
        FROM $tableName 
        WHERE type NOT IN ('first', 'streak', 'volume', 'perfect', 'special', 'challenge')
        OR rarity NOT IN ('common', 'rare', 'epic', 'legendary')
      ''');
      if (invalidTypes.isNotEmpty) {
        for (final row in invalidTypes) {
          (validation['issues'] as List<String>).add('잘못된 타입/레어도: ${row['id']} (${row['type']}, ${row['rarity']})');
        }
      }

      debugPrint('🔍 업적 데이터베이스 검증 완료');
      debugPrint('📊 총 업적: ${validation['stats']['totalCount']}/${validation['stats']['expectedCount']}');
      debugPrint('🔓 잠금 해제: ${validation['stats']['unlockedCount']}개 (${validation['stats']['completionRate']}%)');
      
      final issues = validation['issues'] as List<String>? ?? <String>[];
      if (issues.isNotEmpty) {
        debugPrint('⚠️ 발견된 문제점들:');
        for (final issue in issues) {
          debugPrint('  - $issue');
        }
      } else {
        debugPrint('✅ 모든 검증 통과');
      }

    } catch (e) {
      validation['isValid'] = false;
      (validation['issues'] as List<String>).add('검증 중 오류 발생: $e');
      debugPrint('❌ 업적 데이터베이스 검증 실패: $e');
    }

    return validation;
  }

  // 업적 데이터베이스 복구 시도
  static Future<bool> repairAchievementDatabase() async {
    try {
      debugPrint('🔧 업적 데이터베이스 복구 시작');
      
      // 1. 검증 실행
      final validation = await validateAchievementDatabase();
      if ((validation['isValid'] as bool?) == true) {
        debugPrint('✅ 복구 불필요: 데이터베이스가 정상 상태입니다');
        return true;
      }

      final db = await database;
      
      // 2. 중복 항목 제거
      debugPrint('🧹 중복 항목 제거 중...');
      await db.rawQuery('''
        DELETE FROM $tableName 
        WHERE rowid NOT IN (
          SELECT MIN(rowid) 
          FROM $tableName 
          GROUP BY id
        )
      ''');

      // 3. 누락된 업적 추가
      debugPrint('📝 누락된 업적 추가 중...');
      final existingIds = await db.rawQuery('SELECT DISTINCT id FROM $tableName');
      final existingIdSet = existingIds.map((row) => row['id'] as String).toSet();
      
      for (final achievement in PredefinedAchievements.all) {
        if (!existingIdSet.contains(achievement.id)) {
          await db.insert(
            tableName,
            achievement.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
          debugPrint('✅ 누락된 업적 추가: ${achievement.id}');
        }
      }

      // 4. 비정상적인 진행도 수정
      debugPrint('🔄 진행도 데이터 수정 중...');
      await db.rawQuery('UPDATE $tableName SET currentValue = 0 WHERE currentValue < 0');
      
      // 5. 재검증
      final revalidation = await validateAchievementDatabase();
      final isRevalidationValid = revalidation['isValid'] as bool? ?? false;
      if (isRevalidationValid) {
        debugPrint('✅ 업적 데이터베이스 복구 완료');
        return true;
      } else {
        debugPrint('❌ 복구 후에도 문제가 남아있습니다');
        return false;
      }

    } catch (e) {
      debugPrint('❌ 업적 데이터베이스 복구 실패: $e');
      return false;
    }
  }

  // 업적 진행도 동기화 (WorkoutHistory 기반으로 재계산)
  static Future<void> synchronizeAchievementProgress() async {
    try {
      debugPrint('🔄 업적 진행도 동기화 시작');
      
      final workouts = await WorkoutHistoryService.getAllWorkouts();
      final statistics = await WorkoutHistoryService.getStatistics();
      final currentStreak = await WorkoutHistoryService.getCurrentStreak();
      
      debugPrint('📊 기준 데이터: 운동 ${workouts.length}회, 스트릭 ${currentStreak}일');
      
      // 모든 업적의 진행도를 다시 계산
      for (final achievement in PredefinedAchievements.all) {
        try {
          int currentValue = 0;
          
          switch (achievement.type) {
            case AchievementType.first:
              currentValue = await _checkFirstAchievements(achievement, workouts);
              break;
            case AchievementType.streak:
              currentValue = currentStreak;
              break;
            case AchievementType.volume:
              currentValue = statistics['totalReps'] as int? ?? 0;
              break;
            case AchievementType.perfect:
              currentValue = await _checkPerfectAchievements(workouts);
              break;
            case AchievementType.special:
              currentValue = await _checkSpecialAchievements(achievement, workouts);
              break;
            case AchievementType.challenge:
              currentValue = await _checkChallengeAchievements(achievement);
              break;
            case AchievementType.statistics:
              currentValue = await _checkStatisticsAchievements(achievement, workouts);
              break;
          }

          // 진행도 업데이트 (잠금 해제 상태는 유지)
          await updateAchievementProgress(achievement.id, currentValue);
          
          debugPrint('🔄 ${achievement.id}: $currentValue/${achievement.targetValue}');
          
        } catch (e) {
          debugPrint('❌ ${achievement.id} 동기화 실패: $e');
        }
      }
      
      debugPrint('✅ 업적 진행도 동기화 완료');
      
    } catch (e) {
      debugPrint('❌ 업적 진행도 동기화 실패: $e');
    }
  }

  // ================================
  // 운동 완료 관련 메서드들  
  // ================================
  
  /// 운동 완료 기록 및 자동 업적 체크
  static Future<void> recordWorkoutCompleted(int totalReps, double completionRate) async {
    try {
      debugPrint('📝 운동 완료 기록: ${totalReps}개, 완료율: ${(completionRate * 100).round()}%');
      
      // SharedPreferences에 운동 기록 저장
      final prefs = await SharedPreferences.getInstance();
      
      // 총 운동 횟수 증가
      final totalWorkouts = prefs.getInt('total_workouts') ?? 0;
      await prefs.setInt('total_workouts', totalWorkouts + 1);
      
      // 총 푸시업 개수 증가
      final totalPushups = prefs.getInt('total_pushups') ?? 0;
      await prefs.setInt('total_pushups', totalPushups + totalReps);
      
      debugPrint('✅ 운동 기록 저장 완료 - 총 ${totalWorkouts + 1}회, 총 ${totalPushups + totalReps}개');
      
      // 업적 체크 및 업데이트
      await checkAndUpdateAchievements();
      
    } catch (e) {
      debugPrint('❌ 운동 완료 기록 실패: $e');
    }
  }

  // === 성능 모니터링 유틸리티 ===
  
  /// 성능 메트릭 시작 측정
  static Stopwatch _startPerformanceTimer(String operation) {
    if (!_enablePerformanceLogging) return Stopwatch();
    final stopwatch = Stopwatch()..start();
    debugPrint('⏱️ 성능 측정 시작: $operation');
    return stopwatch;
  }
  
  /// 성능 메트릭 종료 및 기록
  static void _endPerformanceTimer(String operation, Stopwatch stopwatch) {
    if (!_enablePerformanceLogging) return;
    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;
    
    _performanceMetrics.putIfAbsent(operation, () => []);
    _performanceMetrics[operation]!.add(duration);
    
    // 최근 10개 기록만 유지
    if (_performanceMetrics[operation]!.length > 10) {
      _performanceMetrics[operation]!.removeAt(0);
    }
    
    debugPrint('📊 성능 측정 완료: $operation - ${duration}ms');
    
    // 경고 임계값 확인 (500ms 이상)
    if (duration > 500) {
      debugPrint('⚠️ 성능 경고: $operation이 ${duration}ms 소요됨');
    }
  }
  
  /// 성능 통계 조회
  static Map<String, Map<String, double>> getPerformanceStats() {
    final stats = <String, Map<String, double>>{};
    
    for (final entry in _performanceMetrics.entries) {
      final times = entry.value;
      if (times.isEmpty) continue;
      
      final avg = times.reduce((a, b) => a + b) / times.length;
      final min = times.reduce((a, b) => a < b ? a : b).toDouble();
      final max = times.reduce((a, b) => a > b ? a : b).toDouble();
      
      stats[entry.key] = {
        'average': avg,
        'min': min,
        'max': max,
        'count': times.length.toDouble(),
      };
    }
    
    return stats;
  }
  
  // === 캐싱 관리 ===
  
  /// 캐시 유효성 확인
  static bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidDuration;
  }
  
  /// 캐시 무효화
  static void _invalidateCache() {
    _achievementCache.clear();
    _lastCacheUpdate = null;
    debugPrint('🗑️ 업적 캐시 무효화');
  }
  
  /// 캐시에서 업적 조회
  static Achievement? _getFromCache(String achievementId) {
    if (!_isCacheValid()) return null;
    return _achievementCache[achievementId];
  }
  
  /// 캐시에 업적 저장
  static void _updateCache(Achievement achievement) {
    _achievementCache[achievement.id] = achievement;
    _lastCacheUpdate = DateTime.now();
  }
  
  // === 배치 처리 ===
  
  /// 업데이트를 배치 처리 대기열에 추가
  static void _addToBatch(String achievementId, int newValue) {
    _pendingUpdates.add({
      'id': achievementId,
      'value': newValue,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    debugPrint('📝 배치 대기열에 추가: $achievementId = $newValue (대기열 크기: ${_pendingUpdates.length})');
    
    // 배치 크기에 도달하면 처리
    if (_pendingUpdates.length >= _batchSize) {
      _processBatch();
    }
  }
  
  /// 배치 처리 실행
  static Future<void> _processBatch() async {
    if (_isBatchProcessing || _pendingUpdates.isEmpty) return;
    
    _isBatchProcessing = true;
    final timer = _startPerformanceTimer('batch_processing');
    
    try {
      debugPrint('🔄 배치 처리 시작: ${_pendingUpdates.length}개 업데이트');
      
      final db = await database;
      await db.transaction((txn) async {
        for (final update in _pendingUpdates) {
          final updateValue = update['value'] as int? ?? 0;
          final updateId = update['id'] as String? ?? '';
          await txn.update(
            tableName,
            {'currentValue': updateValue},
            where: 'id = ?',
            whereArgs: [updateId],
          );
        }
      });
      
      // 캐시 업데이트
      for (final update in _pendingUpdates) {
        final updateId = update['id'] as String? ?? '';
        final updateValue = update['value'] as int? ?? 0;
        final cached = _getFromCache(updateId);
        if (cached != null) {
          final updated = cached.copyWith(currentValue: updateValue);
          _updateCache(updated);
        }
      }
      
      debugPrint('✅ 배치 처리 완료: ${_pendingUpdates.length}개 업데이트');
      _pendingUpdates.clear();
      
    } catch (e) {
      debugPrint('❌ 배치 처리 실패: $e');
      // 실패한 업데이트는 개별 처리로 재시도
      await _retryFailedUpdates();
    } finally {
      _isBatchProcessing = false;
      _endPerformanceTimer('batch_processing', timer);
    }
  }
  
  /// 실패한 업데이트 재시도
  static Future<void> _retryFailedUpdates() async {
    debugPrint('🔄 실패한 업데이트 개별 재시도 시작');
    final failedUpdates = List.from(_pendingUpdates);
    _pendingUpdates.clear();
    
    for (final update in failedUpdates) {
      try {
        final value = update['value'] as int? ?? 0;
        final id = update['id'] as String? ?? '';
        await updateAchievementProgress(id, value);
        debugPrint('✅ 재시도 성공: $id');
      } catch (e) {
        debugPrint('❌ 재시도 실패: ${update['id']} - $e');
      }
    }
  }
  
  // === 상태 백업 및 복구 ===
  
  /// 현재 상태 백업
  static Future<void> _backupState() async {
    try {
      final achievements = await getAllAchievements();
      _lastKnownState = {
        'achievements': achievements.map((a) => a.toMap()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      debugPrint('💾 상태 백업 완료: ${achievements.length}개 업적');
    } catch (e) {
      debugPrint('❌ 상태 백업 실패: $e');
    }
  }
  
  /// 백업된 상태로 복구
  static Future<bool> _restoreState() async {
    if (_lastKnownState == null) {
      debugPrint('❌ 복구할 백업 상태가 없음');
      return false;
    }
    
    try {
      final achievementMaps = _lastKnownState!['achievements'] as List<dynamic>;
      final db = await database;
      
      await db.transaction((txn) async {
        for (final mapDynamic in achievementMaps) {
          final map = mapDynamic as Map<String, dynamic>;
          await txn.update(
            tableName,
            map,
            where: 'id = ?',
            whereArgs: [map['id']],
          );
        }
      });
      
      _invalidateCache(); // 캐시 무효화
      debugPrint('✅ 상태 복구 완료: ${achievementMaps.length}개 업적');
      return true;
    } catch (e) {
      debugPrint('❌ 상태 복구 실패: $e');
      return false;
    }
  }
}
