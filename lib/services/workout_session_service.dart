import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 운동 세션 진행 상황을 관리하는 서비스
/// 앱이 갑자기 종료되어도 세트 진행 상황을 복원할 수 있습니다.
class WorkoutSessionService {
  static const String _sessionKey = 'current_workout_session';
  static const String _sessionDateKey = 'current_workout_session_date';

  /// 현재 운동 세션 저장
  static Future<void> saveWorkoutSession({
    required int currentSet,
    required int currentReps,
    required List<int> completedReps,
    required List<int> targetReps,
    required int restTimeSeconds,
    required bool isRestTime,
    required int restTimeRemaining,
    required String userLevel,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final sessionData = {
        'currentSet': currentSet,
        'currentReps': currentReps,
        'completedReps': completedReps,
        'targetReps': targetReps,
        'restTimeSeconds': restTimeSeconds,
        'isRestTime': isRestTime,
        'restTimeRemaining': restTimeRemaining,
        'userLevel': userLevel,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(_sessionKey, json.encode(sessionData));
      await prefs.setString(_sessionDateKey, DateTime.now().toIso8601String().split('T')[0]);
      
      print('💾 운동 세션 저장됨: Set ${currentSet + 1}, Reps $currentReps');
    } catch (e) {
      print('❌ 운동 세션 저장 실패: $e');
    }
  }

  /// 저장된 운동 세션 복원
  static Future<Map<String, dynamic>?> restoreWorkoutSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);
      final sessionDate = prefs.getString(_sessionDateKey);
      
      if (sessionJson == null || sessionDate == null) {
        return null;
      }
      
      // 오늘 날짜와 비교
      final today = DateTime.now().toIso8601String().split('T')[0];
      if (sessionDate != today) {
        // 다른 날짜의 세션이면 삭제
        await clearWorkoutSession();
        return null;
      }
      
      final sessionData = json.decode(sessionJson) as Map<String, dynamic>;
      
      // 타임스탬프 확인 (6시간 이상 지났으면 무효)
      final timestamp = sessionData['timestamp'] as int;
      final sessionTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      if (now.difference(sessionTime).inHours >= 6) {
        await clearWorkoutSession();
        return null;
      }
      
      print('🔄 운동 세션 복원됨: Set ${sessionData['currentSet'] + 1}');
      return sessionData;
    } catch (e) {
      print('❌ 운동 세션 복원 실패: $e');
      await clearWorkoutSession(); // 오류 시 세션 삭제
      return null;
    }
  }

  /// 운동 세션 삭제 (운동 완료 시 호출)
  static Future<void> clearWorkoutSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      await prefs.remove(_sessionDateKey);
      print('🗑️ 운동 세션 삭제됨');
    } catch (e) {
      print('❌ 운동 세션 삭제 실패: $e');
    }
  }

  /// 저장된 세션이 있는지 확인
  static Future<bool> hasActiveSession() async {
    final session = await restoreWorkoutSession();
    return session != null;
  }

  /// 세션 데이터 요약 정보 반환
  static Future<String?> getSessionSummary() async {
    final session = await restoreWorkoutSession();
    if (session == null) return null;
    
    final currentSet = session['currentSet'] as int;
    final totalSets = (session['targetReps'] as List).length;
    final completedSets = (session['completedReps'] as List).cast<int>();
    final completedCount = completedSets.where((reps) => reps > 0).length;
    
    return '세트 ${currentSet + 1}/$totalSets (완료: $completedCount세트)';
  }
} 