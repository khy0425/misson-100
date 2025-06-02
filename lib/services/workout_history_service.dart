import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/workout_history.dart';
import 'notification_service.dart';
import 'dart:io';

class WorkoutHistoryService {
  static Database? _database;
  static Database? _testDatabase; // 테스트용 데이터베이스
  static const String tableName = 'workout_history';
  static const String sessionTableName = 'workout_sessions'; // 진행 중 세션 테이블
  
  // 달력 업데이트 콜백들 (여러 화면에서 동시에 사용 가능)
  static final List<VoidCallback> _onWorkoutSavedCallbacks = [];

  // 테스트용 데이터베이스 설정
  static void setTestDatabase(Database testDb) {
    _testDatabase = testDb;
  }
  
  // 운동 저장 시 콜백 추가 (달력 업데이트용)
  static void addOnWorkoutSavedCallback(VoidCallback callback) {
    if (!_onWorkoutSavedCallbacks.contains(callback)) {
      _onWorkoutSavedCallbacks.add(callback);
    }
  }
  
  // 운동 저장 시 콜백 제거
  static void removeOnWorkoutSavedCallback(VoidCallback callback) {
    _onWorkoutSavedCallbacks.remove(callback);
  }
  
  // 모든 콜백 제거
  static void clearOnWorkoutSavedCallbacks() {
    _onWorkoutSavedCallbacks.clear();
  }
  
  // 기존 호환성을 위한 메서드 (deprecated)
  @Deprecated('Use addOnWorkoutSavedCallback instead')
  static void setOnWorkoutSaved(VoidCallback callback) {
    addOnWorkoutSavedCallback(callback);
  }

  static Future<Database> get database async {
    if (_testDatabase != null) return _testDatabase!;

    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'workout_history.db');
    return await openDatabase(path, version: 3, onCreate: _createDatabase, onUpgrade: _upgradeDatabase);
  }

  static Future<void> _createDatabase(Database db, int version) async {
    // workout_history 테이블 (duration, pushupType 컬럼 포함)
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        workoutTitle TEXT NOT NULL,
        targetReps TEXT NOT NULL,
        completedReps TEXT NOT NULL,
        totalReps INTEGER NOT NULL,
        completionRate REAL NOT NULL,
        level TEXT NOT NULL,
        duration INTEGER DEFAULT 10,
        pushupType TEXT DEFAULT 'Push-up'
      )
    ''');
    
    // 진행 중 세션 테이블 (중간 저장용)
    await db.execute('''
      CREATE TABLE $sessionTableName (
        id TEXT PRIMARY KEY,
        startTime TEXT NOT NULL,
        lastUpdateTime TEXT NOT NULL,
        workoutTitle TEXT NOT NULL,
        targetReps TEXT NOT NULL,
        completedReps TEXT NOT NULL,
        currentSet INTEGER NOT NULL,
        totalSets INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        level TEXT NOT NULL
      )
    ''');
    
    debugPrint('✅ 운동 기록 및 세션 테이블 생성 완료 (v$version)');
  }
  
  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    debugPrint('🔧 데이터베이스 업그레이드: v$oldVersion → v$newVersion');
    
    if (oldVersion < 2) {
      // 버전 2: 세션 테이블 추가
      await db.execute('''
        CREATE TABLE $sessionTableName (
          id TEXT PRIMARY KEY,
          startTime TEXT NOT NULL,
          lastUpdateTime TEXT NOT NULL,
          workoutTitle TEXT NOT NULL,
          targetReps TEXT NOT NULL,
          completedReps TEXT NOT NULL,
          currentSet INTEGER NOT NULL,
          totalSets INTEGER NOT NULL,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          level TEXT NOT NULL
        )
      ''');
      debugPrint('✅ 세션 테이블 추가 완료');
    }
    
    if (oldVersion < 3) {
      // 버전 3: workout_history 테이블에 duration, pushupType 컬럼 추가
      try {
        await db.execute('ALTER TABLE $tableName ADD COLUMN duration INTEGER DEFAULT 10');
        debugPrint('✅ duration 컬럼 추가 완료');
      } catch (e) {
        debugPrint('⚠️ duration 컬럼 추가 실패 (이미 존재할 수 있음): $e');
      }
      
      try {
        await db.execute('ALTER TABLE $tableName ADD COLUMN pushupType TEXT DEFAULT \'Push-up\'');
        debugPrint('✅ pushupType 컬럼 추가 완료');
      } catch (e) {
        debugPrint('⚠️ pushupType 컬럼 추가 실패 (이미 존재할 수 있음): $e');
      }
    }
  }

  // === 진행 중 세션 관리 기능 ===
  
  /// 새 운동 세션 시작
  static Future<String> startWorkoutSession({
    required String workoutTitle,
    required List<int> targetReps,
    required int totalSets,
    required String level,
  }) async {
    final db = await database;
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();
    
    final session = {
      'id': sessionId,
      'startTime': now,
      'lastUpdateTime': now,
      'workoutTitle': workoutTitle,
      'targetReps': targetReps.join(','),
      'completedReps': List.generate(totalSets, (index) => 0).join(','),
      'currentSet': 0,
      'totalSets': totalSets,
      'isCompleted': 0,
      'level': level,
    };
    
    await db.insert(sessionTableName, session, conflictAlgorithm: ConflictAlgorithm.replace);
    debugPrint('🎯 새 운동 세션 시작: $sessionId ($workoutTitle)');
    
    return sessionId;
  }
  
  /// 세트 완료 시 즉시 저장
  static Future<void> saveSetProgress({
    required String sessionId,
    required int setIndex,
    required int completedReps,
    required int currentSet,
  }) async {
    final db = await database;
    
    try {
      // 현재 세션 정보 가져오기
      final sessionQuery = await db.query(
        sessionTableName,
        where: 'id = ?',
        whereArgs: [sessionId],
        limit: 1,
      );
      
      if (sessionQuery.isEmpty) {
        debugPrint('❌ 세션을 찾을 수 없음: $sessionId');
        return;
      }
      
      final session = sessionQuery.first;
      final completedRepsList = (session['completedReps'] as String).split(',').map(int.parse).toList();
      
      // 세트 결과 업데이트
      if (setIndex < completedRepsList.length) {
        completedRepsList[setIndex] = completedReps;
      }
      
      // 세션 업데이트
      await db.update(
        sessionTableName,
        {
          'completedReps': completedRepsList.join(','),
          'currentSet': currentSet,
          'lastUpdateTime': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [sessionId],
      );
      
      debugPrint('💾 세트 $setIndex 즉시 저장 완료: $completedReps회 (세션: $sessionId)');
      
      // 백업 파일에도 저장 (추가 안전장치)
      await _saveSessionBackup(sessionId, completedRepsList, currentSet);
      
    } catch (e, stackTrace) {
      debugPrint('❌ 세트 저장 오류: $e');
      debugPrint('스택 트레이스: $stackTrace');
      rethrow;
    }
  }
  
  /// 운동 세션 완료 처리
  static Future<void> completeWorkoutSession(String sessionId) async {
    final db = await database;
    
    try {
      await db.update(
        sessionTableName,
        {
          'isCompleted': 1,
          'lastUpdateTime': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [sessionId],
      );
      
      debugPrint('✅ 운동 세션 완료 처리: $sessionId');
      
      // 완료된 세션을 정식 운동 기록으로 이전
      await _migrateCompletedSession(sessionId);
      
    } catch (e) {
      debugPrint('❌ 세션 완료 처리 오류: $e');
      rethrow;
    }
  }
  
  /// 미완료 세션 복구
  static Future<Map<String, dynamic>?> recoverIncompleteSession() async {
    final db = await database;
    
    try {
      final sessions = await db.query(
        sessionTableName,
        where: 'isCompleted = ?',
        whereArgs: [0],
        orderBy: 'lastUpdateTime DESC',
        limit: 1,
      );
      
      if (sessions.isNotEmpty) {
        final session = sessions.first;
        debugPrint('🔄 미완료 세션 발견: ${session['id']} (${session['workoutTitle']})');
        
        // 백업 파일에서도 확인
        final backupData = await _loadSessionBackup(session['id'] as String);
        if (backupData != null) {
          debugPrint('📁 백업에서 추가 데이터 복구');
          return {
            ...session,
            'backupData': backupData,
          };
        }
        
        return session;
      }
      
      debugPrint('✅ 복구할 미완료 세션 없음');
      return null;
      
    } catch (e) {
      debugPrint('❌ 세션 복구 오류: $e');
      return null;
    }
  }
  
  /// 세션 정리 (완료된 세션들 제거)
  static Future<void> cleanupCompletedSessions() async {
    final db = await database;
    
    try {
      final deletedCount = await db.delete(
        sessionTableName,
        where: 'isCompleted = ?',
        whereArgs: [1],
      );
      
      debugPrint('🧹 완료된 세션 정리: $deletedCount개 삭제');
      
    } catch (e) {
      debugPrint('❌ 세션 정리 오류: $e');
    }
  }
  
  // === 백업 시스템 (파일 기반) ===
  
  /// 세션 백업 저장
  static Future<void> _saveSessionBackup(String sessionId, List<int> completedReps, int currentSet) async {
    try {
      // SharedPreferences나 파일로 백업 저장 (구현 예정)
      debugPrint('💾 세션 백업 저장: $sessionId');
    } catch (e) {
      debugPrint('❌ 세션 백업 저장 오류: $e');
    }
  }
  
  /// 세션 백업 로드
  static Future<Map<String, dynamic>?> _loadSessionBackup(String sessionId) async {
    try {
      // SharedPreferences나 파일에서 백업 로드 (구현 예정)
      debugPrint('📁 세션 백업 로드: $sessionId');
      return null;
    } catch (e) {
      debugPrint('❌ 세션 백업 로드 오류: $e');
      return null;
    }
  }
  
  /// 완료된 세션을 정식 운동 기록으로 이전
  static Future<void> _migrateCompletedSession(String sessionId) async {
    final db = await database;
    
    try {
      final sessions = await db.query(
        sessionTableName,
        where: 'id = ?',
        whereArgs: [sessionId],
        limit: 1,
      );
      
      if (sessions.isEmpty) return;
      
      final session = sessions.first;
      final completedRepsList = (session['completedReps'] as String).split(',').map(int.parse).toList();
      final targetRepsList = (session['targetReps'] as String).split(',').map(int.parse).toList();
      
      final totalReps = completedRepsList.fold(0, (sum, reps) => sum + reps);
      final targetTotal = targetRepsList.fold(0, (sum, reps) => sum + reps);
      final completionRate = targetTotal > 0 ? totalReps / targetTotal : 0.0;
      
      // WorkoutHistory 객체 생성
      final workoutHistory = WorkoutHistory(
        id: sessionId,
        date: DateTime.parse(session['startTime'] as String),
        workoutTitle: session['workoutTitle'] as String,
        targetReps: targetRepsList,
        completedReps: completedRepsList,
        totalReps: totalReps,
        completionRate: completionRate,
        level: session['level'] as String,
      );
      
      // 정식 운동 기록으로 저장
      await saveWorkoutHistory(workoutHistory);
      
      debugPrint('📋 세션을 정식 운동 기록으로 이전 완료: $sessionId');
      
    } catch (e) {
      debugPrint('❌ 세션 이전 오류: $e');
      rethrow;
    }
  }

  // 운동 기록 저장
  static Future<void> saveWorkoutHistory(WorkoutHistory history) async {
    debugPrint('💾 운동 기록 저장 시작: ${history.id}');
    debugPrint('📅 운동 날짜: ${history.date}');
    debugPrint('📊 운동 데이터: ${history.totalReps}회, 완료율 ${(history.completionRate * 100).toStringAsFixed(1)}%');
    
    try {
      final db = await database;
      
      // 저장 전 데이터베이스 상태 확인
      final beforeCount = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      final countBefore = beforeCount.first['count'] as int;
      debugPrint('🗄️ 저장 전 운동 기록 개수: $countBefore개');
      
      await db.insert(
        tableName,
        history.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // 저장 후 데이터베이스 상태 확인
      final afterCount = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      final countAfter = afterCount.first['count'] as int;
      debugPrint('🗄️ 저장 후 운동 기록 개수: $countAfter개 (${countAfter - countBefore > 0 ? '증가' : '동일'})');
      
      // 방금 저장된 데이터 확인
      final savedWorkout = await getWorkoutByDate(history.date);
      if (savedWorkout != null) {
        debugPrint('✅ 운동 기록 저장 성공 확인: ${savedWorkout.id} - ${savedWorkout.totalReps}회');
      } else {
        debugPrint('❌ 운동 기록 저장 확인 실패: 데이터를 찾을 수 없음');
      }
      
      // 운동 저장 후 달력 업데이트 콜백 호출
      debugPrint('📞 달력 업데이트 콜백 호출 시작 (등록된 콜백 수: ${_onWorkoutSavedCallbacks.length}개)');
      
      if (_onWorkoutSavedCallbacks.isEmpty) {
        debugPrint('⚠️ 등록된 콜백이 없습니다. 달력/홈 화면이 아직 초기화되지 않았을 수 있습니다.');
      }
      
      for (int i = 0; i < _onWorkoutSavedCallbacks.length; i++) {
        try {
          debugPrint('📞 콜백 $i 호출 중...');
          _onWorkoutSavedCallbacks[i]();
          debugPrint('✅ 콜백 $i 호출 완료');
        } catch (e) {
          debugPrint('❌ 콜백 $i 호출 실패: $e');
        }
      }
      debugPrint('📞 모든 콜백 호출 완료');
      
      // 오늘 운동을 완료했으므로 오늘의 리마인더 취소
      await NotificationService.cancelTodayWorkoutReminder();
      debugPrint('🔕 오늘의 리마인더 취소 완료');
      
      // 운동 완료 축하 알림
      await NotificationService.showWorkoutCompletionCelebration(
        totalReps: history.totalReps,
        completionRate: history.completionRate,
      );
      debugPrint('🎉 운동 완료 축하 알림 전송');
      
      // 연속 운동 스트릭 확인 및 격려 알림
      final streak = await getCurrentStreak();
      debugPrint('🔥 현재 연속 운동 스트릭: $streak일');
      
      if (streak >= 3 && streak % 3 == 0) {
        await NotificationService.showStreakEncouragement(streak);
        debugPrint('🏆 스트릭 격려 알림 전송: $streak일 연속');
      }
      
      debugPrint('✅ 운동 기록 저장 완료: ${history.date} - 달력 업데이트 신호 전송 및 오늘 리마인더 취소');
    } catch (e, stackTrace) {
      debugPrint('❌ 운동 기록 저장 오류: $e');
      debugPrint('스택 트레이스: $stackTrace');
      rethrow;
    }
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

  // 모든 운동 기록 삭제 (데이터 초기화용)
  static Future<void> clearAllRecords() async {
    final db = await database;
    await db.delete(tableName);
    debugPrint('🗑️ 모든 운동 기록 삭제 완료');
  }
  
  // 데이터베이스 완전 재생성 (스키마 문제 해결용)
  static Future<void> resetDatabase() async {
    try {
      // 기존 데이터베이스 파일 삭제
      final String path = join(await getDatabasesPath(), 'workout_history.db');
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ 기존 데이터베이스 파일 삭제 완료');
      }
      
      // 데이터베이스 참조 초기화
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      
      debugPrint('✅ 데이터베이스 완전 재설정 완료');
    } catch (e) {
      debugPrint('❌ 데이터베이스 재설정 오류: $e');
      rethrow;
    }
  }

  // 스키마 자동 수정 (누락된 컬럼 추가)
  static Future<void> fixSchemaIfNeeded() async {
    try {
      final db = await database;
      
      // 테이블 구조 확인
      final tableInfo = await db.rawQuery("PRAGMA table_info($tableName)");
      final columnNames = tableInfo.map((row) => row['name'] as String).toSet();
      
      debugPrint('🔍 현재 테이블 컬럼: $columnNames');
      
      bool needsFix = false;
      
      // duration 컬럼 확인 및 추가
      if (!columnNames.contains('duration')) {
        debugPrint('🔧 duration 컬럼이 없음, 추가 중...');
        await db.execute('ALTER TABLE $tableName ADD COLUMN duration INTEGER DEFAULT 10');
        debugPrint('✅ duration 컬럼 추가 완료');
        needsFix = true;
      }
      
      // pushupType 컬럼 확인 및 추가
      if (!columnNames.contains('pushupType')) {
        debugPrint('🔧 pushupType 컬럼이 없음, 추가 중...');
        await db.execute('ALTER TABLE $tableName ADD COLUMN pushupType TEXT DEFAULT \'Push-up\'');
        debugPrint('✅ pushupType 컬럼 추가 완료');
        needsFix = true;
      }
      
      if (needsFix) {
        debugPrint('🔄 스키마 수정 완료 - 앱을 재시작하면 정상 작동합니다');
      } else {
        debugPrint('✅ 스키마가 이미 최신 상태입니다');
      }
      
    } catch (e) {
      debugPrint('❌ 스키마 수정 실패: $e');
      rethrow;
    }
  }
}
