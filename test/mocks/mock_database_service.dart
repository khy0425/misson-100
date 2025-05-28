import 'package:mission100/models/user_profile.dart';
import 'package:mission100/models/workout_session.dart';
import 'package:mission100/services/database_service.dart';

/// 테스트용 데이터베이스 서비스 모킹 클래스
class MockDatabaseService {
  // 인메모리 데이터 저장소
  UserProfile? _userProfile;
  final List<WorkoutSession> _workoutSessions = [];
  bool _isInitialized = false;

  // 테스트 데이터 설정을 위한 헬퍼 메서드들
  void setMockUserProfile(UserProfile profile) {
    _userProfile = profile;
  }

  void addMockWorkoutSession(WorkoutSession session) {
    _workoutSessions.add(session);
  }

  void clearMockData() {
    _userProfile = null;
    _workoutSessions.clear();
    _isInitialized = false;
  }

  // DatabaseService 메서드들 모킹
  Future<int> insertUserProfile(UserProfile profile) async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    _userProfile = profile;
    return 1; // 모킹된 ID 반환
  }

  Future<UserProfile?> getUserProfile() async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    return _userProfile;
  }

  Future<int> updateUserProfile(UserProfile profile) async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    _userProfile = profile;
    return 1; // 업데이트된 행 수
  }

  Future<int> deleteUserProfile(int id) async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    if (_userProfile?.id == id) {
      _userProfile = null;
      return 1; // 삭제된 행 수
    }
    return 0;
  }

  Future<int> insertWorkoutSession(WorkoutSession session) async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    _workoutSessions.add(session);
    return _workoutSessions.length; // 모킹된 ID 반환
  }

  Future<List<WorkoutSession>> getAllWorkoutSessions() async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    return _workoutSessions.toList();
  }

  Future<List<WorkoutSession>> getWorkoutSessionsByWeek(int week) async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    return _workoutSessions.where((session) => session.week == week).toList();
  }

  Future<List<WorkoutSession>> getWorkoutSessionsByUserId(int userId) async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    return _workoutSessions.toList(); // 모든 세션 반환 (단일 사용자 가정)
  }

  Future<WorkoutSession?> getWorkoutSession(int week, int day) async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    try {
      return _workoutSessions.firstWhere(
        (session) => session.week == week && session.day == day,
      );
    } catch (e) {
      return null;
    }
  }

  Future<WorkoutSession?> getTodayWorkoutSession() async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    final today = DateTime.now();
    try {
      return _workoutSessions.firstWhere(
        (session) => session.date.year == today.year &&
                     session.date.month == today.month &&
                     session.date.day == today.day,
      );
    } catch (e) {
      return null;
    }
  }

  Future<int> updateWorkoutSession(WorkoutSession session) async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    final index = _workoutSessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _workoutSessions[index] = session;
      return 1; // 업데이트된 행 수
    }
    return 0;
  }

  Future<int> deleteWorkoutSession(int id) async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    final initialLength = _workoutSessions.length;
    _workoutSessions.removeWhere((session) => session.id == id);
    return initialLength - _workoutSessions.length; // 삭제된 행 수
  }

  Future<int> getTotalPushups() async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    return _workoutSessions
        .where((session) => session.isCompleted)
        .fold<int>(0, (sum, session) => sum + session.totalReps);
  }

  Future<int> getCompletedWorkouts() async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    return _workoutSessions.where((session) => session.isCompleted).length;
  }

  Future<List<WorkoutSession>> getRecentWorkouts({int limit = 7}) async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    final sortedSessions = _workoutSessions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return sortedSessions.take(limit).toList();
  }

  Future<int> getConsecutiveDays() async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    
    final completedSessions = _workoutSessions
        .where((session) => session.isCompleted)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    if (completedSessions.isEmpty) return 0;
    
    int consecutiveDays = 0;
    DateTime? lastDate;
    
    for (final session in completedSessions) {
      final currentDate = session.date;
      
      if (lastDate == null) {
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

  Future<void> close() async {
    _isInitialized = false;
  }

  Future<void> deleteAllData() async {
    if (!_isInitialized) {
      throw Exception('Database not initialized');
    }
    await Future.delayed(const Duration(milliseconds: 5));
    clearMockData();
  }

  // 테스트용 헬퍼 메서드들
  bool get isInitialized => _isInitialized;
  int get workoutSessionCount => _workoutSessions.length;
  bool get hasUserProfile => _userProfile != null;
  
  void initialize() {
    _isInitialized = true;
  }
} 