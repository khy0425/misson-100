import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import '../models/achievement.dart';
import '../models/workout_history.dart';
import 'workout_history_service.dart';
// import '../services/notification_service.dart';

class AchievementService {
  static const String tableName = 'achievements';
  static Database? _database;
  static Database? _testDatabase; // 테스트용 데이터베이스

  // 테스트용 데이터베이스 설정
  static void setTestDatabase(Database testDb) {
    _testDatabase = testDb;
  }

  // 데이터베이스 getter (테스트용 데이터베이스가 있으면 우선 사용)
  static Future<Database> get database async {
    if (_testDatabase != null) return _testDatabase!;

    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'achievements.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  static Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        iconCode TEXT NOT NULL,
        type TEXT NOT NULL,
        rarity TEXT NOT NULL,
        targetValue INTEGER NOT NULL,
        currentValue INTEGER DEFAULT 0,
        isUnlocked INTEGER DEFAULT 0,
        unlockedAt TEXT,
        xpReward INTEGER DEFAULT 0,
        motivationalMessage TEXT NOT NULL
      )
    ''');
  }

  // 초기화 - 미리 정의된 업적들 로드
  static Future<void> initialize() async {
    final db = await database;

    // 이미 초기화되었는지 확인
    final existingAchievements = await db.query(tableName, limit: 1);
    if (existingAchievements.isNotEmpty) return;

    // 미리 정의된 업적들 추가
    for (final achievement in PredefinedAchievements.all) {
      await db.insert(tableName, achievement.toMap());
    }
  }

  // 모든 업적 조회
  static Future<List<Achievement>> getAllAchievements() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'rarity DESC, isUnlocked DESC, id ASC',
    );

    return List.generate(maps.length, (i) {
      return Achievement.fromMap(maps[i]);
    });
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
        // await NotificationService.sendAchievementNotification(
        //   title: achievement.title,
        //   description: achievement.description,
        //   xpReward: achievement.xpReward,
        // );
        debugPrint('🏆 업적 달성 알림 전송: ${achievement.title}');
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
          currentValue = statistics['totalReps'] ?? 0;
          break;
        case AchievementType.perfect:
          currentValue = await _checkPerfectAchievements(workouts);
          break;
        case AchievementType.special:
          currentValue = await _checkSpecialAchievements(achievement, workouts);
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
}
