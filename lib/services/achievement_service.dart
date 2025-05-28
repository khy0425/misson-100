import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/achievement.dart';
import '../models/workout_history.dart';
import 'workout_history_service.dart';
import 'notification_service.dart';

class AchievementService {
  static const String tableName = 'achievements';
  static Database? _database;
  static Database? _testDatabase; // 테스트용 데이터베이스
  
  // 실시간 업데이트를 위한 콜백들
  static VoidCallback? _onAchievementUnlocked;
  static VoidCallback? _onStatsUpdated;
  static BuildContext? _globalContext;

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
    
    debugPrint('✅ 성공적으로 파싱된 업적 개수: ${achievements.length}');
    return achievements;
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

  // 업적 진행도 업데이트
  static Future<void> updateAchievementProgress(
    String achievementId,
    int newValue,
  ) async {
    final db = await database;
    await db.update(
      tableName,
      {'currentValue': newValue},
      where: 'id = ?',
      whereArgs: [achievementId],
    );
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

  // 운동 기록 기반으로 업적 진행도 체크 및 업데이트
  static Future<List<Achievement>> checkAndUpdateAchievements() async {
    final List<Achievement> newlyUnlocked = [];
    final workouts = await WorkoutHistoryService.getAllWorkouts();
    final statistics = await WorkoutHistoryService.getStatistics();
    final currentStreak = await WorkoutHistoryService.getCurrentStreak();

    // 각 업적 타입별로 체크
    for (final achievement in PredefinedAchievements.all) {
      if (await _isAchievementUnlocked(achievement.id)) continue;

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
      }

      // 진행도 업데이트
      await updateAchievementProgress(achievement.id, currentValue);

      // 달성 조건 체크
      if (currentValue >= achievement.targetValue) {
        final unlockedAchievement = await unlockAchievement(achievement.id);
        if (unlockedAchievement != null) {
          newlyUnlocked.add(unlockedAchievement);
        }
      }
    }

    return newlyUnlocked;
  }

  // 첫 번째 달성 업적 체크
  static Future<int> _checkFirstAchievements(
    Achievement achievement,
    List<WorkoutHistory> workouts,
  ) async {
    switch (achievement.id) {
      case 'first_workout':
        return workouts.isNotEmpty ? 1 : 0;
      case 'first_perfect_set':
        // 완벽한 세트가 하나라도 있는지 확인
        for (final workout in workouts) {
          for (int i = 0; i < workout.targetReps.length; i++) {
            if (workout.completedReps[i] >= workout.targetReps[i]) {
              return 1; // 첫 번째 완벽한 세트 달성
            }
          }
        }
        return 0;
      case 'first_level_up':
        // TODO: 레벨 시스템 구현 후 체크
        return 0;
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
      case 'endurance_king':
      case 'comeback_kid':
      case 'overachiever':
      case 'double_trouble':
      case 'consistency_master':
        // 이러한 업적들은 별도 로직이 필요하므로 현재는 0 반환
        // 추후 구체적인 조건 구현 예정
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
    final db = await database;
    await db.delete(tableName);
    debugPrint('🗑️ 모든 업적 데이터 삭제 완료');
    
    // SharedPreferences에서 업적 관련 데이터도 삭제
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tutorial_view_count');
    await prefs.remove('pending_achievement_events');
    
    // 다시 초기화 (중복 방지를 위해 강제 초기화)
    await _forceInitialize();
    debugPrint('🔄 업적 데이터베이스 재초기화 완료');
  }

  // 강제 초기화 (중복 방지)
  static Future<void> _forceInitialize() async {
    final db = await database;

    // 미리 정의된 업적들 추가 (중복 방지)
    debugPrint('🚀 업적 강제 초기화 시작 - 총 ${PredefinedAchievements.all.length}개 업적');
    for (final achievement in PredefinedAchievements.all) {
      try {
        await db.insert(
          tableName, 
          achievement.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore, // 중복 시 무시
        );
        debugPrint('✅ 업적 추가: ${achievement.id}');
      } catch (e) {
        debugPrint('❌ 업적 추가 실패: ${achievement.id} - $e');
      }
    }
    debugPrint('🎉 업적 강제 초기화 완료');
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
}
