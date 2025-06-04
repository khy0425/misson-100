import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mission100_chad.db');

    return await openDatabase(
      path, 
      version: 2, // 버전을 2로 업그레이드
      onCreate: _onCreate, 
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // UserProfile 테이블 생성
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        level TEXT NOT NULL,
        initial_max_reps INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        chad_level INTEGER DEFAULT 0,
        reminder_enabled INTEGER DEFAULT 0,
        reminder_time TEXT,
        workout_days TEXT
      )
    ''');

    // WorkoutSession 테이블 생성
    await db.execute('''
      CREATE TABLE workout_session (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        week INTEGER NOT NULL,
        day INTEGER NOT NULL,
        target_reps TEXT NOT NULL,
        completed_reps TEXT,
        is_completed INTEGER DEFAULT 0,
        total_reps INTEGER DEFAULT 0,
        total_time INTEGER DEFAULT 0,
        UNIQUE(date, week, day)
      )
    ''');

    // 인덱스 생성
    await db.execute('CREATE INDEX idx_workout_date ON workout_session(date)');
    await db.execute(
      'CREATE INDEX idx_workout_week_day ON workout_session(week, day)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // workout_days 컬럼 추가
      await db.execute('ALTER TABLE user_profile ADD COLUMN workout_days TEXT');
      debugPrint('✅ 데이터베이스 업그레이드: workout_days 컬럼 추가 완료');
    }
  }

  // UserProfile CRUD 작업
  Future<int> insertUserProfile(UserProfile profile) async {
    final db = await database;
    return await db.insert('user_profile', profile.toMap());
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final maps = await db.query('user_profile');

    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUserProfile(UserProfile profile) async {
    final db = await database;
    return await db.update(
      'user_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteUserProfile(int id) async {
    final db = await database;
    return await db.delete('user_profile', where: 'id = ?', whereArgs: [id]);
  }

  // WorkoutSession CRUD 작업
  Future<int> insertWorkoutSession(WorkoutSession session) async {
    final db = await database;
    return await db.insert(
      'workout_session',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WorkoutSession>> getAllWorkoutSessions() async {
    final db = await database;
    final maps = await db.query('workout_session');

    return List.generate(maps.length, (i) {
      return WorkoutSession.fromMap(maps[i]);
    });
  }

  Future<List<WorkoutSession>> getWorkoutSessionsByWeek(int week) async {
    final db = await database;
    final maps = await db.query(
      'workout_session',
      where: 'week = ?',
      whereArgs: [week],
    );

    return List.generate(maps.length, (i) {
      return WorkoutSession.fromMap(maps[i]);
    });
  }

  Future<List<WorkoutSession>> getWorkoutSessionsByUserId(int userId) async {
    final db = await database;
    final maps = await db.query('workout_session');

    return List.generate(maps.length, (i) {
      return WorkoutSession.fromMap(maps[i]);
    });
  }

  Future<WorkoutSession?> getWorkoutSession(int week, int day) async {
    final db = await database;
    final maps = await db.query(
      'workout_session',
      where: 'week = ? AND day = ?',
      whereArgs: [week, day],
    );

    if (maps.isNotEmpty) {
      return WorkoutSession.fromMap(maps.first);
    }
    return null;
  }

  Future<WorkoutSession?> getTodayWorkoutSession() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final maps = await db.query(
      'workout_session',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (maps.isNotEmpty) {
      return WorkoutSession.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateWorkoutSession(WorkoutSession session) async {
    final db = await database;
    return await db.update(
      'workout_session',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteWorkoutSession(int id) async {
    final db = await database;
    return await db.delete('workout_session', where: 'id = ?', whereArgs: [id]);
  }

  // 통계 메서드
  Future<int> getTotalPushups() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(total_reps) as total FROM workout_session WHERE is_completed = 1',
    );
    return result.first['total'] as int? ?? 0;
  }

  Future<int> getCompletedWorkouts() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM workout_session WHERE is_completed = 1',
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<List<WorkoutSession>> getRecentWorkouts({int limit = 7}) async {
    final db = await database;
    final maps = await db.query(
      'workout_session',
      orderBy: 'date DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return WorkoutSession.fromMap(maps[i]);
    });
  }

  // 연속 운동일 계산
  Future<int> getConsecutiveDays() async {
    final db = await database;
    final maps = await db.query(
      'workout_session',
      where: 'is_completed = 1',
      orderBy: 'date DESC',
    );

    if (maps.isEmpty) return 0;

    int consecutiveDays = 0;
    DateTime? lastDate;

    for (final map in maps) {
      final currentDate = DateTime.parse(map['date'] as String);

      if (lastDate == null) {
        // 첫 번째 운동 날짜
        lastDate = currentDate;
        consecutiveDays = 1;
      } else {
        final difference = lastDate.difference(currentDate).inDays;
        if (difference == 1) {
          consecutiveDays++;
          lastDate = currentDate;
        } else {
          break;
        }
      }
    }

    return consecutiveDays;
  }

  // 데이터베이스 닫기
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // 모든 데이터 삭제
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('workout_session');
    await db.delete('user_profile');
  }

  // 데이터베이스 완전 초기화 (테스트용)
  Future<void> resetDatabase() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'mission100_chad.db');
      
      // 데이터베이스 파일 삭제
      await deleteDatabase(path);
      debugPrint('데이터베이스 초기화 완료');
    } catch (e) {
      debugPrint('데이터베이스 초기화 오류: $e');
    }
  }

  // 테이블별 데이터 삭제
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('user_profile');
      await db.delete('workout_session');
      debugPrint('모든 데이터 삭제 완료');
    } catch (e) {
      debugPrint('데이터 삭제 오류: $e');
    }
  }

  // 데이터베이스 상태 확인
  Future<Map<String, dynamic>> getDatabaseStatus() async {
    try {
      final db = await database;
      
      final userCount = await db.rawQuery('SELECT COUNT(*) as count FROM user_profile');
      final sessionCount = await db.rawQuery('SELECT COUNT(*) as count FROM workout_session');
      
      return {
        'userProfiles': userCount.first['count'],
        'workoutSessions': sessionCount.first['count'],
        'databaseExists': true,
      };
    } catch (e) {
      debugPrint('데이터베이스 상태 확인 오류: $e');
      return {
        'userProfiles': 0,
        'workoutSessions': 0,
        'databaseExists': false,
        'error': e.toString(),
      };
    }
  }
}
