import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout_history.dart';

class WorkoutHistoryService {
  static Database? _database;
  static Database? _testDatabase; // 테스트용 데이터베이스
  static const String tableName = 'workout_history';

  // 테스트용 데이터베이스 설정
  static void setTestDatabase(Database testDb) {
    _testDatabase = testDb;
  }

  static Future<Database> get database async {
    if (_testDatabase != null) return _testDatabase!;

    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'workout_history.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  static Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        workoutTitle TEXT NOT NULL,
        targetReps TEXT NOT NULL,
        completedReps TEXT NOT NULL,
        totalReps INTEGER NOT NULL,
        completionRate REAL NOT NULL,
        level TEXT NOT NULL
      )
    ''');
  }

  // 운동 기록 저장
  static Future<void> saveWorkoutHistory(WorkoutHistory history) async {
    final db = await database;
    await db.insert(
      tableName,
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 특정 날짜의 운동 기록 조회
  static Future<WorkoutHistory?> getWorkoutByDate(DateTime date) async {
    final db = await database;
    final dateStr = _dateToString(date);

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'date LIKE ?',
      whereArgs: ['$dateStr%'],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return WorkoutHistory.fromMap(maps.first);
    }
    return null;
  }

  // 모든 운동 기록 조회
  static Future<List<WorkoutHistory>> getAllWorkouts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return WorkoutHistory.fromMap(maps[i]);
    });
  }

  // 특정 월의 운동 기록 조회
  static Future<List<WorkoutHistory>> getWorkoutsByMonth(DateTime month) async {
    final db = await database;
    final monthStr = _monthToString(month);

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'date LIKE ?',
      whereArgs: ['$monthStr%'],
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) {
      return WorkoutHistory.fromMap(maps[i]);
    });
  }

  // 운동 기록 삭제
  static Future<void> deleteWorkout(String id) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // 통계 정보 조회
  static Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalWorkouts,
        AVG(completionRate) as averageCompletion,
        SUM(totalReps) as totalReps,
        MAX(completionRate) as bestCompletion
      FROM $tableName
    ''');

    if (result.isNotEmpty) {
      return result.first;
    }
    return {
      'totalWorkouts': 0,
      'averageCompletion': 0.0,
      'totalReps': 0,
      'bestCompletion': 0.0,
    };
  }

  // 연속 운동 일수 계산 (개선된 버전)
  static Future<int> getCurrentStreak() async {
    final workouts = await getAllWorkouts();
    if (workouts.isEmpty) return 0;

    // 날짜별로 그룹화 (시간 정보 제거)
    final workoutDates = workouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet()
        .toList();

    workoutDates.sort((a, b) => b.compareTo(a)); // 최신 날짜부터

    int streak = 0;
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    // 어제부터 시작해서 연속성 확인 (오늘은 아직 운동할 수 있으므로 제외)
    DateTime checkDate = todayNormalized.subtract(const Duration(days: 1));

    // 오늘 운동했다면 오늘부터 시작
    if (workoutDates.contains(todayNormalized)) {
      checkDate = todayNormalized;
    }

    for (int i = 0; i < 100; i++) {
      // 최대 100일까지 확인
      final currentCheckDate = checkDate.subtract(Duration(days: i));

      if (workoutDates.contains(currentCheckDate)) {
        streak++;
      } else {
        break; // 연속성이 끊어지면 중단
      }
    }

    return streak;
  }

  // 특정 기간 내 운동 일수 계산
  static Future<int> getWorkoutDaysInPeriod(int days) async {
    final workouts = await getAllWorkouts();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return workouts
        .where((w) => w.date.isAfter(cutoffDate))
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet()
        .length;
  }

  // 날짜를 문자열로 변환 (YYYY-MM-DD)
  static String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 월을 문자열로 변환 (YYYY-MM)
  static String _monthToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }
}
