import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workout_history_service.dart';

/// 운동 재개 기능을 관리하는 서비스
class WorkoutResumptionService {
  static const String _workoutBackupKey = 'workout_backup';
  static const String _lastSessionKey = 'last_session_id';
  
  /// 저장된 운동 상태가 있는지 확인
  static Future<bool> hasResumableWorkout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. SharedPreferences 백업 확인
      final backupString = prefs.getString(_workoutBackupKey);
      if (backupString != null) {
        final backupData = jsonDecode(backupString) as Map<String, dynamic>;
        final backupTime = DateTime.parse(backupData['timestamp'] as String);
        
        // 24시간 이내의 백업만 유효
        if (DateTime.now().difference(backupTime).inHours < 24) {
          debugPrint('📁 유효한 SharedPreferences 백업 발견');
          return true;
        }
      }
      
      // 2. 데이터베이스 미완료 세션 확인
      final incompleteSession = await WorkoutHistoryService.recoverIncompleteSession();
      if (incompleteSession != null) {
        debugPrint('🔄 미완료 세션 발견: ${incompleteSession['id']}');
        return true;
      }
      
      return false;
      
    } catch (e) {
      debugPrint('❌ 재개 가능한 운동 확인 오류: $e');
      return false;
    }
  }
  
  /// 운동 상태 복원을 위한 데이터 조회
  static Future<WorkoutResumptionData?> getResumptionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. SharedPreferences 백업에서 데이터 로드
      final backupString = prefs.getString(_workoutBackupKey);
      Map<String, dynamic>? sharedPrefsData;
      
      if (backupString != null) {
        final backupData = jsonDecode(backupString) as Map<String, dynamic>;
        final backupTime = DateTime.parse(backupData['timestamp'] as String);
        
        if (DateTime.now().difference(backupTime).inHours < 24) {
          sharedPrefsData = backupData;
        }
      }
      
      // 2. 데이터베이스 세션 데이터 로드
      final sessionData = await WorkoutHistoryService.recoverIncompleteSession();
      
      if (sharedPrefsData != null || sessionData != null) {
        return WorkoutResumptionData(
          sharedPrefsData: sharedPrefsData,
          sessionData: sessionData,
        );
      }
      
      return null;
      
    } catch (e) {
      debugPrint('❌ 복원 데이터 로드 오류: $e');
      return null;
    }
  }
  
  /// 운동 재개 후 백업 데이터 정리
  static Future<void> clearBackupData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // SharedPreferences 백업 데이터 제거
      await prefs.remove(_workoutBackupKey);
      await prefs.remove(_lastSessionKey);
      
      // 완료된 세션 정리는 WorkoutHistoryService에서 처리
      await WorkoutHistoryService.cleanupCompletedSessions();
      
      debugPrint('🧹 백업 데이터 정리 완료');
      
    } catch (e) {
      debugPrint('❌ 백업 데이터 정리 오류: $e');
    }
  }
  
  /// 마지막 세션 ID 저장
  static Future<void> saveLastSessionId(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSessionKey, sessionId);
    } catch (e) {
      debugPrint('❌ 마지막 세션 ID 저장 오류: $e');
    }
  }
  
  /// 마지막 세션 ID 조회
  static Future<String?> getLastSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastSessionKey);
    } catch (e) {
      debugPrint('❌ 마지막 세션 ID 조회 오류: $e');
      return null;
    }
  }
  
  /// 운동 상태 유효성 검증
  static bool validateWorkoutState(Map<String, dynamic> data) {
    try {
      // 필수 필드 검증
      final requiredFields = [
        'sessionId', 'currentSet', 'currentReps', 
        'completedReps', 'targetReps', 'workoutTitle'
      ];
      
      for (final field in requiredFields) {
        if (!data.containsKey(field)) {
          debugPrint('❌ 필수 필드 누락: $field');
          return false;
        }
      }
      
      // 데이터 타입 검증
      if (data['currentSet'] is! int || data['currentReps'] is! int) {
        debugPrint('❌ 잘못된 데이터 타입');
        return false;
      }
      
      // 배열 데이터 검증
      if (data['completedReps'] is! String || data['targetReps'] is! String) {
        debugPrint('❌ 잘못된 배열 데이터 형식');
        return false;
      }
      
      return true;
      
    } catch (e) {
      debugPrint('❌ 상태 검증 오류: $e');
      return false;
    }
  }
  
  /// 운동 재개 통계 기록
  static Future<void> recordResumptionStats({
    required String resumptionSource,
    required int recoveredSets,
    required int recoveredReps,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 재개 통계 업데이트
      final totalResumptions = prefs.getInt('total_resumptions') ?? 0;
      final totalRecoveredSets = prefs.getInt('total_recovered_sets') ?? 0;
      final totalRecoveredReps = prefs.getInt('total_recovered_reps') ?? 0;
      
      await prefs.setInt('total_resumptions', totalResumptions + 1);
      await prefs.setInt('total_recovered_sets', totalRecoveredSets + recoveredSets);
      await prefs.setInt('total_recovered_reps', totalRecoveredReps + recoveredReps);
      await prefs.setString('last_resumption_source', resumptionSource);
      await prefs.setString('last_resumption_time', DateTime.now().toIso8601String());
      
      debugPrint('📊 재개 통계 기록: $resumptionSource - $recoveredSets세트, $recoveredReps회');
      
    } catch (e) {
      debugPrint('❌ 재개 통계 기록 오류: $e');
    }
  }
}

/// 운동 재개 데이터를 담는 클래스
class WorkoutResumptionData {
  final Map<String, dynamic>? sharedPrefsData;
  final Map<String, dynamic>? sessionData;
  
  WorkoutResumptionData({
    this.sharedPrefsData,
    this.sessionData,
  });
  
  /// 더 신뢰할 수 있는 데이터 소스 선택
  Map<String, dynamic>? get primaryData {
    // SharedPreferences 데이터가 더 최신이고 완전한 경우 우선
    if (sharedPrefsData != null && 
        WorkoutResumptionService.validateWorkoutState(sharedPrefsData!)) {
      return sharedPrefsData;
    }
    
    // 그렇지 않으면 세션 데이터 사용
    return sessionData;
  }
  
  /// 데이터 소스 이름
  String get dataSource {
    if (primaryData == sharedPrefsData) {
      return 'SharedPreferences';
    } else if (primaryData == sessionData) {
      return 'Database Session';
    }
    return 'Unknown';
  }
  
  /// 복원 가능한 데이터가 있는지 확인
  bool get hasResumableData => primaryData != null;
} 